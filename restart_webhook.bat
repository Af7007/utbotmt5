@echo off
echo Parando servidor Flask existente...

taskkill /F /IM python.exe /T 2>nul
timeout /t 2 /nobreak >nul

echo Iniciando novo servidor Flask...
start "Webhook Server" cmd /k "python C:\utbot\webhook_receiver.py"

echo Servidor reiniciado!
echo Acesse http://localhost:8080/examples para ver exemplos
pause