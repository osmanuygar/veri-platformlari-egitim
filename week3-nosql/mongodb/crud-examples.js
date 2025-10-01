// MongoDB CRUD Örnekleri

use ecommerce;

// ============ CREATE ============

// Tek doküman
db.products.insertOne({
  name: "Keyboard",
  price: 300,
  category: "Accessories"
});

// Çoklu doküman
db.products.insertMany([
  { name: "Monitor", price: 5000, category: "Electronics" },
  { name: "Webcam", price: 800, category: "Accessories" }
]);

// ============ READ ============

// Tümünü getir
db.products.find();

// Filtre ile
db.products.find({ category: "Electronics" });

// Projection (sadece bazı alanlar)
db.products.find(
  { price: { $gt: 500 } },
  { name: 1, price: 1, _id: 0 }
);

// Sıralama
db.products.find().sort({ price: -1 });

// Limit
db.products.find().limit(10);

// ============ UPDATE ============

// Tek doküman güncelle
db.products.updateOne(
  { name: "Laptop" },
  { $set: { price: 14000 } }
);

// Çoklu güncelleme
db.products.updateMany(
  { category: "Electronics" },
  { $mul: { price: 1.1 } }  // %10 zam
);

// Upsert (yoksa ekle)
db.products.updateOne(
  { name: "Tablet" },
  { $set: { price: 8000, category: "Electronics" } },
  { upsert: true }
);

// ============ DELETE ============

// Tek doküman sil
db.products.deleteOne({ name: "Webcam" });

// Çoklu silme
db.products.deleteMany({ inStock: false });