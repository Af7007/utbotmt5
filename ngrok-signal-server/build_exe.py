"""
Build script para criar executável standalone do signal_client.py

Uso:
    1. Instale PyInstaller: pip install pyinstaller
    2. Execute: python build_exe.py
    3. O executável estará em dist/signal_client.exe
"""

import PyInstaller.__main__
import os
import shutil

# Limpar build anterior
if os.path.exists('build'):
    shutil.rmtree('build')
if os.path.exists('dist'):
    shutil.rmtree('dist')

# Build do executável
PyInstaller.__main__.run([
    'signal_client.py',
    '--onefile',           # Single file executable
    '--noconsole',         # Hide console window (use --console para debug)
    '--name=signal_client', # Nome do executável
    '--icon=NONE',         # Ícone (adicione um .ico se quiser)
    '--clean',             # Limpar cache
])

print("\n" + "="*50)
print("EXECUTÁVEL CRIADO: dist/signal_client.exe")
print("="*50)
print("\nPara usar em outro PC:")
print("1. Copie dist/signal_client.exe para o PC")
print("2. Execute o .exe (não precisa instalar Python)")
print("\nPara auto-iniciar:")
print("Win+R -> shell:startup -> Crie atalho para o .exe")
