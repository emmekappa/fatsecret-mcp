# Multi-stage build for FatSecret MCP Server

# 1) Builder stage
FROM node:20-alpine AS build
WORKDIR /app

# Install build dependencies (if needed) and dumb-init for signal handling
RUN apk add --no-cache dumb-init

# Copy manifests first for better caching
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies (include devDeps for build)
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy sources and build
COPY src ./src
RUN npm run build

# 2) Runtime stage
FROM node:20-alpine AS runtime
WORKDIR /app

# Create non-root user and install dumb-init
RUN addgroup -S app && adduser -S app -G app \
  && apk add --no-cache dumb-init

# Environment
ENV NODE_ENV=production \
    FATSECRET_CONFIG_PATH=/data/.fatsecret-mcp-config.json \
    NODE_OPTIONS="--enable-source-maps"

# Prepare data directory for config persistence
RUN mkdir -p /data && chown -R app:app /data
VOLUME ["/data"]

# Copy only what is needed at runtime
COPY --chown=app:app package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi
COPY --from=build --chown=app:app /app/dist ./dist

# Switch to non-root
USER app

# Entrypoint and command
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "dist/index.js"]

# Healthcheck: consider healthy if node process is running
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD sh -c 'ps | grep -E "[n]ode" >/dev/null' || exit 1
