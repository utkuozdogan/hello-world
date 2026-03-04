"""SQL Server tabanlı basit depo takip CLI örneği."""

import os
from decimal import Decimal

import pyodbc
from dotenv import load_dotenv

load_dotenv()


class DepoTakipService:
    def __init__(self) -> None:
        conn_str = os.getenv("SQLSERVER_CONN_STR")
        if not conn_str:
            raise ValueError("SQLSERVER_CONN_STR tanımlı değil.")
        self.conn_str = conn_str

    def _connect(self):
        return pyodbc.connect(self.conn_str)

    def urun_ekle(self, urun_kodu: str, urun_adi: str, birim: str, min_stok: Decimal = Decimal("0")) -> None:
        query = """
            INSERT INTO dbo.Urunler (UrunKodu, UrunAdi, Birim, MinStok)
            VALUES (?, ?, ?, ?)
        """
        with self._connect() as conn:
            conn.execute(query, (urun_kodu, urun_adi, birim, min_stok))
            conn.commit()

    def depo_ekle(self, depo_kodu: str, depo_adi: str) -> None:
        query = """
            INSERT INTO dbo.Depolar (DepoKodu, DepoAdi)
            VALUES (?, ?)
        """
        with self._connect() as conn:
            conn.execute(query, (depo_kodu, depo_adi))
            conn.commit()

    def stok_hareketi_ekle(
        self,
        urun_kodu: str,
        depo_kodu: str,
        hareket_tipi: str,
        miktar: Decimal,
        birim_fiyat: Decimal | None = None,
        aciklama: str | None = None,
    ) -> None:
        query = """
            EXEC dbo.sp_StokHareketEkle
                @UrunKodu = ?,
                @DepoKodu = ?,
                @HareketTipi = ?,
                @Miktar = ?,
                @BirimFiyat = ?,
                @Aciklama = ?
        """
        with self._connect() as conn:
            conn.execute(query, (urun_kodu, depo_kodu, hareket_tipi, miktar, birim_fiyat, aciklama))
            conn.commit()

    def anlik_stok_listele(self) -> list[tuple]:
        query = """
            SELECT UrunKodu, UrunAdi, DepoKodu, DepoAdi, NetStok, MinStok
            FROM dbo.vw_AnlikStok
            ORDER BY UrunKodu, DepoKodu
        """
        with self._connect() as conn:
            rows = conn.execute(query).fetchall()
        return [tuple(row) for row in rows]


def demo():
    service = DepoTakipService()
    service.urun_ekle("PRD-001", "Matkap", "ADET", Decimal("10"))
    service.depo_ekle("DP-001", "Merkez Depo")
    service.stok_hareketi_ekle("PRD-001", "DP-001", "GIRIS", Decimal("100"), Decimal("1500"), "Açılış stoğu")

    for satir in service.anlik_stok_listele():
        print(satir)


if __name__ == "__main__":
    demo()
