@echo off
REM Adiciona o signal_client.py ao startup do Windows

set SCRIPT_DIR=%~dp0
set PYTHON_EXE=pythonw.exe

echo ========================================
echo    INSTALL SIGNAL CLIENT - STARTUP
echo ========================================
echo.

REM Localizar python.exe
where pythonw.exe >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] pythonw.exe nao encontrado!
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('where pythonw.exe') do set PYTHON_PATH=%%i

echo Python encontrado: %PYTHON_PATH%
echo.

REM Criar atalho no startup
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set SHORTCUT_PATH=%STARTUP_FOLDER%\Signal Client.lnk
set TARGET_PATH=%SCRIPT_DIR%signal_client.py
set WORKING_DIR=%SCRIPT_DIR%

powershell -Command ^
"$ws = New-Object -ComObject WScript.Shell; ^
$s = $ws.CreateShortcut('%SHORTCUT_PATH%'); ^
$s.TargetPath = '%PYTHON_PATH%'; ^
$s.Arguments = '"%TARGET_PATH%"'; ^
$s.WorkingDirectory = '%WORKING_DIR%'; ^
$s.Save();"

if exist "%SHORTCUT_PATH%" (
    echo [SUCESSO] Atalho criado no startup!
    echo Local: %SHORTCUT_PATH%
    echo.
    echo O client sera iniciado automaticamente no proximo boot.
    echo.
    echo Para REMOVER, delete este arquivo: %SHORTCUT_PATH%
) else (
    echo [ERRO] Nao foi possivel criar o atalho.
)

echo.
pause
