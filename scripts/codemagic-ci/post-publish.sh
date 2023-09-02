#!/bin/sh
set -e
echo "Start: post-publish.sh"
cd ./scripts/codemagic-ci
npm i

ENV_VARS=$( jq -n \
                  --arg fciBuildStepStatus "$FCI_BUILD_STEP_STATUS" \
                  --arg fciProjectId "$FCI_PROJECT_ID" \
                  --arg fciBuildId "$FCI_BUILD_ID" \
                  --arg appVersion "$APP_VERSION" \
                  --arg buildPlatform "$BUILD_PLATFORM" \
                  --arg buildNumber "$PROJECT_BUILD_NUMBER" \
                  --arg buildEnv "$BUILD_ENV" \
                  --argjson fciArtifactLinks "$FCI_ARTIFACT_LINKS" \
                  --arg buildBranch "$FCI_BRANCH" \
                  --arg commitHash "$FCI_COMMIT" \
                  --arg prNumber "$FCI_PULL_REQUEST_NUMBER" \
                  '{fciBuildStepStatus: $fciBuildStepStatus, fciProjectId: $fciProjectId, fciBuildId: $fciBuildId, appVersion: $appVersion, buildPlatform: $buildPlatform, buildNumber: $buildNumber, buildEnv: $buildEnv, fciArtifactLinks: $fciArtifactLinks, buildBranch: $buildBranch, commitHash: $commitHash, prNumber: $prNumber}' )

echo "Writing env-vars.json from \$ENV_VARS ..."
echo $ENV_VARS > env-vars.json

echo "Find build artifacts"
dsymPath=$(find $CM_BUILD_DIR/build/ios/archive/Runner.xcarchive -name "*.dSYM" | head -1)
if [[ -z ${dsymPath} ]]
then
  echo "No debug symbols were found, skip publishing to Firebase Crashlytics"
else
  echo "Publishing debug symbols from $dsymPath to Firebase Crashlytics"
  ls -d -- ios/Pods/*
  $CM_BUILD_DIR/ios/Pods/FirebaseCrashlytics/upload-symbols \
    -gsp ios/Runner/GoogleService-Info.plist -p ios $dsymPath
fi

node ./build-notifier.js
echo "End: post-publish.sh"
