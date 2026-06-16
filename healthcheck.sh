#!/bin/sh

# Check if nginx is running
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
