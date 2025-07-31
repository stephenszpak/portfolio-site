#!/bin/bash

# Test script for Docker setup
set -e

echo "🧪 Testing Docker setup..."

# Check if containers are running
echo "📦 Checking if containers are running..."
if ! docker-compose ps | grep -q "szpak_portfolio_web.*Up"; then
  echo "❌ Web container is not running"
  exit 1
fi

if ! docker-compose ps | grep -q "szpak_portfolio_db.*Up"; then
  echo "❌ Database container is not running"
  exit 1
fi

echo "✅ Containers are running"

# Test database connection
echo "🗄️ Testing database connection..."
if ! docker-compose exec -T db pg_isready -U postgres; then
  echo "❌ Database connection failed"
  exit 1
fi

echo "✅ Database is accessible"

# Test web application
echo "🌐 Testing web application..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000)
if [ "$HTTP_CODE" != "200" ]; then
  echo "❌ Web application returned HTTP $HTTP_CODE"
  exit 1
fi

echo "✅ Web application is responding"

# Test different routes
echo "🔗 Testing application routes..."
ROUTES=("/" "/about" "/projects" "/technologies" "/contact" "/assistant")

for route in "${ROUTES[@]}"; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4000$route")
  if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Route $route returned HTTP $HTTP_CODE"
    exit 1
  fi
  echo "✅ Route $route is working"
done

echo ""
echo "🎉 All tests passed! Docker setup is working correctly."
echo "📋 Summary:"
echo "   • PostgreSQL database: ✅ Running"
echo "   • Phoenix application: ✅ Running"
echo "   • All routes: ✅ Accessible"
echo "   • Application URL: http://localhost:4000"