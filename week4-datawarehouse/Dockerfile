FROM python:3.11-slim

LABEL authors="osmanuygar.kose"
LABEL description="ETL Service for Data Warehouse Week 4"

# Çalışma dizini
WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodları
COPY python/ /app/

# Script'leri çalıştırılabilir yap
RUN chmod +x /app/*.py

# Default command
CMD ["python", "full_pipeline.py"]