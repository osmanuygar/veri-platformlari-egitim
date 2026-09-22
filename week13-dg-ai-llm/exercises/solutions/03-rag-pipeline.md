# ✅ Çözüm 3: Uçtan Uca RAG

## 3.2-3.3 İlk sorgular

Hafta 7 hakkındaki soru için sonuçlar **Hafta 7'den** gelmelidir (Kafka
ile ilgili tek hafta). Bağlam dışı ("pizza tarifi") sorusunda, sistem
prompt'undaki talimat sayesinde model genelde *"Bu ders notlarında bu
konuya dair yeterli bilgi bulamadım"* benzeri bir cevap verir.

**Bu talimat olmasaydı:** Küçük modeller bile geniş bir "dünya bilgisi"
ile eğitildiği için, pizza tarifi hakkında **halüsinasyon** üreterek
(ders notlarıyla hiç ilgisi olmayan, uydurma ama akıcı görünen bir
cevap) yanıt verirdi — RAG'ın "sadece bağlamı kullan" kısıtlaması
olmadan model her zaman kendi (bazen yanlış/alakasız) bilgisine
başvurabilir.

## 3.4 Şeffaflık ve temellendirme

`--show-context` ile modele giden ham metni gördüğünüzde, iyi bir RAG
cevabının bu metindeki ifadelere **yakından** dayandığını görmelisiniz
— cümleler birebir aynı olmasa da, aktarılan bilgi bağlamda **gerçekten
var olmalıdır**. Eğer model bağlamda olmayan bir detay eklerse, bu
**temellendirme (groundedness) hatasıdır** — RAG'ın kendisi doğru
çalışsa bile (doğru parça bulundu), generation adımı bağlamı sadık
şekilde kullanmamıştır.

## 3.5 `top-k`'nın etkisi

`top-k=1` ile cevap genelde **dar** kalır — sadece tek bir parçanın
kapsadığı açıdan cevap verir, konunun diğer önemli yönleri (örn. "backfill"
sorusunda hem tanım hem örnek komut hem de `catchup` ile ilişkisi ayrı
parçalarda olabilir) eksik kalabilir.

`top-k=8` ile daha eksiksiz bir cevap beklenir, ama bazı bulunan parçalar
**alakasız** olabilir (8. en yakın parça, aslında sorudan oldukça uzak
olabilir) — bu, modelin "gürültülü" bir bağlamdan doğru bilgiyi süzmesini
zorlaştırabilir ve bazen cevabı gereksiz uzatır ya da dikkatini dağıtır.

## 3.6 RAG değerlendirmesi

Bu bölüm kişiye özel pratik bir alıştırmadır. Beklenen gözlem: **isabet**
(retrieval) genelde yüksek çıkar (embedding modeli, konuyu doğru haftaya
eşlemede başarılıdır) ama **temellendirme** bazen düşebilir (küçük
modeller, bağlamı bazen kendi yorumuyla karıştırabilir) — bu, "hangi
adımın (retrieval mi generation mı) iyileştirilmesi gerektiğini" ayırt
etmenin pratik yoludur.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| RAG'ın iki başarısızlık modu | Retrieval hatası (yanlış parça) vs generation hatası (yanlış kullanım) |
| Sistem prompt kısıtlaması | Halüsinasyonu azaltır, tamamen ortadan kaldırmaz |
| `top-k` | Eksiklik/gürültü ödünleşmesi |
| Değerlendirme | Çok boyutlu olmalı — isabet, alaka, temellendirme ayrı ayrı |

**[← Alıştırma 3](../03-rag-pipeline.md)**
