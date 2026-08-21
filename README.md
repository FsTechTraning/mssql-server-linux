# SQL Server コンテナの docker-compose 構成サンプル

## Get Started
このリポジトリをクローンする。
```console
git clone https://github.com/FsTechTraning/mssql-server-linux.git
```

クローンしたローカルリポジトリ内に入る。
```console
cd ./mssql-server-linux
```

DB コンテナを起動。
```console
docker-compose up -d
```

## 設定値など
設定値を変えたい時は、以下の箇所の値の不整合が起こらないように留意する。 

### docker-compose.yml:
```yaml
environment:
    SA_PASSWORD: msSqlserver123
    ACCEPT_EULA: "Y"
    MSSQL_AGENT_ENABLED: "true"
ports:
    - published: 1433
      target: 1433
```

### 初期設定接続シェル: db-init.sh
```shell
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P msSqlserver123 -d master -C -i db-init.sql
```
### 初期データ登録 SQL: db-init.sql
```sql
DROP DATABASE if exists MstDb;
GO

CREATE DATABASE MstDb;
GO

use MstDb;
GO

DROP TABLE if exists MstBranches;

CREATE TABLE MstBranches (
  Id int identity NOT NULL
  , Cd nvarchar(5)
  , Name nvarchar(max)
  , PrefCd nvarchar(5)
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstBranches_PKC PRIMARY KEY (Id)
) ;

DROP TABLE if exists MstDisasterStocks;

CREATE TABLE MstDisasterStocks (
  Id int identity NOT NULL
  , ProductCd nvarchar(15) NOT NULL
  , SavingStockKbn nvarchar(5) NOT NULL
  , PrefCd nvarchar(5)
  , BranchCd nvarchar(5)
  , Quantity int NOT NULL
  , StockStartDate datetime2 NOT NULL
  , StockEndDate datetime2 NOT NULL
  , ReserveBranchCd nvarchar(5) NOT NULL
  , StockConditionKbn nvarchar(5) NOT NULL
  , Version int NOT NULL
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstDisasterStocks_PKC PRIMARY KEY (Id)
) ;

DROP TABLE if exists MstKbns;

CREATE TABLE MstKbns (
  Id int identity NOT NULL
  , Kbn nvarchar(50)
  , Cd nvarchar(5)
  , Value nvarchar(max)
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstKbns_PKC PRIMARY KEY (Id)
) ;

DROP TABLE if exists MstManufactures;

CREATE TABLE MstManufactures (
  Id int identity NOT NULL
  , Cd nvarchar(10)
  , Name nvarchar(max)
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstManufactures_PKC PRIMARY KEY (Id)
) ;

DROP TABLE if exists MstPrefs;

CREATE TABLE MstPrefs (
  Id int identity NOT NULL
  , Cd nvarchar(5)
  , Name nvarchar(max)
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstPrefs_PKC PRIMARY KEY (Id)
) ;

DROP TABLE if exists MstProducts;

CREATE TABLE MstProducts (
  Id int identity NOT NULL
  , Cd nvarchar(15)
  , Name nvarchar(max)
  , Volume nvarchar(max)
  , ManufactureCd nvarchar(10)
  , CreatedAt datetime2
  , UpdatedAt datetime2
  , CONSTRAINT MstProducts_PKC PRIMARY KEY (Id)
) ;

BULK INSERT dbo.MstBranches
FROM '/usr/src/docker/data/dbo.MstBranches.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

BULK INSERT dbo.MstDisasterStocks
FROM '/usr/src/docker/data/dbo.MstDisasterStocks.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

BULK INSERT dbo.MstKbns
FROM '/usr/src/docker/data/dbo.MstKbns.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

BULK INSERT dbo.MstManufactures
FROM '/usr/src/docker/data/dbo.MstManufactures.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

BULK INSERT dbo.Mstprefs
FROM '/usr/src/docker/data/dbo.Mstprefs.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

BULK INSERT dbo.MstProducts
FROM '/usr/src/docker/data/dbo.MstProducts.csv'
WITH
(
   FORMAT='csv',
   FIRSTROW=2,
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   DATAFILETYPE='widechar',
   KEEPIDENTITY
);

-- テーブル仕様書に記載された一意制約・外部キー制約。
-- CSVを投入した後に追加することで、初期データ自体も制約検証の対象にする。
ALTER TABLE dbo.MstManufactures
  ADD CONSTRAINT MstManufactures_Cd_UQC UNIQUE (Cd);

ALTER TABLE dbo.MstPrefs
  ADD CONSTRAINT MstPrefs_Cd_UQC UNIQUE (Cd);

ALTER TABLE dbo.MstProducts
  ADD CONSTRAINT MstProducts_Cd_UQC UNIQUE (Cd);

ALTER TABLE dbo.MstBranches
  ADD CONSTRAINT MstBranches_Cd_UQC UNIQUE (Cd);

ALTER TABLE dbo.MstProducts
  ADD CONSTRAINT MstProducts_ManufactureCd_FKC
  FOREIGN KEY (ManufactureCd) REFERENCES dbo.MstManufactures (Cd);

ALTER TABLE dbo.MstBranches
  ADD CONSTRAINT MstBranches_PrefCd_FKC
  FOREIGN KEY (PrefCd) REFERENCES dbo.MstPrefs (Cd);

ALTER TABLE dbo.MstDisasterStocks
  ADD CONSTRAINT MstDisasterStocks_ProductCd_FKC
  FOREIGN KEY (ProductCd) REFERENCES dbo.MstProducts (Cd);

ALTER TABLE dbo.MstDisasterStocks
  ADD CONSTRAINT MstDisasterStocks_PrefCd_FKC
  FOREIGN KEY (PrefCd) REFERENCES dbo.MstPrefs (Cd);

ALTER TABLE dbo.MstDisasterStocks
  ADD CONSTRAINT MstDisasterStocks_BranchCd_FKC
  FOREIGN KEY (BranchCd) REFERENCES dbo.MstBranches (Cd);

ALTER TABLE dbo.MstDisasterStocks
  ADD CONSTRAINT MstDisasterStocks_ReserveBranchCd_FKC
  FOREIGN KEY (ReserveBranchCd) REFERENCES dbo.MstBranches (Cd);
```
