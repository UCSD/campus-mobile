#!/bin/sh
set -ex

echo "Start: post-clone.sh"
echo "APP_VERSION: $APP_VERSION"

echo "Installing Node.js..."
curl "https://nodejs.org/dist/latest/node-${VERSION:-$(wget -qO- https://nodejs.org/dist/latest/ | sed -nE 's|.*>node-(.*)\.pkg</a>.*|\1|p')}.pkg" > "$HOME/Downloads/node-latest.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-latest.pkg" -target "/"
node --version

echo "Writing app-config.js from \$APP_CONFIG..."
echo $APP_CONFIG | base64 --decode > ./scripts/codemagic-ci/app-config.js

echo "./ios/Runner/GoogleService-Info.plist --> $BUILD_ENV"
echo $FIREBASE_IOS | base64 --decode > ./ios/Runner/GoogleService-Info.plist

echo "./android/app/google-services.json --> $BUILD_ENV"
echo $FIREBASE_ANDROID | base64 --decode > ./android/app/google-services.json


# Set env vars
echo "Setting build environment: $BUILD_ENV"
if [ "$BUILD_ENV" == "PROD" ]; then
    node ./scripts/codemagic-ci/set-env.js PROD
    sh ./scripts/codemagic-ci/verify-env.sh PROD
elif [ "$BUILD_ENV" == "PROD-TEST" ]; then
    node ./scripts/codemagic-ci/set-env.js PROD
    sh ./scripts/codemagic-ci/verify-env.sh PROD
    node ./scripts/codemagic-ci/set-env.js PROD-TEST
    sh ./scripts/codemagic-ci/verify-env.sh PROD-TEST
elif [ "$BUILD_ENV" == "QA" ]; then
    node ./scripts/codemagic-ci/set-env.js QA
    sh ./scripts/codemagic-ci/verify-env.sh QA
else
    echo "Error: BUILD_ENV not found, exiting."
    echo "End: post-clone.sh"
    exit 1
fi

echo "End: post-clone.sh"
