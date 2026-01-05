@echo off
REM Deploy para Vercel - TradingView Signal Server

echo ============================================
echo  VERCEL DEPLOY
echo ============================================
echo.

REM Verificar login
echo Verificando login...
vercel whoami >nul 2>&1
if errorlevel 1 (
    echo.
    echo Voce precisa fazer login primeiro!
    echo.
    echo Abrindo navegador para autenticacao...
    vercel login
    echo.
)

REM Verificar Vercel CLI
vercel --version >nul 2>&1
if errorlevel 1 (
    echo [1/3] Instalando Vercel CLI...
    npm install -g vercel
) else (
    echo [1/3] Vercel CLI OK
)

echo.
echo [2/3] Instalando dependencias...
call npm install

echo.
echo [3/3] Fazendo deploy para Vercel...
echo.
echo Na primeira vez:
echo   - Selecione seu account (GitHub/GitLab/Email)
echo   - "Set up and develop": N
echo   - "Which scope": sua conta
echo   - "Link to existing project": N
echo   - "Project name": tradingview-signal-server (ou outro)
echo   - "In which directory is your code": . (ponto)
echo   - "Want to override settings": N
echo.

vercel --prod

echo.
echo ============================================
echo  DEPLOY CONCLUIDO!
echo ============================================
echo.
echo URL do seu projeto: https://tradingview-signal-server-xxxxx.vercel.app
echo.
echo Configure TradingView:
echo   Webhook: SUA_URL/webhook
echo.
echo Configure Clients:
echo   NGROK_URL = "SUA_URL"
echo.
pause
