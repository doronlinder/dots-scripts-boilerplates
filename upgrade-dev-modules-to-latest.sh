#!/bin/bash

DEV_PACKAGES=$(npm ls --dev --depth 0 | grep -oE ' (.*)@' | tr -d ' @')

if [ -z "${DEV_PACKAGES}" ]; then
    >&2 echo 'You do not seem to be in a node module'
    exit 1
fi

if [ ! -f 'package.json' ]; then
    >&2 echo Can not find package.json
    exit 1
fi

function echoLog {
    echo -e "\e[96m${*}\e[0m"
}

echoLog Removing all dev dependencies...
npm uninstall --save-dev $DEV_PACKAGES > /dev/null
echoLog Adding latest versions of dev dependencies...
npm install --save-dev $DEV_PACKAGES > /dev/null
echoLog Done!
