#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Activate the virtual environment
source /app/api/.venv/bin/activate

echo "=== DEBUG: Investigating container structure ==="
echo "Current directory: $(pwd)"
echo "Contents of /app:"
ls -la /app/
echo ""
echo "Contents of /app/api:"
ls -la /app/api/
echo ""
echo "Searching for Python files containing 'celery':"
find /app -name "*.py" -type f -exec grep -l "celery" {} \; 2>/dev/null || echo "No Python files with 'celery' found"
echo ""
echo "Searching for files named '*celery*':"
find /app -name "*celery*" -type f 2>/dev/null || echo "No files with 'celery' in name found"
echo ""
echo "Contents of Python site-packages:"
python -c "import sys; print('\n'.join(sys.path))"
echo ""
echo "Trying to import various celery modules:"
python -c "
try:
    import celery_app
    print('SUCCESS: celery_app module found')
except ImportError as e:
    print(f'FAILED: celery_app - {e}')

try:
    import app.celery_app
    print('SUCCESS: app.celery_app module found')
except ImportError as e:
    print(f'FAILED: app.celery_app - {e}')

try:
    from app import celery_app
    print('SUCCESS: from app import celery_app')
except ImportError as e:
    print(f'FAILED: from app import celery_app - {e}')
"

# Start health check server in the background
echo "Starting health check server on port 5000..."
export FLASK_APP=health_check:app
flask run --host=0.0.0.0 --port=5000 &

# Keep container running for investigation
echo "Container will stay running for investigation..."
sleep 3600
