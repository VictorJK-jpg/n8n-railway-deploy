# Define N8N_VERSION globally so it can be used in both FROM instructions
# We'll still use this for the build stage if you have custom nodes,
# but the production stage will use latest-alpine for robustness.
ARG N8N_VERSION=1.39.1

# --- Stage 1: Build Stage (Optional, if you have custom nodes) ---
# We'll keep this stage for now, but it might become unnecessary if you don't have custom code.
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Install n8n as a local dependency (still useful for getting the exact version's files)
RUN npm install n8n@${N8N_VERSION} --production --unsafe-perm --omit=dev --legacy-peer-deps

# --- Stage 2: Production Stage (Using Official n8n Image as Base) ---
# Start from the official n8n image, which has n8n correctly installed and configured
# Using 'latest-alpine' for robustness, as specific patch versions might not have -alpine tags
FROM n8nio/n8n:latest-alpine

# Set the user to root temporarily to install additional packages if needed
USER root

# Install necessary runtime dependencies (if any, for example, git if you use git nodes)
# This is where you'd add any system dependencies your specific workflows might need
# RUN apk add --no-cache git

# Revert to the n8n user for security
USER node

# Set environment variables for n8n
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV N8N_BIND_ADDRESS=0.0.0.0
ENV N8N_HOST=https://n8n-railway-deploy-production-bdfc.up.railway.app/
# Expose the port n8n listens on
EXPOSE 5678

# The CMD is already set correctly in the official n8n image, so we don't need to override it
# CMD ["n8n", "start"] # This is typically what the official image uses
