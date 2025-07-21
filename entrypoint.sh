#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Activate the virtual environment to make commands like 'flask' and 'celery' available
source /app/api/.venv/bin/activate

# Start health check server in the background
echo "Starting health check server on port 5000..."
export FLASK_APP=health_check:app
flask run --host=0.0.0.0 --port=5000 &

# Wait a bit for the health server to start
sleep 5

# Change to the correct directory and execute the Celery worker
echo "Starting Celery worker from /app/api..."
cd /app/api
celery -A celery_app worker -l INFO
