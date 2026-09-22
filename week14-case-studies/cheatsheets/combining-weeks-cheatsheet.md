# 📋 Haftaları Birleştirme Cheatsheet

Bu hafta kendi `docker-compose.yml`'i **yok** — vakanıza göre önceki
haftaların servislerini birlikte çalıştırırsınız. Bu, gerçek dünyada
"ayrı ayrı geliştirilmiş servisleri bir araya getirme" becerisinin
küçük ölçekli bir provasıdır.

---

## 🧩 Yöntem 1: Her Hafta Kendi Terminalinde (en basit)

Farklı haftaların servisleri **farklı Docker network'lerinde** çalışır,
birbirleriyle konuşamazlar — ama siz (host makineden) her ikisine de
`localhost:<port>` ile erişebilirsiniz. Çoğu vaka için bu **yeterlidir**:
veriyi bir haftadan çekip Python scriptinizle işleyip başka bir haftaya yazarsınız.

```bash
# Terminal 1
cd week02-di-rdbms && docker compose up -d

# Terminal 2
cd week07-de-kafka && docker compose up -d

# Kendi entegrasyon scriptiniz (host'ta çalışır, ikisine de bağlanır)
python my_integration.py   # localhost:5433 (week02) ve localhost:9092 (week07) kullanır
```

**Port çakışması olursa:** [`PORTS.md`](../../PORTS.md)'e bakın, her haftanın
kendi port aralığı vardır — aynı anda çalıştırmak genelde sorunsuzdur.

---

## 🧩 Yöntem 2: Ortak Network ile Container'lar Arası Bağlantı

Container'ların (host değil, **birbirleriyle**) doğrudan konuşması
gerekiyorsa (örn. bir Airflow DAG'ının başka bir haftanın Postgres'ine
container adıyla bağlanması), paylaşılan bir Docker network'ü kurmanız gerekir.

```bash
# 1. Paylaşılan bir network oluşturun
docker network create week14_shared

# 2. Her iki haftanın compose dosyasına bu network'ü EK olarak bağlayın
#    (docker-compose.override.yml ile, orijinal dosyaları değiştirmeden)
```

`docker-compose.override.yml` (week02 klasöründe):
```yaml
services:
  postgres:
    networks:
      - week14_shared

networks:
  week14_shared:
    external: true
```

Aynı override deseni week07'nin `kafka` servisi için de eklenir. Compose,
aynı klasördeki `docker-compose.override.yml`'i **otomatik** okur — ekstra
bir `-f` bayrağı gerekmez.

```bash
cd week02-di-rdbms && docker compose up -d       # override otomatik uygulanır
cd ../week07-de-kafka && docker compose up -d    # override otomatik uygulanır

# Artık week07'nin bir container'ından week02'nin postgres'ine
# container adıyla erişilebilir (host adı: "postgres", ama dikkat:
# iki haftada da "postgres" adında servis varsa çakışma olur —
# gerekirse override'da container_name/hostname'i özelleştirin)
```

---

## 🧩 Yöntem 3: Tek Bir `docker compose -f ... -f ...` Komutu

Birden fazla compose dosyasını **tek bir proje** altında birleştirebilirsiniz:

```bash
docker compose \
  -f week02-di-rdbms/docker-compose.yml \
  -f week07-de-kafka/docker-compose.yml \
  -f week11-bi-reporting/docker-compose.yml \
  --project-name week14-case1 \
  up -d postgres kafka connect metabase
```

⚠️ **Dikkat:** Her orijinal dosyada servisler kendi named network'lerine
(`week02_network`, `week07_network`…) bağlıdır. Bu komut hepsini
**tek bir proje** altında ayağa kaldırır ama servisler **birbirleriyle
otomatik konuşamaz** (hâlâ ayrı network'lerdeler) — container'lar arası
iletişim gerekiyorsa Yöntem 2'deki gibi bir paylaşılan network eklemeniz gerekir.

---

## 🗺 Hangi Yöntem Ne Zaman

| İhtiyaç | Yöntem |
|---|---|
| Sadece host'unuzdan her ikisine de erişim (script ile entegrasyon) | **1** |
| Container'lar birbirini adıyla bulmalı (örn. Airflow → başka haftanın DB'si) | **2** |
| Tek komutla hepsini başlatıp durdurmak istiyorsunuz, network önemli değil | **3** |

Çoğu vaka için **Yöntem 1** yeterlidir — kendi Python/Airflow scriptiniz
host'ta (ya da kendi container'ınızda) çalışır, farklı haftaların açık
portlarına bağlanır. Bu, gerçek dünyadaki "farklı ekiplerin farklı
sistemler işlettiği, sizin entegrasyon kodu yazdığınız" senaryoyu da
daha iyi yansıtır.

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Aynı port iki haftada da kullanılıyor | Nadir ama mümkün, özellikle özelleştirdiyseniz | `docker-compose.override.yml` ile portu değiştirin |
| Container adı çakışması | İki haftada da aynı `container_name` | Override ile birini yeniden adlandırın |
| Toplam RAM yetmiyor | 2-3 haftanın servisleri birlikte ağır | Vakanız için gerçekten gerekli servisleri seçin, gerisini kapatın |
| Container'lar birbirini bulamıyor | Farklı network'lerdeler (Yöntem 3 tuzağı) | Yöntem 2'deki paylaşılan network deseni |

---

**[← Hafta 14 README](../README.md)**
