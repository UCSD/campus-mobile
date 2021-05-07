#!/bin/sh
set -e

echo "Running verify-env.sh $1"

if [ "$1" == "PROD" ]; then
	qa_slash=$(grep -rio "https.*\/qa" lib | wc -l | sed -e "s/^[ \t]*//")
	qa_dash=$(grep -rio "https.*-qa" lib | wc -l | sed -e "s/^[ \t]*//")
	dev_slash=$(grep -rio "https.*\/dev" lib | wc -l | sed -e "s/^[ \t]*//")
	dev_dash=$(grep -rio "https.*-dev" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_android=$(grep -rio "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_ios=$(grep -rio "SCANDIT_NATIVE_LICENSE_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	background_android=0

	if [ "$2" == "ANDROID" ]; then
		echo "$2: Background location check"
		background_android=$(grep -rio "ACCESS_BACKGROUND_LOCATION" android | wc -l | sed -e "s/^[ \t]*//")
	fi

	invalid_count=$((qa_slash + qa_dash + dev_slash + dev_dash + scandit_android + scandit_ios + background_android))

	if [ "$invalid_count" -eq 0 ]; then
		echo "\nverify-env.sh PROD: PASS"
	else
		echo "\nset-env-prod: FAIL (erors: ${invalid_count})"
		grep -rin "https.*\/qa" lib
		grep -rin "https.*-qa" lib
		grep -rin "https.*\/dev" lib
		grep -rin "https.*-dev" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_IOS_PH" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib
		if [ "$2" == "ANDROID" ]; then
			grep -rin "ACCESS_BACKGROUND_LOCATION" android
		fi
		exit 1
	fi
elif [ "$1" == "PROD-TEST" ]; then
	topics=$(grep -rio "https.*prod/topics.json" lib | wc -l | sed -e "s/^[ \t]*//")

	invalid_count=$((topics))

	if [ "$invalid_count" -eq 0 ]; then
		echo "\nset-env-prod-test: PASS"
	else
		echo "\nset-env-prod-test: FAIL (erors: ${invalid_count})"
		grep -rin "https.*prod/topics.json" lib
		grep -rin "\"freeFood\"" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_IOS_PH" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib
		exit 1
	fi
elif [ "$1" == "QA" ]; then
	scandit_android=$(grep -rio "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_ios=$(grep -rio "SCANDIT_NATIVE_LICENSE_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	background_android=0

	if [ "$2" == "ANDROID" ]; then
		echo "$2: Background location check"
		background_android=$(grep -rio "ACCESS_BACKGROUND_LOCATION" android | wc -l | sed -e "s/^[ \t]*//")
	fi

	invalid_count=$((scandit_android + scandit_ios + background_android))

	if [ "$invalid_count" -eq 0 ]; then
		echo "\nset-env-qa: PASS"
	else
		echo "\nset-env-qa: FAIL (erors: ${invalid_count})"
		grep -rin "https.*\/prod" lib
		grep -rin "https.*-prod" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_IOS_PH" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib
		if [ "$2" == "ANDROID" ]; then
			grep -rin "ACCESS_BACKGROUND_LOCATION" android
		fi
		exit 1
	fi
else
	echo "Error: verify-env.sh: Environment not specified (PROD|PROD-TEST|QA)"
	exit 1
fi
