#!/bin/sh
set -ex
echo "Start: post-publish.sh"
cd ./scripts/codemagic-ci
npm i
node ./build-notifier.js $FCI_PROJECT_ID $FCI_BUILD_ID $APP_VERSION $PROJECT_BUILD_NUMBER $BUILD_ENV $WEBHOOK_URL "$FCI_ARTIFACT_LINKS" $FCI_BRANCH $FCI_COMMIT $FCI_PULL_REQUEST_NUMBER
echo "End: post-publish.sh"
