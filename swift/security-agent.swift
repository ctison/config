#!/usr/bin/env swift
import AppKit
import Foundation

// Simple macOS dialog that visually mimics the system authentication prompt.
// It is purely a demo UI and does not perform any privileged action.

final class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  private var usernameField: NSTextField!
  private var passwordField: NSSecureTextField!

  func applicationDidFinishLaunching(_ notification: Notification) {
    buildUI()
  }

  private func buildUI() {
    let size = NSSize(width: 280, height: 360)
    window = NSWindow(
      contentRect: NSRect(origin: .zero, size: size),
      styleMask: [],
      backing: .buffered,
      defer: false
    )
    // window.title = ""
    // window.titleVisibility = .hidden
    // window.titlebarAppearsTransparent = true
    // window.styleMask.insert(.fullSizeContentView)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.isMovableByWindowBackground = true
    // window.standardWindowButton(.zoomButton)?.isHidden = true
    // window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    // window.standardWindowButton(.closeButton)?.isHidden = true
    // window.styleMask.remove(.resizable)

    // Background card
    let backdrop = NSVisualEffectView()
    backdrop.material = .popover
    backdrop.blendingMode = .withinWindow
    backdrop.state = .active
    backdrop.wantsLayer = true
    backdrop.layer?.cornerRadius = 25
    backdrop.layer?.masksToBounds = true
    backdrop.layer?.backgroundColor =
      NSColor(red: 0xB5 / 255.0, green: 0xC2 / 255.0, blue: 0xEC / 255.0, alpha: 1.0).cgColor
    backdrop.translatesAutoresizingMaskIntoConstraints = false
    window.contentView = NSView(frame: NSRect(origin: .zero, size: size))
    guard let content = window.contentView else { return }
    content.addSubview(backdrop)

    NSLayoutConstraint.activate([
      backdrop.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
      backdrop.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
      backdrop.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
      backdrop.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -20),
    ])

    // Lock icon (SF Symbol)
    let icon = NSImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    if let image = NSImage(systemSymbolName: "lock.fill", accessibilityDescription: "Security") {
      icon.image = image
      icon.contentTintColor = NSColor.systemYellow
    }

    // Title: "Pearcleaner"
    let titleLabel = NSTextField(labelWithString: "Pearcleaner")
    titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .medium)
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    // Message
    let message = "Pearcleaner wants to\nmake changes.\n\nEnter your password to allow this."
    let messageLabel = NSTextField(labelWithString: message)
    messageLabel.font = NSFont.systemFont(ofSize: 13)
    messageLabel.textColor = .secondaryLabelColor
    messageLabel.lineBreakMode = .byWordWrapping
    messageLabel.maximumNumberOfLines = 0
    messageLabel.translatesAutoresizingMaskIntoConstraints = false

    // Username and password fields
    usernameField = NSTextField()
    usernameField.placeholderString = "Username"
    usernameField.font = NSFont.systemFont(ofSize: 13)
    usernameField.translatesAutoresizingMaskIntoConstraints = false
    usernameField.stringValue = "nil"

    passwordField = NSSecureTextField()
    passwordField.placeholderString = "Password"
    passwordField.font = NSFont.systemFont(ofSize: 13)
    passwordField.translatesAutoresizingMaskIntoConstraints = false

    // Buttons
    let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelTapped))
    cancelButton.bezelStyle = .rounded
    cancelButton.keyEquivalent = "\u{1b}"  // Escape
    cancelButton.translatesAutoresizingMaskIntoConstraints = false

    let okButton = NSButton(title: "OK", target: self, action: #selector(okTapped))
    okButton.bezelStyle = .rounded
    okButton.keyEquivalent = "\r"  // Return
    okButton.translatesAutoresizingMaskIntoConstraints = false

    // Stack and layout
    let v = NSView()
    v.translatesAutoresizingMaskIntoConstraints = false
    backdrop.addSubview(v)

    backdrop.addSubview(icon)
    backdrop.addSubview(titleLabel)
    backdrop.addSubview(messageLabel)
    backdrop.addSubview(usernameField)
    backdrop.addSubview(passwordField)
    backdrop.addSubview(cancelButton)
    backdrop.addSubview(okButton)

    NSLayoutConstraint.activate([
      icon.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 20),
      icon.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 20),
      icon.widthAnchor.constraint(equalToConstant: 32),
      icon.heightAnchor.constraint(equalToConstant: 32),

      titleLabel.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(
        lessThanOrEqualTo: backdrop.trailingAnchor, constant: -20),

      messageLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
      messageLabel.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 20),
      messageLabel.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -20),

      usernameField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
      usernameField.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
      usernameField.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
      usernameField.heightAnchor.constraint(equalToConstant: 24),

      passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 8),
      passwordField.leadingAnchor.constraint(equalTo: usernameField.leadingAnchor),
      passwordField.trailingAnchor.constraint(equalTo: usernameField.trailingAnchor),
      passwordField.heightAnchor.constraint(equalToConstant: 24),

      okButton.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -20),
      okButton.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -16),

      cancelButton.trailingAnchor.constraint(equalTo: okButton.leadingAnchor, constant: -8),
      cancelButton.centerYAnchor.constraint(equalTo: okButton.centerYAnchor),
    ])

    window.level = .floating
    window.center()
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    window.makeFirstResponder(passwordField)
  }

  @objc private func cancelTapped() {
    NSApp.terminate(nil)
  }

  @objc private func okTapped() {
    // Demo behavior: simply close the window. In a real app you would verify credentials.
    window.close()
    NSApp.terminate(nil)
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)  // Hide Dock icon and app menu bar
app.run()
