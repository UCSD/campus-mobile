#!/usr/bin/env bash

echo "#### appcenter-post-clone START ####"

# Install our version of Node
set -ex
brew uninstall node@6
NODE_VERSION="9.4.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"

# Insert environment variables
if [ "$BUILD_ENV" == "PROD" ];
then
    npm run campus-prod-ci
else
    npm run campus-qa-ci
fi

echo "#### appcenter-post-clone END ####"
