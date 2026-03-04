USE DepoTakipDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_StokHareketEkle
    @UrunKodu NVARCHAR(50),
    @DepoKodu NVARCHAR(50),
    @HareketTipi NVARCHAR(10),
    @Miktar DECIMAL(18,2),
    @BirimFiyat DECIMAL(18,2) = NULL,
    @Aciklama NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UrunId INT = (SELECT UrunId FROM dbo.Urunler WHERE UrunKodu = @UrunKodu AND Aktif = 1);
    DECLARE @DepoId INT = (SELECT DepoId FROM dbo.Depolar WHERE DepoKodu = @DepoKodu AND Aktif = 1);

    IF @UrunId IS NULL
        THROW 50001, 'Geçersiz ürün kodu.', 1;

    IF @DepoId IS NULL
        THROW 50002, 'Geçersiz depo kodu.', 1;

    IF @HareketTipi = 'CIKIS'
    BEGIN
        DECLARE @MevcutStok DECIMAL(18,2) = (
            SELECT ISNULL(SUM(CASE WHEN HareketTipi='GIRIS' THEN Miktar ELSE -Miktar END),0)
            FROM dbo.StokHareketleri
            WHERE UrunId = @UrunId AND DepoId = @DepoId
        );

        IF @MevcutStok < @Miktar
            THROW 50003, 'Yetersiz stok.', 1;
    END

    INSERT INTO dbo.StokHareketleri (UrunId, DepoId, HareketTipi, Miktar, BirimFiyat, Aciklama)
    VALUES (@UrunId, @DepoId, @HareketTipi, @Miktar, @BirimFiyat, @Aciklama);
END;
GO

CREATE OR ALTER VIEW dbo.vw_AnlikStok
AS
SELECT
    u.UrunKodu,
    u.UrunAdi,
    d.DepoKodu,
    d.DepoAdi,
    SUM(CASE WHEN s.HareketTipi='GIRIS' THEN s.Miktar ELSE -s.Miktar END) AS NetStok,
    u.MinStok
FROM dbo.StokHareketleri s
JOIN dbo.Urunler u ON u.UrunId = s.UrunId
JOIN dbo.Depolar d ON d.DepoId = s.DepoId
GROUP BY u.UrunKodu, u.UrunAdi, d.DepoKodu, d.DepoAdi, u.MinStok;
GO
