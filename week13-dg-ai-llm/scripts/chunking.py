"""
Hafta 13 — parçalama (chunking) stratejileri

RAG kalitesinin en kritik kararı budur: bir parça çok büyükse ilgisiz
bilgi taşır (arama hassasiyeti düşer), çok küçükse bağlamını kaybeder.
"""
import re
from pathlib import Path

from common import REPO_ROOT


def find_week_readmes():
    """week01-... .. week14-... klasörlerindeki README.md dosyalarını bulur."""
    files = sorted(REPO_ROOT.glob("week[0-9][0-9]-*/README.md"))
    return files


def week_meta(path: Path):
    """'week07-de-kafka/README.md' -> (7, 'de-kafka')"""
    name = path.parent.name  # week07-de-kafka
    m = re.match(r"week(\d+)-(.+)", name)
    return int(m.group(1)), m.group(2)


def chunk_by_heading(text: str, min_chars: int = 200):
    """
    Strateji A (ÖNERİLEN): Markdown ## başlıklarına göre böl.
    Her chunk, doğal bir "konu" sınırında biter — bağlam bütünlüğü en yüksek.
    """
    # ## veya ### ile başlayan satırları böl noktası kabul et
    parts = re.split(r"\n(?=##\s)", text)
    chunks = []
    for p in parts:
        p = p.strip()
        if len(p) < min_chars:
            continue
        # Başlığı ayıkla (metadata için)
        title_match = re.match(r"^#{2,3}\s*(.+)", p)
        title = title_match.group(1).strip() if title_match else "—"
        chunks.append({"section": title, "text": p})
    return chunks


def chunk_by_fixed_size(text: str, size: int = 800, overlap: int = 100):
    """
    Strateji B: Sabit karakter sayısına göre böl (örtüşmeli).
    Basit ve hızlıdır ama bir cümlenin/kod bloğunun ORTASINDAN kesebilir.
    """
    chunks = []
    start = 0
    while start < len(text):
        end = start + size
        piece = text[start:end].strip()
        if len(piece) > 50:
            chunks.append({"section": f"karakter {start}-{end}", "text": piece})
        start += size - overlap
    return chunks


def chunk_by_paragraph(text: str, min_chars: int = 200, max_chars: int = 1500):
    """
    Strateji C: Boş satırla ayrılan paragraflara göre böl, ardışık kısa
    paragrafları max_chars'a ulaşana kadar birleştir.
    """
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    chunks = []
    buffer = ""
    for p in paragraphs:
        if len(buffer) + len(p) < max_chars:
            buffer += ("\n\n" if buffer else "") + p
        else:
            if len(buffer) >= min_chars:
                chunks.append({"section": "—", "text": buffer})
            buffer = p
    if len(buffer) >= min_chars:
        chunks.append({"section": "—", "text": buffer})
    return chunks


STRATEGIES = {
    "heading": chunk_by_heading,
    "fixed": chunk_by_fixed_size,
    "paragraph": chunk_by_paragraph,
}
