# Alıştırma 4: Simpson Paradoksu

**Süre:** ~25 dakika · **Veri:** `data-samples/campaign_simpsons.csv`

---

## 4.1 Genel rakama bakın

```python
camp = pd.read_csv("data-samples/campaign_simpsons.csv")
camp.groupby('campaign')['converted'].mean()
```

**Soru:** Hangi kampanya (A ya da B) genel dönüşüm oranında daha iyi görünüyor?
Bir pazarlama toplantısında bu rakamla karşılaşsaydınız hangi kampanyayı
büyütme kararı alırdınız?

---

## 4.2 Segmentlere ayırın

```python
camp.groupby(['campaign', 'device'])['converted'].mean()
```

**Görev:** Sonucu bir tabloya dökün.

| Kampanya | Cihaz | Dönüşüm oranı |
|---|---|---|
| A | mobil | |
| A | masaüstü | |
| B | mobil | |
| B | masaüstü | |

**Soru:** Cihaz bazında hangi kampanya kazanıyor? Bu, 4.1'deki sonuçla
**çelişiyor mu**?

---

## 4.3 Neden oluyor?

```python
camp.groupby(['campaign', 'device']).size()
```

**Görev:** Her kampanya-cihaz kombinasyonunun **gösterim (impression) sayısını**
bulun.

**Soru:** A kampanyasının trafiğinin çoğu hangi cihazda? B'ninki hangisinde?
Masaüstü mü mobil mi genelde daha yüksek dönüşüm sağlıyor? Bu iki gözlemi
birleştirdiğinizde, genel rakamın neden yanıltıcı olduğunu bir cümlede
açıklayın.

---

## 4.4 Doğru karar

**Soru:** Bir pazarlama ekibine hangi tavsiyeyi verirsiniz — "A'yı büyüt"
mü, "B'yi büyüt" mü, yoksa daha nüanslı bir cevap mı? Nasıl formüle edersiniz?

---

## 4.5 Genel ders

**Soru:** Bu paradoksu üretim ortamında (gerçek bir A/B test raporunda)
fark etmeden geçmemek için hangi alışkanlığı edinmelisiniz? (İpucu: "genel
rakam" ile yetinmemek, hangi ek adımı atmak gerekir?)

---

## ✅ Ne öğrendik

- **Simpson Paradoksu**: bir ilişki, altta yatan bir değişkene (burada
  cihaz türü) göre bölündüğünde **tersine dönebilir**.
- Sebep, gruplar arasındaki **karışım oranının** (composition) farklı olmasıdır
  — burada A'nın trafiği zaten yüksek dönüşümlü segmente kaymış.
- Genel bir toplam rakam **asla tek başına yeterli değildir**; en azından
  bilinen önemli değişkenlere göre segmentlere ayırıp kontrol etmek gerekir.
- Bu, hafta 9'da göreceğimiz "korelasyon ≠ nedensellik" ve "confounding
  variable" (karıştırıcı değişken) kavramlarının doğrudan pratik örneğidir.

📎 [Çözüm](./solutions/04-simpsons-paradox.md)
