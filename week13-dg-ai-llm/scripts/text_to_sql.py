#!/usr/bin/env python3
"""
Hafta 13 — Alıştırma 5: Text-to-SQL

Doğal dilde bir soru sorun, LLM şemayı görerek bir SQL sorgusu üretsin,
script bunu ÇALIŞTIRMADAN ÖNCE doğrulasın (sadece SELECT'e izin ver),
sonra çalıştırıp sonucu göstersin.

⚠️ Bu, "LLM'in ürettiği SQL'i körü körüne çalıştırma" riskinin somut bir
göstergesidir — doğrulama katmanı OLMADAN bu script tehlikeli olurdu.

Kullanım:
    python scripts/text_to_sql.py "En çok sipariş veren müşteri kim?"
    python scripts/text_to_sql.py "..." --execute          # sorguyu gerçekten çalıştır
    python scripts/text_to_sql.py "..." --show-prompt       # LLM'e giden tam prompt'u göster
"""
import argparse
import re
import sys

import psycopg2

from common import PG, OLLAMA_URL, OLLAMA_CHAT_MODEL, C, banner, require

require("ollama")
import ollama

SCHEMA_DESCRIPTION = """
Şema: shop

TABLO: shop.customers (id, full_name, city, segment)
  segment: 'bronze' | 'silver' | 'gold'

TABLO: shop.products (id, sku, name, category, price)

TABLO: shop.orders (id, customer_id, order_date, status)
  status: 'completed' | 'shipped' | 'cancelled'
  customer_id -> shop.customers.id

TABLO: shop.order_items (id, order_id, product_id, quantity, unit_price)
  order_id -> shop.orders.id
  product_id -> shop.products.id
"""

SYSTEM_PROMPT = f"""Sen bir PostgreSQL uzmanısın. Sana verilen şemaya göre,
kullanıcının doğal dildeki sorusunu cevaplayan TEK BİR SQL sorgusu üret.

{SCHEMA_DESCRIPTION}

KURALLAR:
- SADECE SELECT sorgusu üret. INSERT/UPDATE/DELETE/DROP/ALTER YASAK.
- Sadece yukarıdaki tabloları/sütunları kullan, uydurma sütun adı yazma.
- Cevabını SADECE SQL kodu olarak ver, açıklama ekleme, ```sql``` bloğu kullanma.
- Sorgunun sonuna noktalı virgül koy.
"""

# Güvenlik: bu kelimelerden biri varsa sorguyu ASLA çalıştırma
FORBIDDEN = re.compile(
    r"\b(insert|update|delete|drop|alter|truncate|grant|revoke|create|"
    r"attach|copy|vacuum|execute|call|do)\b", re.IGNORECASE)


def extract_sql(raw: str) -> str:
    """Modelin bazen eklediği ```sql``` bloklarını temizler."""
    text = raw.strip()
    text = re.sub(r"^```sql\s*|^```\s*|```$", "", text, flags=re.MULTILINE).strip()
    return text


def validate_sql(sql: str) -> tuple[bool, str]:
    """Çok katmanlı, basit ama katı bir güvenlik kontrolü."""
    stripped = sql.strip().rstrip(";").strip()

    if not stripped:
        return False, "Boş sorgu"
    if ";" in stripped:
        return False, "Birden fazla ifade (noktalı virgülle ayrılmış) tespit edildi — reddedildi"
    if not re.match(r"(?is)^\s*select\b", stripped):
        return False, "Sorgu SELECT ile başlamıyor"
    if FORBIDDEN.search(stripped):
        return False, f"Yasaklı anahtar kelime tespit edildi: {FORBIDDEN.search(stripped).group()}"
    return True, "OK"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("question")
    ap.add_argument("--execute", action="store_true", help="doğrulamadan geçerse gerçekten çalıştır")
    ap.add_argument("--show-prompt", action="store_true")
    args = ap.parse_args()

    banner("Text-to-SQL", f"Soru: \"{args.question}\"")

    if args.show_prompt:
        print(f"{C.DIM}{SYSTEM_PROMPT}{C.RESET}\n")

    client = ollama.Client(host=OLLAMA_URL)
    print(f"{C.DIM}[1/3] {OLLAMA_CHAT_MODEL} SQL üretiyor…{C.RESET}")
    try:
        response = client.chat(model=OLLAMA_CHAT_MODEL, messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": args.question},
        ])
    except Exception as e:
        print(f"{C.RED}✖ Ollama hatası: {e}{C.RESET}")
        sys.exit(1)

    sql = extract_sql(response.message.content)
    print(f"\n{C.BOLD}Üretilen SQL:{C.RESET}\n{C.CYAN}{sql}{C.RESET}\n")

    print(f"{C.DIM}[2/3] Güvenlik doğrulaması yapılıyor…{C.RESET}")
    ok, reason = validate_sql(sql)
    if not ok:
        print(f"{C.RED}✖ REDDEDİLDİ: {reason}{C.RESET}")
        print(f"{C.DIM}  Bu sorgu ÇALIŞTIRILMAYACAK.{C.RESET}")
        sys.exit(1)
    print(f"{C.GREEN}✔ Doğrulama geçti: sadece SELECT, yasaklı kelime yok{C.RESET}")

    if not args.execute:
        print(f"\n{C.YELLOW}Sorguyu gerçekten çalıştırmak için --execute ekleyin.{C.RESET}\n")
        return

    print(f"\n{C.DIM}[3/3] Sorgu çalıştırılıyor (salt-okunur transaction içinde)…{C.RESET}\n")
    conn = psycopg2.connect(**PG)
    conn.set_session(readonly=True)   # ekstra güvenlik katmanı: bağlantı seviyesinde salt-okunur
    try:
        with conn.cursor() as cur:
            cur.execute(sql)
            cols = [d[0] for d in cur.description] if cur.description else []
            rows = cur.fetchall() if cur.description else []
    except psycopg2.Error as e:
        print(f"{C.RED}✖ SQL çalıştırma hatası: {e}{C.RESET}")
        sys.exit(1)
    finally:
        conn.close()

    if not rows:
        print(f"{C.DIM}(sonuç yok){C.RESET}")
        return

    print(f"{C.BOLD}{'  '.join(cols)}{C.RESET}")
    print("─" * 50)
    for row in rows[:20]:
        print("  ".join(str(v) for v in row))
    if len(rows) > 20:
        print(f"{C.DIM}… ve {len(rows)-20} satır daha{C.RESET}")


if __name__ == "__main__":
    main()
