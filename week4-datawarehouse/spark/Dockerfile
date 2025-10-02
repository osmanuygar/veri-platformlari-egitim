FROM bitnami/spark:3.5
LABEL authors="osmanuygar.kose"
USER root

# Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy Spark jobs
COPY jobs/ /opt/spark-jobs/

# PostgreSQL JDBC driver (zaten bitnami image'de var)
# Hadoop AWS için S3A support (zaten var)

USER 1001

WORKDIR /opt/spark-jobs