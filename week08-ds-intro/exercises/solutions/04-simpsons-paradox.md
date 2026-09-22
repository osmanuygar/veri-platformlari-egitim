# ✅ Çözüm 4: Simpson Paradoksu

## 4.1 Genel rakam

`camp.groupby('campaign')['converted'].mean()` → **A ≈ %18.1, B ≈ %12.0**.

Toplantı senaryosunda bu rakamla karşılaşan biri **A kampanyasını büyütme**
kararı alırdı — ki bu, ilerleyen adımlarda göreceğimiz gibi **yanlış** bir karar olurdu.

## 4.2 Segmentlere ayırma

| Kampanya | Cihaz | Dönüşüm oranı |
|---|---|---|
| A | mobil | %1.0 |
| A | masaüstü | %20.0 |
| B | mobil | %10.0 |
| B | masaüstü | %30.0 |

**Evet, doğrudan çelişiyor.** Cihaz bazında **B, A'yı HER İKİ segmentte de**
büyük farkla geçiyor (mobilde 10x, masaüstünde 1.5x daha iyi). Ama genel
rakamda A önde görünüyor.

## 4.3 Neden oluyor?

```python
camp.groupby(['campaign', 'device']).size()
```

| Kampanya | Cihaz | Gösterim |
|---|---|---|
| A | mobil | 1.000 |
| A | masaüstü | 9.000 |
| B | mobil | 9.000 |
| B | masaüstü | 1.000 |

**A'nın trafiğinin %90'ı masaüstünde** (yüksek dönüşümlü segment),
**B'nin trafiğinin %90'ı mobilde** (düşük dönüşümlü segment).

Tek cümlede: *A, her segmentte B'den kötü performans gösterse de, trafiğinin
büyük kısmını zaten "doğası gereği" yüksek dönüşümlü olan masaüstü segmentine
yönlendirdiği için genel ortalaması yapay olarak yükseliyor — B ise tam tersi,
düşük dönüşümlü mobil segmentte yoğunlaştığı için genel ortalaması düşük kalıyor.*

Bu, `campaign` (kampanya) ile `converted` (dönüşüm) arasındaki ilişkinin,
`device` (cihaz) adlı bir **karıştırıcı değişken (confounder)** tarafından
gizlendiği klasik bir durumdur.

## 4.4 Doğru karar

Doğru tavsiye: **"B kampanyasını büyütün — her cihaz segmentinde tutarlı
şekilde daha iyi performans gösteriyor. A'nın genel rakamının yüksek
görünmesi, sadece daha fazla masaüstü trafiği almasından kaynaklanıyor;
kampanyanın kendi kalitesiyle ilgisi yok."**

Daha nüanslı bir öneri: Her iki kampanyayı da **aynı cihaz karışımıyla**
çalıştırıp (ya da cihaz bazında ayrı bütçelendirip) adil bir karşılaştırma yapın.

## 4.5 Genel ders

Alışkanlık: **Hiçbir zaman tek bir toplam/genel rakamla karar vermeyin.**
En azından bilinen önemli ayırıcı değişkenlere (cihaz, bölge, zaman dilimi,
kullanıcı segmenti gibi) göre **segmentleyip kontrol edin** — özellikle
karşılaştırdığınız iki grubun bu değişkenlere göre **dengesiz dağıldığından**
şüpheleniyorsanız. A/B test raporlarında "genel dönüşüm" tek başına asla
yeterli bir kanıt değildir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Simpson Paradoksu | Segmentlere ayrılınca ilişki tersine dönebilir |
| Sebep | Gruplar arası karışım oranı (composition) farklıdır |
| Karıştırıcı değişken | Hem gruplamayı hem sonucu etkileyen gizli değişken |
| Korunma | Genel rakamla yetinmeyin, bilinen değişkenlere göre segmentleyin |

**[← Alıştırma 4](../04-simpsons-paradox.md)**
