#!/bin/sh

set -e

# Disable logging of downloads x')
ln -sfv /dev/null ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2

# Disable .DS_Store on USB devices
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable .DS_Store on Network Stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Bluetooth
defaults write bluetoothaudiod "Enable AptX codec" -bool true
defaults write bluetoothaudiod "Enable AAC codec" -bool true