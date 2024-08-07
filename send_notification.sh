#!/bin/bash

# Replace the placeholders with your email settings
EMAIL_TO="lalatendu.swain@gmail.com"
SUBJECT="System Notification: Ubuntu System Turned On"
DATE=$(date)
EXTERNAL_IP=$(curl -s https://ipinfo.io/ip)
GEO_LOCATION=$(curl -s https://ipinfo.io/${EXTERNAL_IP}/json | jq -r '.city + ", " + .region + ", " + .country')

# Body of the email with IP and geolocation information
BODY="Your Ubuntu system has been turned on at $DATE\n\nExternal IP Address: $EXTERNAL_IP\nLocation: $GEO_LOCATION"

# Send the email
echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL_TO"
