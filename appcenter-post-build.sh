#!/usr/bin/env bash
echo "#### appcenter-post-build START ####"

npm install --global react-native-cli
npm install --global bugsnag-sourcemaps




if [ -n "$APPCENTER_XCODE_PROJECT" ]
then
    echo "Generating React Native bundle for iOS..."
    react-native bundle \
        --platform ios \
        --dev false \
        --entry-file index.js \
        --bundle-output ios-release.bundle \
        --sourcemap-output ios-release.bundle.map
    
    echo "Uploading source map for iOS..."
    bugsnag-sourcemaps upload \
        --api-key $BUGSNAG_KEY \
        --code-bundle-id $APPCENTER_BUILD_ID \
        --source-map ios-release.bundle.map \
        --minified-url main.jsbundle \
        --minified-file ios-release.bundle \
        --upload-sources
else
    echo "Generating React Native bundle for Android..."
    react-native bundle \
        --platform android \
        --dev false \
        --entry-file index.js \
        --bundle-output android-release.bundle \
        --sourcemap-output android-release.bundle.map

    echo "Uploading source map for Android..."
    bugsnag-sourcemaps upload \
        --api-key $BUGSNAG_KEY \
        --code-bundle-id $APPCENTER_BUILD_ID \
        --source-map android-release.bundle.map \
        --minified-url main.jsbundle \
        --minified-file android-release.bundle \
        --upload-sources
fi

echo '## APPCENTER SOURCE:'
find $APPCENTER_SOURCE_DIRECTORY

echo '## APPCENTER OUTPUT:'
find $APPCENTER_OUTPUT_DIRECTORY

echo '## APPCENTER_REACTNATIVE_PACKAGE: $APPCENTER_REACTNATIVE_PACKAGE'

echo "#### appcenter-post-build END ####"
