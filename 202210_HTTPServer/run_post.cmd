
set "PATH=%PATH%;.\python\python-3.8.10-embed-amd64\"
echo %PATH%

set "DATASOURCE=test\"

python client.py %DATASOURCE% > records.log 2>&1

pause
