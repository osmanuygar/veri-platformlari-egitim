-- Week 5 - Window Functions Exercises

/*
ALIŞT

IRMA 1: ROW_NUMBER
Her kategorideki ürünleri fiyata göre sırala ve sıra numarası ver
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 2: RANK vs DENSE_RANK
Ürünleri fiyata göre RANK ve DENSE_RANK ile sırala, farkı gözlemle
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 3: Top N per Group
Her kategorideki en pahalı 3 ürünü bul
İpucu: Window function ile RANK kullan, sonra WHERE ile filtrele
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 4: Running Total
Müşterilerin tarihe göre toplam harcamalarının kümülatif toplamını hesapla
İpucu: SUM() OVER (ORDER BY ...)
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 5: Moving Average
Son 7 günlük sipariş ortalamasını hesapla
İpucu: ROWS BETWEEN kullan
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 6: LEAD ve LAG
Her siparişin bir önceki ve sonraki sipariş tarihini göster
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 7: FIRST_VALUE ve LAST_VALUE
Her kategorideki ilk ve son eklenen ürünü bul
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 8: PERCENT_RANK
Ürünlerin fiyat bazında yüzdelik dilimini hesapla
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 9: NTILE
Müşterileri toplam harcamaya göre 4 gruba böl (quartiles)
*/
-- Kodunuzu buraya yazın



/*
ALIŞTIRMA 10: Complex Window
Her müşteri için:
- Toplam sipariş sayısı
- Toplam harcama
- Ortalama sipariş tutarı
- Müşteri segmentindeki sıralaması
Hepsini tek sorguda hesapla
*/
-- Kodunuzu buraya yazın