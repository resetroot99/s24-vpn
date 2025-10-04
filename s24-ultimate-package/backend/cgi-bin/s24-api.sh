#!/bin/sh
# S24 VPN Router - Unified API Handler
# This script routes all API requests to the appropriate handlers

# Enable CGI mode
echo "Content-Type: application/json"
echo ""

# Parse query string
QUERY_STRING="${QUERY_STRING}"
REQUEST_METHOD="${REQUEST_METHOD:-GET}"

# Get action from path
ACTION=$(echo "$QUERY_STRING" | sed 's/.*action=\([^&]*\).*/\1/')

# Route to appropriate handler based on path
case "$PATH_INFO" in
    /vpn-control)
        /usr/bin/s24-vpn-control "$@"
        ;;
    /devices)
        /usr/bin/s24-devices "$@"
        ;;
    /device-control)
        /usr/bin/s24-device-control "$@"
        ;;
    /wifi-settings)
        /usr/bin/s24-wifi "$@"
        ;;
    /guest-wifi)
        /usr/bin/s24-guest-wifi "$@"
        ;;
    /killswitch)
        /usr/bin/s24-killswitch "$@"
        ;;
    /privacy-mode)
        /usr/bin/s24-privacy-mode "$@"
        ;;
    /firewall)
        /usr/bin/s24-firewall "$@"
        ;;
    /change-password)
        /usr/bin/s24-change-password "$@"
        ;;
    /router-settings)
        /usr/bin/s24-router-settings "$@"
        ;;
    /system)
        /usr/bin/s24-system "$@"
        ;;
    /status)
        /usr/bin/s24-status "$@"
        ;;
    /stats)
        /usr/bin/s24-stats "$@"
        ;;
    *)
        echo '{"error":"Unknown endpoint","path":"'"$PATH_INFO"'"}'
        ;;
esac

