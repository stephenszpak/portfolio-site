#!/bin/bash
set -e

# Wait for database
until pg_isready -h db -p 5432 -U postgres; do
  echo "Waiting for database..."
  sleep 2
done

# Update dependencies to fix any lock issues
mix deps.get

# Create database if it doesn't exist
mix ecto.create

# Run migrations
mix ecto.migrate

# Start Phoenix server
exec mix phx.server