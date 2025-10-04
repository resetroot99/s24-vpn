#!/bin/sh
echo "Content-Type: application/json"
echo ""

SERVER=$(echo "$QUERY_STRING" | sed -n 's/^.*server=\([^&]*\).*$/\1/p')

if [ -z "$SERVER" ]; then
    echo '{"success":false,"message":"No server specified"}'
    exit 1
fi

OUTPUT=$(/usr/bin/strat24-vpn-switch "$SERVER" 2>&1)

if [ $? -eq 0 ]; then
    echo "{\"success\":true,\"server\":\"$SERVER\"}"
else
    echo "{\"success\":false,\"message\":\"Failed\"}"
fi

