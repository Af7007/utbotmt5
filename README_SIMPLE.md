# 🤖 MT5 Webhook Trading - Versão Simples (SEM DLL)

## ✅ O QUE ESTÁ PRONTO

- ✅ **Flask server** (webhook_receiver.py) - Recebe sinais externos
- ✅ **EA simplificado** (HttpTraderSimple.mq5) - SEM necessidade de DLL
- ✅ **Comunicação por arquivo** (signal.json) - Mais simples e confiável
- ✅ **Gestão de risco** - Volume por % equity
- ✅ **TP/SL automáticos** - 100/50 pips

## 🚀 INSTALAÇÃO RÁPIDA (10 minutos)

### 1️⃣ Configurar MT5 (5 min)

#### Passo 1: Habilitar trading automático
```
MT5 > Tools > Options > Expert Advisors > ✅ Allow algorithmic trading
```

#### Passo 2: Copiar EA
```cmd
# Abrir pasta do MT5
MT5 > File > Open Data Folder > MQL5 > Experts

# Copiar HttpTraderSimple.mq5 para lá
```

#### Passo 3: Compilar EA
```
MT5 > Pressionar F4 (MetaEditor)
MetaEditor > File > Open > Experts\HttpTraderSimple.mq5
MetaEditor > Pressionar F7 (Compile)
Fechar MetaEditor
```

#### Passo 4: Anexar EA ao gráfico
```
MT5 > Abrir gráfico XAUUSD
Navigator (Ctrl+N) > Expert Advisors > Arrastar HttpTraderSimple para o gráfico

Configurar:
- Symbol: XAUUSD
- Risk Percent: 2.0
- TP: 100 pips
- SL: 50 pips
- ✅ Allow algorithmic trading

Clicar OK
```

#### Passo 5: Verificar EA rodando
```
Deve aparecer 😊 (sorriso verde) no gráfico

Aba Experts deve mostrar:
=== HttpTrader EA Initialized (Simple/No DLL) ===
Symbol: XAUUSD
Magic Number: 12345
Risk Percent: 2%
```

---

### 2️⃣ Testar Sistema (5 min)

#### Terminal 1: Iniciar Flask
```bash
cd C:\utbot
python webhook_receiver.py
```

**Saída esperada:**
```
 * Running on http://127.0.0.1:8080
```

#### Terminal 2: Enviar sinal LONG
```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer meu-token-123" \
  -d "{\"action\": \"long\"}"
```

**Resposta esperada:**
```json
{"status": "success", "message": "Signal buy written to file"}
```

#### Verificar execução no MT5 (1-2 segundos):
```
Aba Experts:
Signal received: {"action":"buy",...}
=== Processing Trade Signal ===
Action: buy
Volume calculated: Equity=10000 Risk=200 Volume=0.02
BUY SUCCESS: Vol=0.02 Entry=2650.50 SL=2645.50 TP=2750.50

Aba Trade:
Nova posição BUY aparece
```

#### Testar reversão (SHORT):
```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer meu-token-123" \
  -d "{\"action\": \"short\"}"
```

**Deve:**
- Fechar posição BUY anterior
- Abrir posição SELL

---

## 📊 Como Funciona

```
[TradingView/Webhook]
    ↓ HTTPS POST {"action": "long"}
[Flask :8080] webhook_receiver.py
    ↓ Traduz long→buy, escreve arquivo
[Arquivo signal.json]
    ↓ {"action": "buy", "timestamp": "..."}
[MT5 EA] HttpTraderSimple.mq5
    ↓ Lê arquivo a cada 1 segundo
    ↓ Fecha posições antigas
    ↓ Calcula volume (2% equity)
    ↓ Abre ordem BUY/SELL com TP/SL
[Mercado] ✅
```

**Latência total**: ~500ms-2s (webhook até execução)

---

## ⚙️ Configurações

### Arquivo `.env` (Flask)
```bash
WEBHOOK_API_KEY=meu-token-123
FLASK_PORT=8080
```

### Inputs do EA (MT5)
- **SymbolName**: XAUUSD
- **MagicNumber**: 12345
- **RiskPercent**: 2.0 (% do equity)
- **TakeProfitPips**: 100
- **StopLossPips**: 50
- **PollingIntervalSec**: 1
- **SignalFilePath**: signal.json

---

## 🐛 Problemas Comuns

### Flask trava ao instalar
**Solução**: Dependências já instaladas! Pule `pip install` e vá direto para testes.

### EA não aparece sorriso 😞
**Solução**:
```
Tools > Options > Expert Advisors > ✅ Allow algorithmic trading
Remover EA e anexar novamente
```

### Sinal não executa
**Solução**:
```bash
# 1. Verificar arquivo signal.json foi criado
dir signal.json

# 2. Ver conteúdo
type signal.json

# 3. Criar manualmente para testar
echo {"action":"buy"} > signal.json
# EA deve processar em 1-2 segundos
```

### Volume muito pequeno
**Solução**: Aumentar `RiskPercent` nos inputs do EA (2.0 → 5.0)

---

## 🌐 Produção (Webhook Externo)

### Expor Flask para internet

**Opção 1: ngrok (teste)**
```bash
# Baixar: https://ngrok.com/download
ngrok http 8080
# URL gerada: https://abc123.ngrok-free.app
```

**Opção 2: VPS + Domínio (produção)**
- Contratar VPS Windows
- Configurar domínio com SSL
- Nginx como reverse proxy

### Configurar TradingView Alert

```
Webhook URL: https://seu-dominio.com/sinais
Message: {"action": "{{strategy.order.action}}"}
Headers: Authorization: Bearer meu-token-123
```

---

## 📁 Arquivos Importantes

```
C:\utbot\
├── webhook_receiver.py      # Flask server (porta 8080)
├── HttpTraderSimple.mq5     # EA sem DLL ✅
├── signal.json              # Arquivo de comunicação
├── .env                     # Configurações
├── logs/webhook.log         # Logs do Flask
├── QUICKSTART.md            # Guia detalhado
└── README_SIMPLE.md         # Este arquivo
```

---

## ✅ Checklist Antes de Conta Real

- [ ] Testado em demo por 1 semana
- [ ] Volume calculado OK (2% equity)
- [ ] TP/SL corretos (100/50 pips)
- [ ] Reversão funciona (long→short→long)
- [ ] Logs sem erros
- [ ] Monitoramento 24h OK

---

## 🎯 Status

**Versão**: 2.0 - Simplificada (SEM DLL)
**Status**: ✅ Pronto para testes em demo
**Próximo passo**: Seguir QUICKSTART.md para configuração completa

---

## 📞 Suporte

**Problemas?**
1. Ver seção "Problemas Comuns" acima
2. Verificar logs: `logs/webhook.log` e MT5 Experts tab
3. Ler `QUICKSTART.md` para troubleshooting detalhado

---

**🚀 Sistema 100% funcional sem necessidade de compilar DLL!**
