-- Örnek Sensör Verileri

USE iot;

-- Örnek sensör ID'leri
-- sensor1: 11111111-1111-1111-1111-111111111111
-- sensor2: 22222222-2222-2222-2222-222222222222

-- Sensör 1 verileri
INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (11111111-1111-1111-1111-111111111111, '2025-09-30 10:00:00', 22.5, 65.0, 'Istanbul');

INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (11111111-1111-1111-1111-111111111111, '2025-09-30 11:00:00', 23.2, 64.5, 'Istanbul');

INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (11111111-1111-1111-1111-111111111111, '2025-09-30 12:00:00', 24.1, 63.0, 'Istanbul');

-- Sensör 2 verileri
INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (22222222-2222-2222-2222-222222222222, '2025-09-30 10:00:00', 21.8, 68.0, 'Ankara');

INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity, location)
VALUES (22222222-2222-2222-2222-222222222222, '2025-09-30 11:00:00', 22.5, 67.5, 'Ankara');
EOF