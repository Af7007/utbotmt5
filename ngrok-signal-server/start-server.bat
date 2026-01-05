@echo off
REM TradingView Signal Server - Starter

echo ========================================
echo    TRADINGVIEW SIGNAL SERVER
echo ========================================
echo.

REM Verificar se Node.js está instalado
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar se ngrok está instalado
where ngrok >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] ngrok nao encontrado!
    echo Instale em: https://ngrok.com/download
    pause
    exit /b 1
)

REM Verificar se node_modules existe
if not exist "node_modules\" (
    echo [INFO] Instalando dependencias...
    call npm install
)

echo.
echo [1] Iniciando servidor Node.js na porta 3000...
start "Signal Server" cmd /k "npm start"

timeout /t 2 >nul

echo.
echo [2] Iniciando ngrok...
start "ngrok" cmd /k "ngrok http 3000"

echo.
echo ========================================
echo Servidores iniciados!
echo ========================================
echo.
echo 1. Copie a URL do ngrok (ex: https://abc123.ngrok-free.app)
echo 2. Configure no TradingView Webhook: URL/webhook
echo 3. Configure os clients com a URL do ngrok
echo.
pause
