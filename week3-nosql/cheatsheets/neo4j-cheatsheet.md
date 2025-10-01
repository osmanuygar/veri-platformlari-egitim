# Neo4j (Cypher) Hızlı Referans

## Node Oluşturma
```cypher
CREATE (n:Person {name: 'John', age: 30})
CREATE (n:Person {name: 'Jane'})
CREATE (c:Company {name: 'Acme Corp'})
```

## İlişki Oluşturma
```cypher
MATCH (a:Person {name: 'John'}), (b:Person {name: 'Jane'})
CREATE (a)-[:KNOWS {since: 2020}]->(b)

MATCH (p:Person {name: 'John'}), (c:Company {name: 'Acme'})
CREATE (p)-[:WORKS_AT]->(c)
```

## Sorgulama
```cypher
// Tüm kişiler
MATCH (p:Person) RETURN p

// İlişkili kişiler
MATCH (p:Person)-[:KNOWS]->(friend)
WHERE p.name = 'John'
RETURN friend

// İki seviye derinlik
MATCH (p:Person)-[:KNOWS*1..2]->(friend)
WHERE p.name = 'John'
RETURN DISTINCT friend
```

## Güncelleme
```cypher
MATCH (p:Person {name: 'John'})
SET p.age = 31

MATCH (p:Person)
WHERE p.age < 18
SET p.category = 'minor'
```

## Silme
```cypher
// Node silme (önce ilişkileri sil)
MATCH (p:Person {name: 'John'})-[r]-()
DELETE r, p

// Ya da
MATCH (p:Person {name: 'John'})
DETACH DELETE p
```

## Aggregation
```cypher
// Kişi başına arkadaş sayısı
MATCH (p:Person)-[:KNOWS]->(friend)
RETURN p.name, COUNT(friend) as friendCount
ORDER BY friendCount DESC

// Yaş ortalaması
MATCH (p:Person)
RETURN AVG(p.age) as avgAge
```

## Path Bulma
```cypher
// En kısa yol
MATCH path = shortestPath(
  (a:Person {name: 'John'})-[:KNOWS*]-(b:Person {name: 'Jane'})
)
RETURN path
```

## Index
```cypher
CREATE INDEX FOR (p:Person) ON (p.name)
CREATE CONSTRAINT FOR (p:Person) REQUIRE p.email IS UNIQUE
```