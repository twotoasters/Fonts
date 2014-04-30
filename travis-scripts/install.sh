#!/bin/bash -v

# -v makes this script print commands before executing them

# install dependencies from Homebrew
brew upgrade xctool

# update CocoaPods
gem upgrade cocoapods

# install gems
bundle install

# install pods
bundle exec pod install

# install Dropbox build dependencies

# bail here if the length of the string in $TWT_DROPBOX_BUILD_DEPENDENCIES_URL is zero
if [[ -z "$TWT_DROPBOX_BUILD_DEPENDENCIES_URL" ]]; then
  exit 0
fi

# Fetch build dependencies from Dropbox
curl -L -o archive.zip "$TWT_DROPBOX_BUILD_DEPENDENCIES_URL?dl=1"

# Unzip the dependencies archive
unzip archive.zip

# remove the archive
rm archive.zip
