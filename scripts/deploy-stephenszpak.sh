#!/bin/bash

# Complete deployment script for www.stephenszpak.com
set -e

echo "🚀 Deploying Stephen Szpak's Portfolio to www.stephenszpak.com"
echo "=================================================="

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

# Step 1: Create the application
echo "📱 Creating Fly.io application..."
if ! fly apps list | grep -q "szpak-portfolio"; then
    fly apps create szpak-portfolio --org personal
    echo "✅ Application created successfully"
else
    echo "ℹ️  Application already exists"
fi

# Step 2: Create PostgreSQL database
echo "🗄️  Creating PostgreSQL database..."
if ! fly postgres list | grep -q "szpak-portfolio-db"; then
    fly postgres create --name szpak-portfolio-db --region ord --vm-size shared-cpu-1x --volume-size 3
    echo "✅ Database created successfully"
else
    echo "ℹ️  Database already exists"
fi

# Step 3: Attach database to application
echo "🔗 Attaching database to application..."
fly postgres attach szpak-portfolio-db --app szpak-portfolio

# Step 4: Set up environment secrets
echo "🔐 Setting up environment secrets..."

# Generate SECRET_KEY_BASE if not already set
if ! fly secrets list --app szpak-portfolio | grep -q SECRET_KEY_BASE; then
    echo "🔑 Generating SECRET_KEY_BASE..."
    SECRET_KEY=$(openssl rand -base64 48)
    fly secrets set SECRET_KEY_BASE="$SECRET_KEY" --app szpak-portfolio
fi

# Set PHX_HOST
fly secrets set PHX_HOST="www.stephenszpak.com" --app szpak-portfolio

# Set contact email
fly secrets set CONTACT_EMAIL="stephen@stephenszpak.com" --app szpak-portfolio

# Prompt for OpenAI API key if needed
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
fi

# Step 5: Deploy the application
echo "📦 Deploying application..."
fly deploy --app szpak-portfolio

# Step 6: Configure custom domain
echo "🌐 Setting up custom domain..."

# Check for www.stephenszpak.com certificate
if ! fly certs list --app szpak-portfolio | grep -q "www.stephenszpak.com"; then
    fly certs create www.stephenszpak.com --app szpak-portfolio
    echo "✅ Created certificate for www.stephenszpak.com"
else
    echo "ℹ️  Certificate for www.stephenszpak.com already exists"
fi

# Check for root domain certificate (exact match for stephenszpak.com without www)
if ! fly certs list --app szpak-portfolio | awk '{print $1}' | grep -x "stephenszpak.com"; then
    fly certs create stephenszpak.com --app szpak-portfolio  
    echo "✅ Created certificate for stephenszpak.com"
else
    echo "ℹ️  Certificate for stephenszpak.com already exists"
fi

# Step 7: Get deployment info
echo ""
echo "✅ Deployment completed successfully!"
echo "=================================================="
echo "🌐 Your portfolio is being deployed to:"
echo "   • https://www.stephenszpak.com"
echo "   • https://stephenszpak.com"
echo "   • https://szpak-portfolio.fly.dev (fallback)"
echo ""
echo "📋 Next Steps:"
echo "1. Configure your DNS records:"
echo "   • A record: stephenszpak.com → $(fly ips list --app szpak-portfolio | grep -E '^v4' | awk '{print $2}')"
echo "   • CNAME record: www.stephenszpak.com → stephenszpak.com"
echo ""
echo "2. Check certificate status:"
echo "   fly certs show www.stephenszpak.com --app szpak-portfolio"
echo ""
echo "3. Monitor deployment:"
echo "   fly logs --app szpak-portfolio"
echo "   fly status --app szpak-portfolio"
echo ""
echo "🎉 Your AI-powered portfolio is ready to showcase your expertise!"