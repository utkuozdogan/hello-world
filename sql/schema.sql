-- SQL Server Depo Takip Sistemi - Şema
CREATE DATABASE DepoTakipDB;
GO

USE DepoTakipDB;
GO

CREATE TABLE dbo.Urunler (
    UrunId INT IDENTITY(1,1) PRIMARY KEY,
    UrunKodu NVARCHAR(50) NOT NULL UNIQUE,
    UrunAdi NVARCHAR(200) NOT NULL,
    Birim NVARCHAR(20) NOT NULL,
    MinStok DECIMAL(18,2) NOT NULL DEFAULT 0,
    Aktif BIT NOT NULL DEFAULT 1,
    OlusturmaTarihi DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Depolar (
    DepoId INT IDENTITY(1,1) PRIMARY KEY,
    DepoKodu NVARCHAR(50) NOT NULL UNIQUE,
    DepoAdi NVARCHAR(200) NOT NULL,
    Aktif BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.StokHareketleri (
    HareketId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UrunId INT NOT NULL,
    DepoId INT NOT NULL,
    HareketTipi NVARCHAR(10) NOT NULL CHECK (HareketTipi IN ('GIRIS','CIKIS')),
    Miktar DECIMAL(18,2) NOT NULL CHECK (Miktar > 0),
    BirimFiyat DECIMAL(18,2) NULL,
    Aciklama NVARCHAR(500) NULL,
    IslemTarihi DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Stok_Urun FOREIGN KEY (UrunId) REFERENCES dbo.Urunler(UrunId),
    CONSTRAINT FK_Stok_Depo FOREIGN KEY (DepoId) REFERENCES dbo.Depolar(DepoId)
);

CREATE INDEX IX_StokHareketleri_UrunDepoTarih
    ON dbo.StokHareketleri(UrunId, DepoId, IslemTarihi DESC);
GO
