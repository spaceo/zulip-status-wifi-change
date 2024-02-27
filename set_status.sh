#!/bin/bash

source "$(dirname "$0")/.env"

# Set variables.
if [ -z ${ZULIP_USERNAME+x} ]; then echo "ZULIP_USERNAME is unset" && exit 1; fi
if [ -z ${ZULIP_API_KEY+x} ]; then echo "ZULIP_API_KEY is unset" && exit 1; fi
if [ -z ${ZULIP_DOMAIN+x} ]; then echo "ZULIP_DOMAIN is unset" && exit 1; fi
if [ -z ${SSID_HOME+x} ]; then echo "SSID_HOME is unset" && exit 1; fi
if [ -z ${SSID_OFFICE+x} ]; then echo "SSID_OFFICE is unset" && exit 1; fi


SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
SSID=$(echo -e "$SSID" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
TIMESTAMP=$(date '+%d-%m-%Y %H:%M:%S')
CURRENT_DAY=$(date '+%A')
LAST_STATUS=`head -n 1 /tmp/zulip_status 2> /dev/null`;
LAST_STATUS=${LAST_STATUS:=none}

echo "$TIMESTAMP"

if [[ "$CURRENT_DAY" == "Saturday"  ||  "$CURRENT_DAY" == "Sunday" ]]; then
    if [ "$LAST_STATUS" == "weekend" ]; then exit 0; fi

    echo "Setting Zulip status to weekend time";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode "status_text=✨ Weekend Timez ✨" \
    --data-urlencode away=true \
    --data-urlencode emoji_name=cocktail \
    --data-urlencode reaction_type=unicode_emoji
    echo "weekend" > /tmp/zulip_status
    echo "---------------------------"
    exit 0
fi


if [ "$SSID" == "$SSID_HOME" ]; then
    if [ "$LAST_STATUS" == "home" ]; then exit 0; fi

    echo "Setting Zulip status to: Arbejder hjemmefra";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=Arbejder hjemmefra' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=house \
    --data-urlencode reaction_type=unicode_emoji

    echo "home" > /tmp/zulip_status
elif [ "$SSID" == "$SSID_OFFICE" ]; then
    if [ "$LAST_STATUS" == "office" ]; then exit 0; fi

    echo "Setting Zulip status to: På Suomisvej";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=På Suomisvej' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=office \
    --data-urlencode reaction_type=unicode_emoji

    echo "office" > /tmp/zulip_status
else
    if [ "$LAST_STATUS" == "remote" ]; then exit 0; fi

    echo "Setting Zulip status to: Arbejder remote";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=Arbejder remote' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=house \
    --data-urlencode reaction_type=unicode_emoji

    echo "remote" > /tmp/zulip_status
fi

echo "---------------------------"
