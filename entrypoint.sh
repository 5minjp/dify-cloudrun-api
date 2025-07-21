#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Start health check server in the background
echo "Starting health check server on port 5000..."
export FLASK_APP=health_check:app
flask run --host=0.0.0.0 --port=5000 &

# Wait a bit for the health server to start
sleep 5

# Execute the Celery worker directly, bypassing the faulty base entrypoint
echo "Starting Celery worker directly..."
celery -A app.celery_app worker -l INFO
