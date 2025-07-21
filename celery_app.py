#!/usr/bin/env python3
"""
Celery application wrapper for Dify
This script creates a Celery app instance that can be used with celery -A celery_app
"""

import os
import sys

# Add the current directory to Python path
sys.path.insert(0, '/app/api')

try:
    # Import the Flask app
    from app import app, celery
    
    # Make celery available at module level
    __all__ = ['celery']
    
    print("Successfully imported Celery app from app.py")
    
except ImportError as e:
    print(f"Failed to import from app.py: {e}")
    
    # Fallback: try to create celery app directly
    try:
        from app_factory import create_app
        
        app = create_app()
        celery = app.extensions.get('celery')
        
        if celery is None:
            raise RuntimeError("Celery extension not found in app.extensions")
            
        print("Successfully created Celery app from app_factory")
        
    except Exception as e2:
        print(f"Failed to create app from app_factory: {e2}")
        sys.exit(1)

if __name__ == '__main__':
    print("Celery app is ready")
    print(f"Celery app: {celery}")
    print(f"Celery broker: {celery.conf.broker_url}")
