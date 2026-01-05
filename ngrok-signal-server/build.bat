@echo off
REM Build do executavel signal_client.exe

echo ============================================
echo  BUILD SIGNAL CLIENT EXECUTABLE
echo ============================================
echo.

REM Verificar se tem Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Python nao encontrado!
    echo Instale Python em: https://www.python.org/
    pause
    exit /b 1
)

REM Instalar PyInstaller se não tiver
echo [1/2] Instalando PyInstaller...
pip install pyinstaller -q

REM Build
echo [2/2] Criando executavel...
python build_exe.py

echo.
echo ============================================
echo  CONCLUIDO!
echo ============================================
echo.
echo Executavel salvo em: dist\signal_client.exe
echo.
echo Copie este arquivo para qualquer PC - nao precisa instalar Python!
echo.
pause
