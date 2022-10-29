
set "PATH=%PATH%;.\python\python-3.8.10-embed-amd64\"
echo %PATH%

python server.py > records.log 2>&1

pause
