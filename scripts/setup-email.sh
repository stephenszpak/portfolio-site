#!/bin/bash

# Email service setup script for contact form
set -e

echo "📧 Setting up Email Service for Contact Form"
echo "============================================"

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

echo ""
echo "Choose your email service provider:"
echo "1. Postmark (recommended for transactional emails)"
echo "2. Mailgun"
echo "3. SendGrid"
echo "4. Generic SMTP"
echo "5. Skip email setup (forms will show success but won't send)"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📮 Setting up Postmark"
        echo "To get your API key:"
        echo "1. Sign up at https://postmarkapp.com"
        echo "2. Create a server and get your Server Token"
        echo ""
        read -p "Enter your Postmark API key: " -s api_key
        if [ ! -z "$api_key" ]; then
            fly secrets set POSTMARK_API_KEY="$api_key" --app szpak-portfolio
            echo "✅ Postmark configured successfully"
        else
            echo "❌ No API key provided"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo "📮 Setting up Mailgun"
        echo "To get your credentials:"
        echo "1. Sign up at https://mailgun.com"
        echo "2. Get your API key from the dashboard"
        echo "3. Note your domain (e.g., sandboxXXX.mailgun.org or your custom domain)"
        echo ""
        read -p "Enter your Mailgun API key: " -s api_key
        read -p "Enter your Mailgun domain: " domain
        if [ ! -z "$api_key" ] && [ ! -z "$domain" ]; then
            fly secrets set MAILGUN_API_KEY="$api_key" MAILGUN_DOMAIN="$domain" --app szpak-portfolio
            echo "✅ Mailgun configured successfully"
        else
            echo "❌ Missing credentials"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "📮 Setting up SendGrid"
        echo "To get your API key:"
        echo "1. Sign up at https://sendgrid.com"
        echo "2. Create an API key in Settings > API Keys"
        echo ""
        read -p "Enter your SendGrid API key: " -s api_key
        if [ ! -z "$api_key" ]; then
            fly secrets set SENDGRID_API_KEY="$api_key" --app szpak-portfolio
            echo "✅ SendGrid configured successfully"
        else
            echo "❌ No API key provided"
            exit 1
        fi
        ;;
    4)
        echo ""
        echo "📮 Setting up Generic SMTP"
        echo "Enter your SMTP server details:"
        echo ""
        read -p "SMTP Host (e.g., smtp.gmail.com): " smtp_host
        read -p "SMTP Port (default 587): " smtp_port
        smtp_port=${smtp_port:-587}
        read -p "SMTP Username: " smtp_username
        read -p "SMTP Password: " -s smtp_password
        
        if [ ! -z "$smtp_host" ] && [ ! -z "$smtp_username" ] && [ ! -z "$smtp_password" ]; then
            fly secrets set SMTP_HOST="$smtp_host" SMTP_PORT="$smtp_port" SMTP_USERNAME="$smtp_username" SMTP_PASSWORD="$smtp_password" --app szpak-portfolio
            echo "✅ SMTP configured successfully"
        else
            echo "❌ Missing SMTP credentials"
            exit 1
        fi
        ;;
    5)
        echo "⚠️  Skipping email setup - contact form will show success but won't send emails"
        echo "You can run this script again later to configure email service"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🚀 Deploying updated configuration..."
fly deploy --app szpak-portfolio

echo ""
echo "✅ Email service setup completed!"
echo "================================="
echo "🌐 Your contact form is now active at:"
echo "   • https://www.stephenszpak.com/contact"
echo ""
echo "📧 Test your contact form to ensure emails are working properly."
echo ""
echo "🔒 Bot Protection Features Enabled:"
echo "   • Rate limiting (3 messages per hour per IP)"
echo "   • Honeypot trap"
echo "   • Content filtering"
echo "   • Form timing validation"
echo "   • Email validation"