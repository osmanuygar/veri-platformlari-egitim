FROM python:3.11-slim
LABEL authors="osmanuygar.kose"
LABEL description="Hafta 1: Veri Dünyasına Giriş - Python Environment"

# Çalışma dizini
WORKDIR /app

# Sistem paketlerini güncelle ve gerekli tool'ları yükle
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    wget \
    vim \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Python paketlerini kopyala
COPY requirements.txt .

# Python bağımlılıklarını yükle
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Jupyter yapılandırması
RUN mkdir -p /root/.jupyter && \
    jupyter notebook --generate-config

# Jupyter token'sız çalışsın (development için)
RUN echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /root/.jupyter/jupyter_notebook_config.py

# Çalışma dizinlerini oluştur
RUN mkdir -p /app/data-samples/structured \
             /app/data-samples/semi-structured \
             /app/data-samples/unstructured \
             /app/scripts \
             /app/notebooks \
             /app/output

# Port expose
EXPOSE 8888

# Jupyter Lab başlat
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--notebook-dir=/app"]