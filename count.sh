#!/bin/bash
# Get current number of guest accounts

source .env

curl -s -m 10 $UPLOAD_URL/count -H "x-auth: $NITTER_GUESTS_AUTH"
