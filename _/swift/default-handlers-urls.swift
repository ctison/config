#!/usr/bin/env swift
import CoreServices
import Foundation

// Normalized representation of one LaunchServices URL scheme handler.
struct DefaultURLHandler {
  let scheme: String
  let appId: String?
  let roles: [String: String]
  let preferredVersions: [String: Any]
  let modificationDate: Any?
  let source: String
  let raw: [String: Any]
}

// User-facing command errors.
enum CLIError: Error, CustomStringConvertible {
  case invalidArguments(String)
  case missingLaunchServicesPlist(String)
  case setDefaultHandlerFailed(scheme: String, appId: String, status: OSStatus)
  case unknownSubcommand(String)
  case unreadableLaunchServicesPlist(String)
  case unwritableLaunchServicesPlist(String)

  var description: String {
    switch self {
    case .invalidArguments(let message):
      return message
    case .missingLaunchServicesPlist(let path):
      return "LaunchServices plist does not exist: \(path)"
    case .setDefaultHandlerFailed(let scheme, let appId, let status):
      return
        "Failed to set default URL handler for \(scheme) to \(appId) (OSStatus \(status))"
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
    ?? "default-handlers"
  print(
    """
    Usage:
      \(executable) ls
      \(executable) set <scheme> <bundle-id>
      \(executable) rm <scheme>

    Subcommands:
      ls      List default URL handlers as JSON
      set     Set a default URL handler and print the result as JSON
      rm      Remove a default URL handler and print the result as JSON
    """)
}

// Convert plist values into JSON-safe values.
func jsonValue(_ value: Any) -> Any {
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
    return value.mapValues(jsonValue)
  case let value as Date:
    return ISO8601DateFormatter().string(from: value)
  case let value as Data:
    return value.base64EncodedString()
  default:
    return String(describing: value)
  }
}

// LaunchServices stores LSHandlerModificationDate as CFAbsoluteTime seconds since 2001-01-01.
func modificationDateISO8601(_ value: Any?) -> String? {
  guard let seconds = value as? TimeInterval, seconds > 0 else {
    return nil
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

// Load URL scheme handlers from all configured LaunchServices plist sources.
func defaultURLHandlers() throws -> [DefaultURLHandler] {
  var handlers: [DefaultURLHandler] = []

  for path in launchServicesPlistPaths {
    for rawHandler in try launchServicesHandlers(from: path) {
      guard let scheme = rawHandler["LSHandlerURLScheme"] as? String else {
        continue
      }

      let handlerRoles = roles(from: rawHandler)
      let appId =
        handlerRoles["LSHandlerRoleAll"]
        ?? handlerRoles["LSHandlerRoleViewer"]
        ?? handlerRoles["LSHandlerRoleEditor"]
        ?? handlerRoles["LSHandlerRoleShell"]

      handlers.append(
        DefaultURLHandler(
          scheme: scheme.lowercased(),
          appId: appId,
          roles: handlerRoles,
          preferredVersions: rawHandler["LSHandlerPreferredVersions"] as? [String: Any] ?? [:],
          modificationDate: rawHandler["LSHandlerModificationDate"],
          source: path,
          raw: rawHandler.mapValues(jsonValue)))
    }
  }

  return handlers.sorted {
    if $0.scheme == $1.scheme {
      return ($0.appId ?? "") < ($1.appId ?? "")
    }

    return $0.scheme < $1.scheme
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

// Print default URL scheme handlers as JSON.
func listDefaultURLHandlers() throws {
  let json = try defaultURLHandlers().map {
    return [
      "scheme": $0.scheme,
      "appId": $0.appId as Any,
      "roles": $0.roles,
      "preferredVersions": $0.preferredVersions.mapValues(jsonValue),
      "modificationDate": jsonValue($0.modificationDate as Any),
      "modificationDateISO8601": modificationDateISO8601($0.modificationDate) as Any,
      "source": $0.source,
      "raw": $0.raw,
    ] as [String: Any]
  }

  printJSON(json, failureMessage: "Failed to encode default URL handlers as JSON")
}

// Find the persisted default handler record for a scheme.
func currentDefaultURLHandler(for scheme: String) -> DefaultURLHandler? {
  return try? defaultURLHandlers().first { $0.scheme == scheme.lowercased() }
}

// Set a scheme's default handler through LaunchServices.
func setDefaultURLHandler(arguments: [String]) throws {
  guard arguments.count == 2 else {
    throw CLIError.invalidArguments("Usage: set <scheme> <bundle-id>")
  }

  let scheme = arguments[0].lowercased()
  let appId = arguments[1]

  let previousAppId = currentDefaultURLHandler(for: scheme)?.appId
  let status = LSSetDefaultHandlerForURLScheme(scheme as CFString, appId as CFString)

  guard status == noErr else {
    throw CLIError.setDefaultHandlerFailed(scheme: scheme, appId: appId, status: status)
  }

  let current = currentDefaultURLHandler(for: scheme)
  let json: [String: Any] = [
    "status": "ok",
    "scheme": scheme,
    "appId": appId,
    "previousAppId": previousAppId as Any,
    "currentAppId": current?.appId as Any,
    "handler": current.map {
      [
        "scheme": $0.scheme,
        "appId": $0.appId as Any,
        "roles": $0.roles,
        "preferredVersions": $0.preferredVersions.mapValues(jsonValue),
        "modificationDate": jsonValue($0.modificationDate as Any),
        "modificationDateISO8601": modificationDateISO8601($0.modificationDate) as Any,
        "source": $0.source,
        "raw": $0.raw,
      ] as [String: Any]
    } as Any,
  ]

  printJSON(json, failureMessage: "Failed to encode set result as JSON")
}

// Remove persisted handler entries for a URL scheme.
func removeDefaultURLHandler(arguments: [String]) throws {
  guard arguments.count == 1 else {
    throw CLIError.invalidArguments("Usage: rm <scheme>")
  }

  let scheme = arguments[0].lowercased()
  let path = launchServicesPlistPaths[0]
  var (plist, format) = try launchServicesPlist(from: path)
  let handlers = plist["LSHandlers"] as? [[String: Any]] ?? []
  let removedHandlers = handlers.filter {
    ($0["LSHandlerURLScheme"] as? String)?.lowercased() == scheme
  }

  plist["LSHandlers"] = handlers.filter {
    ($0["LSHandlerURLScheme"] as? String)?.lowercased() != scheme
  }

  if !removedHandlers.isEmpty {
    try writeLaunchServicesPlist(plist, format: format, to: path)
  }

  let current = currentDefaultURLHandler(for: scheme)
  let json: [String: Any] = [
    "status": "ok",
    "scheme": scheme,
    "removed": removedHandlers.map { $0.mapValues(jsonValue) },
    "removedCount": removedHandlers.count,
    "currentAppId": current?.appId as Any,
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
    try listDefaultURLHandlers()
  case "set":
    try setDefaultURLHandler(arguments: Array(arguments.dropFirst()))
  case "rm":
    try removeDefaultURLHandler(arguments: Array(arguments.dropFirst()))
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
