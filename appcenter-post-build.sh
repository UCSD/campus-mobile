#!/usr/bin/env bash
echo "#### appcenter-post-build START ####"

npm install --global react-native-cli
npm install --global bugsnag-sourcemaps

# Debug
pwd
ls -la
echo "Bundle File: $BUNDLE_FILE"

react-native bundle \
    --platform ios \
    --dev false \
    --entry-file index.js \
    --bundle-output ios-release.bundle \
    --sourcemap-output ios-release.bundle.map

# Upload source maps to bugsnag 
bugsnag-sourcemaps upload \
   --api-key $BUGSNAG_KEY \
   --code-bundle-id $APPCENTER_BUILD_ID \
   --source-map ios-release.bundle.map \
   --minified-url main.jsbundle \
   --minified-file ios-release.bundle \
   --upload-sources

echo '## APPCENTER SOURCE:'
find $APPCENTER_SOURCE_DIRECTORY

echo '## APPCENTER OUTPUT:'
find $APPCENTER_OUTPUT_DIRECTORY

echo "#### appcenter-post-build END ####"
