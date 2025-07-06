# --- Stage 1: Build Stage ---
# Use a Node.js base image with build tools
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Install n8n globally (or as a project dependency if you have custom code)
# Using a specific version is recommended for stability
ARG N8N_VERSION=1.39.1 # You can change this to the desired n8n version
RUN npm install -g n8n@${N8N_VERSION}

# If you have custom n8n nodes or extensions, copy them here
# COPY ./custom-nodes /app/custom-nodes
# RUN npm install --prefix /app/custom-nodes

# --- Stage 2: Production Stage ---
# Use a minimal base image for the final runtime
FROM alpine:3.19

# Install necessary runtime dependencies (e.g., for n8n's internal browser, if used)
# For a basic n8n setup, often curl and ca-certificates are sufficient.
# If you use nodes that require specific system libraries (e.g., image processing),
# you might need to add them here.
RUN apk add --no-cache curl ca-certificates

# Set working directory
WORKDIR /usr/local/bin/n8n

# Copy n8n installation from the build stage
COPY --from=build /usr/local/lib/node_modules/n8n ./node_modules/n8n
COPY --from=build /usr/local/bin/n8n /usr/local/bin/n8n

# Expose the port n8n listens on (default 5678)
# Railway will map this to 8080 externally
EXPOSE 5678

# Set environment variables for n8n
# N8N_HOST and N8N_PROTOCOL will be set by Railway environment variables
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https

# Command to run n8n
# Use 'n8n start' for production environments
CMD ["n8n", "start"]
