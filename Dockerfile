# Use the official Dify API image as the base
FROM langgenius/dify-api:1.6.0

# Set the working directory
WORKDIR /app/api

# Copy the health check script into the container
COPY health_check.py /app/api/health_check.py

# Copy the custom entrypoint script into the container
COPY entrypoint.sh /app/api/entrypoint.sh

# Fix line endings to be UNIX-style (LF)
RUN sed -i 's/\r$//' /app/api/entrypoint.sh

# Make the script executable
RUN chmod +x /app/api/entrypoint.sh

# Set the entrypoint to our custom script
ENTRYPOINT ["/app/api/entrypoint.sh"]
