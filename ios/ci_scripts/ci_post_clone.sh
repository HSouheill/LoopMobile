#!/bin/sh
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache iOS artifacts
flutter precache --ios

# Install pub + pods
cd $CI_PRIMARY_REPOSITORY_PATH
flutter pub get
cd ios
pod install
