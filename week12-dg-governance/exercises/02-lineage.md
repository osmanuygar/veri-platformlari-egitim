# Alıştırma 2: Marquez ile Soy Ağacı

**Süre:** ~30 dakika · **Dosya:** `scripts/emit_lineage.py`

---

## 2.1 Lineage gönderin

```bash
python scripts/emit_lineage.py
```

Ardından http://localhost:3002 adresine gidin, `week12-dg` namespace'ini seçin.

**Görev:** `transform_customer_marts` job'una tıklayıp giriş (`raw.customers`,
`raw.orders`) ve çıkış (`marts.customers_masked`) dataset'lerini ekranda bulun.

---

## 2.2 Etki analizi (impact analysis)

**Senaryo:** `raw.customers` tablosundaki `tckn` sütununun adını
`national_id` olarak değiştirmeyi düşünüyorsunuz.

**Görev:** Marquez'de `raw.customers` dataset'ine gidip **aşağı akışını**
(downstream) inceleyin.

**Soru:** Bu değişiklik hangi job'ları ve hangi dataset'leri etkiler?
Lineage grafiği olmadan bu soruyu nasıl cevaplardınız — muhtemelen
kod tabanında `grep tckn` yapmanız gerekirdi. Bu, kaç dosyaya/ekibe
sormanız gerektiğini nasıl etkiler?

---

## 2.3 Başarısız bir çalıştırmayı gönderin

```bash
python scripts/emit_lineage.py --fail-transform
```

**Görev:** Marquez'de `transform_customer_marts` job'unun **Runs**
sekmesine gidip başarısız çalıştırmayı bulun.

**Soru:** `export_to_bi` job'u bu senaryoda hiç çalıştı mı? Script'in
kodunda bunu sağlayan satırı bulun. Gerçek bir Airflow DAG'ında bu davranış
nasıl elde edilir (hafta 6'yı hatırlayın)?

---

## 2.4 Kök neden analizi

**Senaryo:** `bi.customer_export` tablosundaki bir sayı yanlış çıktı.
Hangi adımda hata olduğunu bulmanız gerekiyor.

**Görev:** Marquez'de `bi.customer_export`'tan geriye doğru (upstream)
tıklayarak, verinin hangi ham tablolardan (`raw.customers`, `raw.orders`)
geçtiğini takip edin.

**Soru:** Bu "geriye doğru izleme" yeteneği olmasaydı, kök nedeni bulmak
için hangi adımları (kod okuma, ekiplerle konuşma, log tarama) atmanız gerekirdi?

---

## 2.5 REST API ile sorgulama

```bash
curl -s http://localhost:5002/api/v1/namespaces/week12-dg/jobs | python3 -m json.tool
```

**Görev:** API'den dönen JSON'da her job'un `latestRun` alanına bakın.

**Soru:** Bu API, bir CI/CD pipeline'ında ya da bir izleme (monitoring)
aracında nasıl kullanılabilir? (İpucu: "tüm job'lar son 24 saatte en az
bir kez başarıyla çalıştı mı" kontrolü otomatikleştirilebilir mi?)

---

## ✅ Ne öğrendik

- OpenLineage, "kim neyi okudu/yazdı" bilgisini standart bir formatta
  yakalar; Marquez bunu görsel bir grafiğe dönüştürür.
- Etki analizi (bir değişikliğin nereleri etkileyeceği), lineage grafiği
  olmadan **elle kod taramaya** dayanır — hataya açık ve yavaştır.
- Kök neden analizi (bir hatanın nereden geldiği), lineage'ı **geriye doğru**
  takip etmekle çok hızlanır.
- Başarısız bir job, downstream job'ların çalışmamasını sağlayarak
  bozuk verinin yayılmasını engeller (hafta 6'daki Airflow davranışıyla aynı ilke).

📎 [Çözüm](./solutions/02-lineage.md)
