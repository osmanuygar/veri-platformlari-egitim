# MinIO Client Dockerfile
FROM python:3.11-slim

LABEL authors="osmanuygar.kose"

LABEL description="MinIO Client with Parquet and Iceberg support"

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy scripts
COPY scripts/ /app/scripts/
COPY sample-data/ /app/sample-data/

# Default command
CMD ["python", "scripts/upload_data.py"]