# 📋 Great Expectations Cheatsheet

```python
import great_expectations as gx
import pandas as pd
```

---

## 🚀 Ephemeral vs File Context

```python
# Ephemeral — hafızada, kaydetmez, hızlı deneme için
context = gx.get_context(mode="ephemeral")

# File — proje klasörüne yazar, Data Docs üretebilir (bu haftanın kullandığı)
context = gx.get_context(mode="file", project_root_dir="./great_expectations")
```

---

## ✅ Validator ve Expectation'lar

```python
validator = context.sources.pandas_default.read_dataframe(df)

validator.expect_column_to_exist("id")
validator.expect_column_values_to_be_unique("id")
validator.expect_column_values_to_not_be_null("email")
validator.expect_column_values_to_match_regex("email", r"^[^@]+@[^@]+\.[^@]+$")
validator.expect_column_values_to_be_in_set("status", ["active", "cancelled"])
validator.expect_column_values_to_be_between("age", min_value=0, max_value=120)
validator.expect_column_mean_to_be_between("price", min_value=10, max_value=1000)

# mostly: %100 yerine bir toleransla geçmesine izin ver
validator.expect_column_values_to_not_be_null("phone", mostly=0.95)  # %95'i yeterli

# Koşullu (sadece bir alt küme üzerinde)
validator.expect_column_values_to_not_be_null(
    "consent_date", row_condition="consent_marketing == True", condition_parser="pandas")
```

---

## 💾 Suite Kaydetme ve Checkpoint Çalıştırma

```python
validator.expectation_suite_name = "my_suite"
validator.save_expectation_suite(discard_failed_expectations=False)

checkpoint = context.add_or_update_checkpoint(name="my_checkpoint", validator=validator)
result = checkpoint.run()

print(result.success)   # tüm suite geçti mi
```

`discard_failed_expectations=False` ÖNEMLİDİR: varsayılan `True` olsaydı,
başarısız olan expectation'lar suite'ten **silinirdi** — bir sonraki
çalıştırmada o kuralı bir daha hiç test etmezdiniz. Kasıtlı olarak
başarısız kalan (henüz düzeltilmemiş) kuralları suite'te tutmak istersiniz.

---

## 📊 Sonuçları Okuma

```python
run_result = list(result.run_results.values())[0]
stats = run_result["validation_result"]["statistics"]
print(stats["success_percent"])

for r in run_result["validation_result"]["results"]:
    print(r["expectation_config"]["expectation_type"], r["success"],
          r["result"].get("unexpected_count"))
```

---

## 📚 Data Docs

```python
context.build_data_docs()
# → gx/uncommitted/data_docs/local_site/index.html
```

Data Docs, her expectation suite'i ve her validation run'ını **otomatik
belgeleyen** statik bir HTML sitesidir — hangi kuralın ne zaman, hangi
sonuçla çalıştığının kalıcı bir kaydı. dbt docs'un (hafta 6) veri kalitesi
karşılığı gibi düşünebilirsiniz.

---

## 🗂 Yaygın Expectation Türleri

| Kategori | Örnek |
|---|---|
| Varlık | `expect_column_to_exist` |
| Benzersizlik | `expect_column_values_to_be_unique` |
| Null kontrolü | `expect_column_values_to_not_be_null` |
| Format | `expect_column_values_to_match_regex` |
| Küme üyeliği | `expect_column_values_to_be_in_set` |
| Aralık | `expect_column_values_to_be_between` |
| İstatistik | `expect_column_mean_to_be_between`, `expect_column_stdev_to_be_between` |
| Satır sayısı | `expect_table_row_count_to_be_between` |
| Çoklu sütun | `expect_multicolumn_sum_to_equal`, `expect_column_pair_values_to_be_equal` |

Tam liste: [Expectation Gallery](https://greatexpectations.io/expectations/)

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `TypeError: ... must be of same type` | Tarih sütunu `datetime64[ns]` değil | `df[col] = pd.to_datetime(df[col]).astype("datetime64[ns]")` |
| `condition_parser is required` | `row_condition` verilmiş ama parser eksik | `condition_parser="pandas"` ekleyin |
| Data Docs boş görünüyor | `build_data_docs()` çağrılmadı | Script'in sonunda çağrıldığından emin olun |
| Suite'te eski kurallar kayboldu | `discard_failed_expectations=True` (varsayılan) | `save_expectation_suite(discard_failed_expectations=False)` |

---

**[← Hafta 12 README](../README.md)** · **[Marquez Cheatsheet →](./marquez-cheatsheet.md)**
