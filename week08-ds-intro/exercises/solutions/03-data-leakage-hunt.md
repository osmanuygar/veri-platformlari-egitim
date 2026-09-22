# ✅ Çözüm 3: Veri Sızıntısı Avı

## 3.1 Şüpheli korelasyon

`cancellation_flag_POST_CHURN` ile `churned` arasındaki korelasyon **1.0**
(ya da neredeyse 1.0) çıkar — çünkü script'te bu sütun kasıtlı olarak
`row["cancellation_flag_POST_CHURN"] = row["churned"]` ile birebir kopyalandı.

Normal davranışsal bir özelliğin (yaş, gelir, sipariş sayısı) hedefle bu
kadar yüksek korelasyona sahip olması **istatistiksel olarak neredeyse
imkânsızdır**. %90'ın üzerindeki her korelasyon şüpheyle karşılanmalıdır.

## 3.2 Sütun adı ipucu

`POST_CHURN` ifadesi açıkça "churn olayından SONRA" anlamına gelir. Bu bilgi,
bir müşteri **henüz churn etmeden önce tahmin yapmaya çalıştığınız anda**
mevcut değildir — sadece geçmişe dönük (retrospektif) analizde bilinir.

## 3.3 Düşünce deneyi

1. **Eğitim setinde doğruluk:** Neredeyse **%100**. Model sadece bu tek
   sütuna bakarak mükemmel tahmin yapar — çünkü sütun zaten cevabın kendisi.
2. **Production'da yeni müşteri:** Henüz churn etmediği için bu sütunun
   gerçek değeri **bilinmez** — genelde `0`/`NULL`/varsayılan bir değer
   girilir (çünkü "henüz iptal olmadı").
3. **Model o anda:** Eğitimde öğrendiği "bu sütun 1 ise churn" kuralını
   uygular, ama üretimde sütun hep `0` olduğu için **her zaman "churn
   etmeyecek" tahmini yapar** — model production'da tamamen işe yaramaz
   hale gelir, üstelik bunun nedeni ilk bakışta anlaşılmaz çünkü eğitim
   metrikleri mükemmeldi.

Bu, veri sızıntısının klasik imzasıdır: **"laboratuvarda %99 doğruluk,
production'da işe yaramıyor."**

## 3.4 Genel kural

| Sütun | Sızıntı riski? | Gerekçe |
|---|---|---|
| `order_count` | Düşük | Tahmin anında bilinen, meşru bir davranışsal özellik |
| `signup_date` | Yok | Geçmişte sabit bir olay, hedeften bağımsız |
| `total_spent` | **Var — dikkat** | Eğer bu değer churn SONRASI dönemi de içeriyorsa (örn. "tüm zamanlar" toplamı, iptalden sonraki iadeler dahil), sızıntı olur |
| `avg_order_value` | Düşük-orta | `total_spent`'e bağımlıysa onun taşıdığı riski miras alır |

**Genel kural:** Bir özelliğin değerini hesaplarken kullandığınız **zaman
penceresi**, tahmin yapma anından SONRAKİ hiçbir bilgiyi içermemelidir.
"Bu özelliği, gerçek hayatta tahmin yapacağım anda elimde olur muydu?"
sorusunu her özellik için sorun.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Aşırı yüksek korelasyon | İlk şüphe sinyali |
| Sütun adındaki zaman ipucu (`POST_*`, `AFTER_*`) | Genelde açık bir uyarı |
| Sızıntının imzası | Eğitimde mükemmel, production'da işe yaramaz |
| Genel test | "Tahmin anında bu bilgi gerçekten elimde olur muydu?" |

**[← Alıştırma 3](../03-data-leakage-hunt.md)**
