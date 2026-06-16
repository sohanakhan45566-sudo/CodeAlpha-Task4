# =====================================
# Stage 1: Build Stage (optimized)
# =====================================
FROM alpine:3.19 AS builder

# Install nginx
RUN apk add --no-cache \
    nginx \
    nginx-mod-stream \
    curl

# Create necessary directories
RUN mkdir -p /var/www/html \
    /run/nginx \
    /var/log/nginx \
    /var/cache/nginx

# Copy static files
COPY src/ /var/www/html/

# =====================================
# Stage 2: Production Stage (final image)
# =====================================
FROM alpine:3.19

# Install nginx and dependencies
RUN apk add --no-cache \
    nginx \
    nginx-mod-stream \
    curl \
    tini \
    && rm -rf /var/cache/apk/*

# Create non-root user for security
RUN adduser -D -g '' -s /bin/sh nginxuser \
    && chown -R nginxuser:nginxuser /var/lib/nginx \
    && chown -R nginxuser:nginxuser /var/log/nginx \
    && chown -R nginxuser:nginxuser /var/cache/nginx \
    && chown -R nginxuser:nginxuser /run

# Copy static files from builder stage
COPY --from=builder --chown=nginxuser:nginxuser /var/www/html /var/www/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Copy health check script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER nginxuser

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh || exit 1

# Use tini as init to handle signals properly
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Default command
CMD ["nginx", "-g", "daemon off;"]
