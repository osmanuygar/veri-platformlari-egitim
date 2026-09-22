# Aşama 1: Vaka Seçimi ve Kapsam Belirleme

**Süre:** ~30 dakika

---

## 1.1 Beş vakayı gözden geçirin

Ana [README.md](../README.md#-5-vaka)'deki 5 vakayı okuyun. Her biri
farklı haftaların bileşenlerini birleştirir.

## 1.2 Seçim kriterleri

Bir vaka seçerken şunları göz önünde bulundurun:

- **Zaman:** Elinizdeki süre (3-4 saat mi, 8-10 saat mi)?
- **İlgi alanı:** Hangi teknoloji yığını sizi daha çok ilgilendiriyor?
- **Ekip becerileri:** Grup çalışıyorsanız, hangi vaka ekibinizin güçlü
  yanlarını (biri Kafka'ya yatkın, biri BI'a yatkın gibi) en iyi kullanır?
- **Donanım:** Vaka, makinenizin kaldırabileceği kadar servis mi gerektiriyor?
  ([PORTS.md](../../PORTS.md) ve ilgili haftaların "Bellek ihtiyacı" notlarına bakın)

## 1.3 Kapsamı daraltın

**En sık yapılan hata:** Vakanın TÜM özelliklerini uygulamaya çalışmak.

**Görev:** `templates/case-study-brief-template.md`'yi kopyalayın ve
**"Dahil" / "Hariç"** bölümlerini doldurun. Örnek:

> **Dahil:** CDC ile sipariş verisinin Kafka'ya akıtılması, Kafka UI'da
> canlı izlenmesi, basit bir tüketicinin agregasyon üretmesi.
>
> **Hariç (bilinçli olarak):** Schema Registry / Avro (JSON ile yetinilecek),
> tam bir BI dashboard'u (sadece SQL sorgusuyla doğrulama yapılacak).

"Hariç" listesi olmayan bir proje planı, kapsam kontrolsüzce büyür.

## 1.4 Başarı kriterini yazılı hale getirin

**Görev:** "Bu proje bittiğinde nasıl anlarım?" sorusuna **tek bir cümlelik,
somut, gözlemlenebilir** bir cevap yazın.

> ❌ "Sistem çalışsın" (belirsiz, ne zaman "bitti" bilinmez)
> ✅ "PostgreSQL'de bir sipariş güncellendiğinde, 5 saniye içinde Kafka
>   UI'da ilgili CDC olayını görebilmeliyim"

---

**[← Alıştırma listesi](./README.md)** · **[Aşama 2 →](./02-architecture-adr.md)**
