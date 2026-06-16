#!/bin/sh
set -e

echo "🚀 Starting CodeAlpha Task 4 - Docker Web Server"

# Validate nginx configuration
echo "🔍 Validating nginx configuration..."
nginx -t

# Start nginx
echo "🌐 Starting nginx..."
exec "$@"
