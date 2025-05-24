#!/bin/bash
set -e

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install psycopg2-binary

# Set environment variables
export FLASK_APP=app
export FLASK_ENV=production

# Run database migrations
flask db upgrade

echo "Build completed successfully" 