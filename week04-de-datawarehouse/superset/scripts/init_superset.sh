#!/bin/bash
# Superset İlk Kurulum Scripti
# Bu script superset-init container'ı tarafından otomatik çalıştırılır

echo "================================================"
echo "Superset İlk Kurulum Başlıyor..."
echo "================================================"

# Database upgrade
echo "[1/4] Database schema güncellemesi..."
superset db upgrade
echo "✓ Database schema güncellendi"

# Admin kullanıcı oluştur
echo "[2/4] Admin kullanıcısı oluşturuluyor..."
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname User \
    --email admin@superset.com \
    --password admin123 || echo "Admin kullanıcısı zaten mevcut"
echo "✓ Admin kullanıcısı hazır"

# Initialize Superset
echo "[3/4] Superset başlatılıyor..."
superset init
echo "✓ Superset başlatıldı"

# Örnek database bağlantısı ekle (opsiyonel)
echo "[4/4] Örnek database bağlantıları ekleniyor..."
# Bu kısım opsiyonel - manuel olarak da eklenebilir

echo ""
echo "================================================"
echo "✓ Superset Kurulumu Tamamlandı!"
echo "================================================"
echo ""
echo "Web UI: http://localhost:8088"
echo "Kullanıcı: admin"
echo "Şifre: admin123"
echo ""
echo "İlk adımlar:"
echo "1. Settings > Database Connections'dan OLAP database'i ekle"
echo "2. Data > Datasets'den tablolarını ekle"
echo "3. Charts > + Chart ile ilk görselleştirmeni oluştur"
echo "4. Dashboards > + Dashboard ile dashboard oluştur"
echo ""
echo "================================================"