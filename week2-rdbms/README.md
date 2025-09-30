# Hafta 2: Temel Veri Tabanı Kavramları

## 📚 İçindekiler

1. [RDBMS Nedir?](#1-rdbms-nedir)
2. [İlişkisel Model Temelleri](#2-ilişkisel-model-temelleri)
3. [ACID Prensipleri](#3-acid-prensipleri)
4. [Temel SQL Komutları](#4-temel-sql-komutları)
5. [İleri SQL Özellikleri](#5-ileri-sql-özellikleri)
6. [İlişkisel Veritabanlarının Sınırlamaları](#6-ilişkisel-veritabanlarının-sınırlamaları)
7. [Pratik Uygulamalar](#7-pratik-uygulamalar)
8. [Alıştırmalar](#8-alıştırmalar)
9. [Kaynaklar](#9-kaynaklar)

---

## 1. RDBMS Nedir?

### 1.1 Tanım

**RDBMS (Relational Database Management System):** İlişkisel Veritabanı Yönetim Sistemi

Verileri **tablolar** (relations) halinde organize eden ve aralarındaki **ilişkileri** yöneten yazılım sistemi.

### 1.2 Temel Özellikler

#### ✅ Veri Bağımsızlığı
- **Fiziksel Bağımsızlık:** Veri depolama şekli değişse, uygulama etkilenmez
- **Mantıksal Bağımsızlık:** Şema değişiklikleri uygulamaları minimum etkiler

#### ✅ ACID Garantisi
Transaction'ların güvenilir şekilde işlenmesi

#### ✅ SQL Desteği
Standart, deklaratif sorgulama dili

#### ✅ Veri Bütünlüğü
- Entity integrity (Primary Key)
- Referential integrity (Foreign Key)
- Domain integrity (Data types, constraints)

#### ✅ Eşzamanlı Erişim Kontrolü
Çoklu kullanıcı desteği, locking mekanizmaları

#### ✅ Güvenlik
- Kullanıcı yetkilendirme
- Rol tabanlı erişim (RBAC)
- Veri şifreleme

### 1.3 Popüler RDBMS Sistemleri

#### PostgreSQL
```
✅ Açık kaynak
✅ ACID uyumlu
✅ Gelişmiş özellikler (JSON, Array, HStore)
✅ Güçlü topluluk desteği
✅ Extensible (özel veri tipleri)
❌ Kurulum ve yönetim karmaşık olabilir
```

**Kullanım Alanları:** Web uygulamaları, veri analizi, GIS uygulamaları

#### MySQL / MariaDB
```
✅ Kullanımı kolay
✅ Hızlı
✅ Geniş hosting desteği
✅ Açık kaynak
❌ Bazı gelişmiş özellikler yok
❌ Full ACID desteği InnoDB'de
```

**Kullanım Alanları:** WordPress, web apps, startuplar

#### Oracle Database
```
✅ Enterprise-grade
✅ Yüksek performans
✅ Kapsamlı özellikler
✅ 7/24 destek
❌ Çok pahalı
❌ Karmaşık lisanslama
```

**Kullanım Alanları:** Bankacılık, telekomünikasyon, büyük şirketler

#### Microsoft SQL Server
```
✅ Windows entegrasyonu
✅ T-SQL (gelişmiş SQL)
✅ Visual Studio entegrasyonu
✅ İyi dokümantasyon
❌ Lisans maliyeti
❌ Mostly Windows (Linux desteği yeni)
```

**Kullanım Alanları:** .NET uygulamaları, Microsoft ekosistemi

#### SQLite
```
✅ Serverless
✅ Hafif (< 1MB)
✅ Dosya tabanlı
✅ Zero-configuration
❌ Eşzamanlı yazma sınırlı
❌ Büyük ölçekli uygulamalar için değil
```

**Kullanım Alanları:** Mobil apps, embedded systems, prototyping

---

## 2. İlişkisel Model Temelleri

### 2.1 Temel Kavramlar

#### Tablo (Table / Relation)
Satır ve sütunlardan oluşan iki boyutlu veri yapısı.

```sql
-- Müşteriler tablosu örneği
CREATE TABLE musteriler (
    musteri_id INT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefon VARCHAR(20),
    kayit_tarihi DATE DEFAULT CURRENT_DATE
);
```

#### Satır (Row / Tuple / Record)
Bir entity'nin tüm özellikleri

```
| musteri_id | ad     | soyad  | email              | telefon       |
|------------|--------|--------|--------------------|---------------|
| 1          | Ahmet  | Yılmaz | ahmet@example.com  | 0532-123-4567 |
```

#### Sütun (Column / Attribute / Field)
Entity'nin bir özelliği

#### Domain
Bir sütunun alabileceği değerler kümesi
```sql
-- Yaş sütunu için domain
CHECK (yas >= 0 AND yas <= 150)

-- Cinsiyet sütunu için domain
CHECK (cinsiyet IN ('E', 'K', 'D'))
```

### 2.2 Anahtarlar (Keys)

#### Primary Key (Birincil Anahtar)
Tablodaki her satırı **benzersiz** şekilde tanımlayan sütun veya sütun kombinasyonu.

**Kurallar:**
- NULL olamaz
- Benzersiz olmalı
- Değişmemeli (immutable)
- Mümkünse tek sütun

```sql
-- Tek sütunlu Primary Key
CREATE TABLE ogrenciler (
    ogrenci_no INT PRIMARY KEY,
    ad VARCHAR(50),
    soyad VARCHAR(50)
);

-- Composite Primary Key (Çoklu sütun)
CREATE TABLE sinif_kayit (
    ogrenci_no INT,
    ders_kodu VARCHAR(10),
    donem VARCHAR(10),
    PRIMARY KEY (ogrenci_no, ders_kodu, donem)
);
```

#### Foreign Key (Yabancı Anahtar)
Başka bir tablonun Primary Key'ini referans eden sütun.

```sql
CREATE TABLE siparisler (
    siparis_id INT PRIMARY KEY,
    musteri_id INT,
    siparis_tarihi DATE,
    toplam_tutar DECIMAL(10,2),
    FOREIGN KEY (musteri_id) REFERENCES musteriler(musteri_id)
);
```

**Referential Integrity Kuralları:**
- `ON DELETE CASCADE`: Parent silinince child da silinir
- `ON DELETE SET NULL`: Parent silinince child NULL olur
- `ON DELETE RESTRICT`: Parent'ta child varsa silinemez
- `ON UPDATE CASCADE`: Parent güncellenince child da güncellenir

```sql
CREATE TABLE siparisler (
    siparis_id INT PRIMARY KEY,
    musteri_id INT,
    FOREIGN KEY (musteri_id) REFERENCES musteriler(musteri_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

#### Unique Key
Benzersiz olmalı ama NULL olabilir (Primary Key'den farkı)

```sql
CREATE TABLE kullanicilar (
    kullanici_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE  -- NULL olabilir
);
```

#### Candidate Key
Primary Key olmaya aday tüm anahtarlar

#### Super Key
Bir satırı benzersiz tanımlayan herhangi bir sütun kombinasyonu

### 2.3 İlişki Türleri

#### Bire-Bir (One-to-One)
```sql
-- Her kişinin bir pasaportu var
CREATE TABLE kisiler (
    kisi_id INT PRIMARY KEY,
    ad VARCHAR(50),
    soyad VARCHAR(50)
);

CREATE TABLE pasaportlar (
    pasaport_no VARCHAR(20) PRIMARY KEY,
    kisi_id INT UNIQUE,  -- UNIQUE makes it 1:1
    verilis_tarihi DATE,
    FOREIGN KEY (kisi_id) REFERENCES kisiler(kisi_id)
);
```

#### Bire-Çok (One-to-Many) - En Yaygın
```sql
-- Bir müşteri birden fazla sipariş verebilir
CREATE TABLE musteriler (
    musteri_id INT PRIMARY KEY,
    ad VARCHAR(50)
);

CREATE TABLE siparisler (
    siparis_id INT PRIMARY KEY,
    musteri_id INT,  -- Foreign Key, UNIQUE değil
    siparis_tarihi DATE,
    FOREIGN KEY (musteri_id) REFERENCES musteriler(musteri_id)
);
```

#### Çoka-Çok (Many-to-Many)
Ara tablo (junction/bridge table) gerektirir.

```sql
-- Öğrenciler birden fazla derse kayıtlı olabilir
-- Dersler birden fazla öğrenciye sahip olabilir

CREATE TABLE ogrenciler (
    ogrenci_id INT PRIMARY KEY,
    ad VARCHAR(50)
);

CREATE TABLE dersler (
    ders_id INT PRIMARY KEY,
    ders_adi VARCHAR(100)
);

-- Junction Table
CREATE TABLE kayitlar (
    ogrenci_id INT,
    ders_id INT,
    kayit_tarihi DATE,
    not DECIMAL(3,2),
    PRIMARY KEY (ogrenci_id, ders_id),
    FOREIGN KEY (ogrenci_id) REFERENCES ogrenciler(ogrenci_id),
    FOREIGN KEY (ders_id) REFERENCES dersler(ders_id)
);
```

### 2.4 Constraints (Kısıtlamalar)

#### NOT NULL
```sql
CREATE TABLE urunler (
    urun_id INT PRIMARY KEY,
    urun_adi VARCHAR(100) NOT NULL,  -- Boş olamaz
    fiyat DECIMAL(10,2) NOT NULL
);
```

#### UNIQUE
```sql
CREATE TABLE kullanicilar (
    kullanici_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,  -- Benzersiz olmalı
    username VARCHAR(50) UNIQUE
);
```

#### CHECK
```sql
CREATE TABLE calisanlar (
    calisan_id INT PRIMARY KEY,
    ad VARCHAR(50),
    yas INT CHECK (yas >= 18 AND yas <= 65),
    maas DECIMAL(10,2) CHECK (maas > 0),
    departman VARCHAR(50) CHECK (departman IN ('IT', 'HR', 'Sales', 'Finance'))
);
```

#### DEFAULT
```sql
CREATE TABLE siparisler (
    siparis_id INT PRIMARY KEY,
    siparis_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    durum VARCHAR(20) DEFAULT 'Beklemede',
    kargo_ucreti DECIMAL(5,2) DEFAULT 0.00
);
```

---

## 3. ACID Prensipleri

### 3.1 Atomicity (Bölünmezlik)

**Tanım:** Transaction ya tamamen başarılı olur ya da hiç olmaz. "Ya hep ya hiç" prensibi.

#### Örnek Senaryo: Para Transferi
```sql
BEGIN TRANSACTION;

-- 1. Ahmet'in hesabından 1000 TL çek
UPDATE hesaplar 
SET bakiye = bakiye - 1000 
WHERE hesap_no = '12345';

-- 2. Mehmet'in hesabına 1000 TL yatır
UPDATE hesaplar 
SET bakiye = bakiye + 1000 
WHERE hesap_no = '67890';

-- Her ikisi de başarılı ise commit
COMMIT;

-- Herhangi biri başarısız ise rollback
-- ROLLBACK;
```

**Ne Olursa Ne Olsun:**
- İki işlem de başarılı → Para transfer edilir
- Herhangi biri başarısız → HİÇBİRİ uygulanmaz
- Asla: Ahmet'ten çekilir ama Mehmet'e yatırılmaz durumu OLMAZ

#### Python Örneği
```python
import psycopg2

conn = psycopg2.connect("dbname=veri_db user=veri_user")
cursor = conn.cursor()

try:
    # Transaction başlat
    cursor.execute("BEGIN;")
    
    # Para çekme
    cursor.execute("""
        UPDATE hesaplar 
        SET bakiye = bakiye - %s 
        WHERE hesap_no = %s
    """, (1000, '12345'))
    
    # Para yatırma
    cursor.execute("""
        UPDATE hesaplar 
        SET bakiye = bakiye + %s 
        WHERE hesap_no = %s
    """, (1000, '67890'))
    
    # Her şey başarılı, commit
    conn.commit()
    print("Transfer başarılı!")
    
except Exception as e:
    # Hata oldu, rollback
    conn.rollback()
    print(f"Transfer başarısız: {e}")
    
finally:
    cursor.close()
    conn.close()
```

### 3.2 Consistency (Tutarlılık)

**Tanım:** Transaction veritabanını tutarlı bir durumdan başka bir tutarlı duruma geçirir. Tüm iş kuralları ve kısıtlamalar korunur.

#### Örnek: Stok Yönetimi
```sql
-- Kısıtlama: Stok negatif olamaz
CREATE TABLE urunler (
    urun_id INT PRIMARY KEY,
    urun_adi VARCHAR(100),
    stok_miktari INT CHECK (stok_miktari >= 0)
);

BEGIN TRANSACTION;

-- 50 adet satış
UPDATE urunler 
SET stok_miktari = stok_miktari - 50 
WHERE urun_id = 1;

-- Eğer stok -10 olacaksa, CHECK constraint ihlal edilir
-- Transaction ROLLBACK olur
-- Veritabanı tutarlı kalır

COMMIT;
```

#### Referential Integrity Örneği
```sql
-- Müşteri silindiğinde sipariş orphan kalmamalı
DELETE FROM musteriler WHERE musteri_id = 5;
-- Eğer sipariş varsa ve CASCADE tanımlı değilse → HATA
-- Veritabanı tutarlı kalır
```

### 3.3 Isolation (Yalıtım)

**Tanım:** Eşzamanlı transaction'lar birbirlerini etkilemez. Her transaction sanki tek başına çalışıyormuş gibi davranır.

#### Isolation Seviyeleri

**1. READ UNCOMMITTED (En Düşük İzolasyon)**
- Dirty Read mümkün
- Transaction henüz commit olmamış veriyi okuyabilir
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Kullanım: Çok nadiren, performans kritikse
```

**2. READ COMMITTED (PostgreSQL Default)**
- Sadece commit edilmiş veriyi okur
- Non-repeatable read mümkün
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN;
SELECT bakiye FROM hesaplar WHERE hesap_no = '12345';  -- 1000 TL
-- Başka bir transaction bakiyeyi 500 TL yapıp commit eder
SELECT bakiye FROM hesaplar WHERE hesap_no = '12345';  -- 500 TL (değişti!)
COMMIT;
```

**3. REPEATABLE READ**
- Aynı sorgu aynı sonucu döner
- Phantom read mümkün
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN;
SELECT * FROM urunler WHERE kategori = 'Elektronik';  -- 10 satır
-- Başka bir transaction yeni elektronik ürün ekler
SELECT * FROM urunler WHERE kategori = 'Elektronik';  -- Hala 10 satır
COMMIT;
```

**4. SERIALIZABLE (En Yüksek İzolasyon)**
- Transaction'lar seri çalışıyormuş gibi
- Hiçbir anomali yok
- En yavaş
```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

#### Concurrency Problemleri

**Dirty Read:** Commit olmamış veriyi okuma
```
T1: UPDATE hesaplar SET bakiye = 500 WHERE id = 1;  (henüz commit yok)
T2: SELECT bakiye FROM hesaplar WHERE id = 1;       (500 okur)
T1: ROLLBACK;                                        (T2 yanlış veri okudu!)
```

**Non-Repeatable Read:** Aynı sorgu farklı sonuç
```
T1: SELECT bakiye FROM hesaplar WHERE id = 1;  -- 1000
T2: UPDATE hesaplar SET bakiye = 500 WHERE id = 1; COMMIT;
T1: SELECT bakiye FROM hesaplar WHERE id = 1;  -- 500 (değişti!)
```

**Phantom Read:** Satır sayısı değişir
```
T1: SELECT COUNT(*) FROM siparisler WHERE durum = 'Beklemede';  -- 5
T2: INSERT INTO siparisler VALUES (...); COMMIT;
T1: SELECT COUNT(*) FROM siparisler WHERE durum = 'Beklemede';  -- 6
```

### 3.4 Durability (Dayanıklılık)

**Tanım:** Commit edilen transaction kalıcıdır. Sistem arızasında bile kaybolmaz.

#### Mekanizmalar

**Write-Ahead Logging (WAL)**
```
1. Transaction değişiklikleri önce LOG'a yazılır
2. Sonra disk'e yazılır
3. Elektrik kesilse bile log'dan recovery edilir
```

**PostgreSQL WAL Örneği:**
```bash
# WAL dosyalarını görüntüle
ls -l /var/lib/postgresql/data/pg_wal/

# WAL arşivleme (yedekleme için)
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
```

#### Recovery Örneği
```sql
-- Transaction commit edildi
BEGIN;
INSERT INTO siparisler VALUES (100, 1, '2025-01-29', 500.00);
COMMIT;  -- Bu noktada kalıcı oldu

-- Sistem çöküyor...
-- Sistem yeniden başlıyor...
-- Recovery işlemi WAL'dan veriyi geri yükler

SELECT * FROM siparisler WHERE siparis_id = 100;
-- Satır hala orada! ✅
```

---

## 4. Temel SQL Komutları

### 4.1 DDL (Data Definition Language)

#### CREATE - Tablo Oluşturma
```sql
CREATE TABLE calisanlar (
    calisan_id SERIAL PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    departman_id INT,
    maas DECIMAL(10,2) CHECK (maas > 0),
    ise_giris_tarihi DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (departman_id) REFERENCES departmanlar(departman_id)
);
```

#### ALTER - Tablo Değiştirme
```sql
-- Sütun ekleme
ALTER TABLE calisanlar ADD COLUMN telefon VARCHAR(20);

-- Sütun silme
ALTER TABLE calisanlar DROP COLUMN telefon;

-- Sütun veri tipini değiştirme
ALTER TABLE calisanlar ALTER COLUMN maas TYPE NUMERIC(12,2);

-- Constraint ekleme
ALTER TABLE calisanlar ADD CONSTRAINT check_maas CHECK (maas >= 17002.12);

-- Constraint silme
ALTER TABLE calisanlar DROP CONSTRAINT check_maas;

-- Sütun adı değiştirme
ALTER TABLE calisanlar RENAME COLUMN ad TO isim;
```

#### DROP - Tablo Silme
```sql
-- Tabloyu sil
DROP TABLE IF EXISTS calisanlar;

-- CASCADE: Bağımlı objeleri de sil
DROP TABLE calisanlar CASCADE;

-- RESTRICT: Bağımlılık varsa silme (default)
DROP TABLE calisanlar RESTRICT;
```

#### TRUNCATE - Tüm Verileri Sil
```sql
-- Hızlı, log tutmaz, auto-increment sıfırlar
TRUNCATE TABLE calisanlar;

-- Restart identity
TRUNCATE TABLE calisanlar RESTART IDENTITY;

-- CASCADE
TRUNCATE TABLE calisanlar CASCADE;
```

### 4.2 DML (Data Manipulation Language)

#### SELECT - Veri Sorgulama

**Basit SELECT:**
```sql
-- Tüm sütunlar
SELECT * FROM calisanlar;

-- Belirli sütunlar
SELECT ad, soyad, maas FROM calisanlar;

-- Alias kullanımı
SELECT ad AS isim, maas AS aylik_maas FROM calisanlar;
```

**WHERE - Filtreleme:**
```sql
-- Koşullu sorgular
SELECT * FROM calisanlar WHERE departman_id = 5;

-- Karşılaştırma operatörleri
SELECT * FROM calisanlar WHERE maas > 50000;
SELECT * FROM calisanlar WHERE maas >= 40000 AND maas <= 60000;
SELECT * FROM calisanlar WHERE maas BETWEEN 40000 AND 60000;

-- IN operatörü
SELECT * FROM calisanlar 
WHERE departman_id IN (1, 3, 5);

-- LIKE - Pattern matching
SELECT * FROM calisanlar WHERE ad LIKE 'A%';      -- A ile başlar
SELECT * FROM calisanlar WHERE email LIKE '%@gmail.com';  -- gmail ile biter
SELECT * FROM calisanlar WHERE ad LIKE '_hmet';   -- İkinci harf h

-- NULL kontrolü
SELECT * FROM calisanlar WHERE telefon IS NULL;
SELECT * FROM calisanlar WHERE telefon IS NOT NULL;

-- Mantıksal operatörler
SELECT * FROM calisanlar 
WHERE departman_id = 2 AND maas > 45000;

SELECT * FROM calisanlar 
WHERE departman_id = 1 OR departman_id = 3;

SELECT * FROM calisanlar 
WHERE NOT (maas < 30000);
```

**ORDER BY - Sıralama:**
```sql
-- Artan sıra (default)
SELECT * FROM calisanlar ORDER BY maas;
SELECT * FROM calisanlar ORDER BY maas ASC;

-- Azalan sıra
SELECT * FROM calisanlar ORDER BY maas DESC;

-- Çoklu sıralama
SELECT * FROM calisanlar 
ORDER BY departman_id ASC, maas DESC;

-- NULL'lar
SELECT * FROM calisanlar ORDER BY telefon NULLS FIRST;
SELECT * FROM calisanlar ORDER BY telefon NULLS LAST;
```

**LIMIT ve OFFSET - Sayfalama:**
```sql
-- İlk 10 satır
SELECT * FROM calisanlar LIMIT 10;

-- Offset ile atlama
SELECT * FROM calisanlar LIMIT 10 OFFSET 20;  -- 21-30 arası

-- Sayfalama örneği (sayfa 3, sayfa başına 10)
SELECT * FROM calisanlar 
ORDER BY calisan_id
LIMIT 10 OFFSET 20;
```

**DISTINCT - Benzersiz Değerler:**
```sql
-- Benzersiz departmanlar
SELECT DISTINCT departman_id FROM calisanlar;

-- Çoklu sütun
SELECT DISTINCT departman_id, sehir FROM calisanlar;
```

**Aggregate Functions:**
```sql
-- Sayma
SELECT COUNT(*) FROM calisanlar;
SELECT COUNT(telefon) FROM calisanlar;  -- NULL'ları sayma
SELECT COUNT(DISTINCT departman_id) FROM calisanlar;

-- Toplam
SELECT SUM(maas) FROM calisanlar;

-- Ortalama
SELECT AVG(maas) FROM calisanlar;
SELECT ROUND(AVG(maas), 2) FROM calisanlar;

-- Min/Max
SELECT MIN(maas), MAX(maas) FROM calisanlar;

-- Birlikte kullanım
SELECT 
    COUNT(*) as calisan_sayisi,
    SUM(maas) as toplam_maas,
    AVG(maas) as ortalama_maas,
    MIN(maas) as min_maas,
    MAX(maas) as max_maas
FROM calisanlar;
```

**GROUP BY - Gruplama:**
```sql
-- Departman başına çalışan sayısı
SELECT departman_id, COUNT(*) as calisan_sayisi
FROM calisanlar
GROUP BY departman_id;

-- Çoklu gruplama
SELECT departman_id, sehir, COUNT(*) 
FROM calisanlar
GROUP BY departman_id, sehir;

-- Aggregate ile
SELECT 
    departman_id,
    COUNT(*) as calisan_sayisi,
    AVG(maas) as ortalama_maas
FROM calisanlar
GROUP BY departman_id
ORDER BY ortalama_maas DESC;
```

**HAVING - Group Filtreleme:**
```sql
-- WHERE: Satırları filtreler (GROUP BY'dan önce)
-- HAVING: Grupları filtreler (GROUP BY'dan sonra)

SELECT departman_id, AVG(maas) as ort_maas
FROM calisanlar
WHERE ise_giris_tarihi > '2020-01-01'  -- WHERE: satırları filtrele
GROUP BY departman_id
HAVING AVG(maas) > 50000;  -- HAVING: grupları filtrele

-- Örnek: 5'ten fazla çalışanı olan departmanlar
SELECT departman_id, COUNT(*) as calisan_sayisi
FROM calisanlar
GROUP BY departman_id
HAVING COUNT(*) > 5;
```

#### INSERT - Veri Ekleme
```sql
-- Tek satır
INSERT INTO calisanlar (ad, soyad, email, departman_id, maas)
VALUES ('Ahmet', 'Yılmaz', 'ahmet@example.com', 2, 55000);

-- Çoklu satır
INSERT INTO calisanlar (ad, soyad, email, departman_id, maas)
VALUES 
    ('Mehmet', 'Kaya', 'mehmet@example.com', 1, 48000),
    ('Ayşe', 'Demir', 'ayse@example.com', 3, 52000),
    ('Fatma', 'Şahin', 'fatma@example.com', 2, 61000);

-- Tüm sütunlar (sırayla)
INSERT INTO calisanlar 
VALUES (DEFAULT, 'Ali', 'Veli', 'ali@example.com', 1, 45000, CURRENT_DATE);

-- SELECT'ten veri ekleme
INSERT INTO calisanlar_arsiv
SELECT * FROM calisanlar WHERE ise_giris_tarihi < '2010-01-01';

-- RETURNING - Eklenen veriyi döndür
INSERT INTO calisanlar (ad, soyad, email, departman_id, maas)
VALUES ('Zeynep', 'Yıldız', 'zeynep@example.com', 4, 58000)
RETURNING calisan_id, ad, soyad;
```

#### UPDATE - Veri Güncelleme
```sql
-- Tek satır güncelleme
UPDATE calisanlar 
SET maas = 60000 
WHERE calisan_id = 5;

-- Çoklu sütun
UPDATE calisanlar 
SET 
    maas = maas * 1.10,  -- %10 zam
    guncelleme_tarihi = CURRENT_TIMESTAMP
WHERE departman_id = 2;

-- Alt sorgu ile
UPDATE calisanlar
SET maas = (SELECT AVG(maas) FROM calisanlar WHERE departman_id = 1)
WHERE calisan_id = 10;

-- FROM clause (PostgreSQL)
UPDATE calisanlar c
SET departman_adi = d.ad
FROM departmanlar d
WHERE c.departman_id = d.departman_id;

-- RETURNING
UPDATE calisanlar 
SET maas = maas * 1.15 
WHERE departman_id = 3
RETURNING calisan_id, ad, maas;
```

#### DELETE - Veri Silme
```sql
-- Koşullu silme
DELETE FROM calisanlar WHERE calisan_id = 10;

-- Çoklu satır
DELETE FROM calisanlar WHERE departman_id = 5;

-- Alt sorgu ile
DELETE FROM calisanlar 
WHERE maas < (SELECT AVG(maas) FROM calisanlar);

-- RETURNING
DELETE FROM calisanlar 
WHERE ise_giris_tarihi < '2010-01-01'
RETURNING *;

-- DİKKAT: WHERE olmadan tüm satırları siler!
-- DELETE FROM calisanlar;  -- KULLANMAYIN!
```

### 4.3 JOIN İşlemleri

#### INNER JOIN
Sadece eşleşen satırları döndürür.

```sql
SELECT 
    c.ad,
    c.soyad,
    d.departman_adi,
    c.maas
FROM calisanlar c
INNER JOIN departmanlar d ON c.departman_id = d.departman_id;
```

#### LEFT JOIN (LEFT OUTER JOIN)
Sol tablonun tüm satırları + eşleşenler

```sql
-- Departmanı olmayan çalışanları da göster
SELECT 
    c.ad,
    c.soyad,
    d.departman_adi
FROM calisanlar c
LEFT JOIN departmanlar d ON c.departman_id = d.departman_id;
```

#### RIGHT JOIN (RIGHT OUTER JOIN)
Sağ tablonun tüm satırları + eşleşenler

```sql
-- Çalışanı olmayan departmanları da göster
SELECT 
    c.ad,
    c.soyad,
    d.departman_adi
FROM calisanlar c
RIGHT JOIN departmanlar d ON c.departman_id = d.departman_id;
```

#### FULL OUTER JOIN
Her iki tablonun tüm satırları

```sql
SELECT 
    c.ad,
    d.departman_adi
FROM calisanlar c
FULL OUTER JOIN departmanlar d ON c.departman_id = d.departman_id;
```

#### CROSS JOIN
Kartezyen çarpım (her kombinasyon)

```sql
SELECT 
    c.ad,
    d.departman_adi
FROM calisanlar c
CROSS JOIN departmanlar d;
-- Dikkat: N * M satır döner!
```

#### SELF JOIN
Tabloyu kendisiyle birleştirme

```sql
-- Her çalışanın yöneticisini bul
SELECT 
    c.ad AS calisan,
    y.ad AS yonetici
FROM calisanlar c
LEFT JOIN calisanlar y ON c.yonetici_id = y.calisan_id;
```

#### Çoklu JOIN
```sql
SELECT 
    c.ad AS calisan_adi,
    d.departman_adi,
    s.sehir_adi,
    p.proje_adi
FROM calisanlar c
INNER JOIN departmanlar d ON c.departman_id = d.departman_id
INNER JOIN sehirler s ON d.sehir_id = s.sehir_id
LEFT JOIN proje_atama pa ON c.calisan_id = pa.calisan_id
LEFT JOIN projeler p ON pa.proje_id = p.proje_id;
```

---

## 5. İleri SQL Özellikleri

### 5.1 Subqueries (Alt Sorgular)

#### Scalar Subquery
```sql
-- Ortalama maaşın üstünde kazananlar
SELECT ad, soyad, maas
FROM calisanlar
WHERE maas > (SELECT AVG(maas) FROM calisanlar);
```

#### IN Subquery
```sql
-- IT departmanındaki çalışanlar
SELECT ad, soyad
FROM calisanlar
WHERE departman_id IN (
    SELECT departman_id 
    FROM departmanlar 
    WHERE departman_adi = 'IT'
);
```

#### EXISTS
```sql
-- En az bir siparişi olan müşteriler
SELECT ad, soyad
FROM musteriler m
WHERE EXISTS (
    SELECT 1 
    FROM siparisler s 
    WHERE s.musteri_id = m.musteri_id
);
```

### 5.2 Views (Görünümler)
```sql
-- View oluşturma
CREATE VIEW calisan_ozeti AS
SELECT 
    c.ad,
    c.soyad,
    d.departman_adi,
    c.maas
FROM calisanlar c
JOIN departmanlar d ON c.departman_id = d.departman_id;

-- View kullanımı
SELECT * FROM calisan_ozeti WHERE maas > 50000;

-- View güncelleme
CREATE OR REPLACE VIEW calisan_ozeti AS
SELECT c.ad, c.soyad, d.departman_adi, c.maas, c.ise_giris_tarihi
FROM calisanlar c
JOIN departmanlar d ON c.departman_id = d.departman_id;

-- View silme
DROP VIEW calisan_ozeti;
```

---

## 6. İlişkisel Veritabanlarının Sınırlamaları

### 6.1 Ölçeklenebilirlik Zorlukları

#### Dikey Ölçeklendirme (Scale-Up)
```
❌ Pahalı (daha güçlü sunucu)
❌ Sınırlı (bir noktada tavan)
❌ Single point of failure
```

#### Yatay Ölçeklendirme (Scale-Out)
```
❌ RDBMS için çok zor
❌ Sharding karmaşık
❌ JOIN'ler yavaşlar
❌ Transaction'lar zorlaşır
```

### 6.2 Performans Darboğazları
- Karmaşık JOIN'ler yavaş
- Milyarlarca satırda index bile yetersiz
- ACID overhead
- Lock contention

### 6.3 Esneklik Kısıtlamaları
- Sabit şema
- Schema migration zor
- Yapısal olmayan veri için uygun değil
- Rapid development zor

### 6.4 Maliyet
- Lisans maliyetleri (Oracle, SQL Server)
- Donanım maliyetleri
- Yönetim maliyeti

---

## 7. Pratik Uygulamalar

### Docker ile PostgreSQL Başlatma
```bash
# PostgreSQL container'ı başlat
docker-compose up -d postgres

# PostgreSQL'e bağlan
docker exec -it veri_postgres psql -U veri_user -d veri_db

# SQL script çalıştır
docker exec -i veri_postgres psql -U veri_user -d veri_db < week2-rdbms/postgres/init-scripts/01-create-schema.sql
```

### Python ile Bağlantı
```python
import psycopg2
from psycopg2.extras import RealDictCursor

# Bağlantı
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="veri_db",
    user="veri_user",
    password="veri_pass"
)

# Cursor oluştur
cursor = conn.cursor(cursor_factory=RealDictCursor)

# Sorgu çalıştır
cursor.execute("SELECT * FROM calisanlar WHERE maas > %s", (50000,))
rows = cursor.fetchall()

for row in rows:
    print(f"{row['ad']} {row['soyad']}: {row['maas']} TL")

cursor.close()
conn.close()
```

---

## 8. Alıştırmalar

### Adım 1: Projeyi Klonlayın veya İndirin

```bash
cd veri-platformlari-egitim/week2-rdms
```

### Adım 2: Docker Container'ı Başlatın

```bash
# Container'ı build et ve başlat
docker-compose up --build -d

# Logları izle
docker-compose logs -f
```

### Adım 3: pgadmin4

Tarayıcınızda açın: **http://localhost:5050/**
Buradan Docker içindeki PostgreSQL'e bağlanabilirsiniz. Ayrıca pgadmin4'ü kullanarak veritabanınızı yönetebilirsiniz.



### Adım 4: adminer

Tarayıcınızda açın: **http://localhost:8080/**
Buradan Docker içindeki PostgreSQL'e bağlanabilirsiniz. Ayrıca adminer'i kullanarak veritabanınızı yönetebilirsiniz.

### Adım 4: Backup Alın

```bash
bash scripts/backup-all.sh
```

```markdown
OUTPUT:
💾 Yedekleme başlatılıyor...
Error response from daemon: No such container: postgres
✅ PostgreSQL yedeklendi
🎉 Tüm yedeklemeler tamamlandı: backups/20250930_181101
```
### Adım 4: Python ile Bağlanın

```bash
pip install -r requirements.txt
python connect_postgres.py 

vy

Jupyter notebook ile çalışmak isterseniz: Week1-rdms deki Notebook'u açabilirsiniz.
```
---

## 9. Kaynaklar

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)
- "Database System Concepts" - Silberschatz, Korth, Sudarshan

---

**[← Hafta 1'e Dön](../hafta1-intro/README.md) | [Ana Sayfaya Dön](../README.md) | [Hafta 3'e Git →](../week3-nosql/README.md)**