# Alıştırma 1: KPI Tasarımı

**Süre:** ~20 dakika · **Format:** Yazılı

---

## 1.1 Senaryo

Bu haftaki `bi.fact_sales` verisiyle çalışan bir e-ticaret şirketinin
**Satış Direktörü** için bir dashboard tasarlıyorsunuz.

**Görev:** 5 KPI tanımlayın. Her biri için:

| Metrik | Tam tanım (formül) | Sahibi | Öncü mü gecikmeli mi |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

Örnek satır: *"Aylık Tekrar Eden Müşteri Oranı — (bu ay ≥2 sipariş veren
müşteri sayısı) / (bu ay sipariş veren toplam müşteri) — Sahibi: CRM Ekibi
— Gecikmeli gösterge (geçmişi özetler)"*

---

## 1.2 Vanity metric testi

**Soru:** Aşağıdaki metriklerden hangileri **vanity metric** (kulağa hoş
gelen ama eyleme geçirilemeyen) riski taşır? Neden?

- "Toplam sayfa görüntüleme"
- "Toplam kayıtlı kullanıcı sayısı"
- "Bu ay churn eden müşteri yüzdesi"
- "Sosyal medya takipçi sayısı"

---

## 1.3 Metrik katmanı (semantic layer)

**Soru:** "Aktif müşteri" tanımını iki farklı ekip farklı şekilde
yapıyor olabilir (biri "son 30 günde alışveriş yapan", diğeri "son 90 günde
giriş yapan"). Bu tutarsızlık nasıl bir soruna yol açar? dbt'deki (hafta 6)
`ref()` mantığının burada bir karşılığı olabilir mi — "tek bir doğru tanımın
tek bir yerde yaşaması" fikri?

---

## ✅ Ne öğrendik

- İyi bir KPI **eyleme geçirilebilir, tek anlamlı ve sahiplidir**.
- Vanity metric'ler büyür ama iş kararını değiştirmez — dashboard'u şişirir, güveni azaltır.
- Metrik tanımının **tek bir yerde** (bir semantic layer'da, dbt modelinde
  ya da paylaşılan bir sözlükte) yaşaması, ekipler arası "hangi rakam doğru"
  tartışmalarını önler.

📎 [Çözüm](./solutions/01-kpi-design.md)
