# ✅ Çözüm 1: KPI Tasarımı

## 1.1 Örnek KPI tablosu

| Metrik | Tam tanım | Sahibi | Öncü/Gecikmeli |
|---|---|---|---|
| Aylık Ciro | Ay içinde `order_status ≠ cancelled` olan siparişlerin `revenue` toplamı | Satış Direktörü | Gecikmeli |
| İptal Oranı | İptal edilen sipariş / toplam sipariş (ay bazında) | Operasyon | Öncü (erken uyarı) |
| Ort. Sipariş Değeri (AOV) | Toplam ciro / sipariş sayısı | Pazarlama | Gecikmeli |
| Aktif Müşteri Sayısı | Son 90 günde ≥1 sipariş veren benzersiz müşteri | CRM | Öncü |
| Bölge Başına Büyüme | (Bu ay bölge cirosu − geçen ay) / geçen ay | Bölge Müdürleri | Gecikmeli |

## 1.2 Vanity metric testi

- **"Toplam sayfa görüntüleme"** — Vanity risk **yüksek**. Bir kullanıcının
  5 kez aynı sayfayı yanlışlıkla açması da sayılır; dönüşümle ilişkisi
  dolaylıdır, tek başına eyleme geçirilemez.
- **"Toplam kayıtlı kullanıcı"** — Vanity risk **yüksek**. Sürekli artan
  bir sayıdır (silinmiş/pasif hesaplar dahil) — "büyüyoruz" hissi verir
  ama aktif kullanım hakkında hiçbir şey söylemez.
- **"Churn yüzdesi"** — Vanity risk **düşük**. Doğrudan eyleme geçirilebilir
  (hangi segment, ne zaman, hangi aksiyon) ve iş sonucuyla doğrudan ilişkilidir.
- **"Sosyal medya takipçi sayısı"** — Vanity risk **çok yüksek**. Klasik
  vanity metric örneği; satışla ilişkisi nadiren doğrudandır.

## 1.3 Metrik katmanı

İki ekip "aktif müşteri"yi farklı tanımlarsa, aynı toplantıda iki farklı
"aktif müşteri sayısı" rakamı ortaya çıkar — bu, **hangi rakama güveneceğiz**
tartışmasına, zamanla da BI araçlarına genel bir güvensizliğe yol açar.

dbt'deki `ref()` mantığının BI'daki karşılığı **semantic layer** (metrik
katmanı) kavramıdır: "aktif müşteri" tanımı **tek bir yerde** (bir dbt
modeli, bir Looker/Cube metrik tanımı) yaşar, tüm dashboard'lar oradan
beslenir. Bu hafta kurduğumuz `bi.fact_sales` ve üzerindeki view'lar
(`v_monthly_revenue` gibi) bu fikrin küçük ölçekli bir örneğidir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| İyi KPI | Eyleme geçirilebilir + tek anlamlı + sahipli |
| Vanity metric | Büyür ama kararı değiştirmez |
| Semantic layer | Metrik tanımının tek doğru kaynağı |

**[← Alıştırma 1](../01-kpi-design.md)**
