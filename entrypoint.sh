#!/bin/bash

set -e

# デバッグ情報を出力
echo "Current working directory: $(pwd)"
echo "Python path: $PYTHONPATH"
echo "Flask app: $FLASK_APP"
echo "Contents of /app/api:"
ls -la /app/api/ | head -10

# Python環境の確認
echo "Python version: $(python --version)"
echo "Python executable: $(which python)"

# app.pyファイルの存在確認
if [ -f "app.py" ]; then
  echo "app.py exists"
else
  echo "app.py not found"
fi

# celery_app.pyの存在確認
if [ -f "celery_app.py" ]; then
  echo "celery_app.py exists"
  # Test celery app import
  echo "Testing Celery app import:"
  python celery_app.py
else
  echo "celery_app.py not found"
fi

# Start a simple HTTP server for health checks (Cloud Run requirement)
if [[ "${MODE}" == "worker" || "${MODE}" == "beat" ]]; then
  nohup python -m http.server 5000 &
fi

if [[ "${MIGRATION_ENABLED}" == "true" ]]; then
  echo "Running migrations"
  flask upgrade-db
fi

if [[ "${MODE}" == "worker" ]]; then

  # Get the number of available CPU cores
  if [ "${CELERY_AUTO_SCALE,,}" = "true" ]; then
    # Set MAX_WORKERS to the number of available cores if not specified
    AVAILABLE_CORES=$(nproc)
    MAX_WORKERS=${CELERY_MAX_WORKERS:-$AVAILABLE_CORES}
    MIN_WORKERS=${CELERY_MIN_WORKERS:-1}
    CONCURRENCY_OPTION="--autoscale=${MAX_WORKERS},${MIN_WORKERS}"
  else
    CONCURRENCY_OPTION="-c ${CELERY_WORKER_AMOUNT:-1}"
  fi

  echo "Starting Celery worker with command:"
  echo "celery -A celery_app worker -P ${CELERY_WORKER_CLASS:-gevent} $CONCURRENCY_OPTION --max-tasks-per-child ${MAX_TASK_PRE_CHILD:-50} --loglevel ${LOG_LEVEL:-INFO} -Q ${CELERY_QUEUES:-dataset,mail,ops_trace,app_deletion}"
  
  # Use our custom celery_app wrapper
  echo "Attempting to start Celery with custom wrapper..."
  exec celery -A celery_app worker -P ${CELERY_WORKER_CLASS:-gevent} $CONCURRENCY_OPTION \
    --max-tasks-per-child ${MAX_TASK_PRE_CHILD:-50} --loglevel ${LOG_LEVEL:-INFO} \
    -Q ${CELERY_QUEUES:-dataset,mail,ops_trace,app_deletion}

elif [[ "${MODE}" == "beat" ]]; then
  exec celery -A celery_app beat --loglevel ${LOG_LEVEL:-INFO}
else
  if [[ "${DEBUG}" == "true" ]]; then
    exec flask run --host=${DIFY_BIND_ADDRESS:-0.0.0.0} --port=${DIFY_PORT:-5001} --debug
  else
    exec gunicorn \
      --bind "${DIFY_BIND_ADDRESS:-0.0.0.0}:${DIFY_PORT:-5001}" \
      --workers ${SERVER_WORKER_AMOUNT:-1} \
      --worker-class ${SERVER_WORKER_CLASS:-gevent} \
      --worker-connections ${SERVER_WORKER_CONNECTIONS:-10} \
      --timeout ${GUNICORN_TIMEOUT:-200} \
      app:app
  fi
fi