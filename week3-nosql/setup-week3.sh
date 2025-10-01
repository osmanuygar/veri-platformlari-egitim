#!/bin/bash

# ============================================
# Week 3 - NoSQL Hızlı Kurulum Scripti
# ============================================

set -e  # Hata durumunda dur

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Week 3 - NoSQL Kurulum Başlatılıyor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. Ön Kontroller
# ============================================

echo "📋 1/5 Ön kontroller yapılıyor..."

# Docker kurulu mu?
if ! command -v docker &> /dev/null; then
    echo "❌ Docker bulunamadı! Lütfen Docker Desktop kurun."
    echo "   https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo "✅ Docker bulundu: $(docker --version)"

# Docker Compose kurulu mu?
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose bulunamadı!"
    exit 1
fi
echo "✅ Docker Compose bulundu: $(docker-compose --version)"

# Docker çalışıyor mu?
if ! docker info &> /dev/null; then
    echo "❌ Docker çalışmıyor! Docker Desktop'u başlatın."
    exit 1
fi
echo "✅ Docker çalışıyor"

echo ""

# ============================================
# 2. Dizin Kontrolü
# ============================================

echo "📁 2/5 Dizin yapısı kontrol ediliyor..."

# week3-nosql klasörüne git veya oluştur
if [ ! -d "week3-nosql" ]; then
    echo "⚠️  week3-nosql klasörü bulunamadı, oluşturuluyor..."
    mkdir -p week3-nosql
fi

cd week3-nosql
echo "✅ Dizin: $(pwd)"

echo ""

# ============================================
# 3. Docker Compose Dosyasını Kontrol Et
# ============================================

echo "🐳 3/5 Docker yapılandırması kontrol ediliyor..."

if [ ! -f "docker-compose.yml" ]; then
    echo "⚠️  docker-compose.yml bulunamadı!"
    echo "   Lütfen docker-compose.yml dosyasını oluşturun."
    exit 1
fi

echo "✅ docker-compose.yml bulundu"

echo ""

# ============================================
# 4. Servisleri Başlat
# ============================================

echo "🚀 4/5 Docker servisleri başlatılıyor..."
echo "   (İlk başlatma 2-3 dakika sürebilir, image'ler indirilecek)"
echo ""

# Tüm servisleri başlat
docker-compose up -d

echo ""
echo "⏳ Servislerin başlaması bekleniyor..."
sleep 10

echo ""

# ============================================
# 5. Durum Kontrolü
# ============================================

echo "🔍 5/5 Servis durumları kontrol ediliyor..."
echo ""

# Servis durumlarını göster
docker-compose ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bağlantı Testleri"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# MongoDB Testi
echo "📗 MongoDB testi..."
if docker exec veri_mongodb mongosh --eval "db.version()" &> /dev/null; then
    echo "   ✅ MongoDB hazır"
    echo "   📍 Bağlantı: docker exec -it veri_mongodb mongosh"
else
    echo "   ⏳ MongoDB henüz hazır değil (birkaç saniye bekleyin)"
fi
echo ""

# Redis Testi
echo "🔴 Redis testi..."
if docker exec veri_redis redis-cli PING &> /dev/null; then
    echo "   ✅ Redis hazır"
    echo "   📍 Bağlantı: docker exec -it veri_redis redis-cli"
else
    echo "   ⏳ Redis henüz hazır değil"
fi
echo ""

# Neo4j Testi
echo "🕸️  Neo4j testi..."
if curl -s http://localhost:7474 > /dev/null; then
    echo "   ✅ Neo4j hazır"
    echo "   📍 Browser: http://localhost:7474"
    echo "   👤 Giriş: neo4j / password123"
else
    echo "   ⏳ Neo4j henüz hazır değil (30 saniye bekleyin)"
fi
echo ""

# Cassandra Testi
echo "📊 Cassandra testi..."
echo "   ⏳ Cassandra başlaması 1-2 dakika sürer..."
echo "   📍 Test için: docker exec -it veri_cassandra cqlsh"
echo ""

# Mongo Express Testi
echo "🌐 Mongo Express (GUI) testi..."
if curl -s http://localhost:8081 > /dev/null; then
    echo "   ✅ Mongo Express hazır"
    echo "   📍 URL: http://localhost:8081"
    echo "   👤 Giriş: admin / admin_pass"
else
    echo "   ⏳ Mongo Express henüz hazır değil"
fi
echo ""

# ============================================
# Özet
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 Kurulum Tamamlandı!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Hızlı Erişim:"
echo ""
echo "   Web Arayüzleri (Tarayıcıda Aç):"
echo "   ▶ Mongo Express: http://localhost:8081"
echo "   ▶ Neo4j Browser: http://localhost:7474"
echo ""
echo "   Terminal Komutları:"
echo "   ▶ MongoDB:   docker exec -it veri_mongodb mongosh"
echo "   ▶ Redis:     docker exec -it veri_redis redis-cli"
echo "   ▶ Cassandra: docker exec -it veri_cassandra cqlsh"
echo "   ▶ Neo4j:     docker exec -it veri_neo4j cypher-shell -u neo4j -p password123"
echo ""
echo "📝 Yararlı Komutlar:"
echo "   ▶ Durumu göster:    docker-compose ps"
echo "   ▶ Logları göster:   docker-compose logs -f"
echo "   ▶ Durdur:           docker-compose stop"
echo "   ▶ Başlat:           docker-compose start"
echo "   ▶ Yeniden başlat:   docker-compose restart"
echo "   ▶ Sil (veri kalır): docker-compose down"
echo "   ▶ Sil (veri gider): docker-compose down -v"
echo ""
echo "🎓 Önemli Notlar:"
echo "   ⚠️  Cassandra başlaması 1-2 dakika sürer, sabırlı olun!"
echo "   ⚠️  Neo4j ilk giriş: neo4j/neo4j → Şifre değiştir: password123"
echo "   ⚠️  Redis şifresi: redis_pass (gerekirse)"
echo ""
echo "📚 Sonraki Adım:"
echo "   README.md dosyasını okuyun ve alıştırmalara başlayın!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================
# Opsiyonel: Tarayıcıda Aç
# ============================================

read -p "Mongo Express'i tarayıcıda açmak ister misiniz? (e/h): " choice
if [ "$choice" = "e" ] || [ "$choice" = "E" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:8081
    elif command -v open &> /dev/null; then
        open http://localhost:8081
    else
        echo "Tarayıcınızda manuel olarak açın: http://localhost:8081"
    fi
fi

read -p "Neo4j Browser'ı tarayıcıda açmak ister misiniz? (e/h): " choice
if [ "$choice" = "e" ] || [ "$choice" = "E" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:7474
    elif command -v open &> /dev/null; then
        open http://localhost:7474
    else
        echo "Tarayıcınızda manuel olarak açın: http://localhost:7474"
    fi
fi

echo ""
echo "Başarılar! 🚀"