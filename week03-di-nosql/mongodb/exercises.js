// MongoDB Alıştırmaları

use ecommerce;

// ALIŞTIRMA 1: 500 TL'den pahalı tüm ürünleri bulun


// ALIŞTIRMA 2: "Electronics" kategorisindeki ürünlerin ortalama fiyatını hesaplayın


// ALIŞTIRMA 3: Her kategorideki ürün sayısını bulun


// ALIŞTIRMA 4: En pahalı 5 ürünü listeleyin


// ========== ÇÖZÜMLER ==========

// Çözüm 1:
db.products.find({ price: { $gt: 500 } });

// Çözüm 2:
db.products.aggregate([
  { $match: { category: "Electronics" } },
  { $group: { _id: null, avgPrice: { $avg: "$price" } } }
]);

// Çözüm 3:
db.products.aggregate([
  { $group: { _id: "$category", count: { $sum: 1 } } }
]);

// Çözüm 4:
db.products.find().sort({ price: -1 }).limit(5);