#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Activate the virtual environment to make commands like 'flask' and 'celery' available
source /app/api/.venv/bin/activate

# Set PYTHONPATH to ensure celery_app can be found
export PYTHONPATH=/app/api:$PYTHONPATH

# Start health check server in the background
echo "Starting health check server on port 5000..."
export FLASK_APP=health_check:app
flask run --host=0.0.0.0 --port=5000 &

# Wait a bit for the health server to start
sleep 5

# Execute the Celery worker
echo "Starting Celery worker..."
celery -A celery_app worker -l INFO
