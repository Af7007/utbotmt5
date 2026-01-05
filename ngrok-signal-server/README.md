# TradingView Signal Server com Ngrok

Distribua sinais do TradingView para múltiplos computadores em redes diferentes.

## Arquitetura

```
TradingView → Ngrok → Script Client (PC1, PC2, ...) → Arquivo Local → EA MT5
```

---

## COMPUTADOR PRINCIPAL (Server)

### 1. Instalar Node.js

Baixe e instale: https://nodejs.org/

### 2. Instalar ngrok

Baixe e instale: https://ngrok.com/download

### 3. Preparar o Servidor

```bash
cd C:\utbot\ngrok-signal-server
npm install
npm start
```

### 4. Iniciar o Ngrok

Em outro terminal:

```bash
ngrok http 3000
```

**Copie a URL gerada**, exemplo: `https://abc123.ngrok-free.app`

### 5. Configurar TradingView

No TradingView, adicione um webhook com a URL:

```
https://abc123.ngrok-free.app/webhook
```

---

## COMPUTADORES CLIENTES

### 1. Instalar Python 3

Baixe e instale: https://www.python.org/downloads/

Marque "Add Python to PATH" durante a instalação.

### 2. Instalar requests

```bash
pip install requests
```

### 3. Editar signal_client.py

Altere a linha `NGROK_URL` para sua URL:

```python
NGROK_URL = "https://abc123.ngrok-free.app"  # sua URL
```

### 4. Testar

```bash
python signal_client.py
```

Você deve ver:
```
==================================================
    TRADINGVIEW SIGNAL CLIENT
==================================================
Servidor: https://abc123.ngrok-free.app/signal
Arquivo local: C:\Users\...\signal_XAUUSD.json
Intervalo: 5 segundos
==================================================
[14:30:15] ✓ Sinal: XAUUSD | buy
```

### 5. Auto-iniciar com Windows

Para o script iniciar automaticamente com o Windows:

1. Pressione `Win+R`
2. Digite `shell:startup` e Enter
3. Crie um atalho com:
   - Alvo: `pythonw.exe "C:\utbot\ngrok-signal-server\signal_client.py"`
   - Iniciar em: `C:\utbot\ngrok-signal-server\`

---

## EA MT5

NÃO precisa ser modificado! O EA continua lendo o arquivo local normalmente.

---

## Testar Webhook

Use curl para testar:

```bash
curl -X POST https://abc123.ngrok-free.app/webhook \
  -H "Content-Type: application/json" \
  -d '{"action":"buy","symbol":"XAUUSD"}'
```

Ou use o site https://webhook.site para testar.

---

## Troubleshooting

### Erro "Cannot open signal file"
- Verifique se o caminho está correto em `get_mt5_common_path()`
- Cada instalação do MT5 pode ter caminhos diferentes

### Ngrok URL expirou
- URLs gratuitas do ngrok mudam quando reiniciado
- Atualize `NGROK_URL` em todos os clients após reiniciar o ngrok

### Script não inicia no startup
- Use `pythonw.exe` em vez de `python` (não abre janela)
- Verifique o caminho completo do python: `where python`
