#!/bin/bash
set -e

# Change to the backend directory
cd backend

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install psycopg2-binary

# Set environment variables
export FLASK_APP=app.py
export FLASK_ENV=production
export PYTHONPATH=$PYTHONPATH:$(pwd)

# Run database migrations
flask db upgrade

echo "Build completed successfully" 