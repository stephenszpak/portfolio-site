#!/bin/bash

# Simple redeploy script for existing deployments
set -e

echo "🚀 Redeploying Stephen Szpak's Portfolio"
echo "========================================"

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

# Check/update OpenAI API key if needed
if ! fly secrets list --app szpak-portfolio | grep -q OPENAI_API_KEY; then
    echo "🤖 Setting up AI Assistant..."
    echo "Please enter your OpenAI API Key (or press Enter to skip):"
    read -s OPENAI_KEY
    if [ ! -z "$OPENAI_KEY" ]; then
        fly secrets set OPENAI_API_KEY="$OPENAI_KEY" --app szpak-portfolio
        echo "✅ OpenAI API key configured"
    else
        echo "⚠️  Skipping OpenAI API key - AI Assistant will be disabled"
    fi
else
    echo "ℹ️  OpenAI API key already configured"
fi

# Deploy the application
echo "📦 Deploying application..."
fly deploy --app szpak-portfolio

# Check status
echo "🔍 Checking deployment status..."
fly status --app szpak-portfolio

echo ""
echo "✅ Redeployment completed successfully!"
echo "======================================="
echo "🌐 Your portfolio is available at:"
echo "   • https://www.stephenszpak.com"
echo "   • https://stephenszpak.com"
echo "   • https://szpak-portfolio.fly.dev"
echo ""
echo "🤖 AI Assistant should now be working with your OpenAI API key!"