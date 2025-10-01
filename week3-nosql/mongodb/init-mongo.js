// MongoDB Başlangıç Scripti

// E-ticaret veritabanı
db = db.getSiblingDB('ecommerce');

// Ürünler collection
db.products.drop();
db.products.insertMany([
  {
    _id: 1,
    name: "Laptop",
    price: 15000,
    category: "Electronics",
    brand: "Dell",
    specs: {
      ram: "16GB",
      cpu: "Intel i7",
      storage: "512GB SSD"
    },
    tags: ["computer", "portable", "work"],
    inStock: true,
    createdAt: new Date()
  },
  {
    _id: 2,
    name: "Mouse",
    price: 150,
    category: "Accessories",
    brand: "Logitech",
    tags: ["computer", "peripheral"],
    inStock: true,
    createdAt: new Date()
  }
]);

// Index oluştur
db.products.createIndex({ category: 1 });
db.products.createIndex({ name: "text", tags: "text" });

print("✅ E-ticaret veritabanı oluşturuldu");