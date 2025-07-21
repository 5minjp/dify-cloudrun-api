#!/usr/bin/env python3
"""
Celery application wrapper for Dify
This script imports the proper Celery app instance from Dify's app.py
"""

import os
import sys

# Add the current directory to Python path
sys.path.insert(0, '/app/api')

# Set required environment variables
os.environ.setdefault('FLASK_APP', 'app.py')

try:
    # Import the main app module which contains the celery instance
    import app
    
    # The celery app should be available as app.celery
    celery = app.celery
    
    print("Successfully imported Celery app from app.py")
    print(f"Celery app: {celery}")
    print(f"Celery app type: {type(celery)}")
    
    # Make sure we have the right attributes
    if hasattr(celery, 'user_options'):
        print(" Celery app has user_options attribute")
    else:
        print(" Celery app missing user_options attribute")
        # Add the missing attribute if needed
        celery.user_options = {}
    
except Exception as e:
    print(f"Error importing Celery app: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

if __name__ == '__main__':
    print("Celery app wrapper is ready")
    print(f"Celery broker: {celery.conf.broker_url}")
