#!/bin/bash

prefFile="/home/user/.apps/plex/Library/Application Support/Plex Media Server/Preferences.xml"

echo "Please go to https://plex.tv/claim in order to obtain a new claim-code, then type it below \n"
echo -n "Claim Code:"

read PLEX_CLAIM

clientId=`cat "${prefFile}" | sed -n 's/.*ProcessedMachineIdentifier="\(\S*\)".*/\1/p'`

loginInfo="$(curl -X POST \
        -H 'X-Plex-Client-Identifier: '${clientId} \
        -H 'X-Plex-Product: Plex Media Server'\
        -H 'X-Plex-Version: 1.1' \
        -H 'X-Plex-Provides: server' \
        -H 'X-Plex-Platform: Linux' \
        -H 'X-Plex-Platform-Version: 1.0' \
        -H 'X-Plex-Device-Name: PlexMediaServer' \
        -H 'X-Plex-Device: Linux' \
        "https://plex.tv/api/claim/exchange?token=${PLEX_CLAIM}")"
  token="$(echo "$loginInfo" | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')"

if [ "$token" ]; then
  echo "Token obtained successfully"
  sed -i "s|PlexOnlineToken=\"[^\"]*\"|PlexOnlineToken=\"${token}\"|" "${prefFile}"
  echo "Plex claim token installed successfully, please RESTART YOUR PLEX SERVER for the changes to take effect!"
fi