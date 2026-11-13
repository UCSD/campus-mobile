#!/bin/sh
# Keep secret values out of shell trace output.
set +x
set -e
echo "Start: post-clone.sh"

echo "Checking required environment variables ..."
# 1. APP_VERSION
if [ -n "$APP_VERSION" ]; then
    echo "APP_VERSION: Found"
else
    echo "Error: APP_VERSION not found, exiting."
    exit 1
fi

# 2. BUILD_ENV
if [ -n "$BUILD_ENV" ]; then
    echo "BUILD_ENV: Found"
else
    echo "Error: BUILD_ENV not found, exiting."
    exit 1
fi

# 3. APP_CONFIG
if [ -n "$APP_CONFIG" ]; then
    echo "APP_CONFIG: Found"
else
    echo "Error: APP_CONFIG not found, exiting."
    exit 1
fi

# 4. SP_CONFIG
if [ -n "$SP_CONFIG" ]; then
    echo "SP_CONFIG: Found"
else
    echo "Error: SP_CONFIG not found, exiting."
    exit 1
fi

# 5. FIREBASE_IOS
if [ -n "$FIREBASE_IOS" ]; then
    echo "FIREBASE_IOS: Found"
else
    echo "Error: FIREBASE_IOS not found, exiting."
    exit 1
fi

# 6. FIREBASE_ANDROID
if [ -n "$FIREBASE_ANDROID" ]; then
    echo "FIREBASE_ANDROID: Found"
else
    echo "Error: FIREBASE_ANDROID not found, exiting."
    exit 1
fi

# 7. BUILD_PLATFORM
if [ -n "$BUILD_PLATFORM" ]; then
    echo "BUILD_PLATFORM: Found"
else
    echo "Error: BUILD_PLATFORM not found, exiting."
    exit 1
fi

write_maps_config() {
    if [ -z "$2" ]; then
        echo "Error: $1 not found for BUILD_PLATFORM=$BUILD_PLATFORM, exiting."
        exit 1
    fi

    echo "Writing Maps configuration to $3 ..."
    (
        umask 077
        printf 'GOOGLE_MAPS_API_KEY=%s\n' "$2" > "$3"
    )
}

# Native Maps configuration is separate from the Flutter .env asset.
case "$BUILD_PLATFORM" in
    ANDROID)
        write_maps_config GOOGLE_MAPS_ANDROID_API_KEY "$GOOGLE_MAPS_ANDROID_API_KEY" ./android/secrets.properties
        ;;
    IOS)
        write_maps_config GOOGLE_MAPS_IOS_API_KEY "$GOOGLE_MAPS_IOS_API_KEY" ./ios/Flutter/Secrets.xcconfig
        ;;
    BOTH)
        write_maps_config GOOGLE_MAPS_ANDROID_API_KEY "$GOOGLE_MAPS_ANDROID_API_KEY" ./android/secrets.properties
        write_maps_config GOOGLE_MAPS_IOS_API_KEY "$GOOGLE_MAPS_IOS_API_KEY" ./ios/Flutter/Secrets.xcconfig
        ;;
    *)
        echo "Error: BUILD_PLATFORM must be ANDROID, IOS, or BOTH, exiting."
        exit 1
        ;;
esac

echo "Installing Node.js ..."
curl "https://nodejs.org/dist/v18.16.0/node-v18.16.0.pkg" > "$HOME/Downloads/node-stable.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-stable.pkg" -target "/"
node --version

echo "Writing .env from \$APP_CONFIG ..."
echo $APP_CONFIG | base64 --decode > ./.env

echo "Writing sp-config.json from \$SP_CONFIG ..."
echo $SP_CONFIG | base64 --decode > ./scripts/codemagic-ci/sp-config.json

echo "./ios/Runner/GoogleService-Info.plist --> $BUILD_ENV"
echo $FIREBASE_IOS | base64 --decode > ./ios/Runner/GoogleService-Info.plist

echo "./android/app/google-services.json --> $BUILD_ENV"
echo $FIREBASE_ANDROID | base64 --decode > ./android/app/google-services.json

# Write release notes
if [ -n "$FCI_PULL_REQUEST_NUMBER" ]; then
    echo "$BUILD_ENV Environment Build (PR: $FCI_PULL_REQUEST_NUMBER)" > ./release_notes.txt
else
    echo "$BUILD_ENV Environment Build (Branch: $FCI_BRANCH)" > ./release_notes.txt
fi

echo "End: post-clone.sh"
