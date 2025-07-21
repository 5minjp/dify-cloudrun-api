# Use the official Dify API image as the base
FROM langgenius/dify-api:1.6.0

# カスタムのentrypoint.shを追加
COPY entrypoint.sh /entrypoint.sh

# エントリーポイントスクリプトに実行権限を付与
RUN chmod +x /entrypoint.sh

# 新しいエントリーポイントを設定
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]