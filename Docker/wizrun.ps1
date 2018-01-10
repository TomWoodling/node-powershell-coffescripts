Set-Location -Path C:\gopath\go-neb

$env:BIND_ADDRESS=":4050"
$env:DATABASE_TYPE="sqlite3"
$env:DATABASE_URL="go-neb.db?_busy_timeout=5000"
$env:BASE_URL="https://public.facing.endpoint bin/go-neb"
$env:CONFIG_FILE="c:\gopath\go-neb\go_neb_conf.yaml"

& .\bin\go-neb.exe