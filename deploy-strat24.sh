#!/bin/sh
# Strat24 Custom Dashboard Deployment Script
# Run this on your GL.iNet router

echo "🚀 Deploying Strat24 Custom Dashboard..."

# Create directories
mkdir -p /www/strat24 /www/cgi-bin /etc/wireguard

# Deploy custom dashboard HTML
cat > /www/strat24/index.html << 'EOF'
