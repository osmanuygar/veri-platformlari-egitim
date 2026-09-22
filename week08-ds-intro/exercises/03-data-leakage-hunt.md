# Alıştırma 3: Veri Sızıntısı Avı

**Süre:** ~20 dakika · **Veri:** `data-samples/customers_dirty.csv`

---

## 3.1 Şüpheli korelasyon

```python
df.corr(numeric_only=True)['churned'].sort_values(ascending=False)
```

**Görev:** `churned` ile en yüksek korelasyona sahip sütunu bulun.

**Soru:** Korelasyon değeri kaç? Normal bir davranışsal özellik (yaş, gelir,
sipariş sayısı) bu kadar yüksek bir korelasyona sahip olabilir mi?

---

## 3.2 Sütun adını ve anlamını inceleyin

`cancellation_flag_POST_CHURN` sütununa bakın.

**Soru:** Sütun adındaki `POST_CHURN` ifadesi size ne söylüyor? Bu bilgi,
bir müşterinin churn edip etmeyeceğini **tahmin etmeden önce** mi yoksa
**churn ettikten sonra** mı bilinir?

---

## 3.3 Bu sütunu bir modelde kullansaydınız

**Düşünce deneyi:** Bu sütunu özellik (feature) olarak bir churn tahmin
modeline verseydiniz:

1. Eğitim (training) setinde model doğruluğu (accuracy) ne olurdu — yüksek mi, düşük mü?
2. Modeli production'a alıp **henüz churn etmemiş** yeni bir müşteride
   çalıştırdığınızda bu sütunun değeri ne olurdu?
3. O anda model ne yapardı?

---

## 3.4 Genel kural

**Görev:** Aşağıdaki 4 sütunun her biri için "sızıntı riski var mı?" diye
işaretleyin ve gerekçelendirin.

| Sütun | Açıklama | Sızıntı riski? | Gerekçe |
|---|---|---|---|
| `order_count` | Müşterinin toplam sipariş sayısı | | |
| `signup_date` | Kayıt tarihi | | |
| `total_spent` | Toplam harcama (churn dahil TÜM zamanlar) | | |
| `avg_order_value` | Ortalama sipariş tutarı | | |

**İpucu:** `total_spent`, müşteri churn ETTİKTEN SONRAKİ dönemi de içeriyor
olabilir mi? Bu, `cancellation_flag_POST_CHURN` kadar açık olmasa da benzer
bir sorun taşıyabilir.

---

## ✅ Ne öğrendik

- Veri sızıntısının en yaygın belirtisi, bir özelliğin hedef değişkenle
  **gerçekçi olmayan derecede yüksek** korelasyona sahip olmasıdır.
- Sızıntı genelde **zaman sırası** ihlalinden gelir: gelecekte bilinecek bir
  bilgi, geçmişteki bir tahmine sızar.
- Sütun adı bazen size ipucu verir (`POST_CHURN`) — ama her zaman değil;
  `total_spent` gibi masum görünen sütunlar da aynı hastalığı taşıyabilir.

📎 [Çözüm](./solutions/03-data-leakage-hunt.md)
