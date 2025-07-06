# --- Stage 1: Build Stage ---
# Use a Node.js base image with build tools
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Install n8n as a local dependency
# This creates a node_modules directory with n8n and its dependencies
ARG N8N_VERSION=1.39.1
RUN npm install n8n@${N8N_VERSION} --production --unsafe-perm --omit=dev --legacy-peer-deps

# --- Stage 2: Production Stage ---
# Use a minimal base image for the final runtime
FROM alpine:3.19

# Install necessary runtime dependencies and Node.js
RUN apk add --no-cache curl ca-certificates nodejs npm

# Set working directory to a standard location for the app
WORKDIR /app

# Copy the node_modules directory from the build stage
COPY --from=build /app/node_modules ./node_modules

# Copy the n8n executable (which is usually in .bin within node_modules)
# This path might vary slightly, but it's common for npm to put executables here
COPY --from=build /app/node_modules/.bin/n8n /usr/local/bin/n8n

# Set the NODE_PATH to ensure Node.js can find modules
ENV NODE_PATH=/app/node_modules

# Set the PATH to include global npm binaries
ENV PATH="/usr/local/bin:${PATH}"

# Expose the port n8n listens on (default 5678)
EXPOSE 5678

# Set environment variables for n8n
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https

# Command to run n8n
CMD ["n8n", "start"]
