#!/usr/bin/env bash
echo "#### appcenter-post-build START ####"

npm install --global react-native-cli
npm install --global bugsnag-sourcemaps

react-native bundle \
    --platform ios \
    --dev false \
    --entry-file index.js \
    --bundle-output ios-release.bundle \
    --sourcemap-output ios-release.bundle.map

# Upload source maps to bugsnag 
bugsnag-sourcemaps upload \
   --api-key $BUGSNAG_KEY \
   --app-version $APP_VERSION \
   --code-bundle-id $APPCENTER_BUILD_ID \
   --source-map ios-release.bundle.map \
   --minified-url main.jsbundle \
   --minified-file ios-release.bundle \
   --upload-sources

echo "#### appcenter-post-build END ####"
