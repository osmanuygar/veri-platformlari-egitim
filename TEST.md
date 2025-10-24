# Veri Platformları Eğitimi - Kapsamlı Test

### Soru 1 (Kolay)
Aşağıdakilerden hangisi **yapısal veri** (structured data) örneği değildir?

A) SQL veritabanındaki müşteri tablosu  
B) CSV formatında satış verileri  
C) Sosyal medya gönderilerindeki kullanıcı yorumları  
D) Excel dosyasındaki envanter listesi  

**Doğru Cevap:** C

**Açıklama:** Sosyal medya yorumları yapısal olmayan veridir. Yapısal veriler tablolar halinde organize edilebilen, satır ve sütunlardan oluşan verilerdir.

---

### Soru 2 (Kolay)
ACID prensiplerinden hangisi, bir transaction'ın ya tamamen gerçekleşmesi ya da hiç gerçekleşmemesi gerektiğini ifade eder?

A) Atomicity (Bölünmezlik)  
B) Consistency (Tutarlılık)  
C) Isolation (İzolasyon)  
D) Durability (Kalıcılık)  

**Doğru Cevap:** A

**Açıklama:** Atomicity, bir transaction'ın bölünemez bir birim olduğunu ve tüm işlemlerin ya hepsinin başarılı olması ya da hiçbirinin uygulanmaması gerektiğini belirtir.

---

### Soru 3 (Orta)
Aşağıdaki SQL sorgusunun çıktısı kaç satır olur?

```sql
SELECT *
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.city = 'Istanbul';
```

Veriler:
- orders tablosu: 100 satır
- customers tablosu: 50 satır (bunlardan 20'si Istanbul'dan)
- Her siparişin geçerli bir customer_id'si var

A) 20  
B) 50  
C) 100  
D) Istanbul'daki müşterilerin sipariş sayısı kadar

**Doğru Cevap:** D

**Açıklama:** LEFT JOIN yapılsa da WHERE koşulu sonuçları filtreler. Istanbul'dan olan 20 müşteriye ait tüm siparişler gösterilir. Eğer her müşterinin 5 siparişi varsa 100, 2 siparişi varsa 40 satır görürüz.

---

### Soru 4 (Kolay)
CAP Teoremi'nde hangi üç özellik yer alır?

A) Consistency, Atomicity, Partition Tolerance  
B) Consistency, Availability, Performance  
C) Consistency, Availability, Partition Tolerance  
D) Caching, Availability, Performance  

**Doğru Cevap:** C

**Açıklama:** CAP Teoremi, dağıtık sistemlerde Consistency (Tutarlılık), Availability (Erişilebilirlik) ve Partition Tolerance (Bölünme Toleransı) özelliklerinden en fazla ikisinin aynı anda garanti edilebileceğini söyler.

---


### Soru 5 (Orta)
Redis öncelikle hangi NoSQL kategorisine girer ve en yaygın kullanım amacı nedir?

A) Document Store - JSON veri saklama  
B) Key-Value Store - Caching ve hızlı veri erişimi  
C) Graph Database - İlişki analizi  
D) Column-Family - Time-series veri  

**Doğru Cevap:** B

**Açıklama:** Redis, in-memory key-value store'dur ve öncelikle caching, session yönetimi ve hızlı veri erişimi için kullanılır.

---

### Soru 6 (Orta)
Neo4j'de sosyal ağ analizi yaparken "A kişisi B kişisini takip ediyor" ilişkisini ifade etmek için hangi Cypher sorgusu kullanılır?

A) `CREATE (a:Person {name:'A'})-[:KNOWS]->(b:Person {name:'B'})`  
B) `CREATE (a:Person {name:'A'})-[:FOLLOWS]->(b:Person {name:'B'})`  
C) `INSERT INTO Person (name) VALUES ('A') FOLLOWS ('B')`  
D) `db.person.insert({from: 'A', to: 'B', relation: 'follows'})`  

**Doğru Cevap:** B

**Açıklama:** Neo4j'de Cypher dilinde CREATE komutu ile node'lar ve ilişkiler oluşturulur. Ok yönü (->) ilişkinin yönünü gösterir.

---

### Soru 7 (Kolay)
OLTP ve OLAP sistemleri arasındaki temel fark nedir?

A) OLTP batch processing yapar, OLAP real-time işler  
B) OLTP işlemsel veriler için, OLAP analitik sorgular için optimize edilmiştir  
C) OLTP yavaş, OLAP hızlıdır  
D) OLTP NoSQL, OLAP SQL kullanır  

**Doğru Cevap:** B

**Açıklama:** OLTP (Online Transaction Processing) günlük işlemlere, OLAP (Online Analytical Processing) karmaşık analizlere ve raporlamaya optimize edilmiştir.

---

### Soru 8 (Orta)
**Star Schema**'da Fact tablosu ile Dimension tabloları arasındaki ilişki nasıldır?

A) Many-to-Many  
B) One-to-One  
C) Fact tablosu merkezdedir ve dimension tablolarıyla ilişkilidir  
D) Dimension tabloları Fact tablosunu içerir  

**Doğru Cevap:** C

**Açıklama:** Star Schema'da Fact tablosu merkezdedir ve ölçümleri (measures) içerir. Dimension tabloları yıldız şeklinde Fact tablosuna bağlanır ve açıklayıcı bilgiler sağlar.

---

### Soru 9 (Orta)
ETL ve ELT süreçleri arasındaki temel fark nedir?

A) ETL veriye önce transform yapar, ELT sonra yapar  
B) ETL bulutta çalışır, ELT on-premise'de  
C) ETL batch işlem yapar, ELT streaming  
D) ETL hızlıdır, ELT yavaş  

**Doğru Cevap:** A

**Açıklama:** ETL (Extract, Transform, Load) veriye hedef sisteme yüklemeden önce transform eder. ELT (Extract, Load, Transform) veriyi önce yükler, sonra hedef sistemde transform eder. ELT modern bulut veri ambarlarında daha yaygındır.

---

### Soru 10 (Zor)
**Snowflake Schema** ve **Star Schema** arasındaki fark nedir?

A) Snowflake Schema'da Fact tablosu yoktur  
B) Snowflake Schema'da dimension tabloları normalize edilmiştir  
C) Star Schema'da daha fazla JOIN gerekir  
D) Snowflake Schema daha hızlı sorgular sağlar  

**Doğru Cevap:** B

**Açıklama:** Snowflake Schema'da dimension tabloları normalize edilir ve alt dimension'lara bölünür. Bu veri tekrarını azaltır ama daha fazla JOIN gerektirir. Star Schema'da dimension'lar denormalize edilir (daha az JOIN, daha fazla depolama).

---

### Soru 11 (Zor)
Bir e-ticaret şirketinde günlük satış verilerini (OLTP) analitik raporlama için veri ambarına (OLAP) taşıyan ETL pipeline'ı tasarlıyorsunuz. Hangi yaklaşım en uygun olur?

A) Tüm veritabanını her gün yeniden kopyalamak  
B) Incremental load (sadece değişen kayıtları almak) ve SCD Type 2 uygulamak  
C) Real-time streaming ile her transaction'ı anında aktarmak  
D) Manuel SQL sorguları ile günde bir kez veri çekmek  

**Doğru Cevap:** B

**Açıklama:** Incremental load performanslı ve veri miktarını minimize eder. SCD (Slowly Changing Dimension) Type 2 tarihsel değişiklikleri takip etmeye olanak sağlar. Bu, OLAP sistemleri için standart bir yaklaşımdır.

---

### Soru 12 (Orta)
Docker Compose ile PostgreSQL ve MongoDB'yi aynı anda çalıştırmak için hangi komut kullanılır?

A) `docker run -d postgres mongodb`  
B) `docker-compose up -d postgres mongodb`  
C) `docker start --all`  
D) `docker-compose run postgres mongodb`  

**Doğru Cevap:** B

**Açıklama:** docker-compose up -d komutu ile belirli servisleri seçerek arka planda (detached mode) başlatabilirsiniz. Servis isimleri docker-compose.yml dosyasında tanımlanmış olmalıdır.

---

### Soru 13 (Orta)
Veri ambarı tasarımında **Fact tablosu** genellikle hangi tür verileri içerir?

A) Müşteri isimleri ve adresleri  
B) Ürün kategorileri ve açıklamaları  
C) Sayısal ölçümler (satış tutarı, miktar, kar)  
D) Tarih ve saat bilgileri  

**Doğru Cevap:** C

**Açıklama:** Fact tablosu iş süreçlerine ait ölçülebilir, sayısal verileri (measures) içerir. Dimension tabloları ise açıklayıcı bilgileri (who, what, where, when) tutar.

---

### Soru 14 (Orta)
MongoDB'de bir collection'daki tüm dokümanları listelemek için hangi komut kullanılır?

A) `db.collection.findAll()`  
B) `db.collection.find()`  
C) `db.collection.select()`  
D) `db.collection.list()`  

**Doğru Cevap:** B

**Açıklama:** MongoDB'de find() metodu kullanılır. find() parametresiz kullanıldığında tüm dokümanları getirir. find({koşul}) ile filtreleme yapılabilir.

---

### Soru 15 (Zor)
Bir şirket müşteri verilerini PostgreSQL'de (OLTP), analizleri ise ayrı bir PostgreSQL veritabanında (OLAP) tutuyor. ETL sürecinde **değişen kayıtları** takip etmek için en uygun yaklaşım hangisidir?

A) Her seferinde tüm tabloyu kopyalamak  
B) Timestamp sütunu kullanarak incremental load yapmak  
C) Sadece yeni kayıtları almak, güncelleme ve silmeleri görmezden gelmek  
D) Manuel olarak değişiklikleri tespit etmek  

**Doğru Cevap:** B

**Açıklama:** Timestamp (updated_at, created_at gibi) sütunları kullanarak sadece değişen kayıtları almak (incremental load) performans açısından en verimli yöntemdir. CDC (Change Data Capture) daha gelişmiş bir alternatiftir.

---



**Not:** Bu test, projedeki README ve müfredat içeriğine dayanarak hazırlanmıştır. Güncel kaynak kodu ve örnekler için GitHub reposunu ziyaret edin.