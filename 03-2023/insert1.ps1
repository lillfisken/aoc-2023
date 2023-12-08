# DB connection
$pg_env = Get-Content .\env.json -Raw | ConvertFrom-Json
$pg_ip = $pg_env.pg_ip
$pg_port = $pg_env.pg_port
$pg_user = $pg_env.pg_user
$pg_pwd = $pg_env.pg_pwd
$pg_db = $pg_env.pg_db

Write-Output "Start processing inputfile"
$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$pg_ip;Port=$pg_port;Database=$pg_db;Uid=$pg_user;Pwd=$pg_pwd;Options='autocommit=off';"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();
#############################################################################################################################
# $file = './03-2023\sample1.txt'
$file = './03-2023\input1.txt'
$table = 'y2023d3t1'
#############################################################################################################################
# delete all existing values
$delSql = "DELETE FROM public.$table;"

# Assignment
$inputdata = Get-Content $file
$cmd = New-Object System.Data.Odbc.OdbcCommand($delSql,$DBConn)
$cmd.ExecuteNonQuery() | Out-Null

foreach ($row in $inputdata) {
    $sql = "INSERT INTO public.$table (input_raw) VALUES ('$row');"
    $cmd = New-Object System.Data.Odbc.OdbcCommand($sql,$DBConn)
    # $count = $cmd.ExecuteNonQuery()
    $cmd.ExecuteNonQuery() | Out-Null
}

#################################################################################################################################
$DBConn.Close()
$timer.Stop() # Stop the timer
$elap = $timer.Elapsed
Write-Output "Elapsed time: $elap"