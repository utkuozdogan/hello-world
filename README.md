# SQL Server Depo Takip Programı (Başlangıç Projesi)

Bu proje, **SQL Server** kullanan basit bir depo takip sistemi iskeleti içerir:

- Ürün ve depo tanımları
- Giriş/çıkış stok hareketleri
- Anlık stok görünümü (`vw_AnlikStok`)
- Python CLI örnek servis katmanı (`app.py`)

## 1) Veritabanını kur

Önce SQL scriptlerini sırasıyla çalıştır:

1. `sql/schema.sql`
2. `sql/procedures.sql`

## 2) Python ortamını hazırla

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 3) Bağlantı ayarını yap

`.env.example` dosyasını `.env` olarak kopyala ve `SQLSERVER_CONN_STR` değerini kendi SQL Server bilgine göre düzenle.

## 4) Örnek çalıştırma

```bash
python app.py
```

## Veri modeli özeti

- `Urunler`: Ürün kartları
- `Depolar`: Depo kartları
- `StokHareketleri`: Giriş/çıkış hareket kayıtları
- `sp_StokHareketEkle`: Stok hareketini iş kurallarıyla ekler
- `vw_AnlikStok`: Ürün/depo bazında net stok raporu

## Geliştirme önerileri

- Kullanıcı/rol yönetimi ekleyin.
- Hareket tiplerini genişletin (transfer, sayım farkı vb.).
- FastAPI veya ASP.NET Core ile REST API katmanı ekleyin.
- React/Vue ile web arayüzü ekleyin.
