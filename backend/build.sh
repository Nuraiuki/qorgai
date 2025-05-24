#!/usr/bin/env bash
# exit on error
set -o errexit

# Install system dependencies
apt-get update
apt-get install -y postgresql-client libpq-dev

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install psycopg2-binary

# Run database migrations
flask db upgrade 