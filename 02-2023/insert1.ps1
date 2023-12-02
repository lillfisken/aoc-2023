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
# $file = './02-2023\sample1.txt'
$file = './02-2023\input1.txt'
$table = 'y2023d2t1'
#############################################################################################################################
# delete all existing values
$delSql = "DELETE FROM public.$table;"

# Assignment
$inputdata = Get-Content $file
$cmd = New-Object System.Data.Odbc.OdbcCommand($delSql,$DBConn)
$cmd.ExecuteNonQuery() | Out-Null

foreach ($row in $inputdata) {
    $game = $row.Split(':')[0].Split(' ')[1]

    $setNo = 1
    foreach ($set in $row.Split(':')[1].Split(';')) {
        $red = 0
        $green = 0
        $blue = 0
        foreach ($color in $set.Split(',')) {
            if ($color.Trim().Split(' ')[1] -eq 'red') { $red = $color.Trim().Split(' ')[0] } 
            if ($color.Trim().Split(' ')[1] -eq 'green') { $green = $color.Trim().Split(' ')[0] }
            if ($color.Trim().Split(' ')[1] -eq 'blue') { $blue = $color.Trim().Split(' ')[0] }
        }
        $sql = "INSERT INTO public.y2023d2t1(
            game, round, red, green, blue)
            VALUES ($game, $setNo, $red, $green, $blue);"
        $cmd = New-Object System.Data.Odbc.OdbcCommand($sql,$DBConn)
        $cmd.ExecuteNonQuery() | Out-Null 
        $setNo += 1
    }
}

#################################################################################################################################
$DBConn.Close()
$timer.Stop() # Stop the timer
$elap = $timer.Elapsed
Write-Output "Elapsed time: $elap"