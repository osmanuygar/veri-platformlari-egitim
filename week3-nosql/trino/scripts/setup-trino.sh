#!/bin/bash

echo "🚀 Trino Setup Script - Week-NoSQL Project"
echo "=========================================="

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Trino'nun hazır olmasını bekle
wait_for_trino() {
    echo -e "${YELLOW}Trino'nun başlamasını bekliyorum...${NC}"

    local retries=0
    local max_retries=30

    until curl -s http://localhost:8080/v1/info > /dev/null || [ $retries -eq $max_retries ]; do
        retries=$((retries + 1))
        echo -e "${YELLOW}Deneme $retries/$max_retries...${NC}"
        sleep 5
    done

    if [ $retries -eq $max_retries ]; then
        echo -e "${RED}❌ Trino başlatılamadı!${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Trino hazır!${NC}"
}

# Katalogları kontrol et
check_catalogs() {
    echo -e "\n${YELLOW}Katalogları kontrol ediyorum...${NC}"

    docker exec veri_trino trino --execute "SHOW CATALOGS;" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Kataloglar başarıyla yüklendi!${NC}"
    else
        echo -e "${RED}❌ Katalog yükleme hatası!${NC}"
        exit 1
    fi
}

# MongoDB şemalarını göster
show_mongodb_schemas() {
    echo -e "\n${YELLOW}MongoDB şemaları:${NC}"
    docker exec veri_trino trino --execute "SHOW SCHEMAS FROM mongodb;" 2>/dev/null || echo -e "${RED}MongoDB katalog hatası${NC}"
}

# Cassandra keyspace'leri göster
show_cassandra_keyspaces() {
    echo -e "\n${YELLOW}Cassandra keyspace'leri:${NC}"
    docker exec veri_trino trino --execute "SHOW SCHEMAS FROM cassandra;" 2>/dev/null || echo -e "${RED}Cassandra katalog hatası${NC}"
}

# Redis şemaları göster
show_redis_schemas() {
    echo -e "\n${YELLOW}Redis şemaları:${NC}"
    docker exec veri_trino trino --execute "SHOW SCHEMAS FROM redis;" 2>/dev/null || echo -e "${RED}Redis katalog hatası${NC}"
}

# Ana fonksiyon
main() {
    echo -e "\n${GREEN}Step 1: Trino hazır duruma geliyor...${NC}"
    wait_for_trino

    echo -e "\n${GREEN}Step 2: Kataloglar kontrol ediliyor...${NC}"
    check_catalogs

    echo -e "\n${GREEN}Step 3: Veritabanı şemaları gösteriliyor...${NC}"
    show_mongodb_schemas
    show_cassandra_keyspaces
    show_redis_schemas

    echo -e "\n${GREEN}=========================================="
    echo -e "✅ Trino kurulumu tamamlandı!"
    echo -e "=========================================="
    echo -e "${YELLOW}Trino CLI'ye bağlanmak için:${NC}"
    echo -e "docker exec -it veri_trino trino"
    echo -e "\n${YELLOW}Trino Web UI:${NC}"
    echo -e "http://localhost:8080"
    echo ""
}

# Script'i çalıştır
main