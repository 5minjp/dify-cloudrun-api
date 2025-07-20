#!/bin/bash
set -e

# Start a simple web server for health checks on port 5000
if [ "$MODE" = "worker" ]; then
  echo "Starting health check server..."
  gunicorn --bind 0.0.0.0:5000 --workers 1 --threads 1 --timeout 300 health_check:app &
fi

# Execute the original entrypoint logic from the base image
# This will start the API server or Celery worker based on the MODE
echo "Executing original entrypoint..."
/entrypoint.sh
