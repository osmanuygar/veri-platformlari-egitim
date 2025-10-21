FROM trinodb/trino:latest

LABEL authors="osmanuygar.kose"
LABEL description="Trino Federated Query Engine for NoSQL Databases"

# Root kullanıcısına geç (yapılandırma için)
USER root

# Gerekli dizinleri oluştur
RUN mkdir -p /etc/trino/catalog \
    && mkdir -p /scripts \
    && chown -R trino:trino /etc/trino \
    && chown -R trino:trino /scripts

# Trino kullanıcısına geri dön
USER trino

# Çalışma dizini
WORKDIR /

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/v1/info || exit 1

# Port expose
EXPOSE 8080

# Varsayılan komut
CMD ["/usr/lib/trino/bin/run-trino"]