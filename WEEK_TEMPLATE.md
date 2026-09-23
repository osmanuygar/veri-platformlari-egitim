# 🧩 Hafta Şablonu

Bu dosya, **her haftanın aynı iskelete** sahip olmasını sağlar. Öğrenciler 1–3. haftalarda
alıştıkları düzeni 14. haftaya kadar aynen buluyor; yeni hafta hazırlarken de tahmin
yürütmeye gerek kalmıyor.

---

## Neden bu iskelet?

İlk sezonda en çok geri bildirim alan haftaların (1, 2, 3) ortak beş özelliği vardı.
Şablon bu beşini zorunlu hale getiriyor:

| # | Özellik | Neden işe yarıyor |
|---|---|---|
| 1 | **Tek komutluk kurulum** (`setup-weekNN.sh`) | Öğrenci ilk 5 dakikada kuruluma değil konuya bakıyor |
| 2 | **Hazır gelen veri** (`init/` veya `init-scripts/`) | Container açılır açılmaz sorgulanacak veri var, boş ekran yok |
| 3 | **Cheatsheet** (`cheatsheets/`) | Ders sırasında kopyala-yapıştır; sonradan da referans |
| 4 | **Ayrı alıştırma + çözüm** (`exercises/`, `exercises/solutions/`) | Önce dene, sonra bak |
| 5 | **Bir "wow" anı** | Haftayı akılda kalıcı yapan tek somut demo |
| 6 | **Alternatifler ve ekosistem** | Öğrenci aracı değil kategoriyi öğrenir; iş hayatında karşısına çıkan açık kaynak ve enterprise araçları tanır |

> 5. madde en kritiği. Hafta 3'ün Trino'su (tek SQL ile 4 farklı veritabanını sorgulamak)
> bu yüzden akılda kaldı. Her hafta böyle **bir** ana ihtiyaç duyar.

---

## Klasör yapısı

```
weekNN-kategori-konu/
├── README.md                 # Ders notu (aşağıdaki bölüm sırası zorunlu)
├── docker-compose.yml        # Haftanın servisleri, PORTS.md'deki portlarla
├── setup-weekNN.sh           # Tek komutluk kurulum + sağlık kontrolü + özet çıktı
├── .env.example              # Gizli olmayan varsayılanlar
├── requirements.txt          # Python bağımlılıkları (varsa)
├── init/                     # Container açılışında otomatik yüklenen şema + veri
├── scripts/                  # Çalıştırılabilir örnekler (producer.py, etl.py …)
├── notebooks/                # Jupyter defterleri (varsa)
├── exercises/
│   ├── 01-....sql|py|js
│   └── solutions/            # Çözümler ayrı klasörde
└── cheatsheets/
    └── <araç>-cheatsheet.md
```

### Adlandırma kuralları

- Klasör: `weekNN-kategori-konu` — `NN` sıfır dolgulu, `kategori` ∈ `di | de | ds | bi | dg`
- Container adı: `weekNN_<servis>` (örn. `week07_kafka`) — haftalar arası çakışmayı önler
- Volume adı: `weekNN_<servis>_data`
- Docker network: `weekNN_network`

---

## README bölüm sırası (zorunlu)

```markdown
# Hafta N: Başlık
> Kategori rozeti · Durum

## 📚 İçindekiler
## 🎯 Öğrenme Hedefleri      ← ölçülebilir fiillerle, checkbox olarak
## 1..K  <Konu başlıkları>   ← ders notu
## 🔄 Alternatifler ve Ekosistem  ← aşağıdaki formatta, zorunlu
## 🚀 Hızlı Başlangıç        ← setup script + servis tablosu + durdurma
## 🧪 Pratik Uygulamalar     ← "Bu Haftanın Wow Anı" alt başlığı dahil
## 📝 Alıştırmalar
## 📋 Cheatsheet
## 📖 Kaynaklar
<navigasyon: ← önceki | 🏠 ana sayfa | sonraki →>
```

---

## 🔄 Alternatifler ve Ekosistem bölümü

Derste tek bir araç kullanıyoruz ama öğrenci iş hayatında başka araçlarla karşılaşacak.
Bu bölümün amacı öğrenciye **"bu aracın yerine ne kullanılabilirdi, neye bakarak seçilirdi?"**
sorusunu sordurmak. Uzun bir katalog olması gerekmez; haftada kullanılan her ana
araç için bir satır yeterli.

Tablo formatı sabittir:

```markdown
## 🔄 Alternatifler ve Ekosistem

Bu hafta kullandığımız araçlar tek seçenek değil. Aynı işi yapan açık kaynak ve
enterprise/yönetilen alternatifler:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **<Araç>** | A, B, C | X, Y, Z | Hangi ihtiyaçta alternatife bakılır |

**Değerlendirirken bakılacaklar:** <bu kategoriye özgü 3–5 kriter>

> ⚖️ **Lisans notu:** (varsa) lisans değişikliği, fork, "açık kaynak değil ama ücretsiz" durumları

📎 Tüm katmanların haritası: [ALTERNATIVES.md](../ALTERNATIVES.md)
```

Kurallar:

- **"Enterprise / Yönetilen"** sütununa hem ticari ürünler (Tableau, Collibra) hem de
  açık kaynak bir aracın yönetilen sürümü (Confluent Cloud, MWAA) yazılabilir.
- **"Ne zaman değerlendirilmeli"** sütunu boş bırakılmaz — isim listesi değil karar ölçütü istiyoruz.
- Lisansı açık kaynak olmayan ama ücretsiz kullanılabilen araçları (BSL, SSPL, ELv2,
  Confluent Community License) "açık kaynak" sütununa yazmayın; lisans notunda belirtin.
- Yeni bir araç eklendiğinde [ALTERNATIVES.md](./ALTERNATIVES.md) de güncellenir.

---

## Öğrenme hedefi yazarken

Ölçülebilir fiil kullanın — "öğrenmek" ölçülemez, "kurmak/karşılaştırmak/yorumlamak" ölçülebilir.

| ✅ İyi | ❌ Kötü |
|---|---|
| "Debezium ile CDC akışı kurup değişiklikleri izlemek" | "Kafka'yı öğrenmek" |
| "p-değerini doğru yorumlamak" | "İstatistik bilmek" |
| "Dengesiz veride doğru metriği seçmek ve gerekçelendirmek" | "Model değerlendirmeyi anlamak" |

---

## setup-weekNN.sh iskeleti

```bash
#!/usr/bin/env bash
set -euo pipefail

WEEK="weekNN-kategori-konu"
cd "$(dirname "$0")"

echo "🚀 $WEEK kurulumu başlıyor…"

command -v docker >/dev/null || { echo "❌ Docker bulunamadı"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "❌ Docker Compose v2 gerekli"; exit 1; }

[ -f .env ] || { cp .env.example .env 2>/dev/null || true; }

docker compose up -d

echo "⏳ Servislerin hazır olması bekleniyor…"
for i in $(seq 1 60); do
  if docker compose ps --format json | grep -q '"Health":"healthy"'; then break; fi
  sleep 2
done

echo ""
echo "✅ Hazır. Arayüzler:"
echo "   • <Servis>  → http://localhost:<port>"
echo ""
echo "📖 Ders notu: ./README.md"
echo "📝 Alıştırmalar: ./exercises/"
```

> Her servise `healthcheck` ekleyin — script'in beklemesi ancak o zaman anlamlı olur.

---

## Kontrol listesi (hafta bitmeden)

- [ ] `docker compose up -d` temiz bir makinede hatasız çalışıyor
- [ ] `docker compose down -v` sonrası tekrar kurulum sorunsuz (yeniden üretilebilirlik)
- [ ] Portlar [`PORTS.md`](./PORTS.md) ile uyumlu, çakışma yok
- [ ] Container açılışında veri otomatik yükleniyor (`init/`)
- [ ] En az 4 alıştırma + çözümleri var
- [ ] En az 1 cheatsheet var
- [ ] "🔄 Alternatifler ve Ekosistem" bölümü var; haftanın her ana aracı tabloda
- [ ] "Wow anı" README'de yazılı ve gerçekten çalışıyor
- [ ] Navigasyon linkleri önceki/sonraki haftaya doğru gidiyor
- [ ] Kök `README.md` müfredat tablosunda durumu güncel
- [ ] Toplam RAM tüketimi `docker stats` ile ölçüldü ve README'de yazılı

---

**[🏠 Ana Sayfa](./README.md)** · **[🔌 Port Haritası](./PORTS.md)** · **[🔄 Alternatifler](./ALTERNATIVES.md)**
