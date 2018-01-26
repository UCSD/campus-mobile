ORG=ucsd
APP=Campus-Mobile-App

build_url=https://appcenter.ms/users/a6wu/apps/Campus-Mobile-App


if [ -z "$APPCENTER_XCODE_PROJECT" ]; then
    build_link="<$build_url|$APP $APPCENTER_BRANCH Android #$APPCENTER_BUILD_ID>"
else
    build_link="<$build_url|$APP $APPCENTER_BRANCH iOS #$APPCENTER_BUILD_ID>"
fi


version() {
    cat package.json | jq -r .version
}

slack_notify() {
    local message
    local "${@}"

    curl -X POST --data-urlencode \
        "payload={
            \"channel\": \"#campus-mobile-ci\",
            \"username\": \"App Center\",
            \"text\": \"$message\"
        }" \
        $SLACK_WEBHOOK
}

slack_notify_build_passed() {
    slack_notify message="✓ $build_link built"
}

slack_notify_build_failed() {
    slack_notify message="💥 $build_link build failed"
}

slack_notify_deployed() {
    slack_notify message="✓ <$build_url|$APP v`version`> released to npm"
}