#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Start health check server in the background
echo "Starting health check server on port 5000..."
export FLASK_APP=health_check:app
flask run --host=0.0.0.0 --port=5000 &

# Wait a bit for the health server to start
sleep 3

# Execute the original entrypoint command to start the main application (Celery worker)
echo "Starting main application (Celery worker)..."
exec /app/api/entrypoint-unit.sh
