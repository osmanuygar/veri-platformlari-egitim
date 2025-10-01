# MongoDB Hızlı Referans

## Bağlantı
```bash
mongosh                          # Bağlan
mongosh "mongodb://localhost:27017"
use mydb                         # Database seç
show dbs                         # Database'leri listele
show collections                 # Collection'ları listele
```

## CRUD
```javascript
// Create
db.users.insertOne({name: "John", age: 30})
db.users.insertMany([{...}, {...}])

// Read
db.users.find()
db.users.find({age: {$gt: 25}})
db.users.findOne({name: "John"})

// Update
db.users.updateOne({name: "John"}, {$set: {age: 31}})
db.users.updateMany({}, {$inc: {age: 1}})

// Delete
db.users.deleteOne({name: "John"})
db.users.deleteMany({age: {$lt: 18}})
```

## Query Operators
```javascript
$eq   // Eşit
$gt   // Büyük
$lt   // Küçük
$gte  // Büyük eşit
$lte  // Küçük eşit
$ne   // Eşit değil
$in   // Dizide var
$nin  // Dizide yok

// Örnek
db.users.find({age: {$gte: 18, $lte: 65}})
db.users.find({status: {$in: ["active", "pending"]}})
```

## Aggregation
```javascript
db.orders.aggregate([
  {$match: {status: "completed"}},
  {$group: {_id: "$customerId", total: {$sum: "$amount"}}},
  {$sort: {total: -1}},
  {$limit: 10}
])
```

## Index
```javascript
db.users.createIndex({email: 1})              // Ascending
db.users.createIndex({name: 1, age: -1})      // Compound
db.users.createIndex({name: "text"})          // Text search
db.users.getIndexes()                         // Index'leri göster
db.users.dropIndex("email_1")                 // Index sil
```