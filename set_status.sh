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

echo "$TIMESTAMP"

if [[ "$CURRENT_DAY" == "Saturday"  ||  "$CURRENT_DAY" == "Sunday" ]]; then
    echo "Setting Zulip status to weekend time";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode "status_text=✨ Weekend Timez ✨" \
    --data-urlencode away=true \
    --data-urlencode emoji_name=cocktail \
    --data-urlencode reaction_type=unicode_emoji
    echo "---------------------------"
    exit 0
fi


if [ "$SSID" == "$SSID_HOME" ]; then
    echo "Setting Zulip status to: Arbejder hjemmefra";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=Arbejder hjemmefra' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=house \
    --data-urlencode reaction_type=unicode_emoji
elif [ "$SSID" == "$SSID_OFFICE" ]; then
    echo "Setting Zulip status to: På Suomisvej";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=På Suomisvej' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=office \
    --data-urlencode reaction_type=unicode_emoji
else
    echo "Setting Zulip status to: Arbejder remote";
    curl -sSX POST $ZULIP_DOMAIN/api/v1/users/me/status \
    -u $ZULIP_USERNAME:$ZULIP_API_KEY \
    --data-urlencode 'status_text=Arbejder remote' \
    --data-urlencode away=false \
    --data-urlencode emoji_name=house \
    --data-urlencode reaction_type=unicode_emoji
fi

echo "---------------------------"
