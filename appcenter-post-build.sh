#!/usr/bin/env bash

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