# Deploy na Vercel - TradingView Signal Server

## Vantagens

- ✅ Não precisa PC ligado 24/7
- ✅ 100% grátis
- ✅ URL fixa (não muda)
- ✅ Deploy com git push
- ⚠️ Delay de 50-200ms (aceitável para trading)

---

## Passo 1: Instalar Vercel CLI

```bash
npm install -g vercel
```

---

## Passo 2: Login

```bash
vercel login
```

---

## Passo 3: Deploy

No diretório `ngrok-signal-server`:

```bash
# Primeiro deploy (perguntará sobre o projeto)
vercel

# Deploy de produção
vercel --prod
```

---

## Passo 4: Configurar TradingView

Após o deploy, a Vercel vai gerar uma URL, exemplo:
```
https://tradingview-signal-server.vercel.app
```

No TradingView, configure o webhook:

```
https://tradingview-signal-server.vercel.app/webhook
```

---

## Passo 5: Atualizar Client

### Executável (.exe)

Rebuild com nova URL:

```bash
# Editar signal_client.py
NGROK_URL = "https://tradingview-signal-server.vercel.app"

# Rebuild
build.bat
```

### Script Python

Editar apenas a URL:
```python
NGROK_URL = "https://tradingview-signal-server.vercel.app"
```

---

## Comandos Úteis

```bash
# Deploy de desenvolvimento
vercel

# Deploy de produção
vercel --prod

# Ver logs
vercel logs

# Remover projeto
vercel remove
```

---

## URLs Após Deploy

| Função | URL |
|--------|-----|
| Webhook TradingView | `https://seu-projeto.vercel.app/webhook` |
| Client consulta | `https://seu-projeto.vercel.app/signal` |

---

## Troubleshooting

### 500 Error
- Verifique os logs: `vercel logs`

### CORS Error
- O módulo `micro-cors` deve estar instalado

### Sinal não chega
- Verifique a URL do webhook no TradingView
- Teste com curl: `curl -X POST https://seu-projeto.vercel.app/webhook -d '{"action":"buy"}'`

---

## Comparação: Vercel vs Local

| Característica | Vercel | ngrok Local |
|----------------|--------|-------------|
| Custo | Grátis | Grátis (paid: $8/mês) |
| PC ligado | Não | Sim |
| URL | Fixa | Muda (free) |
| Delay | 50-200ms | 10-50ms |
| Setup | 5 min | 2 min |
