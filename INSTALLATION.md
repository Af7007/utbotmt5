# Guia de Instalação e Teste - Sistema de Automação MT5

## 📋 Pré-requisitos

### Software Necessário
- ✅ MetaTrader 5 instalado
- ✅ Python 3.8+ instalado
- ✅ Visual Studio 2019+ ou MinGW-w64 (para compilar DLL)
- ✅ Conta demo MT5 ativa

### Verificar Instalações
```bash
# Verificar Python
python --version

# Verificar pip
pip --version
```

---

## 🔧 FASE 1: Instalar Dependências Python

```bash
cd C:\utbot
pip install -r requirements.txt
```

**Saída esperada:**
```
Successfully installed Flask-3.0.0 requests-2.31.0 python-dotenv-1.0.0
```

---

## 🏗️ FASE 2: Compilar DLL (HttpServer.dll)

### Opção A: Visual Studio (Recomendado)

1. Abrir "Developer Command Prompt for VS 2019" ou superior

2. Navegar para pasta do projeto:
```cmd
cd C:\utbot
```

3. Compilar DLL:
```cmd
cl.exe /LD /EHsc /Fe:HttpServer.dll HttpServer.cpp ws2_32.lib /std:c++17
```

**Saída esperada:**
```
HttpServer.cpp
   Creating library HttpServer.lib and object HttpServer.exp
```

### Opção B: MinGW-w64

```bash
g++ -shared -o HttpServer.dll HttpServer.cpp -lws2_32 -std=c++17
```

### Verificar DLL criada

```bash
dir HttpServer.dll
```

Deve aparecer o arquivo `HttpServer.dll` na pasta.

---

## 📁 FASE 3: Copiar DLL para MT5

### Encontrar pasta do MT5

1. Abrir MT5
2. Menu: `File` > `Open Data Folder`
3. Navegar para: `MQL5\Libraries\`

**Caminho típico:**
```
C:\Users\[SeuUsuario]\AppData\Roaming\MetaQuotes\Terminal\[HashAleatorio]\MQL5\Libraries\
```

### Copiar DLL

```cmd
copy HttpServer.dll "C:\Users\[SeuUsuario]\AppData\Roaming\MetaQuotes\Terminal\[HashAleatorio]\MQL5\Libraries\HttpServer.dll"
```

**⚠️ IMPORTANTE:** Substitua `[SeuUsuario]` e `[HashAleatorio]` pelos valores corretos!

---

## ⚙️ FASE 4: Configurar MetaTrader 5

### 1. Habilitar DLLs

1. MT5 > `Tools` > `Options`
2. Aba `Expert Advisors`
3. ✅ Marcar: **Allow algorithmic trading**
4. ✅ Marcar: **Allow DLL imports**
5. ✅ Marcar: **Allow imports of external experts**
6. Clicar `OK`

### 2. Adicionar DLL à Whitelist

1. `Tools` > `Options` > `Expert Advisors`
2. Botão: **"Allowed DLL imports"**
3. Adicionar: `HttpServer.dll`
4. Clicar `OK`

---

## 📝 FASE 5: Compilar Expert Advisor (MQL5)

### 1. Copiar EA para pasta do MT5

```cmd
copy HttpTrader.mq5 "C:\Users\[SeuUsuario]\AppData\Roaming\MetaQuotes\Terminal\[HashAleatorio]\MQL5\Experts\HttpTrader.mq5"
```

### 2. Abrir MetaEditor

1. No MT5, pressionar `F4` (abre MetaEditor)
2. Ou: `Tools` > `MetaQuotes Language Editor`

### 3. Compilar EA

1. No MetaEditor: `File` > `Open` > Navegar até `Experts\HttpTrader.mq5`
2. Pressionar `F7` (Compile)
3. Verificar aba `Errors` - deve estar vazio (0 errors, 0 warnings é ideal)

**Saída esperada:**
```
'HttpTrader.mq5' HttpTrader.mq5 1 1
0 error(s), 0 warning(s), compiled successfully
```

### 4. Anexar EA ao Gráfico

1. No MT5, abrir gráfico **XAUUSD** (Gold Spot)
2. No `Navigator` (Ctrl+N), expandir `Expert Advisors`
3. Arrastar `HttpTrader` para o gráfico XAUUSD
4. Na janela de configuração:
   - **Symbol:** XAUUSD
   - **Magic Number:** 12345
   - **Risk Percent:** 2.0
   - **Take Profit Pips:** 100
   - **Stop Loss Pips:** 50
   - **Polling Interval Sec:** 1
5. ✅ Marcar: **Allow algorithmic trading**
6. ✅ Marcar: **Allow DLL imports**
7. Clicar `OK`

### 5. Verificar EA está rodando

No gráfico XAUUSD, deve aparecer:
- 😊 Sorriso no canto superior direito (EA ativo)
- Aba `Experts` deve mostrar:
  ```
  HTTP Server started on port 5000
  Timer set to poll every 1 second(s)
  === HttpTrader EA Initialized ===
  Symbol: XAUUSD
  Magic Number: 12345
  Risk Percent: 2%
  Take Profit: 100 pips
  Stop Loss: 50 pips
  ```

---

## 🌐 FASE 6: Configurar e Testar Flask Server

### 1. Configurar variáveis de ambiente

Editar arquivo `.env`:
```bash
WEBHOOK_API_KEY=meu-token-secreto-123
DLL_SERVER_URL=http://localhost:5000
FLASK_PORT=8080
```

**⚠️ Trocar `meu-token-secreto-123` por um token forte!**

### 2. Iniciar Flask Server

**Terminal 1:**
```bash
cd C:\utbot
python webhook_receiver.py
```

**Saída esperada:**
```
 * Running on http://0.0.0.0:8080
Press CTRL+C to quit
```

### 3. Testar Health Check

**Terminal 2:**
```bash
curl http://localhost:8080/health
```

**Resposta esperada:**
```json
{"status":"ok","service":"webhook_receiver"}
```

---

## ✅ FASE 7: Testar Integração Completa

### Teste 1: Sinal LONG (BUY)

```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer meu-token-secreto-123" \
  -d "{\"action\": \"long\"}"
```

**Resposta esperada:**
```json
{
  "status": "success",
  "message": "Signal buy forwarded to MT5",
  "data": {
    "action": "buy",
    "timestamp": "2024-01-15T10:30:00.123456"
  }
}
```

**Verificar no MT5:**
1. Aba `Experts` deve mostrar:
   ```
   Signal received: {"action":"buy","timestamp":"..."}
   === Processing Trade Signal ===
   Action: buy
   Closing all positions for XAUUSD
   Volume calculated: Equity=10000 Risk=200 Volume=0.02
   BUY SUCCESS: Vol=0.02 Entry=2650.50 SL=2645.50 TP=2750.50
   === Trade Signal Processed ===
   ```

2. Aba `Trade` deve mostrar nova posição BUY aberta

3. Arquivo `logs/webhook.log` deve conter:
   ```
   2024-01-15 10:30:00 - INFO - Signal received: long -> buy
   2024-01-15 10:30:00 - INFO - Signal forwarded to DLL successfully
   ```

### Teste 2: Sinal SHORT (SELL)

```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer meu-token-secreto-123" \
  -d "{\"action\": \"short\"}"
```

**Verificar no MT5:**
- Deve FECHAR a posição BUY anterior
- Deve ABRIR nova posição SELL

**Logs esperados:**
```
Signal received: {"action":"sell",...}
Closing all positions for XAUUSD
Closed position: 123456
Volume calculated: ...
SELL SUCCESS: Vol=0.02 Entry=2650.00 SL=2655.00 TP=2550.00
```

### Teste 3: Testar sem autenticação (deve falhar)

```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -d "{\"action\": \"long\"}"
```

**Resposta esperada (erro 401):**
```json
{"error": "Unauthorized"}
```

### Teste 4: Testar ação inválida (deve falhar)

```bash
curl -X POST http://localhost:8080/sinais \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer meu-token-secreto-123" \
  -d "{\"action\": \"invalid\"}"
```

**Resposta esperada (erro 400):**
```json
{"error": "Invalid action. Use 'long' or 'short'"}
```

---

## 🐛 Troubleshooting

### Problema: "DLL not found" no MT5

**Solução:**
```bash
# Verificar se DLL está no lugar certo
dir "C:\Users\[Usuario]\AppData\Roaming\MetaQuotes\Terminal\*\MQL5\Libraries\HttpServer.dll"

# Se não estiver, copiar novamente
copy HttpServer.dll "C:\Users\[Usuario]\AppData\Roaming\MetaQuotes\Terminal\[Hash]\MQL5\Libraries\"
```

### Problema: "DLL imports not allowed"

**Solução:**
1. MT5 > Tools > Options > Expert Advisors
2. ✅ Marcar **"Allow DLL imports"**
3. Reiniciar MT5
4. Anexar EA novamente

### Problema: Flask não inicia (porta ocupada)

**Solução:**
```bash
# Windows: Verificar quem está usando porta 8080
netstat -ano | findstr :8080

# Matar processo (substitua PID)
taskkill /PID [numero] /F

# Ou usar outra porta no .env
FLASK_PORT=8081
```

### Problema: "No signal received" no MT5

**Solução:**
```bash
# 1. Verificar DLL iniciada
# Deve aparecer no log: "HTTP Server started on port 5000"

# 2. Testar DLL diretamente
curl -X POST http://localhost:5000 \
  -H "Content-Type: application/json" \
  -d "{\"action\":\"buy\"}"

# 3. Verificar polling está funcionando
# Deve aparecer prints periódicos se houver sinal
```

### Problema: Volume muito pequeno ou erro "TRADE_RETCODE_INVALID_VOLUME"

**Solução:**
```mql5
// Aumentar RiskPercent nos inputs do EA
// Padrão: 2.0 -> Tentar: 5.0 ou 10.0

// Ou verificar equity mínimo
// Equity mínimo recomendado: $1000 para 2% risk
```

### Problema: "SL/TP too close" no MT5

**Solução:**
```mql5
// Aumentar valores de TP/SL nos inputs
// Padrão: TP=100, SL=50
// Tentar: TP=200, SL=100

// Verificar SYMBOL_TRADE_STOPS_LEVEL do broker
Print("Min Stop Level: ", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL));
```

---

## 📊 Monitoramento

### Logs para verificar

1. **Flask logs:** `C:\utbot\logs\webhook.log`
2. **MT5 Experts tab:** Ver em tempo real
3. **MT5 Journal tab:** Ver operações do sistema

### Comandos úteis de monitoramento

```bash
# Ver últimas 10 linhas do log Flask
tail -n 10 logs/webhook.log

# Ver log em tempo real (Windows)
Get-Content logs\webhook.log -Wait -Tail 10

# Ver status do Flask
curl http://localhost:8080/status
```

---

## 🚀 Próximos Passos

### Para Produção (VPS)

1. **Obter VPS Windows:**
   - Recomendado: Vultr, DigitalOcean, AWS
   - Mínimo: 2 vCPU, 4GB RAM, Windows Server 2019+

2. **Instalar no VPS:**
   - MT5
   - Python 3.8+
   - Visual Studio Redistributable

3. **Expor Flask para internet:**
   ```bash
   # Opção A: ngrok (teste)
   ngrok http 8080

   # Opção B: Nginx + SSL (produção)
   # Seguir documentação Nginx + Let's Encrypt
   ```

4. **Configurar webhook externo:**
   - TradingView: Alerts > Webhook URL
   - Payload: `{"action": "{{strategy.order.action}}"}`
   - Headers: `Authorization: Bearer seu-token-secreto-123`

5. **Monitoramento 24/7:**
   - Configurar alertas (Telegram, Email)
   - Dashboard de status
   - Logs automatizados

---

## ✅ Checklist Final

Antes de usar em conta real:

- [ ] Testado em conta demo por pelo menos 1 semana
- [ ] Volume calculado corretamente (2% do equity)
- [ ] TP/SL aplicados corretamente (100/50 pips)
- [ ] Teste de reversão (long→short→long) funciona
- [ ] Logs sem erros
- [ ] Autenticação Flask funcionando
- [ ] DLL estável por 24h+
- [ ] VPS configurado com failover
- [ ] Alertas configurados

---

## 📞 Suporte

**Problemas comuns:** Ver seção Troubleshooting acima

**Documentação oficial:**
- MQL5: https://www.mql5.com/en/docs
- Flask: https://flask.palletsprojects.com/
- Python requests: https://docs.python-requests.org/

---

**🎉 Sistema instalado e testado com sucesso!**

Agora você pode receber sinais 24/7 e executar operações automaticamente no MT5.
