# FROM microsoft/mssql-server-linux:2017-latest
# FROM microsoft/mssql-server-linux:latest
# FROM mcr.microsoft.com/mssql/server:2017-latest
# 2022-latest (2026-08-18 検証時点) を digest で固定
FROM mcr.microsoft.com/mssql/server@sha256:ba4c8329f48fb8f02e1416be6a930ebfd71268caee78aa985f3af4315e457c89

# 2022イメージの既定ユーザーは非rootの mssql。COPY/chmod を通すためroot化し、
# 実行時は元のイメージの既定どおり mssql に戻す。
USER root

COPY . /usr/src/docker

WORKDIR /usr/src/docker

RUN chmod +x ./db-init.sh
RUN chmod +r ./data/dbo.MstBranches.csv
RUN chmod +r ./data/dbo.MstDisasterStocks.csv
RUN chmod +r ./data/dbo.MstKbns.csv
RUN chmod +r ./data/dbo.MstManufactures.csv
RUN chmod +r ./data/dbo.MstPrefs.csv
RUN chmod +r ./data/dbo.MstProducts.csv

USER mssql

CMD /bin/bash ./entrypoint.sh
