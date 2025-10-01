-- Cassandra Schema Tanımları

-- Keyspace oluştur
CREATE KEYSPACE IF NOT EXISTS iot WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE iot;

-- Sensör verileri tablosu
CREATE TABLE IF NOT EXISTS sensor_data (
  sensor_id UUID,
  timestamp TIMESTAMP,
  temperature DOUBLE,
  humidity DOUBLE,
  location TEXT,
  PRIMARY KEY (sensor_id, timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Günlük özet tablosu
CREATE TABLE IF NOT EXISTS daily_summary (
  sensor_id UUID,
  day DATE,
  avg_temperature DOUBLE,
  max_temperature DOUBLE,
  min_temperature DOUBLE,
  readings_count INT,
  PRIMARY KEY (sensor_id, day)
) WITH CLUSTERING ORDER BY (day DESC);