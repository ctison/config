#!/usr/bin/env swift
import Foundation
import SystemConfiguration

func escapeForAppleScript(_ string: String) -> String {
  return string
    .replacingOccurrences(of: "\"", with: "\\\"")
}

func showNotification(title: String, message: String) {
  let title = escapeForAppleScript(title)
  let message = escapeForAppleScript(message)

  let script = """
    display notification "\(message)" with title "\(title)"
    """

  let process = Process()
  process.launchPath = "/usr/bin/osascript"
  process.arguments = ["-e", script]
  process.launch()
  process.waitUntilExit()
}

// Show initial notification
showNotification(title: "DNS Monitor", message: "DNS monitoring started")

var serverAddresses: [String] = []

guard
  let store = SCDynamicStoreCreate(
    nil, "dns-fetcher" as CFString,
    { (ctx, _, _) in
      guard
        let globalDns = SCDynamicStoreCopyValue(nil, "State:/Network/Global/DNS" as CFString)
          as? [String: Any]
      else {
        print("Failed to copy global DNS value")
        exit(1)
      }

      let _serverAddresses = globalDns["ServerAddresses"] as? [String] ?? []

      print("\(_serverAddresses)")

      if _serverAddresses.count > 0 && _serverAddresses != serverAddresses {
        serverAddresses = _serverAddresses
        showNotification(
          title: "DNS Changed", message: "\(_serverAddresses)")
      }

    }, nil)
else {
  print("Failed to create SCDynamicStore")
  exit(1)
}

guard
  SCDynamicStoreSetNotificationKeys(
    store, nil, ["State:/Network/Global/DNS" as CFString] as CFArray)
else {
  print("Failed to set notification keys")
  exit(1)
}

let runLoop = CFRunLoopGetCurrent()
let runLoopSource = SCDynamicStoreCreateRunLoopSource(nil, store, 0)

CFRunLoopAddSource(runLoop, runLoopSource, CFRunLoopMode.defaultMode)
CFRunLoopRun()
