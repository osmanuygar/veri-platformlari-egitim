-- Hafta 6 — başlangıç verisi (küçük, elle takip edilebilir)
-- Büyük hacim isteyen alıştırmalar için scripts/generate_more_data.py kullanın.

SET search_path TO raw, public;

INSERT INTO raw_customers (id, first_name, last_name, email, city, created_at) VALUES
 (1,'Ayşe','Yılmaz','ayse.yilmaz@example.com','İstanbul','2025-01-05'),
 (2,'Mehmet','Demir','mehmet.demir@example.com','Ankara','2025-01-12'),
 (3,'Zeynep','Kaya','zeynep.kaya@example.com','İzmir','2025-02-01'),
 (4,'Ali','Şahin','ali.sahin@example.com','Bursa','2025-02-14'),
 (5,'Fatma','Çelik','fatma.celik@example.com','Antalya','2025-03-03'),
 (6,'Emre','Arslan','emre.arslan@example.com','İstanbul','2025-03-20'),
 (7,'Elif','Doğan','elif.dogan@example.com','Adana','2025-04-02'),
 (8,'Burak','Koç','burak.koc@example.com','Konya','2025-04-18');

INSERT INTO raw_orders (id, customer_id, order_date, status) VALUES
 (1,1,'2025-05-01','completed'),
 (2,1,'2025-05-15','completed'),
 (3,2,'2025-05-03','shipped'),
 (4,3,'2025-05-04','placed'),
 (5,3,'2025-05-20','returned'),
 (6,4,'2025-05-06','completed'),
 (7,5,'2025-05-07','cancelled'),
 (8,6,'2025-05-08','completed'),
 (9,6,'2025-05-22','shipped'),
 (10,7,'2025-05-10','completed'),
 (11,8,'2025-05-11','placed'),
 (12,2,'2025-05-25','completed');

INSERT INTO raw_payments (id, order_id, payment_method, amount) VALUES
 (1,1,'credit_card',15000),
 (2,2,'coupon',2000),
 (3,3,'credit_card',8500),
 (4,4,'bank_transfer',12000),
 (5,5,'credit_card',9900),
 (6,6,'gift_card',5000),
 (7,7,'credit_card',3200),
 (8,8,'credit_card',22000),
 (9,9,'bank_transfer',7600),
 (10,10,'credit_card',11000),
 (11,11,'coupon',1500),
 (12,12,'credit_card',18000);
