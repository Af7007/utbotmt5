# 🚀 Quick Start - Sistema SEM DLL

## ✅ Vantagens desta versão

- ❌ **NÃO precisa de Visual Studio**
- ❌ **NÃO precisa compilar DLL**
- ✅ **Comunicação por arquivo** (mais simples)
- ✅ **Funciona imediatamente**
- ✅ **Mesma funcionalidade completa**

---

## 📁 Arquitetura Simplificada

```
[Webhook Externo]
    ↓ POST {"action": "long"}
[Flask Server :8080] webhook_receiver.py
    ↓ Escreve signal.json
[Arquivo signal.json]
    ↓ Lido a cada 1 segundo
[HttpTraderSimple.mq5 EA]
    ↓ Fecha posições antigas
    ↓ Calcula volume (2% equity)
    ↓ Abre ordem com TP/SL
[MetaTrader 5] ✅
```

---

## 🔧 Instalação (5 minutos)

### PASSO 1: Verificar Python (JÁ FEITO ✅)

```bash
python --version
# Python 3.12.0 ✅

pip list | grep Flask
# Flask 3.0.0 ✅
```

### PASSO 2: Configurar MT5

#### 2.1 - Habilitar trading automático

1. Abrir MT5
2. Menu: `Tools` > `Options` > `Expert Advisors`
3. ✅ **Allow algorithmic trading**
4. Clicar `OK`

#### 2.2 - Copiar EA para MT5

**Opção A - Via MT5:**
1. No MT5: `File` > `Open Data Folder`
2. Navegar para: `MQL5\Experts\`
3. Copiar `HttpTraderSimple.mq5` para essa pasta

**Opção B - Via comando:**
```cmd
copy HttpTraderSimple.mq5 "%APPDATA%\MetaQuotes\Terminal\*\MQL5\Experts\"
```

#### 2.3 - Compilar EA

1. No MT5, pressionar `F4` (abre MetaEditor)
2. No MetaEditor: `File` > `Open` > `Experts\HttpTraderSimple.mq5`
3. Pressionar `F7` (Compile)
4. Verificar: **0 errors, 0 warnings**
5. Fechar MetaEditor

#### 2.4 - Anexar EA ao gráfico

1. No MT5, abrir gráfico **XAUUSD**
2. No painel `Navigator` (Ctrl+N), expandir `Expert Advisors`
3. Arrastar `HttpTraderSimple` para o gráfico XAUUSD
4. Na janela de configuração:
   - **Symbol:** XAUUSD
   - **Magic Number:** 12345
   - **Risk Percent:** 2.0
   - **Take Profit Pips:** 100
   - **Stop Loss Pips:** 50
   - **Polling Interval Sec:** 1
   - **Signal File Path:** signal.json
5. ✅ Marcar: **Allow algorithmic trading**
6. Clicar `OK`

#### 2.5 - Verificar EA rodando

No gráfico XAUUSD, deve aparecer:
- 😊 **Sorriso verde** no canto superior direito
- Aba `Experts` (Ctrl+T) deve mostrar:
  ```
  Timer set to poll every 1 second(s)
  === HttpTrader EA Initialized (Simple/No DLL) ===
  Symbol: XAUUSD
  Magic Number: 12345
  Risk Percent: 2%
  Take Profit: 100 pips
  Stop Loss: 50 pips
  Signal File: signal.json
  ```

---

## 🧪 PASSO 3: Testar Sistema Completo

### 3.1 - Iniciar Flask Server

**Terminal 1:**
```bash
cd C:\utbot
python webhook_receiver.py
```

**Saída esperada:**
```
 * Running on http://127.0.0.1:8080
 * Running on http://192.168.1.3:8080
```

### 3.2 - Enviar sinal LONG (teste)

**Terminal 2:**
```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer seu-token-super-secreto-aqui" \
  -d "{\"action\": \"long\"}"
```

**Resposta esperada:**
```json
{
  "status": "success",
  "message": "Signal buy written to file",
  "data": {
    "action": "buy",
    "timestamp": "2024-01-15T10:30:00.123456"
  }
}
```

### 3.3 - Verificar execução no MT5

**Aba `Experts` do MT5 (em 1-2 segundos):**
```
Signal received: {"action":"buy","timestamp":"..."}
=== Processing Trade Signal ===
Action: buy
Closing all positions for XAUUSD
Volume calculated: Equity=10000 Risk=200 Volume=0.02
BUY SUCCESS: Vol=0.02 Entry=2650.50 SL=2645.50 TP=2750.50
=== Trade Signal Processed ===
```

**Aba `Trade` do MT5:**
- Deve aparecer nova posição BUY
- Volume: 0.02 lotes (ou calculado conforme seu equity)
- SL/TP aplicados

**Arquivo `signal.json` criado:**
```bash
cat signal.json
# {"action": "buy", "timestamp": "2024-01-15T10:30:00.123456"}
```

**Logs Flask (`logs/webhook.log`):**
```
2024-01-15 10:30:00 - INFO - Signal received: long -> buy
2024-01-15 10:30:00 - INFO - Signal written to file successfully
```

### 3.4 - Enviar sinal SHORT (reverter)

```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer seu-token-super-secreto-aqui" \
  -d "{\"action\": \"short\"}"
```

**Verificar no MT5:**
- Deve FECHAR posição BUY anterior
- Deve ABRIR nova posição SELL

---

## 📊 Verificar Status

### Health Check

```bash
curl http://localhost:8080/health
# {"status":"ok","service":"webhook_receiver"}
```

### Status Detalhado

```bash
curl http://localhost:8080/status
```

**Resposta:**
```json
{
  "status": "running",
  "signal_file": "signal.json",
  "signal_exists": true,
  "last_signal": {
    "action": "buy",
    "timestamp": "2024-01-15T10:30:00.123456"
  },
  "timestamp": "2024-01-15T10:31:00.000000"
}
```

---

## 🐛 Troubleshooting

### EA não inicia (cara triste 😞)

**Solução:**
1. Verificar: `Tools` > `Options` > `Expert Advisors` > ✅ Allow algorithmic trading
2. Remover EA do gráfico e anexar novamente
3. Verificar aba `Experts` para mensagens de erro

### "File not found" no EA

**Solução:**
```mql5
// Verificar se arquivo está acessível
// No input SignalFilePath, usar caminho completo:
SignalFilePath = "C:\\utbot\\signal.json"
```

Ou copiar signal.json para pasta comum do MT5:
```cmd
# Depois que Flask criar signal.json:
copy signal.json "%APPDATA%\MetaQuotes\Terminal\Common\Files\"
```

### Flask não recebe requisições

**Solução:**
```bash
# Verificar porta 8080 está livre
netstat -ano | findstr :8080

# Se ocupada, usar outra porta em .env:
FLASK_PORT=8081
```

### Volume muito pequeno (< 0.01)

**Solução:**
```mql5
// Aumentar RiskPercent nos inputs do EA
// Padrão: 2.0 -> Tentar: 5.0 ou 10.0

// Ou verificar equity mínimo
// Recomendado: $1000+ para 2% risk
```

### Sinal não executa no MT5

**Solução:**
1. Verificar arquivo `signal.json` foi criado:
   ```bash
   dir signal.json
   ```

2. Verificar conteúdo:
   ```bash
   type signal.json
   ```

3. Verificar EA está fazendo polling:
   - Logs do EA devem mostrar leitura periódica

4. Testar escrita manual:
   ```bash
   echo {"action":"buy"} > signal.json
   ```
   EA deve processar em até 1 segundo

---

## 🌐 Expor para Internet (Produção)

### Opção A: ngrok (teste/desenvolvimento)

```bash
# Instalar ngrok: https://ngrok.com/download
ngrok http 8080

# URL gerada: https://abc123.ngrok-free.app
# Usar essa URL no webhook externo
```

### Opção B: VPS + Domínio (produção)

1. Contratar VPS Windows
2. Instalar MT5, Python, Flask
3. Configurar domínio com SSL (Let's Encrypt)
4. Usar Nginx como reverse proxy
5. Configurar Flask como serviço Windows

---

## 📝 Configurar Webhook Externo (TradingView)

1. TradingView > Criar Alert
2. **Webhook URL**: `https://seu-dominio.com/sinais`
3. **Message**:
   ```json
   {"action": "{{strategy.order.action}}"}
   ```
4. **Custom Headers**:
   ```
   Authorization: Bearer seu-token-super-secreto-aqui
   ```

**Nota:** TradingView envia `"action": "buy"` ou `"action": "sell"` - por isso usamos `long/short` como aliases no Flask.

---

## ✅ Checklist de Validação

Antes de usar em conta real:

- [ ] ✅ Flask rodando sem erros
- [ ] ✅ EA anexado e mostrando 😊
- [ ] ✅ Teste LONG executou ordem BUY
- [ ] ✅ Teste SHORT fechou BUY e abriu SELL
- [ ] ✅ Volume calculado corretamente (2% equity)
- [ ] ✅ TP/SL aplicados (100/50 pips)
- [ ] ✅ Logs sem erros (Flask + MT5)
- [ ] ✅ Arquivo signal.json sendo criado
- [ ] ✅ Testado por 24h em demo
- [ ] ✅ Monitoramento configurado

---

## 🎯 Resumo

**Diferenças da versão com DLL:**
- ❌ NÃO precisa compilar DLL C++
- ❌ NÃO precisa Visual Studio
- ✅ Usa arquivo `signal.json` para comunicação
- ✅ Mesma funcionalidade completa
- ✅ Latência similar (~500ms-2s)

**Arquivos importantes:**
- `webhook_receiver.py` - Flask server
- `HttpTraderSimple.mq5` - EA sem DLL
- `signal.json` - Arquivo de comunicação
- `.env` - Configurações
- `logs/webhook.log` - Logs do Flask

**Próximo passo:** Testar por 1 semana em conta demo antes de usar em real! 🚀

---

**Status**: ✅ Sistema completo e funcional SEM DLL
