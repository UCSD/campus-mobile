#!/usr/bin/env bash
echo "#### appcenter-post-clone START ####"
set -ex

# Insert environment variables
if [ "$BUILD_ENV" == "PROD" ];
then
    npm run campus-prod-ci
else
    npm run campus-qa-ci
fi

echo "#### appcenter-post-clone END ####"
