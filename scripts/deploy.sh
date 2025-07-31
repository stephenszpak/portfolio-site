#!/bin/bash

# Deploy script for Fly.io
set -e

echo "🚀 Starting deployment to Fly.io..."

# Generate a new secret key if not set
if ! fly secrets list | grep -q SECRET_KEY_BASE; then
  echo "🔐 Generating SECRET_KEY_BASE..."
  SECRET_KEY=$(openssl rand -base64 48)
  fly secrets set SECRET_KEY_BASE="$SECRET_KEY"
fi

# Deploy the application
echo "📦 Deploying application..."
fly deploy

# Show the deployment status
echo "✅ Deployment completed!"
echo "🌐 Your application should be available at: https://$(fly info --name szpak-portfolio | grep Hostname | awk '{print $2}')"