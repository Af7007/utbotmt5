# Tasks: Filtragem de Sinais por Símbolo

## 1. Modificações no Processamento de Sinais
- [ ] 1.1 Modificar `ReadSignalFile()` - Adicionar parsing do campo 'symbol'
- [ ] 1.2 Modificar `ProcessTradeSignal()` - Adicionar validação de símbolo
- [ ] 1.3 Implementar `IsSignalForThisSymbol()` - Verifica se sinal é para este EA
- [ ] 1.4 Implementar `LogIgnoredSignal()` - Registra sinais ignorados

## 2. Validação de JSON
- [ ] 2.1 Testar sinal com símbolo correto (BTCUSD)
- [ ] 2.2 Testar sinal com símbolo incorreto (EURUSD para EA BTCUSD)
- [ ] 2.3 Testar sinal sem campo 'symbol' (compatibilidade)
- [ ] 2.4 Testar sinal com campo 'symbol' vazio
- [ ] 2.5 Testar com múltiplos símbolos: XAUUSD, EURUSD, BTCUSD

## 3. Logging e Debug
- [ ] 3.1 Adicionar logging de validação de símbolo
- [ ] 3.2 Adicionar logging de sinais ignorados
- [ ] 3.3 Incluir informações do símbolo nos logs
- [ ] 3.4 Manter formato de log existente

## 4. Testes com Trade Viewers
- [ ] 4.1 Simular múltiplos trade viewers enviando para símbolos diferentes
- [ ] 4.2 Verificar que EA BTCUSD processa apenas sinais BTCUSD
- [ ] 4.3 Verificar que EA XAUUSD processa apenas sinais XAUUSD
- [ ] 4.4 Testar mudança dinâmica do `TradingSymbol`
- [ ] 4.5 Validar performance com múltiplos sinais simultâneos

## 5. Compatibilidade
- [ ] 5.1 Garantir que sinais antigos (sem 'symbol') ainda funcionem
- [ ] 5.2 Verificar que não quebra fluxo existente
- [ ] 5.3 Testar com todos os modos de operação (hedge, trend, etc.)