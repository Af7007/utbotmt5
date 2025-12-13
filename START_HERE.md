# 🚀 COMECE AQUI - Sistema de Automação MT5

## ✅ PROBLEMA RESOLVIDO: SEM NECESSIDADE DE DLL!

Como você não tem Visual Studio, **criamos uma versão simplificada** que:
- ❌ **NÃO precisa de DLL**
- ❌ **NÃO precisa compilar nada em C++**
- ✅ **Usa arquivo para comunicação** (mais simples)
- ✅ **Mesma funcionalidade completa**

---

## 📂 ARQUIVOS CRIADOS

### 🟢 Arquivos Principais (USE ESTES)

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| **webhook_receiver.py** | Flask server (porta 8080) | ✅ Pronto |
| **HttpTraderSimple.mq5** | EA sem DLL | ✅ Pronto |
| **signal.json** | Comunicação Flask ↔ MT5 | ✅ Criado |
| **.env** | Configurações (API key) | ✅ Pronto |
| **requirements.txt** | Dependências Python | ✅ Pronto |

### 📖 Documentação

| Arquivo | Para quê serve |
|---------|----------------|
| **START_HERE.md** | Este arquivo - Comece aqui! |
| **README_SIMPLE.md** | Guia resumido (5 min) |
| **QUICKSTART.md** | Guia completo passo a passo |
| **INSTALLATION.md** | Guia técnico detalhado |

### 🔴 Arquivos Antigos (NÃO USE)

| Arquivo | Status |
|---------|--------|
| ~~HttpTrader.mq5~~ | ❌ Requer DLL (não usar) |
| ~~HttpServer.cpp~~ | ❌ Requer compilação (não usar) |

---

## 🎯 PRÓXIMOS PASSOS (10 minutos)

### ✅ Passo 1: Verificar Python (JÁ FEITO)

```bash
python --version
# Python 3.12.0 ✅

pip list | grep Flask
# Flask 3.0.0 ✅
```

**Status**: ✅ **Tudo OK! Python e Flask já instalados.**

---

### 🔧 Passo 2: Configurar MT5

#### 2.1 - Habilitar trading
```
MT5 > Tools > Options > Expert Advisors
✅ Allow algorithmic trading
```

#### 2.2 - Copiar EA
```
MT5 > File > Open Data Folder > MQL5 > Experts
Copiar: HttpTraderSimple.mq5 para essa pasta
```

#### 2.3 - Compilar EA
```
MT5 > Pressionar F4 (MetaEditor)
File > Open > Experts\HttpTraderSimple.mq5
Pressionar F7 (Compile) - Deve dar 0 errors
Fechar MetaEditor
```

#### 2.4 - Anexar ao gráfico
```
MT5 > Abrir gráfico XAUUSD
Navigator (Ctrl+N) > Expert Advisors
Arrastar HttpTraderSimple para o gráfico

Inputs:
- Symbol: XAUUSD
- Risk%: 2.0
- TP: 100 pips
- SL: 50 pips
✅ Allow algorithmic trading

OK
```

#### 2.5 - Verificar
```
Deve aparecer 😊 no gráfico
Aba Experts:
=== HttpTrader EA Initialized (Simple/No DLL) ===
```

---

### 🧪 Passo 3: Testar Sistema

#### Terminal 1: Iniciar Flask
```bash
cd C:\utbot
python webhook_receiver.py
```

Aguardar:
```
* Running on http://127.0.0.1:8080
```

#### Terminal 2: Enviar sinal LONG
```bash
curl -X POST http://localhost:8080/sinais ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer meu-token-123" ^
  -d "{\"action\": \"long\"}"
```

**Resposta esperada:**
```json
{"status": "success", "message": "Signal buy written to file"}
```

#### Verificar MT5 (1-2 segundos)

**Aba Experts:**
```
Signal received: {"action":"buy",...}
=== Processing Trade Signal ===
BUY SUCCESS: Vol=0.02 Entry=2650.50 SL=2645.50 TP=2750.50
```

**Aba Trade:**
- Nova posição BUY aparece ✅

#### Testar SHORT (reversão)
```bash
curl -X POST http://localhost:8080/sinais ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer meu-token-123" ^
  -d "{\"action\": \"short\"}"
```

**Deve:**
- Fechar posição BUY ✅
- Abrir posição SELL ✅

---

## 📊 Arquitetura do Sistema

```
[Webhook Externo]
    ↓ POST {"action": "long"}
[Flask Server :8080]
    ↓ Escreve signal.json
[Arquivo signal.json]
    ↓ {"action": "buy"}
[EA lê arquivo] (1x/segundo)
    ↓ Fecha posições antigas
    ↓ Calcula volume (2% equity)
    ↓ Abre BUY/SELL com TP/SL
[MetaTrader 5] ✅
```

**Latência**: ~500ms-2s

---

## 🐛 Solução de Problemas Rápida

### Flask não inicia
```bash
# Já está instalado! Apenas execute:
python webhook_receiver.py
```

### EA mostra 😞 (cara triste)
```
Tools > Options > Expert Advisors > ✅ Allow algorithmic trading
Remover EA e anexar novamente
```

### Sinal não executa
```bash
# Verificar arquivo criado
dir signal.json

# Criar manualmente para testar
echo {"action":"buy"} > signal.json
# EA deve processar em 1 seg
```

### Volume muito pequeno
```
Aumentar RiskPercent nos inputs: 2.0 → 5.0
Ou aumentar equity da conta demo
```

---

## 📚 Documentação Completa

Leia nesta ordem:

1. **START_HERE.md** ← Você está aqui
2. **README_SIMPLE.md** - Guia rápido (5 min)
3. **QUICKSTART.md** - Guia passo a passo completo
4. **INSTALLATION.md** - Troubleshooting avançado

---

## 🎯 Checklist de Validação

Antes de usar em conta real:

- [ ] ✅ Flask rodando sem erros
- [ ] ✅ EA anexado com 😊
- [ ] ✅ Teste LONG executou
- [ ] ✅ Teste SHORT executou
- [ ] ✅ Volume calculado (2% equity)
- [ ] ✅ TP/SL corretos (100/50 pips)
- [ ] ✅ Testado 1 semana em demo

---

## 🌐 Para Produção (Webhook Real)

### Expor Flask para internet

```bash
# Opção 1: ngrok (teste)
ngrok http 8080
# URL: https://abc123.ngrok-free.app/sinais
```

### Configurar TradingView

```
Alert > Webhook URL: https://seu-dominio.com/sinais
Message: {"action": "{{strategy.order.action}}"}
Headers: Authorization: Bearer meu-token-123
```

---

## 💡 Dicas Importantes

1. **Sempre testar em DEMO primeiro**
2. **Monitorar logs**: `logs/webhook.log` e MT5 Experts tab
3. **Começar com 2% risk** (pode ajustar depois)
4. **Testar reversão** (long→short→long)
5. **VPS recomendado** para produção 24/7

---

## 📞 Precisa de Ajuda?

**Problemas comuns**: Ver seção "Solução de Problemas" acima

**Guia completo**: Abrir `QUICKSTART.md`

**Documentação técnica**: Abrir `INSTALLATION.md`

---

## ✅ Status do Sistema

| Componente | Status | Versão |
|------------|--------|--------|
| Python + Flask | ✅ Instalado | 3.12 |
| webhook_receiver.py | ✅ Pronto | 2.0 |
| HttpTraderSimple.mq5 | ✅ Pronto | 2.0 |
| signal.json | ✅ Criado | - |
| Comunicação | ✅ Arquivo | - |
| DLL C++ | ❌ Não necessária | - |

---

## 🚀 RESUMO

**O que temos:**
- ✅ Sistema completo de automação MT5
- ✅ Recebe webhooks externos (TradingView, etc)
- ✅ Executa ordens automaticamente
- ✅ Gestão de risco (2% equity)
- ✅ TP/SL automáticos (100/50 pips)
- ✅ **SEM necessidade de compilar DLL!**

**Próximo passo:**
1. Seguir **Passo 2 e 3** acima (10 min)
2. Testar por 1 semana em demo
3. Ajustar parâmetros se necessário
4. Expor para internet (produção)

---

**🎉 Sistema 100% pronto! Comece pelo Passo 2 acima! 🚀**
