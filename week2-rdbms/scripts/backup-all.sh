#!/bin/bash
# Tüm veritabanlarını yedekle

BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Yedekleme başlatılıyor..."

# PostgreSQL backup
docker exec week2_postgres pg_dump -U veri_user veri_db > "$BACKUP_DIR/postgres_backup.sql"
echo "✅ PostgreSQL yedeklendi"

# MySQL backup
#docker exec veri_mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD veri_db > "$BACKUP_DIR/mysql_backup.sql"
#echo "✅ MySQL yedeklendi"

echo "🎉 Tüm yedeklemeler tamamlandı: $BACKUP_DIR"