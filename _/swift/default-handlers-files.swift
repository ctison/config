#!/usr/bin/env swift
import CoreServices
import Foundation

// Normalized representation of one LaunchServices file/content handler.
struct DefaultFileHandler {
  let contentType: String?
  let contentTag: String?
  let contentTagClass: String?
  let appId: String?
  let roles: [String: String]
  let preferredVersions: [String: Any]
  let modificationDate: Any?
  let rank: String?
  let source: String
  let raw: [String: Any]
}

// User-facing command errors.
enum CLIError: Error, CustomStringConvertible {
  case invalidArguments(String)
  case missingLaunchServicesPlist(String)
  case setDefaultHandlerFailed(contentType: String, appId: String, role: String, status: OSStatus)
  case unknownSubcommand(String)
  case unreadableLaunchServicesPlist(String)
  case unwritableLaunchServicesPlist(String)

  var description: String {
    switch self {
    case .invalidArguments(let message):
      return message
    case .missingLaunchServicesPlist(let path):
      return "LaunchServices plist does not exist: \(path)"
    case .setDefaultHandlerFailed(let contentType, let appId, let role, let status):
      return
        "Failed to set default file handler for \(contentType) to \(appId) with role \(role) (OSStatus \(status))"
    case .unknownSubcommand(let subcommand):
      return "Unknown subcommand: \(subcommand)"
    case .unreadableLaunchServicesPlist(let path):
      return "Could not read LaunchServices plist: \(path)"
    case .unwritableLaunchServicesPlist(let path):
      return "Could not write LaunchServices plist: \(path)"
    }
  }
}

let launchServicesPlistPaths = [
  ("~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
    as NSString).expandingTildeInPath
]

// Print command usage and available subcommands.
func usage() {
  let executable =
    (CommandLine.arguments.first as NSString?)?.lastPathComponent
    ?? "default-handlers-files"
  print(
    """
    Usage:
      \(executable) ls
      \(executable) list-content-types
      \(executable) set <content-type> <bundle-id>
      \(executable) set --role <all|viewer|editor|shell> <content-type> <bundle-id>
      \(executable) rm <target>
      \(executable) rm --content-type <content-type>
      \(executable) rm --content-tag <content-tag>

    Subcommands:
      ls      List default file/content handlers as JSON
      list-content-types
              List built-in content types as JSON
      set     Set a default file/content handler and print the result as JSON
      rm      Remove default file/content handlers and print the result as JSON
    """)
}

// Convert plist values into JSON-safe values.
func jsonValue(_ value: Any?) -> Any {
  guard let value = value else {
    return NSNull()
  }

  switch value {
  case let value as String:
    return value
  case let value as NSNumber:
    return value
  case let value as Bool:
    return value
  case let value as [Any]:
    return value.map(jsonValue)
  case let value as [String: Any]:
    return value.mapValues { jsonValue($0) }
  case let value as Date:
    return ISO8601DateFormatter().string(from: value)
  case let value as Data:
    return value.base64EncodedString()
  default:
    return String(describing: value)
  }
}

// LaunchServices stores LSHandlerModificationDate as CFAbsoluteTime seconds since 2001-01-01.
func modificationDateISO8601(_ value: Any?) -> Any {
  guard let seconds = value as? TimeInterval, seconds > 0 else {
    return NSNull()
  }

  return ISO8601DateFormatter().string(from: Date(timeIntervalSinceReferenceDate: seconds))
}

// Read only the LSHandlers array from a LaunchServices plist.
func launchServicesHandlers(from path: String) throws -> [[String: Any]] {
  let url = URL(fileURLWithPath: path)

  guard FileManager.default.fileExists(atPath: path) else {
    return []
  }

  let data = try Data(contentsOf: url)
  let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

  guard let dictionary = plist as? [String: Any],
    let handlers = dictionary["LSHandlers"] as? [[String: Any]]
  else {
    throw CLIError.unreadableLaunchServicesPlist(path)
  }

  return handlers
}

// Read the full plist and its current storage format for later writes.
func launchServicesPlist(from path: String) throws -> ([String: Any], PropertyListSerialization.PropertyListFormat) {
  let url = URL(fileURLWithPath: path)

  guard FileManager.default.fileExists(atPath: path) else {
    throw CLIError.missingLaunchServicesPlist(path)
  }

  let data = try Data(contentsOf: url)
  var format = PropertyListSerialization.PropertyListFormat.binary
  let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)

  guard let dictionary = plist as? [String: Any],
    dictionary["LSHandlers"] is [[String: Any]]
  else {
    throw CLIError.unreadableLaunchServicesPlist(path)
  }

  return (dictionary, format)
}

// Write the updated plist atomically while preserving its original format.
func writeLaunchServicesPlist(_ plist: [String: Any], format: PropertyListSerialization.PropertyListFormat, to path: String)
  throws
{
  let data = try PropertyListSerialization.data(fromPropertyList: plist, format: format, options: 0)
  let url = URL(fileURLWithPath: path)

  do {
    try data.write(to: url, options: [.atomic])
  } catch {
    throw CLIError.unwritableLaunchServicesPlist(path)
  }
}

// Extract all role-specific app bundle identifiers from an LSHandler entry.
func roles(from handler: [String: Any]) -> [String: String] {
  var roles: [String: String] = [:]

  for role in ["LSHandlerRoleAll", "LSHandlerRoleViewer", "LSHandlerRoleEditor", "LSHandlerRoleShell"] {
    if let appId = handler[role] as? String {
      roles[role] = appId
    }
  }

  return roles
}

// Load file/content handlers from all configured LaunchServices plist sources.
func defaultFileHandlers() throws -> [DefaultFileHandler] {
  var handlers: [DefaultFileHandler] = []

  for path in launchServicesPlistPaths {
    for rawHandler in try launchServicesHandlers(from: path) {
      let contentType = rawHandler["LSHandlerContentType"] as? String
      let contentTag = rawHandler["LSHandlerContentTag"] as? String
      let contentTagClass = rawHandler["LSHandlerContentTagClass"] as? String

      guard contentType != nil || contentTag != nil else {
        continue
      }

      let handlerRoles = roles(from: rawHandler)
      let appId =
        handlerRoles["LSHandlerRoleAll"]
        ?? handlerRoles["LSHandlerRoleViewer"]
        ?? handlerRoles["LSHandlerRoleEditor"]
        ?? handlerRoles["LSHandlerRoleShell"]

      handlers.append(
        DefaultFileHandler(
          contentType: contentType,
          contentTag: contentTag,
          contentTagClass: contentTagClass,
          appId: appId,
          roles: handlerRoles,
          preferredVersions: rawHandler["LSHandlerPreferredVersions"] as? [String: Any] ?? [:],
          modificationDate: rawHandler["LSHandlerModificationDate"],
          rank: rawHandler["LSHandlerRank"] as? String,
          source: path,
          raw: rawHandler.mapValues { jsonValue($0) }))
    }
  }

  return handlers.sorted {
    let leftKey = [
      $0.contentType ?? "",
      $0.contentTagClass ?? "",
      $0.contentTag ?? "",
      $0.appId ?? "",
    ].joined(separator: "\u{0}")
    let rightKey = [
      $1.contentType ?? "",
      $1.contentTagClass ?? "",
      $1.contentTag ?? "",
      $1.appId ?? "",
    ].joined(separator: "\u{0}")

    return leftKey < rightKey
  }
}

// Serialize a JSON-compatible value to stdout.
func printJSON(_ value: Any, failureMessage: String) {
  guard JSONSerialization.isValidJSONObject(value),
    let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]),
    let output = String(data: data, encoding: .utf8)
  else {
    fputs("\(failureMessage)\n", stderr)
    exit(1)
  }

  print(output)
}

// Print default file/content handlers as JSON.
func listDefaultFileHandlers() throws {
  let json = try defaultFileHandlers().map {
    return [
      "contentType": jsonValue($0.contentType),
      "contentTag": jsonValue($0.contentTag),
      "contentTagClass": jsonValue($0.contentTagClass),
      "appId": jsonValue($0.appId),
      "roles": $0.roles,
      "preferredVersions": $0.preferredVersions.mapValues { jsonValue($0) },
      "modificationDate": jsonValue($0.modificationDate),
      "modificationDateISO8601": modificationDateISO8601($0.modificationDate),
      "rank": jsonValue($0.rank),
      "source": $0.source,
      "raw": $0.raw,
    ] as [String: Any]
  }

  printJSON(json, failureMessage: "Failed to encode default file handlers as JSON")
}

func jsonDefaultFileHandler(_ handler: DefaultFileHandler) -> [String: Any] {
  return [
    "contentType": jsonValue(handler.contentType),
    "contentTag": jsonValue(handler.contentTag),
    "contentTagClass": jsonValue(handler.contentTagClass),
    "appId": jsonValue(handler.appId),
    "roles": handler.roles,
    "preferredVersions": handler.preferredVersions.mapValues { jsonValue($0) },
    "modificationDate": jsonValue(handler.modificationDate),
    "modificationDateISO8601": modificationDateISO8601(handler.modificationDate),
    "rank": jsonValue(handler.rank),
    "source": handler.source,
    "raw": handler.raw,
  ]
}

let builtinContentTypeIdentifiers = [
  // cSpell:disable
  "com.adobe.pdf",
  "com.apple.alias-file",
  "com.apple.applescript.script",
  "com.apple.application",
  "com.apple.application-bundle",
  "com.apple.application-file",
  "com.apple.archive",
  "com.apple.audio-unit-plugin",
  "com.apple.binary-property-list",
  "com.apple.bundle",
  "com.apple.disk-image",
  "com.apple.executable",
  "com.apple.file-url",
  "com.apple.finder-internet-location",
  "com.apple.framework",
  "com.apple.icns",
  "com.apple.internet-location",
  "com.apple.mach-o-binary",
  "com.apple.package",
  "com.apple.pkpass",
  "com.apple.plugin",
  "com.apple.property-list",
  "com.apple.protected-mpeg-4-audio",
  "com.apple.protected-mpeg-4-video",
  "com.apple.quicklook-generator",
  "com.apple.reality",
  "com.apple.resolvable",
  "com.apple.rtfd",
  "com.apple.scenekit.scene",
  "com.apple.symbolic-link",
  "com.apple.systempreference.prefpane",
  "com.apple.tv.mpeg-2-transport-stream",
  "com.apple.url-bookmark-data",
  "com.apple.webarchive",
  "com.apple.x509-certificate",
  "com.apple.xpc-service",
  "com.microsoft.bmp",
  "com.microsoft.ico",
  "com.microsoft.waveform-audio",
  "com.pkware.zip-archive",
  "com.rarlab.rar-archive",
  "com.sun.java-archive",
  "org.7-zip.7-zip-archive",
  "org.gnu.gnu-zip-archive",
  "org.gnu.gnu-zip-tar-archive",
  "org.gnu.gnu-tar-archive",
  "org.oasis-open.opendocument.presentation",
  "org.oasis-open.opendocument.spreadsheet",
  "org.oasis-open.opendocument.text",
  "org.openxmlformats.presentationml.presentation",
  "org.openxmlformats.spreadsheetml.sheet",
  "org.openxmlformats.wordprocessingml.document",
  "org.tukaani.xz-archive",
  "public.3d-content",
  "public.aiff-audio",
  "public.archive",
  "public.assembly-source",
  "public.audio",
  "public.audiovisual-content",
  "public.avi",
  "public.bz2-archive",
  "public.c-header",
  "public.c-plus-plus-header",
  "public.c-plus-plus-source",
  "public.c-source",
  "public.calendar-event",
  "public.comma-separated-values-text",
  "public.composite-content",
  "public.contact",
  "public.content",
  "public.css",
  "public.data",
  "public.database",
  "public.delimited-values-text",
  "public.directory",
  "public.dng",
  "public.email-message",
  "public.epub",
  "public.executable",
  "public.exr",
  "public.filename-extension",
  "public.flat-rtfd",
  "public.folder",
  "public.font",
  "public.geojson",
  "public.gif",
  "public.heic",
  "public.heics",
  "public.heif",
  "public.html",
  "public.image",
  "public.item",
  "public.jpeg",
  "public.jpeg-2000",
  "public.jpeg-xl",
  "public.json",
  "public.link-presentation-metadata",
  "public.log",
  "public.m3u-playlist",
  "public.midi-audio",
  "public.mime-type",
  "public.movie",
  "public.mp3",
  "public.mpeg",
  "public.mpeg-2-video",
  "public.mpeg-4",
  "public.mpeg-4-audio",
  "public.objective-c-plus-plus-source",
  "public.objective-c-source",
  "public.opentype-font",
  "public.perl-script",
  "public.php-script",
  "public.plain-text",
  "public.png",
  "public.presentation",
  "public.python-script",
  "public.raw-image",
  "public.ruby-script",
  "public.rtf",
  "public.script",
  "public.shell-script",
  "public.source-code",
  "public.spreadsheet",
  "public.svg-image",
  "public.swift-source",
  "public.tab-separated-values-text",
  "public.tar-archive",
  "public.text",
  "public.tiff",
  "public.to-do-item",
  "public.unix-executable",
  "public.url",
  "public.url-name",
  "public.utf16-external-plain-text",
  "public.utf16-plain-text",
  "public.utf8-plain-text",
  "public.utf8-tab-separated-values-text",
  "public.vcard",
  "public.video",
  "public.volume",
  "public.webp",
  "public.xml",
  "public.xml-property-list",
  "public.yaml",
  "public.zip-archive",
  // cSpell:enable
]

func allTags(for identifier: String, tagClass: String) -> [String] {
  guard
    let tags = UTTypeCopyAllTagsWithClass(identifier as CFString, tagClass as CFString)?
      .takeRetainedValue() as? [String]
  else {
    return []
  }

  return tags.sorted()
}

func preferredTag(for identifier: String, tagClass: String) -> Any {
  guard
    let tag = UTTypeCopyPreferredTagWithClass(identifier as CFString, tagClass as CFString)?
      .takeRetainedValue() as? String
  else {
    return NSNull()
  }

  return tag
}

func contentTypeDescription(for identifier: String) -> Any {
  guard let description = UTTypeCopyDescription(identifier as CFString)?.takeRetainedValue() as? String else {
    return NSNull()
  }

  return description
}

// Print built-in content types as JSON.
func listContentTypes() {
  let filenameExtensionTagClass = "public.filename-extension"
  let mimeTypeTagClass = "public.mime-type"
  let json = Set(builtinContentTypeIdentifiers).sorted().map { identifier in
    let filenameExtensions = allTags(for: identifier, tagClass: filenameExtensionTagClass)
    let mimeTypes = allTags(for: identifier, tagClass: mimeTypeTagClass)

    return [
      "identifier": identifier,
      "description": contentTypeDescription(for: identifier),
      "preferredFilenameExtension": preferredTag(for: identifier, tagClass: filenameExtensionTagClass),
      "preferredMIMEType": preferredTag(for: identifier, tagClass: mimeTypeTagClass),
      "tags": [
        filenameExtensionTagClass: filenameExtensions,
        mimeTypeTagClass: mimeTypes,
      ],
      "isDeclared": UTTypeIsDeclared(identifier as CFString),
      "isDynamic": UTTypeIsDynamic(identifier as CFString),
      "source": "builtin",
    ] as [String: Any]
  }

  printJSON(json, failureMessage: "Failed to encode content types as JSON")
}

// Find the persisted default handler record for a content type.
func currentDefaultFileHandler(for contentType: String) -> DefaultFileHandler? {
  return try? defaultFileHandlers().first { $0.contentType == contentType }
}

func roleMask(from role: String) -> LSRolesMask? {
  switch role {
  case "all":
    return LSRolesMask(rawValue: 0xFFFFFFFF)
  case "viewer":
    return LSRolesMask(rawValue: 0x00000002)
  case "editor":
    return LSRolesMask(rawValue: 0x00000004)
  case "shell":
    return LSRolesMask(rawValue: 0x00000008)
  default:
    return nil
  }
}

func roleAppId(from handler: DefaultFileHandler?, role: String) -> String? {
  guard let handler = handler else {
    return nil
  }

  switch role {
  case "all":
    return handler.roles["LSHandlerRoleAll"] ?? handler.appId
  case "viewer":
    return handler.roles["LSHandlerRoleViewer"] ?? handler.appId
  case "editor":
    return handler.roles["LSHandlerRoleEditor"] ?? handler.appId
  case "shell":
    return handler.roles["LSHandlerRoleShell"] ?? handler.appId
  default:
    return handler.appId
  }
}

func parseSetArguments(_ arguments: [String]) throws -> (role: String, contentType: String, appId: String) {
  if arguments.count == 2 {
    return ("all", arguments[0], arguments[1])
  }

  if arguments.count == 4 && arguments[0] == "--role" {
    let role = arguments[1].lowercased()
    guard roleMask(from: role) != nil else {
      throw CLIError.invalidArguments("Role must be one of: all, viewer, editor, shell")
    }

    return (role, arguments[2], arguments[3])
  }

  throw CLIError.invalidArguments("Usage: set <content-type> <bundle-id> | set --role <all|viewer|editor|shell> <content-type> <bundle-id>")
}

// Set a content type's default handler through LaunchServices.
func setDefaultFileHandler(arguments: [String]) throws {
  let parsed = try parseSetArguments(arguments)
  guard let roleMask = roleMask(from: parsed.role) else {
    throw CLIError.invalidArguments("Role must be one of: all, viewer, editor, shell")
  }

  let previousAppId = roleAppId(from: currentDefaultFileHandler(for: parsed.contentType), role: parsed.role)
  let status = LSSetDefaultRoleHandlerForContentType(
    parsed.contentType as CFString,
    roleMask,
    parsed.appId as CFString
  )

  guard status == noErr else {
    throw CLIError.setDefaultHandlerFailed(
      contentType: parsed.contentType,
      appId: parsed.appId,
      role: parsed.role,
      status: status
    )
  }

  let current = currentDefaultFileHandler(for: parsed.contentType)
  let handlerJSON: Any
  if let current = current {
    handlerJSON = jsonDefaultFileHandler(current)
  } else {
    handlerJSON = NSNull()
  }

  let json: [String: Any] = [
    "status": "ok",
    "contentType": parsed.contentType,
    "appId": parsed.appId,
    "role": parsed.role,
    "previousAppId": jsonValue(previousAppId),
    "currentAppId": jsonValue(roleAppId(from: current, role: parsed.role)),
    "handler": handlerJSON,
  ]

  printJSON(json, failureMessage: "Failed to encode set result as JSON")
}

func normalizedContentTag(_ value: String) -> String {
  if value.hasPrefix(".") {
    return String(value.dropFirst())
  }

  return value
}

func fileHandlerMatches(_ handler: [String: Any], mode: String, target: String) -> Bool {
  switch mode {
  case "contentType":
    return (handler["LSHandlerContentType"] as? String) == target
  case "contentTag":
    let contentTag = normalizedContentTag(target)
    return (handler["LSHandlerContentTag"] as? String) == contentTag
  default:
    return false
  }
}

func removedFileHandlers(from handlers: [[String: Any]], mode: String, target: String) -> [[String: Any]] {
  return handlers.filter {
    fileHandlerMatches($0, mode: mode, target: target)
  }
}

func keptFileHandlers(from handlers: [[String: Any]], mode: String, target: String) -> [[String: Any]] {
  return handlers.filter { handler in
    !fileHandlerMatches(handler, mode: mode, target: target)
  }
}

func parseRemoveArguments(_ arguments: [String]) throws -> (mode: String?, target: String) {
  guard !arguments.isEmpty else {
    throw CLIError.invalidArguments("Usage: rm <target>")
  }

  if arguments.count == 2 && arguments[0] == "--content-type" {
    return ("contentType", arguments[1])
  }

  if arguments.count == 2 && arguments[0] == "--content-tag" {
    return ("contentTag", normalizedContentTag(arguments[1]))
  }

  if arguments.count == 1 {
    return (nil, arguments[0])
  }

  throw CLIError.invalidArguments("Usage: rm <target> | rm --content-type <content-type> | rm --content-tag <content-tag>")
}

// Remove persisted handler entries for a file/content target.
func removeDefaultFileHandler(arguments: [String]) throws {
  let parsed = try parseRemoveArguments(arguments)
  let path = launchServicesPlistPaths[0]
  var (plist, format) = try launchServicesPlist(from: path)
  let handlers = plist["LSHandlers"] as? [[String: Any]] ?? []
  let mode = parsed.mode ?? (
    removedFileHandlers(from: handlers, mode: "contentType", target: parsed.target).isEmpty
      ? "contentTag"
      : "contentType"
  )
  let effectiveTarget = mode == "contentTag" ? normalizedContentTag(parsed.target) : parsed.target
  let removedHandlers = removedFileHandlers(from: handlers, mode: mode, target: effectiveTarget)

  plist["LSHandlers"] = keptFileHandlers(from: handlers, mode: mode, target: effectiveTarget)

  if !removedHandlers.isEmpty {
    try writeLaunchServicesPlist(plist, format: format, to: path)
  }

  let currentHandlers = removedFileHandlers(
    from: try launchServicesHandlers(from: path),
    mode: mode,
    target: effectiveTarget
  )
  let json: [String: Any] = [
    "status": "ok",
    "target": effectiveTarget,
    "mode": mode,
    "removed": removedHandlers.map { $0.mapValues { jsonValue($0) } },
    "removedCount": removedHandlers.count,
    "current": currentHandlers.map { $0.mapValues { jsonValue($0) } },
    "source": path,
  ]

  printJSON(json, failureMessage: "Failed to encode remove result as JSON")
}

// Dispatch command-line arguments to the selected subcommand.
func run() throws {
  let arguments = Array(CommandLine.arguments.dropFirst())

  guard let subcommand = arguments.first else {
    usage()
    return
  }

  switch subcommand {
  case "ls":
    guard arguments.count == 1 else {
      throw CLIError.invalidArguments("Usage: ls")
    }
    try listDefaultFileHandlers()
  case "list-content-types":
    guard arguments.count == 1 else {
      throw CLIError.invalidArguments("Usage: list-content-types")
    }
    listContentTypes()
  case "set":
    try setDefaultFileHandler(arguments: Array(arguments.dropFirst()))
  case "rm":
    try removeDefaultFileHandler(arguments: Array(arguments.dropFirst()))
  case "-h", "--help", "help":
    usage()
  default:
    throw CLIError.unknownSubcommand(subcommand)
  }
}

// Run the CLI and render errors consistently.
do {
  try run()
} catch {
  fputs("\(error)\n\n", stderr)
  usage()
  exit(1)
}
