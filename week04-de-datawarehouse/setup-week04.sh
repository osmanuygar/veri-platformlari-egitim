#!/bin/bash

# ============================================
# Week 4 - Data Warehouse Hızlı Kurulum
# ============================================

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Week 4 - Data Warehouse Kurulum"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# Ön Kontroller
# ============================================
echo "📋 Ön kontroller..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker bulunamadı!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker: $(docker --version)${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose bulunamadı!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose: $(docker-compose --version)${NC}"

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker çalışmıyor!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker çalışıyor${NC}"

echo ""

# ============================================
# Dizin Kontrolü
# ============================================
echo "📁 Dizin yapısı kontrol ediliyor..."

if [ ! -d "week04-de-datawarehouse" ]; then
    echo -e "${YELLOW}⚠️  week04-de-datawarehouse klasörü bulunamadı, oluşturuluyor...${NC}"
    mkdir -p week04-de-datawarehouse
fi

cd week04-de-datawarehouse
echo -e "${GREEN}✅ Dizin: $(pwd)${NC}"

echo ""

# ============================================
# Environment Dosyası
# ============================================
echo "🔧 Environment dosyası kontrol ediliyor..."

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.example bulunamadı${NC}"
    fi
else
    echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
fi

echo ""

# ============================================
# Servisleri Başlat
# ============================================
echo "🚀 Servisleri başlatmak istiyor musunuz?"
echo ""
echo "Seçenekler:"
echo "  1) Temel Servisler (OLTP, OLAP, pgAdmin, MinIO)"
echo "  2) + Spark ve Jupyter"
echo "  3) + Superset (BI Tool)"
echo "  4) Tümü (Airflow dahil)"
echo "  5) İptal"
echo ""
read -p "Seçiminiz (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}Temel servisler başlatılıyor...${NC}"
        docker-compose up -d postgres-oltp postgres-olap pgadmin minio minio-init
        ;;
    2)
        echo -e "${GREEN}Temel servisler + Spark ve Jupyter başlatılıyor...${NC}"
        docker-compose up -d postgres-oltp postgres-olap pgadmin minio minio-init spark-master spark-worker jupyter
        ;;
    3)
        echo -e "${GREEN}Temel servisler + Spark + Jupyter + Superset başlatılıyor...${NC}"
        docker-compose up -d postgres-oltp postgres-olap pgadmin minio minio-init spark-master spark-worker jupyter superset
        ;;
    4)
        echo -e "${GREEN}Tüm servisler başlatılıyor (Airflow dahil)...${NC}"
        docker-compose --profile airflow up -d
        ;;
    5)
        echo -e "${YELLOW}İptal edildi${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Geçersiz seçim${NC}"
        exit 1
        ;;
esac

echo ""
echo "⏳ Servislerin başlaması bekleniyor..."
sleep 15

echo ""

# ============================================
# Durum Kontrolü
# ============================================
echo "🔍 Servis durumları:"
echo ""
docker-compose ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bağlantı Testleri"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# OLTP Test
echo "📊 OLTP PostgreSQL testi..."
if docker exec postgres_oltp pg_isready -U oltp_user &> /dev/null; then
    echo -e "   ${GREEN}✅ OLTP PostgreSQL hazır${NC}"
    echo "   📍 Port: 5432"
    echo "   📍 Bağlantı: docker exec -it postgres_oltp psql -U oltp_user -d ecommerce_oltp"
else
    echo -e "   ${YELLOW}⏳ OLTP henüz hazır değil${NC}"
fi
echo ""

# OLAP Test
echo "📈 OLAP PostgreSQL testi..."
if docker exec postgres_olap pg_isready -U olap_user &> /dev/null; then
    echo -e "   ${GREEN}✅ OLAP PostgreSQL hazır${NC}"
    echo "   📍 Port: 5433"
    echo "   📍 Bağlantı: docker exec -it postgres_olap psql -U olap_user -d ecommerce_olap"
else
    echo -e "   ${YELLOW}⏳ OLAP henüz hazır değil${NC}"
fi
echo ""

# pgAdmin Test
echo "🗄️  pgAdmin testi..."
if curl -s http://localhost:5050 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✅ pgAdmin hazır${NC}"
    echo "   📍 URL: http://localhost:5050"
    echo "   👤 Giriş: admin@datawarehouse.com / admin123"
else
    echo -e "   ${YELLOW}⏳ pgAdmin henüz hazır değil${NC}"
fi
echo ""

# MinIO Test
echo "🗄️  MinIO testi..."
if curl -s http://localhost:9001 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✅ MinIO hazır${NC}"
    echo "   📍 Console: http://localhost:9001"
    echo "   📍 API: http://localhost:9000"
    echo "   👤 Giriş: minio_admin / minio_password123"
else
    echo -e "   ${YELLOW}⏳ MinIO henüz hazır değil${NC}"
fi
echo ""

# Spark Test (eğer başlatıldıysa)
if docker ps | grep -q spark_master; then
    echo "⚡ Apache Spark testi..."
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Spark Master hazır${NC}"
        echo "   📍 Master UI: http://localhost:8080"
        echo "   📍 Worker UI: http://localhost:8081"
    else
        echo -e "   ${YELLOW}⏳ Spark henüz hazır değil${NC}"
    fi
    echo ""
fi

# Jupyter Test (eğer başlatıldıysa)
if docker ps | grep -q jupyter; then
    echo "📓 Jupyter Lab testi..."
    if curl -s http://localhost:8888 > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Jupyter Lab hazır${NC}"
        echo "   📍 URL: http://localhost:8888"
        echo "   🔑 Token: datawarehouse123"
    else
        echo -e "   ${YELLOW}⏳ Jupyter henüz hazır değil${NC}"
    fi
    echo ""
fi

# Superset Test (eğer başlatıldıysa)
if docker ps | grep -q superset; then
    echo "📊 Superset testi..."
    echo -e "   ${YELLOW}⏳ Superset başlaması 2-3 dakika sürer${NC}"
    echo "   📍 URL: http://localhost:8088 (biraz bekleyin)"
    echo "   👤 Giriş: admin / admin123"
    echo ""
fi

# ============================================
# Veri Yükleme Önerisi
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Sonraki Adımlar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  OLTP veritabanını yükle:"
echo "   docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/01-schema.sql"
echo "   docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/02-sample-data.sql"
echo ""
echo "2️⃣  OLAP yapısını oluştur:"
echo "   docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/01-dimensions.sql"
echo "   docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/02-facts.sql"
echo ""
echo "3️⃣  ETL pipeline çalıştır:"
echo "   docker-compose --profile etl up -d etl-service"
echo "   docker exec etl_service python full_pipeline.py"
echo ""
echo "4️⃣  Jupyter'da notebook'ları aç:"
echo "   open http://localhost:8888"
echo ""
echo "5️⃣  README.md'yi oku ve alıştırmalara başla!"
echo ""

# ============================================
# Tarayıcıda Aç (Opsiyonel)
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Web arayüzlerini tarayıcıda açmak ister misiniz? (e/h): " open_browser

if [ "$open_browser" = "e" ] || [ "$open_browser" = "E" ]; then
    echo ""
    echo "🌐 Tarayıcılar açılıyor..."

    # Platforma göre open komutu
    if command -v xdg-open &> /dev/null; then
        OPEN_CMD="xdg-open"
    elif command -v open &> /dev/null; then
        OPEN_CMD="open"
    else
        echo -e "${YELLOW}Tarayıcı açılamadı. Manuel olarak açın.${NC}"
        OPEN_CMD=""
    fi

    if [ -n "$OPEN_CMD" ]; then
        $OPEN_CMD http://localhost:5050 2>/dev/null &  # pgAdmin
        sleep 2
        $OPEN_CMD http://localhost:9001 2>/dev/null &  # MinIO
        sleep 2

        if docker ps | grep -q jupyter; then
            $OPEN_CMD http://localhost:8888 2>/dev/null &  # Jupyter
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}🎉 Week 4 Kurulum Tamamlandı!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Yararlı Komutlar:"
echo "   • Durumu göster:    docker-compose ps"
echo "   • Logları göster:   docker-compose logs -f"
echo "   • Durdur:           docker-compose stop"
echo "   • Başlat:           docker-compose start"
echo "   • Sil:              docker-compose down"
echo "   • Tam sil:          docker-compose down -v"
echo ""
echo "📚 Dokümantasyon:"
echo "   • Ana rehber:       cat README.md"
echo "   • OLTP vs OLAP:     cat docs/01-oltp-vs-olap.md"
echo "   • ETL Guide:        cat docs/04-etl-best-practices.md"
echo ""
echo "🎓 İyi çalışmalar! 🚀"
