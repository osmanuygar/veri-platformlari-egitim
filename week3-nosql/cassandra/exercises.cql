-- Cassandra Alıştırmaları

USE iot;

-- ALIŞTIRMA 1: Belirli bir sensörün son 24 saatlik verilerini getirin


-- ALIŞTIRMA 2: Bir sensörün ortalama sıcaklığını hesaplayın (uygulama tarafında)


-- ALIŞTIRMA 3: Yeni bir sensör ekleyin ve 5 okuma kaydedin


-- ========== ÇÖZÜMLER ==========

-- Çözüm 1:
SELECT * FROM sensor_data
WHERE sensor_id = 11111111-1111-1111-1111-111111111111
  AND timestamp > '2025-09-29 00:00:00'
ORDER BY timestamp DESC;

-- Çözüm 2: (Cassandra'da aggregation sınırlı, uygulama tarafında yapılmalı)
SELECT temperature FROM sensor_data
WHERE sensor_id = 11111111-1111-1111-1111-111111111111;
-- Ortalama Python/Java ile hesaplanır

-- Çözüm 3:
INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), 25.0, 60.0, 'Izmir');