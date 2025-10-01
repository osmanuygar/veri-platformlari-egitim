--
-- PostgreSQL database dump
--

\restrict YZN86hecjFM7ko9hBAosYldGNHJpYUqw9TlMdhTz1Po928h10VR1YpMZbu78Ois

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ecommerce; Type: SCHEMA; Schema: -; Owner: veri_user
--

CREATE SCHEMA ecommerce;


ALTER SCHEMA ecommerce OWNER TO veri_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adresler; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.adresler (
    adres_id integer NOT NULL,
    musteri_id integer NOT NULL,
    adres_baslik character varying(50) NOT NULL,
    adres_satir1 character varying(200) NOT NULL,
    adres_satir2 character varying(200),
    sehir character varying(50) NOT NULL,
    ilce character varying(50),
    posta_kodu character varying(10),
    ulke character varying(50) DEFAULT 'Türkiye'::character varying,
    varsayilan boolean DEFAULT false
);


ALTER TABLE ecommerce.adresler OWNER TO veri_user;

--
-- Name: adresler_adres_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.adresler_adres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.adresler_adres_id_seq OWNER TO veri_user;

--
-- Name: adresler_adres_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.adresler_adres_id_seq OWNED BY ecommerce.adresler.adres_id;


--
-- Name: kategoriler; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.kategoriler (
    kategori_id integer NOT NULL,
    kategori_adi character varying(100) NOT NULL,
    aciklama text,
    ust_kategori_id integer
);


ALTER TABLE ecommerce.kategoriler OWNER TO veri_user;

--
-- Name: kategoriler_kategori_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.kategoriler_kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.kategoriler_kategori_id_seq OWNER TO veri_user;

--
-- Name: kategoriler_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.kategoriler_kategori_id_seq OWNED BY ecommerce.kategoriler.kategori_id;


--
-- Name: musteriler; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.musteriler (
    musteri_id integer NOT NULL,
    ad character varying(50) NOT NULL,
    soyad character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    telefon character varying(20),
    dogum_tarihi date,
    kayit_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    aktif boolean DEFAULT true,
    CONSTRAINT chk_dogum_tarihi CHECK ((dogum_tarihi < CURRENT_DATE)),
    CONSTRAINT chk_email CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'::text))
);


ALTER TABLE ecommerce.musteriler OWNER TO veri_user;

--
-- Name: TABLE musteriler; Type: COMMENT; Schema: ecommerce; Owner: veri_user
--

COMMENT ON TABLE ecommerce.musteriler IS 'Müşteri bilgileri';


--
-- Name: COLUMN musteriler.musteri_id; Type: COMMENT; Schema: ecommerce; Owner: veri_user
--

COMMENT ON COLUMN ecommerce.musteriler.musteri_id IS 'Benzersiz müşteri kimliği';


--
-- Name: COLUMN musteriler.email; Type: COMMENT; Schema: ecommerce; Owner: veri_user
--

COMMENT ON COLUMN ecommerce.musteriler.email IS 'Müşteri email adresi (benzersiz)';


--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.musteriler_musteri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.musteriler_musteri_id_seq OWNER TO veri_user;

--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.musteriler_musteri_id_seq OWNED BY ecommerce.musteriler.musteri_id;


--
-- Name: siparis_detaylari; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.siparis_detaylari (
    detay_id integer NOT NULL,
    siparis_id integer NOT NULL,
    urun_id integer NOT NULL,
    adet integer NOT NULL,
    birim_fiyat numeric(10,2) NOT NULL,
    indirim_orani numeric(5,2) DEFAULT 0,
    ara_toplam numeric(10,2) NOT NULL,
    CONSTRAINT chk_adet CHECK ((adet > 0)),
    CONSTRAINT chk_birim_fiyat CHECK ((birim_fiyat > (0)::numeric)),
    CONSTRAINT chk_indirim CHECK (((indirim_orani >= (0)::numeric) AND (indirim_orani <= (100)::numeric)))
);


ALTER TABLE ecommerce.siparis_detaylari OWNER TO veri_user;

--
-- Name: siparis_detaylari_detay_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.siparis_detaylari_detay_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.siparis_detaylari_detay_id_seq OWNER TO veri_user;

--
-- Name: siparis_detaylari_detay_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.siparis_detaylari_detay_id_seq OWNED BY ecommerce.siparis_detaylari.detay_id;


--
-- Name: siparisler; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.siparisler (
    siparis_id integer NOT NULL,
    musteri_id integer NOT NULL,
    siparis_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    durum character varying(20) DEFAULT 'Beklemede'::character varying,
    toplam_tutar numeric(10,2) NOT NULL,
    kargo_adresi_id integer,
    kargo_ucreti numeric(8,2) DEFAULT 0,
    odeme_yontemi character varying(50),
    CONSTRAINT chk_durum CHECK (((durum)::text = ANY ((ARRAY['Beklemede'::character varying, 'Onaylandi'::character varying, 'Hazirlaniyor'::character varying, 'Kargoda'::character varying, 'Teslim Edildi'::character varying, 'Iptal'::character varying])::text[]))),
    CONSTRAINT chk_toplam CHECK ((toplam_tutar >= (0)::numeric))
);


ALTER TABLE ecommerce.siparisler OWNER TO veri_user;

--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.siparisler_siparis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.siparisler_siparis_id_seq OWNER TO veri_user;

--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.siparisler_siparis_id_seq OWNED BY ecommerce.siparisler.siparis_id;


--
-- Name: stok_hareketleri; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.stok_hareketleri (
    hareket_id integer NOT NULL,
    urun_id integer NOT NULL,
    hareket_tipi character varying(20) NOT NULL,
    miktar integer NOT NULL,
    onceki_stok integer NOT NULL,
    yeni_stok integer NOT NULL,
    aciklama text,
    hareket_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_hareket_tipi CHECK (((hareket_tipi)::text = ANY ((ARRAY['Giris'::character varying, 'Cikis'::character varying, 'Duzeltme'::character varying, 'Iade'::character varying])::text[])))
);


ALTER TABLE ecommerce.stok_hareketleri OWNER TO veri_user;

--
-- Name: stok_hareketleri_hareket_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.stok_hareketleri_hareket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.stok_hareketleri_hareket_id_seq OWNER TO veri_user;

--
-- Name: stok_hareketleri_hareket_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.stok_hareketleri_hareket_id_seq OWNED BY ecommerce.stok_hareketleri.hareket_id;


--
-- Name: urun_yorumlari; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.urun_yorumlari (
    yorum_id integer NOT NULL,
    urun_id integer NOT NULL,
    musteri_id integer NOT NULL,
    puan integer NOT NULL,
    yorum_baslik character varying(200),
    yorum_metni text,
    yorum_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    onaylandi boolean DEFAULT false,
    CONSTRAINT chk_puan CHECK (((puan >= 1) AND (puan <= 5)))
);


ALTER TABLE ecommerce.urun_yorumlari OWNER TO veri_user;

--
-- Name: urun_yorumlari_yorum_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.urun_yorumlari_yorum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.urun_yorumlari_yorum_id_seq OWNER TO veri_user;

--
-- Name: urun_yorumlari_yorum_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.urun_yorumlari_yorum_id_seq OWNED BY ecommerce.urun_yorumlari.yorum_id;


--
-- Name: urunler; Type: TABLE; Schema: ecommerce; Owner: veri_user
--

CREATE TABLE ecommerce.urunler (
    urun_id integer NOT NULL,
    kategori_id integer,
    urun_adi character varying(200) NOT NULL,
    aciklama text,
    fiyat numeric(10,2) NOT NULL,
    maliyet numeric(10,2),
    stok_miktari integer DEFAULT 0,
    min_stok_seviyesi integer DEFAULT 10,
    aktif boolean DEFAULT true,
    ekleme_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_fiyat CHECK ((fiyat > (0)::numeric)),
    CONSTRAINT chk_stok CHECK ((stok_miktari >= 0))
);


ALTER TABLE ecommerce.urunler OWNER TO veri_user;

--
-- Name: urunler_urun_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: veri_user
--

CREATE SEQUENCE ecommerce.urunler_urun_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.urunler_urun_id_seq OWNER TO veri_user;

--
-- Name: urunler_urun_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: veri_user
--

ALTER SEQUENCE ecommerce.urunler_urun_id_seq OWNED BY ecommerce.urunler.urun_id;


--
-- Name: v_musteri_ozet; Type: VIEW; Schema: ecommerce; Owner: veri_user
--

CREATE VIEW ecommerce.v_musteri_ozet AS
 SELECT m.musteri_id,
    (((m.ad)::text || ' '::text) || (m.soyad)::text) AS ad_soyad,
    m.email,
    count(s.siparis_id) AS toplam_siparis,
    COALESCE(sum(s.toplam_tutar), (0)::numeric) AS toplam_harcama,
    max(s.siparis_tarihi) AS son_siparis_tarihi
   FROM (ecommerce.musteriler m
     LEFT JOIN ecommerce.siparisler s ON ((m.musteri_id = s.musteri_id)))
  WHERE (m.aktif = true)
  GROUP BY m.musteri_id, m.ad, m.soyad, m.email;


ALTER TABLE ecommerce.v_musteri_ozet OWNER TO veri_user;

--
-- Name: v_urun_ozet; Type: VIEW; Schema: ecommerce; Owner: veri_user
--

CREATE VIEW ecommerce.v_urun_ozet AS
 SELECT u.urun_id,
    u.urun_adi,
    k.kategori_adi,
    u.fiyat,
    u.stok_miktari,
    count(DISTINCT y.yorum_id) AS yorum_sayisi,
    round(avg(y.puan), 2) AS ortalama_puan,
    count(DISTINCT sd.siparis_id) AS satis_sayisi
   FROM (((ecommerce.urunler u
     LEFT JOIN ecommerce.kategoriler k ON ((u.kategori_id = k.kategori_id)))
     LEFT JOIN ecommerce.urun_yorumlari y ON ((u.urun_id = y.urun_id)))
     LEFT JOIN ecommerce.siparis_detaylari sd ON ((u.urun_id = sd.urun_id)))
  WHERE (u.aktif = true)
  GROUP BY u.urun_id, u.urun_adi, k.kategori_adi, u.fiyat, u.stok_miktari;


ALTER TABLE ecommerce.v_urun_ozet OWNER TO veri_user;

--
-- Name: adresler adres_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.adresler ALTER COLUMN adres_id SET DEFAULT nextval('ecommerce.adresler_adres_id_seq'::regclass);


--
-- Name: kategoriler kategori_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.kategoriler ALTER COLUMN kategori_id SET DEFAULT nextval('ecommerce.kategoriler_kategori_id_seq'::regclass);


--
-- Name: musteriler musteri_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.musteriler ALTER COLUMN musteri_id SET DEFAULT nextval('ecommerce.musteriler_musteri_id_seq'::regclass);


--
-- Name: siparis_detaylari detay_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparis_detaylari ALTER COLUMN detay_id SET DEFAULT nextval('ecommerce.siparis_detaylari_detay_id_seq'::regclass);


--
-- Name: siparisler siparis_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparisler ALTER COLUMN siparis_id SET DEFAULT nextval('ecommerce.siparisler_siparis_id_seq'::regclass);


--
-- Name: stok_hareketleri hareket_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.stok_hareketleri ALTER COLUMN hareket_id SET DEFAULT nextval('ecommerce.stok_hareketleri_hareket_id_seq'::regclass);


--
-- Name: urun_yorumlari yorum_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urun_yorumlari ALTER COLUMN yorum_id SET DEFAULT nextval('ecommerce.urun_yorumlari_yorum_id_seq'::regclass);


--
-- Name: urunler urun_id; Type: DEFAULT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urunler ALTER COLUMN urun_id SET DEFAULT nextval('ecommerce.urunler_urun_id_seq'::regclass);


--
-- Data for Name: adresler; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.adresler (adres_id, musteri_id, adres_baslik, adres_satir1, adres_satir2, sehir, ilce, posta_kodu, ulke, varsayilan) FROM stdin;
1	1	Ev	Atatürk Cad. No:123	\N	Istanbul	Kadıköy	34710	Türkiye	t
2	1	İş	Barbaros Bulvarı No:45	\N	Istanbul	Beşiktaş	34353	Türkiye	f
3	2	Ev	Cumhuriyet Mah. Sok:15	\N	Ankara	Çankaya	06420	Türkiye	t
4	3	Ev	Alsancak Mah. No:78	\N	Izmir	Konak	35220	Türkiye	t
5	4	Ev	Bahçelievler Mah. No:90	\N	Antalya	Muratpaşa	07050	Türkiye	t
6	5	Ev	Kemeraltı Cad. No:34	\N	Bursa	Osmangazi	16010	Türkiye	t
\.


--
-- Data for Name: kategoriler; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.kategoriler (kategori_id, kategori_adi, aciklama, ust_kategori_id) FROM stdin;
1	Elektronik	Elektronik ürünler	\N
2	Bilgisayar	Bilgisayar ve aksesuarları	1
3	Telefon	Akıllı telefonlar	1
4	Giyim	Giyim ürünleri	\N
5	Erkek Giyim	Erkek giyim ürünleri	4
6	Kadın Giyim	Kadın giyim ürünleri	4
7	Kitap	Kitaplar ve dergiler	\N
8	Ev & Yaşam	Ev eşyaları	\N
\.


--
-- Data for Name: musteriler; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.musteriler (musteri_id, ad, soyad, email, telefon, dogum_tarihi, kayit_tarihi, aktif) FROM stdin;
1	Ahmet	Yılmaz	ahmet.yilmaz@example.com	0532-111-2233	1985-05-15	2025-09-30 14:28:32.643757	t
2	Mehmet	Kaya	mehmet.kaya@example.com	0533-222-3344	1990-08-20	2025-09-30 14:28:32.643757	t
3	Ayşe	Demir	ayse.demir@example.com	0534-333-4455	1988-03-10	2025-09-30 14:28:32.643757	t
4	Fatma	Şahin	fatma.sahin@example.com	0535-444-5566	1992-11-25	2025-09-30 14:28:32.643757	t
5	Ali	Çelik	ali.celik@example.com	0536-555-6677	1987-07-30	2025-09-30 14:28:32.643757	t
6	Zeynep	Arslan	zeynep.arslan@example.com	0537-666-7788	1995-02-14	2025-09-30 14:28:32.643757	t
7	Mustafa	Aydın	mustafa.aydin@example.com	0538-777-8899	1983-09-05	2025-09-30 14:28:32.643757	t
8	Elif	Yıldız	elif.yildiz@example.com	0539-888-9900	1991-12-18	2025-09-30 14:28:32.643757	t
9	Can	Özdemir	can.ozdemir@example.com	0540-999-0011	1989-04-22	2025-09-30 14:28:32.643757	t
10	Selin	Kurt	selin.kurt@example.com	0541-000-1122	1994-06-08	2025-09-30 14:28:32.643757	t
\.


--
-- Data for Name: siparis_detaylari; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.siparis_detaylari (detay_id, siparis_id, urun_id, adet, birim_fiyat, indirim_orani, ara_toplam) FROM stdin;
\.


--
-- Data for Name: siparisler; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.siparisler (siparis_id, musteri_id, siparis_tarihi, durum, toplam_tutar, kargo_adresi_id, kargo_ucreti, odeme_yontemi) FROM stdin;
1	1	2025-01-15 10:30:00	Teslim Edildi	25450.00	1	0.00	Kredi Kartı
2	2	2025-01-16 14:20:00	Teslim Edildi	45000.00	3	0.00	Banka Havalesi
3	3	2025-01-17 09:15:00	Kargoda	1850.00	4	0.00	Kredi Kartı
4	4	2025-01-18 16:45:00	Hazirlaniyor	650.00	5	0.00	Kapıda Ödeme
5	5	2025-01-19 11:00:00	Onaylandi	920.00	6	0.00	Kredi Kartı
6	1	2025-01-20 13:30:00	Beklemede	350.00	1	0.00	Kredi Kartı
7	6	2025-01-21 10:00:00	Onaylandi	35000.00	\N	0.00	Banka Havalesi
8	7	2025-01-22 15:20:00	Hazirlaniyor	800.00	\N	0.00	Kredi Kartı
9	8	2025-01-23 09:45:00	Teslim Edildi	1200.00	\N	0.00	Kapıda Ödeme
10	9	2025-01-24 14:10:00	Kargoda	450.00	\N	0.00	Kredi Kartı
\.


--
-- Data for Name: stok_hareketleri; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.stok_hareketleri (hareket_id, urun_id, hareket_tipi, miktar, onceki_stok, yeni_stok, aciklama, hareket_tarihi) FROM stdin;
\.


--
-- Data for Name: urun_yorumlari; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.urun_yorumlari (yorum_id, urun_id, musteri_id, puan, yorum_baslik, yorum_metni, yorum_tarihi, onaylandi) FROM stdin;
\.


--
-- Data for Name: urunler; Type: TABLE DATA; Schema: ecommerce; Owner: veri_user
--

COPY ecommerce.urunler (urun_id, kategori_id, urun_adi, aciklama, fiyat, maliyet, stok_miktari, min_stok_seviyesi, aktif, ekleme_tarihi) FROM stdin;
1	2	Laptop Dell XPS 13	13 inç, Intel i7, 16GB RAM, 512GB SSD	25000.00	18000.00	15	5	t	2025-09-30 14:28:32.646426
2	2	MacBook Air M2	13 inç, Apple M2, 8GB RAM, 256GB SSD	35000.00	28000.00	10	3	t	2025-09-30 14:28:32.646426
3	2	Asus ROG Gaming Laptop	15 inç, RTX 3060, 16GB RAM, 1TB SSD	32000.00	24000.00	8	3	t	2025-09-30 14:28:32.646426
4	3	iPhone 14 Pro	128GB, Space Black	45000.00	38000.00	20	5	t	2025-09-30 14:28:32.646426
5	3	Samsung Galaxy S23	256GB, Phantom Black	35000.00	28000.00	25	5	t	2025-09-30 14:28:32.646426
6	3	Google Pixel 7	128GB, Snow	28000.00	22000.00	12	5	t	2025-09-30 14:28:32.646426
7	5	Erkek Kot Pantolon	Slim fit, Lacivert	450.00	200.00	50	20	t	2025-09-30 14:28:32.646426
8	5	Erkek Gömlek	Beyaz, Pamuklu	350.00	150.00	40	15	t	2025-09-30 14:28:32.646426
9	6	Kadın Elbise	Çiçek desenli, Yaz koleksiyonu	650.00	300.00	30	10	t	2025-09-30 14:28:32.646426
10	6	Kadın Bluz	Saten, Pembe	400.00	180.00	35	15	t	2025-09-30 14:28:32.646426
11	7	Suç ve Ceza	Dostoyevski, Klasik	120.00	50.00	100	20	t	2025-09-30 14:28:32.646426
12	7	Simyacı	Paulo Coelho, Roman	95.00	40.00	80	20	t	2025-09-30 14:28:32.646426
13	7	İnce Memed	Yaşar Kemal, Roman	110.00	45.00	60	15	t	2025-09-30 14:28:32.646426
14	8	Kahve Makinesi	Otomatik, Paslanmaz çelik	1200.00	700.00	25	10	t	2025-09-30 14:28:32.646426
15	8	Blender	1000W, 2L kapasite	800.00	400.00	30	10	t	2025-09-30 14:28:32.646426
\.


--
-- Name: adresler_adres_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.adresler_adres_id_seq', 33, true);


--
-- Name: kategoriler_kategori_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.kategoriler_kategori_id_seq', 33, true);


--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.musteriler_musteri_id_seq', 33, true);


--
-- Name: siparis_detaylari_detay_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.siparis_detaylari_detay_id_seq', 33, true);


--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.siparisler_siparis_id_seq', 33, true);


--
-- Name: stok_hareketleri_hareket_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.stok_hareketleri_hareket_id_seq', 1, false);


--
-- Name: urun_yorumlari_yorum_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.urun_yorumlari_yorum_id_seq', 1, false);


--
-- Name: urunler_urun_id_seq; Type: SEQUENCE SET; Schema: ecommerce; Owner: veri_user
--

SELECT pg_catalog.setval('ecommerce.urunler_urun_id_seq', 33, true);


--
-- Name: adresler adresler_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.adresler
    ADD CONSTRAINT adresler_pkey PRIMARY KEY (adres_id);


--
-- Name: kategoriler kategoriler_kategori_adi_key; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.kategoriler
    ADD CONSTRAINT kategoriler_kategori_adi_key UNIQUE (kategori_adi);


--
-- Name: kategoriler kategoriler_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.kategoriler
    ADD CONSTRAINT kategoriler_pkey PRIMARY KEY (kategori_id);


--
-- Name: musteriler musteriler_email_key; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.musteriler
    ADD CONSTRAINT musteriler_email_key UNIQUE (email);


--
-- Name: musteriler musteriler_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.musteriler
    ADD CONSTRAINT musteriler_pkey PRIMARY KEY (musteri_id);


--
-- Name: siparis_detaylari siparis_detaylari_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparis_detaylari
    ADD CONSTRAINT siparis_detaylari_pkey PRIMARY KEY (detay_id);


--
-- Name: siparisler siparisler_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparisler
    ADD CONSTRAINT siparisler_pkey PRIMARY KEY (siparis_id);


--
-- Name: stok_hareketleri stok_hareketleri_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.stok_hareketleri
    ADD CONSTRAINT stok_hareketleri_pkey PRIMARY KEY (hareket_id);


--
-- Name: urun_yorumlari urun_yorumlari_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urun_yorumlari
    ADD CONSTRAINT urun_yorumlari_pkey PRIMARY KEY (yorum_id);


--
-- Name: urunler urunler_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urunler
    ADD CONSTRAINT urunler_pkey PRIMARY KEY (urun_id);


--
-- Name: idx_adresler_musteri; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_adresler_musteri ON ecommerce.adresler USING btree (musteri_id);


--
-- Name: idx_detay_siparis; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_detay_siparis ON ecommerce.siparis_detaylari USING btree (siparis_id);


--
-- Name: idx_detay_urun; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_detay_urun ON ecommerce.siparis_detaylari USING btree (urun_id);


--
-- Name: idx_siparisler_durum; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_siparisler_durum ON ecommerce.siparisler USING btree (durum);


--
-- Name: idx_siparisler_musteri; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_siparisler_musteri ON ecommerce.siparisler USING btree (musteri_id);


--
-- Name: idx_siparisler_tarih; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_siparisler_tarih ON ecommerce.siparisler USING btree (siparis_tarihi DESC);


--
-- Name: idx_stok_tarih; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_stok_tarih ON ecommerce.stok_hareketleri USING btree (hareket_tarihi DESC);


--
-- Name: idx_stok_urun; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_stok_urun ON ecommerce.stok_hareketleri USING btree (urun_id);


--
-- Name: idx_urunler_aktif; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_urunler_aktif ON ecommerce.urunler USING btree (aktif) WHERE (aktif = true);


--
-- Name: idx_urunler_fiyat; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_urunler_fiyat ON ecommerce.urunler USING btree (fiyat);


--
-- Name: idx_urunler_kategori; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_urunler_kategori ON ecommerce.urunler USING btree (kategori_id);


--
-- Name: idx_yorumlar_tarih; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_yorumlar_tarih ON ecommerce.urun_yorumlari USING btree (yorum_tarihi DESC);


--
-- Name: idx_yorumlar_urun; Type: INDEX; Schema: ecommerce; Owner: veri_user
--

CREATE INDEX idx_yorumlar_urun ON ecommerce.urun_yorumlari USING btree (urun_id);


--
-- Name: siparisler fk_kargo_adres; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparisler
    ADD CONSTRAINT fk_kargo_adres FOREIGN KEY (kargo_adresi_id) REFERENCES ecommerce.adresler(adres_id) ON DELETE SET NULL;


--
-- Name: urunler fk_kategori; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urunler
    ADD CONSTRAINT fk_kategori FOREIGN KEY (kategori_id) REFERENCES ecommerce.kategoriler(kategori_id) ON DELETE SET NULL;


--
-- Name: adresler fk_musteri; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.adresler
    ADD CONSTRAINT fk_musteri FOREIGN KEY (musteri_id) REFERENCES ecommerce.musteriler(musteri_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: siparisler fk_musteri_siparis; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparisler
    ADD CONSTRAINT fk_musteri_siparis FOREIGN KEY (musteri_id) REFERENCES ecommerce.musteriler(musteri_id) ON DELETE RESTRICT;


--
-- Name: siparis_detaylari fk_siparis; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparis_detaylari
    ADD CONSTRAINT fk_siparis FOREIGN KEY (siparis_id) REFERENCES ecommerce.siparisler(siparis_id) ON DELETE CASCADE;


--
-- Name: stok_hareketleri fk_stok_urun; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.stok_hareketleri
    ADD CONSTRAINT fk_stok_urun FOREIGN KEY (urun_id) REFERENCES ecommerce.urunler(urun_id) ON DELETE CASCADE;


--
-- Name: siparis_detaylari fk_urun; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.siparis_detaylari
    ADD CONSTRAINT fk_urun FOREIGN KEY (urun_id) REFERENCES ecommerce.urunler(urun_id) ON DELETE RESTRICT;


--
-- Name: kategoriler fk_ust_kategori; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.kategoriler
    ADD CONSTRAINT fk_ust_kategori FOREIGN KEY (ust_kategori_id) REFERENCES ecommerce.kategoriler(kategori_id) ON DELETE SET NULL;


--
-- Name: urun_yorumlari fk_yorum_musteri; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urun_yorumlari
    ADD CONSTRAINT fk_yorum_musteri FOREIGN KEY (musteri_id) REFERENCES ecommerce.musteriler(musteri_id) ON DELETE CASCADE;


--
-- Name: urun_yorumlari fk_yorum_urun; Type: FK CONSTRAINT; Schema: ecommerce; Owner: veri_user
--

ALTER TABLE ONLY ecommerce.urun_yorumlari
    ADD CONSTRAINT fk_yorum_urun FOREIGN KEY (urun_id) REFERENCES ecommerce.urunler(urun_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict YZN86hecjFM7ko9hBAosYldGNHJpYUqw9TlMdhTz1Po928h10VR1YpMZbu78Ois

