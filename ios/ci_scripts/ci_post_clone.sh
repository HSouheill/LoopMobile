#!/bin/sh
set -e

# Install Flutter (pinned to the version verified locally to avoid stable-channel regressions)
git clone https://github.com/flutter/flutter.git $HOME/flutter
git -C $HOME/flutter checkout 3.41.9
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache iOS artifacts
flutter precache --ios

# Install pub + pods
cd $CI_PRIMARY_REPOSITORY_PATH
flutter pub get
cd ios
pod install
