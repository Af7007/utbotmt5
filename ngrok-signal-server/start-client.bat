@echo off
REM TradingView Signal Client - Starter

echo ========================================
echo    TRADINGVIEW SIGNAL CLIENT
echo ========================================
echo.

REM Verificar se Python está instalado
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Python nao encontrado!
    echo Instale em: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Verificar se requests está instalado
python -c "import requests" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Instalando biblioteca requests...
    pip install requests
)

echo [INFO] Iniciando client...
echo.
echo Pressione Ctrl+C para encerrar.
echo.

python signal_client.py

pause
