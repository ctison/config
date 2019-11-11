#!/bin/sh
set -e

apt-get update
apt-get install -y \
          amass \
          bazel \
          bettercap{,-caplets,-ui} \
          calibre \
          certbot \
          cmatrix \
          fzf \
          hashcat \
          inotify-tools \
          mmdb-bin \
          metasploit-framework \
          mitmproxy \
          origami-pdf \
          postgresql-11 \
          tesseract-ocr

# Networking
apt-get install -y \
amass 