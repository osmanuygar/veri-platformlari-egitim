// Sosyal Ağ Örneği

// Kullanıcılar oluştur
CREATE (alice:User {name: 'Alice', age: 30, city: 'Istanbul'})
CREATE (bob:User {name: 'Bob', age: 25, city: 'Ankara'})
CREATE (charlie:User {name: 'Charlie', age: 28, city: 'Izmir'})
CREATE (david:User {name: 'David', age: 32, city: 'Istanbul'})
CREATE (eve:User {name: 'Eve', age: 27, city: 'Ankara'});

// İlişkiler oluştur
MATCH (a:User {name: 'Alice'}), (b:User {name: 'Bob'})
CREATE (a)-[:FOLLOWS {since: date('2024-01-15')}]->(b);

MATCH (b:User {name: 'Bob'}), (c:User {name: 'Charlie'})
CREATE (b)-[:FOLLOWS {since: date('2024-02-20')}]->(c);

MATCH (a:User {name: 'Alice'}), (c:User {name: 'Charlie'})
CREATE (a)-[:FOLLOWS {since: date('2024-03-10')}]->(c);

MATCH (c:User {name: 'Charlie'}), (d:User {name: 'David'})
CREATE (c)-[:FOLLOWS {since: date('2024-01-25')}]->(d);

MATCH (d:User {name: 'David'}), (e:User {name: 'Eve'})
CREATE (d)-[:FOLLOWS {since: date('2024-02-14')}]->(e);

MATCH (a:User {name: 'Alice'}), (d:User {name: 'David'})
CREATE (a)-[:FOLLOWS {since: date('2024-03-01')}]->(d);

// ========== SORGULAR ==========

// 1. Alice'in takip ettikleri
MATCH (alice:User {name: 'Alice'})-[:FOLLOWS]->(friend)
RETURN friend.name, friend.city;

// 2. Alice'i takip edenler
MATCH (follower:User)-[:FOLLOWS]->(alice:User {name: 'Alice'})
RETURN follower.name;

// 3. Mutual friends (karşılıklı takip)
MATCH (a:User)-[:FOLLOWS]->(b:User)-[:FOLLOWS]->(a)
RETURN a.name, b.name;

// 4. Arkadaşlarının arkadaşları (2. derece)
MATCH (alice:User {name: 'Alice'})-[:FOLLOWS]->()-[:FOLLOWS]->(fof)
WHERE alice <> fof
RETURN DISTINCT fof.name;

// 5. Arkadaş önerisi (henüz takip etmediği kişiler)
MATCH (alice:User {name: 'Alice'})-[:FOLLOWS]->()-[:FOLLOWS]->(suggestion)
WHERE alice <> suggestion
  AND NOT (alice)-[:FOLLOWS]->(suggestion)
RETURN suggestion.name, COUNT(*) as mutualFriends
ORDER BY mutualFriends DESC;


