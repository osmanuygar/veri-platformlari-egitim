-- ============================================
-- Hafta 2: Örnek Veri Yükleme
-- ============================================

SET search_path TO ecommerce, public;

-- ============================================
-- 1. KATEGORILER
-- ============================================
INSERT INTO kategoriler (kategori_adi, aciklama, ust_kategori_id) VALUES
('Elektronik', 'Elektronik ürünler', NULL),
('Bilgisayar', 'Bilgisayar ve aksesuarları', 1),
('Telefon', 'Akıllı telefonlar', 1),
('Giyim', 'Giyim ürünleri', NULL),
('Erkek Giyim', 'Erkek giyim ürünleri', 4),
('Kadın Giyim', 'Kadın giyim ürünleri', 4),
('Kitap', 'Kitaplar ve dergiler', NULL),
('Ev & Yaşam', 'Ev eşyaları', NULL);

-- ============================================
-- 2. MÜŞTERILER
-- ============================================
INSERT INTO musteriler (ad, soyad, email, telefon, dogum_tarihi, aktif) VALUES
('Ahmet', 'Yılmaz', 'ahmet.yilmaz@example.com', '0532-111-2233', '1985-05-15', TRUE),
('Mehmet', 'Kaya', 'mehmet.kaya@example.com', '0533-222-3344', '1990-08-20', TRUE),
('Ayşe', 'Demir', 'ayse.demir@example.com', '0534-333-4455', '1988-03-10', TRUE),
('Fatma', 'Şahin', 'fatma.sahin@example.com', '0535-444-5566', '1992-11-25', TRUE),
('Ali', 'Çelik', 'ali.celik@example.com', '0536-555-6677', '1987-07-30', TRUE),
('Zeynep', 'Arslan', 'zeynep.arslan@example.com', '0537-666-7788', '1995-02-14', TRUE),
('Mustafa', 'Aydın', 'mustafa.aydin@example.com', '0538-777-8899', '1983-09-05', TRUE),
('Elif', 'Yıldız', 'elif.yildiz@example.com', '0539-888-9900', '1991-12-18', TRUE),
('Can', 'Özdemir', 'can.ozdemir@example.com', '0540-999-0011', '1989-04-22', TRUE),
('Selin', 'Kurt', 'selin.kurt@example.com', '0541-000-1122', '1994-06-08', TRUE);

-- ============================================
-- 3. ADRESLER
-- ============================================
INSERT INTO adresler (musteri_id, adres_baslik, adres_satir1, sehir, ilce, posta_kodu, varsayilan) VALUES
(1, 'Ev', 'Atatürk Cad. No:123', 'Istanbul', 'Kadıköy', '34710', TRUE),
(1, 'İş', 'Barbaros Bulvarı No:45', 'Istanbul', 'Beşiktaş', '34353', FALSE),
(2, 'Ev', 'Cumhuriyet Mah. Sok:15', 'Ankara', 'Çankaya', '06420', TRUE),
(3, 'Ev', 'Alsancak Mah. No:78', 'Izmir', 'Konak', '35220', TRUE),
(4, 'Ev', 'Bahçelievler Mah. No:90', 'Antalya', 'Muratpaşa', '07050', TRUE),
(5, 'Ev', 'Kemeraltı Cad. No:34', 'Bursa', 'Osmangazi', '16010', TRUE);

-- ============================================
-- 4. ÜRÜNLER
-- ============================================
INSERT INTO urunler (kategori_id, urun_adi, aciklama, fiyat, maliyet, stok_miktari, min_stok_seviyesi) VALUES
-- Elektronik
(2, 'Laptop Dell XPS 13', '13 inç, Intel i7, 16GB RAM, 512GB SSD', 25000.00, 18000.00, 15, 5),
(2, 'MacBook Air M2', '13 inç, Apple M2, 8GB RAM, 256GB SSD', 35000.00, 28000.00, 10, 3),
(2, 'Asus ROG Gaming Laptop', '15 inç, RTX 3060, 16GB RAM, 1TB SSD', 32000.00, 24000.00, 8, 3),
(3, 'iPhone 14 Pro', '128GB, Space Black', 45000.00, 38000.00, 20, 5),
(3, 'Samsung Galaxy S23', '256GB, Phantom Black', 35000.00, 28000.00, 25, 5),
(3, 'Google Pixel 7', '128GB, Snow', 28000.00, 22000.00, 12, 5),

-- Giyim
(5, 'Erkek Kot Pantolon', 'Slim fit, Lacivert', 450.00, 200.00, 50, 20),
(5, 'Erkek Gömlek', 'Beyaz, Pamuklu', 350.00, 150.00, 40, 15),
(6, 'Kadın Elbise', 'Çiçek desenli, Yaz koleksiyonu', 650.00, 300.00, 30, 10),
(6, 'Kadın Bluz', 'Saten, Pembe', 400.00, 180.00, 35, 15),

-- Kitap
(7, 'Suç ve Ceza', 'Dostoyevski, Klasik', 120.00, 50.00, 100, 20),
(7, 'Simyacı', 'Paulo Coelho, Roman', 95.00, 40.00, 80, 20),
(7, 'İnce Memed', 'Yaşar Kemal, Roman', 110.00, 45.00, 60, 15),

-- Ev & Yaşam
(8, 'Kahve Makinesi', 'Otomatik, Paslanmaz çelik', 1200.00, 700.00, 25, 10),
(8, 'Blender', '1000W, 2L kapasite', 800.00, 400.00, 30, 10);

-- ============================================
-- 5. SİPARİŞLER
-- ============================================
INSERT INTO siparisler (musteri_id, siparis_tarihi, durum, toplam_tutar, kargo_adresi_id, odeme_yontemi) VALUES
(1, '2025-01-15 10:30:00', 'Teslim Edildi', 25450.00, 1, 'Kredi Kartı'),
(2, '2025-01-16 14:20:00', 'Teslim Edildi', 45000.00, 3, 'Banka Havalesi'),
(3, '2025-01-17 09:15:00', 'Kargoda', 1850.00, 4, 'Kredi Kartı'),
(4, '2025-01-18 16:45:00', 'Hazirlaniyor', 650.00, 5, 'Kapıda Ödeme'),
(5, '2025-01-19 11:00:00', 'Onaylandi', 920.00, 6, 'Kredi Kartı'),
(1, '2025-01-20 13:30:00', 'Beklemede', 350.00, 1, 'Kredi Kartı'),
(6, '2025-01-21 10:00:00', 'Onaylandi', 35000.00, NULL, 'Banka Havalesi'),
(7, '2025-01-22 15:20:00', 'Hazirlaniyor', 800.00, NULL, 'Kredi Kartı'),
(8, '2025-01-23 09:45:00', 'Teslim Edildi', 1200.00, NULL, 'Kapıda Ödeme'),
(9, '2025-01-24 14:10:00', 'Kargoda', 450.00, NULL, 'Kredi Kartı');

-- ============================================
-- 6. SİPARİŞ DETAYLARI
-- ============================================
INSERT INTO siparis_detaylari (siparis_id, urun_id, adet, birim_fiyat, indirim_orani, ara_toplam) VALUES
-- Sipariş 1
(1, 1, 1, 25000.00, 0, 25000.00),
(1, 11, 1, 450.00, 0, 450.00),

-- Sipariş 2
(2, 4, 1, 45000.00, 0, 45000.00),

-- Sipariş 3
(3, 7, 2, 450.00, 10, 810.00),
(3, 15, 1, 1200.00, 5, 1140.00),

-- Sipariş 4
(4, 9, 1, 650.00, 0, 650.00),

-- Sipariş 5
(5, 12, 2, 95.00, 0, 190.00),
(5, 13, 1, 110.00, 0, 110.00),
(5, 14, 1, 1200.00, 50, 600.00),

-- Sipariş 6
(6, 8, 1, 350.00, 0, 350.00),

-- Sipariş 7
(7, 2, 1, 35000.00, 0, 35000.00),

-- Sipariş 8
(8, 16, 1, 800.00, 0, 800.00),

-- Sipariş 9
(9, 15, 1, 1200.00, 0, 1200.00),

-- Sipariş 10
(10, 7, 1, 450.00, 0, 450.00);

-- ============================================
-- 7. ÜRÜN YORUMLARI
-- ============================================
INSERT INTO urun_yorumlari (urun_id, musteri_id, puan, yorum_baslik, yorum_metni, onaylandi) VALUES
(1, 1, 5, 'Harika laptop!', 'Çok memnun kaldım, performansı çok iyi.', TRUE),
(1, 3, 4, 'İyi ama pahalı', 'Ürün kaliteli ama fiyatı biraz yüksek', TRUE),
(4, 2, 5, 'Mükemmel telefon', 'Kamera kalitesi harika, bataryası uzun gidiyor', TRUE),
(7, 4, 5, 'Çok rahat', 'Kumaşı çok kaliteli ve rahat', TRUE),
(11, 5, 4, 'Güzel kitap', 'Çok etkileyici bir roman', TRUE),
(15, 8, 5, 'Süper kahve', 'Her sabah harika kahve içiyorum', TRUE);

-- ============================================
-- 8. STOK HAREKETLERİ
-- ============================================
INSERT INTO stok_hareketleri (urun_id, hareket_tipi, miktar, onceki_stok, yeni_stok, aciklama) VALUES
(1, 'Cikis', 1, 16, 15, 'Sipariş #1'),
(4, 'Cikis', 1, 21, 20, 'Sipariş #2'),
(7, 'Cikis', 2, 52, 50, 'Sipariş #3'),
(9, 'Cikis', 1, 31, 30, 'Sipariş #4');

-- ============================================
-- İSTATİSTİKLER
-- ============================================
SELECT
    'Veri yükleme tamamlandı! ✅' as status,
    (SELECT COUNT(*) FROM musteriler) as musteri_sayisi,
    (SELECT COUNT(*) FROM urunler) as urun_sayisi,
    (SELECT COUNT(*) FROM siparisler) as siparis_sayisi,
    (SELECT SUM(toplam_tutar) FROM siparisler) as toplam_ciro;