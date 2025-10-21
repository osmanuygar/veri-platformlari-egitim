#!/bin/bash

echo "🧪 Trino Test Queries - Week-NoSQL Project"
echo "==========================================="

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test sonuçları
PASSED=0
FAILED=0

# Test fonksiyonu
run_test() {
    local test_name=$1
    local query=$2

    echo -e "\n${BLUE}Test: ${test_name}${NC}"
    echo -e "${YELLOW}Query: ${query}${NC}"

    result=$(docker exec veri_trino trino --execute "$query" 2>&1)

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        echo "$result"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "$result"
        FAILED=$((FAILED + 1))
    fi
}

# Test 1: Katalogları listele
run_test "Show Catalogs" "SHOW CATALOGS;"

# Test 2: MongoDB şemaları
run_test "MongoDB Schemas" "SHOW SCHEMAS FROM mongodb;"

# Test 3: Cassandra keyspaces
run_test "Cassandra Keyspaces" "SHOW SCHEMAS FROM cassandra;"

# Test 4: Redis schemas
run_test "Redis Schemas" "SHOW SCHEMAS FROM redis;"

# Test 5: MongoDB veri sayısı
run_test "MongoDB Count" "SELECT COUNT(*) as total FROM mongodb.ecommerce.users;"

# Test 6: Cassandra veri sayısı
run_test "Cassandra Count" "SELECT COUNT(*) as total FROM cassandra.ecommerce.users;"

# Test 7: Cross-database query
run_test "Cross-Database Count" "
SELECT 'MongoDB' as db, COUNT(*) as count FROM mongodb.ecommerce.users
UNION ALL
SELECT 'Cassandra' as db, COUNT(*) as count FROM cassandra.ecommerce.users;"

# Test 8: MongoDB filtreleme
run_test "MongoDB Filter" "SELECT name, age FROM mongodb.ecommerce.users WHERE age > 25 LIMIT 5;"

# Test 9: Cassandra select
run_test "Cassandra Select" "SELECT email FROM cassandra.ecommerce.users LIMIT 5;"

# Sonuçları göster
echo -e "\n${BLUE}=========================================="
echo "Test Sonuçları"
echo "==========================================${NC}"
echo -e "${GREEN}Başarılı: ${PASSED}${NC}"
echo -e "${RED}Başarısız: ${FAILED}${NC}"
echo -e "${BLUE}Toplam: $((PASSED + FAILED))${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Tüm testler başarılı!${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Bazı testler başarısız oldu!${NC}"
    exit 1
fi