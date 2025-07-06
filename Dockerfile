# --- Stage 1: Build Stage ---
# Use a Node.js base image with build tools
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if you had them, though n8n is global)
# This step is more common for custom Node.js apps, but good practice if you ever add custom nodes
# COPY package*.json ./

# Install n8n globally. This creates the necessary structure for copying.
ARG N8N_VERSION=1.39.1
RUN npm install -g n8n@${N8N_VERSION}

# --- Stage 2: Production Stage ---
# Use a minimal base image for the final runtime
FROM alpine:3.19

# Install necessary runtime dependencies and Node.js
# We need nodejs and npm to run n8n and install its dependencies
RUN apk add --no-cache curl ca-certificates nodejs npm

# Set working directory for n8n
WORKDIR /usr/local/lib/node_modules/n8n

# --- NEW COPY AND INSTALL STRATEGY ---
# Copy the n8n package content from the build stage
# This ensures all its files, including package.json, are present
COPY --from=build /usr/local/lib/node_modules/n8n .

# Install n8n's production dependencies within this stage
# This ensures all required modules like 'semver' are correctly placed
RUN npm install --production --unsafe-perm --omit=dev

# Copy the n8n executable (symlink) to the standard bin path
COPY --from=build /usr/local/bin/n8n /usr/local/bin/n8n

# Set the PATH to include global npm binaries
ENV PATH="/usr/local/bin:${PATH}"

# Expose the port n8n listens on (default 5678)
EXPOSE 5678

# Set environment variables for n8n
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https

# Command to run n8n
CMD ["n8n", "start"]
