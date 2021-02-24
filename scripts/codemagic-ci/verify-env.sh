#!/bin/sh
set -ex

if [ "$1" == "PROD" ]; then
	qa_slash=$(grep -rio "https.*\/qa" lib | wc -l | sed -e "s/^[ \t]*//")
	qa_dash=$(grep -rio "https.*-qa" lib | wc -l | sed -e "s/^[ \t]*//")
	dev_slash=$(grep -rio "https.*\/dev" lib | wc -l | sed -e "s/^[ \t]*//")
	dev_dash=$(grep -rio "https.*-dev" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_android=$(grep -rio "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_ios=$(grep -rio "SCANDIT_NATIVE_LICENSE_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_android1=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_android2=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" android | wc -l | sed -e "s/^[ \t]*//")
	maps_ios1=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_ios2=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" ios | wc -l | sed -e "s/^[ \t]*//")

	invalid_count=$((qa_slash + qa_dash + dev_slash + dev_dash + scandit_android + scandit_ios + maps_android1 + maps_android2 + maps_ios1 + maps_ios2))

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
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" lib
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" ios
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" lib
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" android
	fi
elif [ "$1" == "PROD-TEST" ]; then
	topics=$(grep -rio "https.*prod/topics.json" lib | wc -l | sed -e "s/^[ \t]*//")
	freefood=$(grep -rio "\"freeFood\"" lib | wc -l | sed -e "s/^[ \t]*//")

	invalid_count=$((topics + freefood))

	if [ "$invalid_count" -eq 0 ]; then
		echo "\nset-env-prod-test: PASS"
	else
		echo "\nset-env-prod-test: FAIL (erors: ${invalid_count})"
		grep -rin "https.*prod/topics.json" lib
		grep -rin "\"freeFood\"" lib
	fi
elif [ "$1" == "QA" ]; then
	prod_slash=$(grep -rio "https.*\/prod" lib | wc -l | sed -e "s/^[ \t]*//")
	prod_dash=$(grep -rio "https.*-prod" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_android=$(grep -rio "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	scandit_ios=$(grep -rio "SCANDIT_NATIVE_LICENSE_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_android1=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_android2=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" android | wc -l | sed -e "s/^[ \t]*//")
	maps_ios1=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" lib | wc -l | sed -e "s/^[ \t]*//")
	maps_ios2=$(grep -rio "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" ios | wc -l | sed -e "s/^[ \t]*//")

	invalid_count=$((prod_slash + prod_dash + scandit_android + scandit_ios + maps_android1 + maps_android2 + maps_ios1 + maps_ios2))

	if [ "$invalid_count" -eq 0 ]; then
		echo "\nset-env-qa: PASS"
	else
		echo "\nset-env-qa: FAIL (erors: ${invalid_count})"
		grep -rin "https.*\/prod" lib
		grep -rin "https.*-prod" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_IOS_PH" lib
		grep -rin "SCANDIT_NATIVE_LICENSE_ANDROID_PH" lib
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" lib
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_IOS_PH" ios
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" lib
		grep -rin "CAMPUS_MOBILE_MAPS_KEY_ANDROID_PH" android

	fi
else
	echo "Error: verify-env.sh: Environment not specified (PROD|PROD-TEST|QA)"
	exit 1
fi
