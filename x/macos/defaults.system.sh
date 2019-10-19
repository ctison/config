#!/bin/sh

set -e

# Disable infrared receiver
defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -int 0

# Deactivate captive portal
defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false
