#wait for the SQL Server to come up
#固定sleepでは2022イメージの起動時間を確実にカバーできないため、接続確立をポーリングする
SQLCMD=/opt/mssql-tools18/bin/sqlcmd
for i in $(seq 1 60); do
  $SQLCMD -S localhost -U sa -P msSqlserver123 -d master -C -Q "SELECT 1" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 2s
done

echo "running set up script"
#run the setup script to create the DB and the schema in the DB
#SQL Server 2022イメージでは sqlcmd が /opt/mssql-tools18/bin へ移動し、既定で暗号化接続になったため -C（サーバー証明書を検証せず信頼）を追加している
$SQLCMD -S localhost -U sa -P msSqlserver123 -d master -C -i db-init.sql