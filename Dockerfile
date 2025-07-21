# Use the official Dify API image as the base
FROM langgenius/dify-api:0.6.16

# Set the working directory
WORKDIR /app/api

# Copy health check script
COPY health_check.py /app/api/health_check.py

# Copy custom entrypoint script
COPY debug_entrypoint.sh /app/api/debug_entrypoint.sh

# Fix line endings and set executable permission
RUN sed -i 's/\r$//' /app/api/debug_entrypoint.sh && chmod +x /app/api/debug_entrypoint.sh

# Set custom entrypoint
ENTRYPOINT ["/app/api/debug_entrypoint.sh"]
