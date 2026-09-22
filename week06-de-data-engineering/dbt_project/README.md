# dbt Projesi — `week06_analytics`

Bu klasör bağımsız bir dbt projesidir; Airflow container'ı içinden
(`/opt/dbt_project`) ya da host makinenizden çalıştırabilirsiniz.

```bash
cd dbt_project
export DBT_PROFILES_DIR=./profiles
dbt deps      # dbt_utils paketini indir (ilk çalıştırmada)
dbt debug     # bağlantıyı doğrula
dbt seed      # seeds/ içindeki CSV'leri yükle
dbt run       # staging + marts modellerini çalıştır
dbt test      # şema testleri + tests/ altındaki özel testler
dbt docs generate && dbt docs serve --port 8091
```

Katman sırası: **source (raw) → staging (`stg_*`) → marts**.
Kural: staging sadece yeniden adlandırır, iş mantığı marts'ta yaşar.
