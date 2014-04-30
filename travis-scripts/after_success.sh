#!/bin/bash -v

# -v makes this script print commands before executing them

# bail here if distribution is disabled
if [[ "$TWT_SHOULD_DISTRIBUTE" != 0 ]]; then
  exit 0
fi

# bail here if the length of the string in $TWT_DROPBOX_DISTRIBUTION_DEPENDENCIES_URL is zero
if [[ -z "$TWT_DROPBOX_DISTRIBUTION_DEPENDENCIES_URL" ]]; then
  exit 0
fi

# Prepare a temporary directory for dealing with distribution dependencies
mkdir -p ~/distribution_resources
pushd ~/distribution_resources

# Fetch dependencies from Dropbox
curl -L -o archive.zip "$TWT_DROPBOX_DISTRIBUTION_DEPENDENCIES_URL?dl=1"

# Fetch the Apple WWDR Certificate
curl -L -o AppleWWDRCA.cer "http://developer.apple.com/certificationauthority/AppleWWDRCA.cer"

# Unzip the dependencies archive
unzip -j archive.zip

# source the distribution environment
source environment.sh

# bail here if a full set of TESTFLIGHT_* or HOCKEYAPP_* environment variables have not been defined

function testflight_enabled ()
{
  [[ -n "$TESTFLIGHT_API_TOKEN" && -n "$TESTFLIGHT_TEAM_TOKEN" && -n "$TESTFLIGHT_DISTRIBUTION_LISTS" ]]
}

function hockeyapp_enabled ()
{
  [[ -n "$HOCKEYAPP_API_TOKEN" && -n "$HOCKEYAPP_APP_ID" ]]
}

if [[ ! testflight_enabled && ! hockeyapp_enabled ]]; then
  exit 0
fi

# Install the provisioning profile
mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
cp *.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/"

# create a temporary keychain
security create-keychain -p travis ios-build.keychain

# remove timeout for keychain auto-lock
security set-keychain-settings ios-build.keychain

# Install the certificates
for cert in *.cer; do
  security import "$cert" -k ios-build.keychain -T /usr/bin/codesign
done

# Install the private key (there should only be one)
for key in *.p12; do
  security import "$key" -k ios-build.keychain -P "$TWT_CODESIGNING_KEY_PASSWORD" -T /usr/bin/codesign
done

# pop back to the project repo directory
popd

# set the default keychain so xcodebuild will look in the right place for code signing identities
security default-keychain -s ios-build.keychain

# build the ipa
ipa build -w "$TRAVIS_XCODE_WORKSPACE" -s "$TRAVIS_XCODE_SCHEME"

# set the default keychain back to its previous value
security default-keychain -s login.keychain

# destroy the temporary keychain
security delete-keychain ios-build.keychain

# remove the provisioning profile
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/*

# remove the distribution_resources directory
rm -rf ~/distribution_resources

# Generate release notes
BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')
RELEASE_NOTES=$(cat <<RELEASE_NOTES_END
Travis CI Build Number: $TRAVIS_BUILD_NUMBER
Build Date: $BUILD_DATE
RELEASE_NOTES_END
)

# upload the ipa to TestFlight
if testflight_enabled; then
  ipa distribute:testflight -a "$TESTFLIGHT_API_TOKEN" -T "$TESTFLIGHT_TEAM_TOKEN" -l "$TESTFLIGHT_DISTRIBUTION_LISTS" -m "$RELEASE_NOTES" --notify
fi

# upload the ipa to HockeyApp
if hockeyapp_enabled; then
  if [[ -n "$HOCKEYAPP_TAGS" ]]; then
    HOCKEYAPP_TAGS_ARGUMENT="--tags \"$HOCKEYAPP_TAGS\""
  fi
  set -x
  ipa distribute:hockeyapp --token "$HOCKEYAPP_API_TOKEN" -i "$HOCKEYAPP_APP_ID" $HOCKEYAPP_TAGS_ARGUMENT -m "$RELEASE_NOTES" --notify
fi
