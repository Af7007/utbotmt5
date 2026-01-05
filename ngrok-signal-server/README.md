# TradingView Signal Server com Ngrok

Distribua sinais do TradingView para múltiplos computadores em redes diferentes.

## Arquitetura

```
TradingView → Ngrok → Signal Client .exe (PC1, PC2, ...) → Arquivo Local → EA MT5
```

**URL configurada:** `https://livelier-nonpurposively-monty.ngrok-free.dev`

---

## COMPUTADOR PRINCIPAL (Server)

### 1. Iniciar o Servidor Node.js

```bash
cd C:\utbot\ngrok-signal-server
npm install
npm start
```

### 2. Iniciar o Ngrok

Em outro terminal:

```bash
ngrok http 8080 --domain=livelier-nonpurposively-monty.ngrok-free.dev
```

### 3. Configurar TradingView

Webhook URL:
```
https://livelier-nonpurposively-monty.ngrok-free.dev/webhook
```

---

## COMPUTADORES CLIENTES (OPÇÃO 1 - EXECUTÁVEL)

**Mais simples! Não precisa instalar Python.**

### 1. Criar o Executável

No PC principal (uma vez só):

```bash
cd C:\utbot\ngrok-signal-server
build.bat
```

Isso cria `dist\signal_client.exe`

### 2. Copiar para Outros PCs

Copie apenas o arquivo `dist\signal_client.exe` para cada PC.

### 3. Executar

Dê dois cliques no `signal_client.exe` - pronto!

### 4. Auto-iniciar com Windows

1. `Win+R` → `shell:startup` → Enter
2. Crie atalho para `signal_client.exe`

---

## COMPUTADORES CLIENTES (OPÇÃO 2 - PYTHON)

Se preferir usar Python diretamente:

### 1. Instalar Python 3

https://www.python.org/ (marque "Add Python to PATH")

### 2. Instalar requests

```bash
pip install requests
```

### 3. Executar

```bash
python signal_client.py
```

---

## Testar

No PC client, você deve ver:

```
==================================================
    TRADINGVIEW SIGNAL CLIENT
==================================================
Servidor: https://livelier-nonpurposively-monty.ngrok-free.dev/signal
Arquivo local: C:\Users\...\signal_XAUUSD.json
Intervalo: 5 segundos
==================================================
[14:30:15] ✓ Sinal: XAUUSD | buy
```

---

## Troubleshooting

### Erro "ngrok.yml: unknown version '3'"
Corrigido! Execute `ngrok` normalmente.

### Client não conecta
- Verifique se o servidor Node.js está rodando no PC principal
- Verifique se o ngrok está rodando
- Teste a URL no navegador: `https://livelier-nonpurposively-monty.ngrok-free.dev/signal`

### MT5 não lê o arquivo
- Caminho correto: `C:\Users\SEU_USUARIO\AppData\Roaming\MetaQuotes\Terminal\Common\Files\`
- O EA deve ler do diretório `FILE_COMMON`
