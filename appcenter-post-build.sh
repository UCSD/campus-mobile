#!/usr/bin/env bash
echo "#### appcenter-post-build START ####"

npm install --global react-native-cli
npm install --global bugsnag-sourcemaps

# Source Maps - iOS
react-native bundle \
    --platform ios \
    --dev false \
    --entry-file index.js \
    --bundle-output ios-release.bundle \
    --sourcemap-output ios-release.bundle.map

bugsnag-sourcemaps upload \
    --api-key $BUGSNAG_KEY \
    --code-bundle-id $APPCENTER_BUILD_ID \
    --source-map ios-release.bundle.map \
    --minified-url main.jsbundle \
    --minified-file ios-release.bundle \
    --upload-sources

# Source Maps - Android
react-native bundle \
    --platform android \
    --dev false \
    --entry-file index.js \
    --bundle-output android-release.bundle \
    --sourcemap-output android-release.bundle.map

bugsnag-sourcemaps upload \
    --api-key $BUGSNAG_KEY \
    --code-bundle-id $APPCENTER_BUILD_ID \
    --source-map android-release.bundle.map \
    --minified-url main.jsbundle \
    --minified-file android-release.bundle \
    --upload-sources
    
echo "#### appcenter-post-build END ####"
