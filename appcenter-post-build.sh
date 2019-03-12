#!/usr/bin/env bash

echo "#### appcenter-post-build START ####"

# Install bugsnag-sourcemaps
npm install --global bugsnag-sourcemaps

# Upload source maps to bugsnag 
bugsnag-sourcemaps upload \
    --api-key $BUGSNAG_KEY \
    --code-bundle-id $APPCENTER_BUILD_ID \
    --source-map index.ios.map \
    --minified-url main.jsbundle \
    --minified-file ios-release.bundle \
    --upload-sources

ls -la $APPCENTER_SOURCE_DIRECTORY
ls -la $APPCENTER_OUTPUT_DIRECTORY

echo "#### appcenter-post-build END ####"
