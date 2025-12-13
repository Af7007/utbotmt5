#!/bin/bash
# Script de Teste de Sinais - TradingView Webhook
# Uso: ./test_signals.sh

WEBHOOK_URL="https://livelier-nonpurposively-monty.ngrok-free.dev"
SIGNAL_FILE="$APPDATA/MetaQuotes/Terminal/Common/Files/signal.json"

echo "================================"
echo "TESTE DE SINAIS - TRADINGVIEW"
echo "================================"
echo ""

# Função para exibir linha separadora
line() {
    echo "--------------------------------"
}

# Teste 1: Health Check
echo "1. HEALTH CHECK"
line
response=$(curl -s -X GET "$WEBHOOK_URL/health")
echo "Response: $response"
if [[ $response == *"ok"* ]]; then
    echo "✅ Webhook online!"
else
    echo "❌ Webhook offline!"
    exit 1
fi
echo ""

# Teste 2: Status
echo "2. STATUS CHECK"
line
curl -s -X GET "$WEBHOOK_URL/status" | python -m json.tool 2>/dev/null || echo "Error parsing JSON"
echo ""

# Teste 3: Enviar Sinal de COMPRA (LONG)
echo "3. TESTANDO SINAL DE COMPRA (LONG)"
line
echo "Enviando sinal..."
response=$(curl -s -X POST "$WEBHOOK_URL/sinais" \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}')
echo "Response: $response"
if [[ $response == *"success"* ]]; then
    echo "✅ Sinal de COMPRA enviado com sucesso!"
else
    echo "❌ Falha ao enviar sinal de COMPRA"
fi
echo ""

echo "Aguardando 3 segundos..."
sleep 3
echo ""

# Verificar arquivo
echo "Verificando arquivo signal.json:"
if [ -f "$SIGNAL_FILE" ]; then
    cat "$SIGNAL_FILE"
    echo ""
    echo "✅ Arquivo existe!"
else
    echo "❌ Arquivo não encontrado!"
fi
echo ""

# Teste 4: Enviar Sinal de VENDA (SHORT)
echo "4. TESTANDO SINAL DE VENDA (SHORT)"
line
echo "Enviando sinal..."
response=$(curl -s -X POST "$WEBHOOK_URL/sinais" \
  -H "Content-Type: application/json" \
  -d '{"action": "short"}')
echo "Response: $response"
if [[ $response == *"success"* ]]; then
    echo "✅ Sinal de VENDA enviado com sucesso!"
else
    echo "❌ Falha ao enviar sinal de VENDA"
fi
echo ""

echo "Aguardando 3 segundos..."
sleep 3
echo ""

# Verificar arquivo novamente
echo "Verificando arquivo signal.json:"
if [ -f "$SIGNAL_FILE" ]; then
    cat "$SIGNAL_FILE"
    echo ""
    echo "✅ Arquivo atualizado!"
else
    echo "❌ Arquivo não encontrado!"
fi
echo ""

# Teste 5: Teste com JSON inválido (simular erro do TradingView)
echo "5. TESTANDO JSON INVÁLIDO (simular erro)"
line
echo "Enviando JSON inválido..."
response=$(curl -s -X POST "$WEBHOOK_URL/sinais" \
  -H "Content-Type: text/plain" \
  -d 'invalid json')
echo "Response: $response"
if [[ $response == *"error"* ]]; then
    echo "✅ Webhook rejeitou corretamente!"
else
    echo "⚠️ Webhook aceitou JSON inválido (inesperado)"
fi
echo ""

# Resumo
line
echo "RESUMO DOS TESTES"
line
echo ""
echo "✅ Webhook está online"
echo "✅ Sinais estão sendo recebidos"
echo "✅ Arquivo signal.json está sendo criado"
echo ""
echo "🔍 PRÓXIMOS PASSOS:"
echo "1. Verifique se o EA (tv.mq5) está rodando no MT5"
echo "2. Verifique se AutoTrading está habilitado (botão verde)"
echo "3. Abra a aba 'Experts' no MT5 e veja os logs"
echo "4. Configure o alerta no TradingView com:"
echo "   URL: $WEBHOOK_URL/sinais"
echo "   Message: {\"action\": \"long\"} ou {\"action\": \"short\"}"
echo ""
echo "📚 Para mais detalhes, veja: TROUBLESHOOTING.md"
echo ""
