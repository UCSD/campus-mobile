#!/usr/bin/env bash -e

cd $APPCENTER_SOURCE_DIRECTORY
source appcenter/slack.sh

if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    slack_notify_build_passed
    exit 0
else
    slack_notify_build_failed
    exit 0
fi