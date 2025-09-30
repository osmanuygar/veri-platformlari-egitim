import pandas as pd
import numpy as np
from pathlib import Path


def check_data_quality(file_path):
    """Kapsamlı veri kalitesi kontrolü"""

    print("=" * 60)
    print(f"VERİ KALİTESİ RAPORU: {Path(file_path).name}")
    print("=" * 60)

    # Dosyayı oku
    df = pd.read_csv(file_path)

    # 1. GENEL BİLGİLER
    print("\n📊 1. GENEL BİLGİLER")
    print(f"   Toplam Satır: {len(df):,}")
    print(f"   Toplam Sütun: {len(df.columns)}")
    print(f"   Bellek Kullanımı: {df.memory_usage(deep=True).sum() / 1024 ** 2:.2f} MB")

    # 2. EKSİK DEĞERLER
    print("\n❓ 2. EKSİK DEĞERLER")
    missing = df.isnull().sum()
    missing_pct = (missing / len(df) * 100).round(2)

    has_missing = False
    for col in df.columns:
        if missing[col] > 0:
            has_missing = True
            status = "🔴" if missing_pct[col] > 20 else "🟡" if missing_pct[col] > 5 else "🟢"
            print(f"   {status} {col}: {missing[col]:,} eksik ({missing_pct[col]}%)")

    if not has_missing:
        print("   ✅ Eksik değer yok")

    # 3. TEKRAR EDEN KAYITLAR
    print("\n🔄 3. TEKRAR EDEN KAYITLAR")
    duplicates = df.duplicated().sum()
    if duplicates > 0:
        print(f"   🔴 {duplicates:,} tekrar eden satır ({duplicates / len(df) * 100:.2f}%)")
    else:
        print("   ✅ Tekrar eden kayıt yok")

    # 4. VERİ TİPLERİ
    print("\n📝 4. VERİ TİPLERİ")
    type_counts = df.dtypes.value_counts()
    for dtype, count in type_counts.items():
        print(f"   • {dtype}: {count} sütun")

    # 5. SAYISAL SÜTUNLAR
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        print("\n🔢 5. SAYISAL SÜTUN İSTATİSTİKLERİ")
        stats = df[numeric_cols].describe()
        print(stats.to_string())

        # Outlier kontrolü
        print("\n   🎯 Outlier Kontrolü (IQR Yöntemi):")
        for col in numeric_cols:
            Q1 = df[col].quantile(0.25)
            Q3 = df[col].quantile(0.75)
            IQR = Q3 - Q1
            lower = Q1 - 1.5 * IQR
            upper = Q3 + 1.5 * IQR
            outliers = df[(df[col] < lower) | (df[col] > upper)]

            if len(outliers) > 0:
                print(f"      🔴 {col}: {len(outliers):,} outlier ({len(outliers) / len(df) * 100:.2f}%)")

    # 6. KATEGORİK SÜTUNLAR
    categorical_cols = df.select_dtypes(include=['object']).columns
    if len(categorical_cols) > 0:
        print("\n📋 6. KATEGORİK SÜTUNLAR")
        for col in categorical_cols[:5]:  # İlk 5 sütun
            nunique = df[col].nunique()
            print(f"\n   • {col}:")
            print(f"      Benzersiz Değer: {nunique}")
            if nunique <= 10:
                print(f"      Dağılım:")
                for val, count in df[col].value_counts().head(5).items():
                    print(f"        - {val}: {count} ({count / len(df) * 100:.1f}%)")

    # 7. KALİTE SKORU
    print("\n⭐ 7. GENEL KALİTE SKORU")

    # Skorlama kriterleri
    completeness_score = ((len(df) - df.isnull().sum().sum()) / (len(df) * len(df.columns))) * 100
    uniqueness_score = ((len(df) - duplicates) / len(df)) * 100

    overall_score = (completeness_score + uniqueness_score) / 2

    print(f"   Tamlık Skoru: {completeness_score:.2f}%")
    print(f"   Benzersizlik Skoru: {uniqueness_score:.2f}%")
    print(f"   📊 GENEL SKOR: {overall_score:.2f}%")

    if overall_score >= 90:
        print("   ✅ Mükemmel kalite!")
    elif overall_score >= 75:
        print("   🟢 İyi kalite")
    elif overall_score >= 60:
        print("   🟡 Orta kalite - İyileştirme gerekli")
    else:
        print("   🔴 Düşük kalite - Ciddi temizlik gerekli")

    print("\n" + "=" * 60)

    return {
        'total_rows': len(df),
        'total_cols': len(df.columns),
        'missing_values': missing.sum(),
        'duplicates': duplicates,
        'overall_score': overall_score
    }


def main():
    """Tüm CSV dosyalarını kontrol et"""
    data_dir = Path('/app/data-samples/structured')

    if not data_dir.exists():
        print("❌ Veri klasörü bulunamadı!")
        print("Önce generate_sample_data.py scriptini çalıştırın")
        return

    csv_files = list(data_dir.glob('*.csv'))

    if not csv_files:
        print("❌ CSV dosyası bulunamadı!")
        return

    print("\n🔍 VERİ KALİTESİ KONTROLÜ BAŞLIYOR...\n")

    results = {}
    for csv_file in csv_files:
        result = check_data_quality(csv_file)
        results[csv_file.name] = result
        print("\n")

    # Özet rapor
    print("=" * 60)
    print("📈 ÖZET RAPOR")
    print("=" * 60)
    for filename, result in results.items():
        print(f"\n{filename}:")
        print(f"  Satır: {result['total_rows']:,}")
        print(f"  Sütun: {result['total_cols']}")
        print(f"  Kalite Skoru: {result['overall_score']:.2f}%")


if __name__ == "__main__":
    main()