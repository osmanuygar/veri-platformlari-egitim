-- Hafta 12 — örnek veri (bilerek birkaç veri kalitesi sorunu içerir)
SET search_path TO raw, public;

INSERT INTO customers (full_name, tckn, email, phone, birth_date, city, income_band, consent_marketing, consent_date) VALUES
 ('Ayşe Yılmaz',   '10000000146', 'ayse.yilmaz@example.com',   '5551234567', '1988-03-12', 'İstanbul', 'high',   true,  '2024-01-10'),
 ('Mehmet Demir',  '10000000254', 'mehmet.demir@example.com',  '5552345678', '1975-07-22', 'Ankara',   'medium', false, NULL),
 ('Zeynep Kaya',   '10000000362', 'zeynep.kaya@example.com',   '5553456789', '1992-11-05', 'İzmir',    'medium', true,  '2024-02-15'),
 ('Ali Şahin',     '10000000479', 'ali.sahin@example.com',     '5554567890', '1980-01-30', 'Bursa',    'low',    false, NULL),
 ('Fatma Çelik',   '10000000587', 'fatma.celik@example.com',   NULL,         '1995-09-18', 'Antalya',  'low',    true,  '2024-03-01'),
 -- Kasıtlı veri kalitesi sorunları (Alıştırma 1'de Great Expectations bunları yakalayacak):
 ('Emre Arslan',   '123',          'gecersiz-email',            '555',        '1970-01-01', 'İstanbul', 'high',   true,  '2024-01-20'),  -- geçersiz TCKN, email, telefon
 ('Elif Doğan',    '10000000695',  NULL,                         '5556789012', '2030-01-01', 'Adana',    'medium', false, NULL),           -- email eksik, gelecekte doğum tarihi
 ('Burak Koç',     '10000000806',  'burak.koc@example.com',     '5557890123', '1985-05-14', NULL,       'low',    true,  '2024-04-01');    -- şehir eksik

INSERT INTO orders (customer_id, order_date, amount, status) VALUES
 (1, '2025-01-15', 2500.00, 'completed'),
 (1, '2025-02-20', 1200.00, 'completed'),
 (2, '2025-01-18',  800.00, 'completed'),
 (3, '2025-03-01', 3200.00, 'completed'),
 (4, '2025-02-10',  450.00, 'cancelled'),
 (5, '2025-03-05', 1800.00, 'completed');
