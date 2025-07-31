#!/bin/bash

# Initial Fly.io setup script
set -e

echo "🛠️ Setting up Fly.io application..."

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo "❌ Fly.io CLI is not installed. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! fly auth whoami &> /dev/null; then
    echo "🔐 Please log in to Fly.io first:"
    echo "   fly auth login"
    exit 1
fi

# Launch the app (this will create fly.toml if it doesn't exist)
echo "🚀 Launching Fly.io application..."
fly launch --no-deploy

# Create a PostgreSQL database
echo "🗄️ Creating PostgreSQL database..."
fly postgres create --name szpak-portfolio-db --region ord

# Attach the database
echo "🔗 Attaching database to application..."
fly postgres attach szpak-portfolio-db

echo "✅ Fly.io setup completed!"
echo ""
echo "Next steps:"
echo "1. Run ./scripts/deploy.sh to deploy your application"
echo "2. Your app will be available at: https://szpak-portfolio.fly.dev"