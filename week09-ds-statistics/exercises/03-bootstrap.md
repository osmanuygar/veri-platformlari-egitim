# Alıştırma 3: Bootstrap Güven Aralığı

**Süre:** ~25 dakika · **Dosya:** `scripts/bootstrap_ci.py`, veri: `data-samples/order_values.csv`

---

## 3.1 Medyan için güven aralığı

```bash
python scripts/bootstrap_ci.py --statistic median
```

**Görev:** %95 güven aralığını not edin.

**Soru:** `order_values.csv` çarpık (sağa çarpık) bir dağılıma sahip.
Medyanın **kapalı-form** (formülle hesaplanan) bir güven aralığı formülü
yoktur/karmaşıktır — bootstrap'ın burada işe yaradığı nokta tam olarak bu.

---

## 3.2 Mekanizmayı anlayın

```python
# scripts/bootstrap_ci.py içindeki döngüyü inceleyin
for i in range(n_boot):
    sample = rng.choice(data, size=n, replace=True)   # ← burası kritik
    boot_stats[i] = stat_fn(sample)
```

**Soru:** `replace=True` (yerine koyarak örnekleme) neden şart? `replace=False`
olsaydı her bootstrap örneklemi orijinal veriyle **birebir aynı** olurdu —
neden? Bu durumda `boot_stats` dizisinde ne kadar çeşitlilik kalırdı?

---

## 3.3 Ortalama vs medyan

```bash
python scripts/bootstrap_ci.py --statistic mean
python scripts/bootstrap_ci.py --statistic median
```

**Görev:** İki güven aralığının **genişliğini** karşılaştırın.

**Soru:** Çarpık bir dağılımda ortalamanın güven aralığı neden medyandan
daha geniş (daha belirsiz) çıkma eğilimindedir? (İpucu: ortalama, aykırı
büyük değerlere karşı daha duyarlıdır.)

---

## 3.4 Bootstrap tekrar sayısının etkisi

```bash
python scripts/bootstrap_ci.py --n-boot 100
python scripts/bootstrap_ci.py --n-boot 2000
python scripts/bootstrap_ci.py --n-boot 10000
```

**Soru:** Tekrar sayısı arttıkça güven aralığının sınırları nasıl değişiyor
— stabilize mi oluyor, yoksa sürekli değişmeye mi devam ediyor? Pratikte
kaç tekrar "yeterli" kabul edilir?

---

## 3.5 %90 vs %99 güven aralığı

```bash
python scripts/bootstrap_ci.py --ci 0.90
python scripts/bootstrap_ci.py --ci 0.99
```

**Soru:** Güven düzeyi arttıkça aralık genişliyor mu daralıyor mu? Bunun
sezgisel açıklaması nedir — "daha emin olmak" için ne ödün vermeniz gerekiyor?

---

## ✅ Ne öğrendik

- Bootstrap, dağılım **varsayımı yapmadan** (normal dağılım gerektirmeden)
  herhangi bir istatistik için güven aralığı üretir.
- "Yerine koyarak örnekleme" (`replace=True`), her bootstrap örnekleminin
  orijinalden hafifçe farklı olmasını sağlayan mekanizmanın ta kendisidir.
- Çarpık dağılımlarda ortalamanın güven aralığı medyandan daha geniştir.
- Güven düzeyi ile aralık genişliği ters orantılıdır — daha fazla emin
  olmak istediğinizde aralık genişler.

📎 [Çözüm](./solutions/03-bootstrap.md)
