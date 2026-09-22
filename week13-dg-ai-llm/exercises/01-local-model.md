# Alıştırma 1: Yerel Model Çalıştırma

**Süre:** ~20 dakika

---

## 1.1 Modelle sohbet edin

```bash
docker exec -it week13_ollama ollama run llama3.2:1b
>>> Sen kimsin ve ne yapabilirsin?
```

**Görev:** Modelin cevabını okuyun. Yanıt hızını (kelime/saniye hissi)
not edin.

---

## 1.2 Daha büyük bir model deneyin (opsiyonel, disk/RAM'e bağlı)

```bash
docker exec week13_ollama ollama pull llama3.2:3b
docker exec -it week13_ollama ollama run llama3.2:3b
>>> Aynı soruyu sor
```

**Soru:** 1B'lik model ile 3B'lik model arasında cevap kalitesinde fark
hissettiniz mi? Hız farkı ne kadar?

---

## 1.3 Donanım gerçeği

**Soru:** Bu modeller GPU'suz, sadece CPU ile çalışıyor. ChatGPT/Claude
gibi bulut modelleri (yüzlerce milyar parametre) neden bu kadar hızlı
yanıt verebiliyor, ama 1B'lik yerel modeliniz bazen yavaş kalıyor?
(İpucu: parametre sayısı, GPU kümesi, donanım maliyeti)

---

## 1.4 Kuantizasyon

```bash
docker exec week13_ollama ollama show llama3.2:1b
```

**Görev:** Çıktıdaki `quantization` alanına bakın (örn. `Q4_K_M`).

**Soru:** Kuantizasyon nedir — bir modelin parametrelerini 32-bit yerine
4-bit ile saklamak ne kazandırır (disk/RAM), neyi riske atar (kalite)?

---

## 1.5 Ne zaman yerel, ne zaman bulut

| Senaryo | Yerel model | Bulut API |
|---|---|---|
| Hassas/gizli veri, dışarı çıkamaz | | |
| En yüksek kalite gerekiyor, bütçe var | | |
| Offline/kapalı ağ ortamı | | |
| Değişken, düşük hacimli kullanım | | |
| Sürekli yüksek hacim, maliyet optimizasyonu önemli | | |

**Görev:** Her senaryo için "yerel" ya da "bulut" işaretleyin ve
gerekçelendirin.

---

## ✅ Ne öğrendik

- Yerel modeller donanım sınırlarıyla çalışır — daha küçük modeller daha
  hızlı ama daha az yetenekli.
- Kuantizasyon, kalite/kaynak ödünleşmesinin somut bir örneğidir.
- Yerel vs bulut kararı, veri mahremiyeti, maliyet ve kalite gereksinimi
  arasında bir dengedir — tek "doğru" cevap yoktur.

📎 [Çözüm](./solutions/01-local-model.md)
