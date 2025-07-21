# ベースイメージとしてDocker Hubからイメージをプル
FROM langgenius/dify-api:latest

# 環境変数を設定（公式Dockerfileに合わせて）
ENV FLASK_APP=app.py
ENV EDITION=SELF_HOSTED
ENV DEPLOY_ENV=PRODUCTION
ENV PYTHONPATH=/app/api

# ワーキングディレクトリを設定
WORKDIR /app/api

# カスタムのentrypoint.shとcelery_app.pyを追加
COPY entrypoint.sh /entrypoint.sh
COPY celery_app.py /app/api/celery_app.py

# エントリーポイントスクリプトに実行権限を付与
RUN chmod +x /entrypoint.sh

# 新しいエントリーポイントを設定
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]