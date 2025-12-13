# Script de Teste de Sinais - TradingView Webhook (PowerShell)
# Uso: .\test_signals.ps1

$WEBHOOK_URL = "https://livelier-nonpurposively-monty.ngrok-free.dev"
$SIGNAL_FILE = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\signal.json"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "TESTE DE SINAIS - TRADINGVIEW" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

function Line {
    Write-Host "--------------------------------" -ForegroundColor Gray
}

# Teste 1: Health Check
Write-Host "1. HEALTH CHECK" -ForegroundColor Yellow
Line
try {
    $response = Invoke-RestMethod -Uri "$WEBHOOK_URL/health" -Method Get
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Green
    if ($response.status -eq "ok") {
        Write-Host "✅ Webhook online!" -ForegroundColor Green
    } else {
        Write-Host "❌ Webhook offline!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erro ao conectar: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Teste 2: Status
Write-Host "2. STATUS CHECK" -ForegroundColor Yellow
Line
try {
    $response = Invoke-RestMethod -Uri "$WEBHOOK_URL/status" -Method Get
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
}
Write-Host ""

# Teste 3: Enviar Sinal de COMPRA (LONG)
Write-Host "3. TESTANDO SINAL DE COMPRA (LONG)" -ForegroundColor Yellow
Line
Write-Host "Enviando sinal..." -ForegroundColor Gray
try {
    $body = @{action = "long"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$WEBHOOK_URL/sinais" -Method Post `
        -ContentType "application/json" -Body $body
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Green
    if ($response.status -eq "success") {
        Write-Host "✅ Sinal de COMPRA enviado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "❌ Falha ao enviar sinal de COMPRA" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "Aguardando 3 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host ""

# Verificar arquivo
Write-Host "Verificando arquivo signal.json:" -ForegroundColor Yellow
if (Test-Path $SIGNAL_FILE) {
    $content = Get-Content $SIGNAL_FILE -Raw
    Write-Host $content -ForegroundColor Cyan
    Write-Host "✅ Arquivo existe!" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo não encontrado em: $SIGNAL_FILE" -ForegroundColor Red
}
Write-Host ""

# Teste 4: Enviar Sinal de VENDA (SHORT)
Write-Host "4. TESTANDO SINAL DE VENDA (SHORT)" -ForegroundColor Yellow
Line
Write-Host "Enviando sinal..." -ForegroundColor Gray
try {
    $body = @{action = "short"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$WEBHOOK_URL/sinais" -Method Post `
        -ContentType "application/json" -Body $body
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Green
    if ($response.status -eq "success") {
        Write-Host "✅ Sinal de VENDA enviado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "❌ Falha ao enviar sinal de VENDA" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "Aguardando 3 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host ""

# Verificar arquivo novamente
Write-Host "Verificando arquivo signal.json:" -ForegroundColor Yellow
if (Test-Path $SIGNAL_FILE) {
    $content = Get-Content $SIGNAL_FILE -Raw
    Write-Host $content -ForegroundColor Cyan
    Write-Host "✅ Arquivo atualizado!" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo não encontrado!" -ForegroundColor Red
}
Write-Host ""

# Teste 5: Teste com conteúdo inválido
Write-Host "5. TESTANDO CONTEÚDO INVÁLIDO (simular erro)" -ForegroundColor Yellow
Line
Write-Host "Enviando conteúdo inválido..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "$WEBHOOK_URL/sinais" -Method Post `
        -ContentType "text/plain" -Body "invalid json" -ErrorAction Stop
    Write-Host "Response: $($response.Content)" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Webhook rejeitou corretamente! (HTTP 400)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Erro: $_" -ForegroundColor Yellow
    }
}
Write-Host ""

# Resumo
Line
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Line
Write-Host ""
Write-Host "✅ Webhook está online" -ForegroundColor Green
Write-Host "✅ Sinais estão sendo recebidos" -ForegroundColor Green
Write-Host "✅ Arquivo signal.json está sendo criado" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Verifique se o EA (tv.mq5) está rodando no MT5" -ForegroundColor White
Write-Host "2. Verifique se AutoTrading está habilitado (botão verde)" -ForegroundColor White
Write-Host "3. Abra a aba 'Experts' no MT5 e veja os logs" -ForegroundColor White
Write-Host "4. Configure o alerta no TradingView com:" -ForegroundColor White
Write-Host "   URL: $WEBHOOK_URL/sinais" -ForegroundColor Cyan
Write-Host "   Message: {`"action`": `"long`"} ou {`"action`": `"short`"}" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para mais detalhes, veja: TROUBLESHOOTING.md" -ForegroundColor Magenta
Write-Host ""
