-- ============================================
-- Hafta 2: E-Ticaret Veritabanı Şeması
-- ============================================

-- Schema oluştur
CREATE SCHEMA IF NOT EXISTS ecommerce;
SET search_path TO ecommerce, public;

-- ============================================
-- 1. MUSTERILER TABLOSU
-- ============================================
CREATE TABLE musteriler (
    musteri_id SERIAL PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefon VARCHAR(20),
    dogum_tarihi DATE,
    kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktif BOOLEAN DEFAULT TRUE,

    CONSTRAINT chk_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT chk_dogum_tarihi CHECK (dogum_tarihi < CURRENT_DATE)
);

COMMENT ON TABLE musteriler IS 'Müşteri bilgileri';
COMMENT ON COLUMN musteriler.musteri_id IS 'Benzersiz müşteri kimliği';
COMMENT ON COLUMN musteriler.email IS 'Müşteri email adresi (benzersiz)';

-- ============================================
-- 2. ADRESLER TABLOSU
-- ============================================
CREATE TABLE adresler (
    adres_id SERIAL PRIMARY KEY,
    musteri_id INT NOT NULL,
    adres_baslik VARCHAR(50) NOT NULL,
    adres_satir1 VARCHAR(200) NOT NULL,
    adres_satir2 VARCHAR(200),
    sehir VARCHAR(50) NOT NULL,
    ilce VARCHAR(50),
    posta_kodu VARCHAR(10),
    ulke VARCHAR(50) DEFAULT 'Türkiye',
    varsayilan BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_musteri FOREIGN KEY (musteri_id)
        REFERENCES musteriler(musteri_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_adresler_musteri ON adresler(musteri_id);

-- ============================================
-- 3. KATEGORILER TABLOSU
-- ============================================
CREATE TABLE kategoriler (
    kategori_id SERIAL PRIMARY KEY,
    kategori_adi VARCHAR(100) NOT NULL UNIQUE,
    aciklama TEXT,
    ust_kategori_id INT,

    CONSTRAINT fk_ust_kategori FOREIGN KEY (ust_kategori_id)
        REFERENCES kategoriler(kategori_id)
        ON DELETE SET NULL
);

-- ============================================
-- 4. URUNLER TABLOSU
-- ============================================
CREATE TABLE urunler (
    urun_id SERIAL PRIMARY KEY,
    kategori_id INT,
    urun_adi VARCHAR(200) NOT NULL,
    aciklama TEXT,
    fiyat DECIMAL(10,2) NOT NULL,
    maliyet DECIMAL(10,2),
    stok_miktari INT DEFAULT 0,
    min_stok_seviyesi INT DEFAULT 10,
    aktif BOOLEAN DEFAULT TRUE,
    ekleme_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_fiyat CHECK (fiyat > 0),
    CONSTRAINT chk_stok CHECK (stok_miktari >= 0),
    CONSTRAINT fk_kategori FOREIGN KEY (kategori_id)
        REFERENCES kategoriler(kategori_id)
        ON DELETE SET NULL
);

CREATE INDEX idx_urunler_kategori ON urunler(kategori_id);
CREATE INDEX idx_urunler_fiyat ON urunler(fiyat);
CREATE INDEX idx_urunler_aktif ON urunler(aktif) WHERE aktif = TRUE;

-- ============================================
-- 5. SIPARISLER TABLOSU
-- ============================================
CREATE TABLE siparisler (
    siparis_id SERIAL PRIMARY KEY,
    musteri_id INT NOT NULL,
    siparis_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    durum VARCHAR(20) DEFAULT 'Beklemede',
    toplam_tutar DECIMAL(10,2) NOT NULL,
    kargo_adresi_id INT,
    kargo_ucreti DECIMAL(8,2) DEFAULT 0,
    odeme_yontemi VARCHAR(50),

    CONSTRAINT chk_durum CHECK (durum IN ('Beklemede', 'Onaylandi', 'Hazirlaniyor', 'Kargoda', 'Teslim Edildi', 'Iptal')),
    CONSTRAINT chk_toplam CHECK (toplam_tutar >= 0),
    CONSTRAINT fk_musteri_siparis FOREIGN KEY (musteri_id)
        REFERENCES musteriler(musteri_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_kargo_adres FOREIGN KEY (kargo_adresi_id)
        REFERENCES adresler(adres_id)
        ON DELETE SET NULL
);

CREATE INDEX idx_siparisler_musteri ON siparisler(musteri_id);
CREATE INDEX idx_siparisler_tarih ON siparisler(siparis_tarihi DESC);
CREATE INDEX idx_siparisler_durum ON siparisler(durum);

-- ============================================
-- 6. SIPARIS DETAYLARI TABLOSU
-- ============================================
CREATE TABLE siparis_detaylari (
    detay_id SERIAL PRIMARY KEY,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    adet INT NOT NULL,
    birim_fiyat DECIMAL(10,2) NOT NULL,
    indirim_orani DECIMAL(5,2) DEFAULT 0,
    ara_toplam DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_adet CHECK (adet > 0),
    CONSTRAINT chk_birim_fiyat CHECK (birim_fiyat > 0),
    CONSTRAINT chk_indirim CHECK (indirim_orani >= 0 AND indirim_orani <= 100),
    CONSTRAINT fk_siparis FOREIGN KEY (siparis_id)
        REFERENCES siparisler(siparis_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_urun FOREIGN KEY (urun_id)
        REFERENCES urunler(urun_id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_detay_siparis ON siparis_detaylari(siparis_id);
CREATE INDEX idx_detay_urun ON siparis_detaylari(urun_id);

-- ============================================
-- 7. URUN YORUMLARI TABLOSU
-- ============================================
CREATE TABLE urun_yorumlari (
    yorum_id SERIAL PRIMARY KEY,
    urun_id INT NOT NULL,
    musteri_id INT NOT NULL,
    puan INT NOT NULL,
    yorum_baslik VARCHAR(200),
    yorum_metni TEXT,
    yorum_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    onaylandi BOOLEAN DEFAULT FALSE,

    CONSTRAINT chk_puan CHECK (puan BETWEEN 1 AND 5),
    CONSTRAINT fk_yorum_urun FOREIGN KEY (urun_id)
        REFERENCES urunler(urun_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_yorum_musteri FOREIGN KEY (musteri_id)
        REFERENCES musteriler(musteri_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_yorumlar_urun ON urun_yorumlari(urun_id);
CREATE INDEX idx_yorumlar_tarih ON urun_yorumlari(yorum_tarihi DESC);

-- ============================================
-- 8. STOK HAREKETLERI TABLOSU (Log)
-- ============================================
CREATE TABLE stok_hareketleri (
    hareket_id SERIAL PRIMARY KEY,
    urun_id INT NOT NULL,
    hareket_tipi VARCHAR(20) NOT NULL,
    miktar INT NOT NULL,
    onceki_stok INT NOT NULL,
    yeni_stok INT NOT NULL,
    aciklama TEXT,
    hareket_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_hareket_tipi CHECK (hareket_tipi IN ('Giris', 'Cikis', 'Duzeltme', 'Iade')),
    CONSTRAINT fk_stok_urun FOREIGN KEY (urun_id)
        REFERENCES urunler(urun_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_stok_urun ON stok_hareketleri(urun_id);
CREATE INDEX idx_stok_tarih ON stok_hareketleri(hareket_tarihi DESC);

-- ============================================
-- VIEWS
-- ============================================

-- Ürün özet view
CREATE OR REPLACE VIEW v_urun_ozet AS
SELECT
    u.urun_id,
    u.urun_adi,
    k.kategori_adi,
    u.fiyat,
    u.stok_miktari,
    COUNT(DISTINCT y.yorum_id) as yorum_sayisi,
    ROUND(AVG(y.puan), 2) as ortalama_puan,
    COUNT(DISTINCT sd.siparis_id) as satis_sayisi
FROM urunler u
LEFT JOIN kategoriler k ON u.kategori_id = k.kategori_id
LEFT JOIN urun_yorumlari y ON u.urun_id = y.urun_id
LEFT JOIN siparis_detaylari sd ON u.urun_id = sd.urun_id
WHERE u.aktif = TRUE
GROUP BY u.urun_id, u.urun_adi, k.kategori_adi, u.fiyat, u.stok_miktari;

-- Müşteri özet view
CREATE OR REPLACE VIEW v_musteri_ozet AS
SELECT
    m.musteri_id,
    m.ad || ' ' || m.soyad as ad_soyad,
    m.email,
    COUNT(s.siparis_id) as toplam_siparis,
    COALESCE(SUM(s.toplam_tutar), 0) as toplam_harcama,
    MAX(s.siparis_tarihi) as son_siparis_tarihi
FROM musteriler m
LEFT JOIN siparisler s ON m.musteri_id = s.musteri_id
WHERE m.aktif = TRUE
GROUP BY m.musteri_id, m.ad, m.soyad, m.email;

-- ============================================
-- BAŞARIYLA TAMAMLANDI
-- ============================================
SELECT 'Schema oluşturuldu! ✅' as status;