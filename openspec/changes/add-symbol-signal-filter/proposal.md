# Change: Identificar Sinais por Símbolo dos Trade Viewer

## Why
Atualmente o EA processa todos os sinais do arquivo JSON independentemente do símbolo. Isso pode causar:
1. Confusão quando múltiplos trade viewers enviam sinais para diferentes símbolos
2. Processamento incorreto de sinais destinados a outros pares
3. Dificuldade em gerenciar múltiplas estratégias para diferentes símbolos

## What Changes
- Adicionar campo 'symbol' obrigatório no arquivo JSON de sinal
- Implementar filtro por símbolo para ignorar sinais não destinados
- Permitir múltiplos trade viewers operando simultaneamente para diferentes símbolos
- Suporte a Bitcoin (BTCUSD) e outros pares major
- Adicionar logging de quais sinais foram ignorados por motivo de símbolo

## Impact
- Affected specs: `trading-bot` (nova validação de símbolo)
- Affected code: `tvlucro.mq5`
  - Modificações: `ProcessTradeSignal()`, `ReadSignalFile()`
  - Novo parâmetro: `TradingSymbol` já existe, será usado para validação
  - Novas funções: `IsSignalForThisSymbol()`, `LogIgnoredSignal()`