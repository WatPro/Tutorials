
set "PATH=%PATH%;.\python\python-3.8.10-embed-amd64\"
echo %PATH%

set "DATASOURCE=test\"
set "DONEPATH=done\"

python client.py %DATASOURCE% %DONEPATH% > clientrecords.log 2>&1

pause
