#!/usr/bin/env bash

# Install our version of Node
set -ex
brew uninstall node@6
NODE_VERSION="9.4.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"

# Insert production values
npm run-script insert-production-values-ci
