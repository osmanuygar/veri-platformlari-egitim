# Aşama 2: Mimari Tasarım ve ADR

**Süre:** ~60 dakika

---

## 2.1 Mimari diyagram çizin

**Görev:** Vakanızın veri akışını gösteren bir diyagram çizin (elle,
[excalidraw.com](https://excalidraw.com) gibi bir araçla, ya da ASCII
sanatıyla — format önemli değil, netlik önemli).

Diyagramınız en az şunları göstermeli:
- Veri kaynağı (nereden geliyor)
- Her işlem adımı (hangi hafta/araç)
- Veri hedefi (nerede son buluyor, kim/ne tüketiyor)
- Ok yönleri (veri akış yönü)

## 2.2 En az 2 Mimari Karar Kaydı (ADR) yazın

Her mühendislik projesinde, "neden X değil de Y" sorusuna cevap veren
kararlar vardır. Bunları **şimdi**, kararı verirken yazılı hale getirin
— altı ay sonra "neden böyle yapmıştık" sorusuna cevap bulamazsınız.

**Görev:** `templates/adr-template.md`'yi kullanarak en az 2 ADR yazın.
Örnek konular (vakanıza göre uyarlayın):

- "Neden Kafka + Debezium, neden basit bir polling script değil?"
- "Neden pgvector, neden ayrı bir Qdrant kurulumu?"
- "Neden bu vakada Metabase, neden Superset değil?"
- "Neden senkron bir pipeline, neden Airflow ile zamanlanmış değil?"

Her ADR'de **en az 2 seçeneği karşılaştırın** — sadece seçtiğiniz yaklaşımı
anlatmak bir ADR değildir, ADR'nin özü **alternatifleri neden elediğinizi** göstermektir.

## 2.3 Maliyet ve gecikme tahmini

**Görev:** Vaka özetinizdeki tabloyu doldurun:

| Bileşen | Varsayımsal aylık bulut maliyeti | Gecikme bütçesi |
|---|---|---|

Gerçek bir maliyet hesabı yapmanız beklenmiyor — amaç, **büyüklük
mertebesini** düşünme alışkanlığı kazanmak (hafta 7'deki "gecikme
bütçesi" ve hafta 6'daki "build vs buy" kavramlarını hatırlayın).

## 2.4 Kendi kendinize eleştirel sorular sorun

- Bu mimari, veri hacmi 10x artarsa hâlâ çalışır mı?
- Tek bir bileşen çökerse (örn. Kafka broker) ne olur?
- Bu mimaride bir PII sütunu var mı? Hafta 12'deki maskeleme ilkeleri uygulandı mı?

---

**[← Aşama 1](./01-case-selection.md)** · **[Aşama 3 →](./03-implementation-demo.md)**
