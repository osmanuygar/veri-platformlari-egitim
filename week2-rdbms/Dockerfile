FROM postgres:15-alpine

LABEL authors="osmanuygar.kose"
LABEL description="Hafta 2: PostgreSQL with sample data and scripts"

# PostgreSQL eklentilerini yükle
RUN apk add --no-cache \
    postgresql-contrib \
    curl \
    bash

# Çalışma dizini
WORKDIR /docker-entrypoint-initdb.d

# Init scriptlerini kopyala (bu scriptler container ilk başladığında otomatik çalışır)
COPY ./postgres/init-scripts/ /docker-entrypoint-initdb.d/

# Backup klasörü oluştur
RUN mkdir -p /backups

# PostgreSQL ayarlarını optimize et (development için)
RUN echo "# Custom PostgreSQL Configuration" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "max_connections = 100" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "shared_buffers = 256MB" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "effective_cache_size = 1GB" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "work_mem = 16MB" >> /usr/local/share/postgresql/postgresql.conf.sample && \
    echo "maintenance_work_mem = 128MB" >> /usr/local/share/postgresql/postgresql.conf.sample

# Port
EXPOSE 5432

# PostgreSQL başlat (base image'dan gelir)
CMD ["postgres"]