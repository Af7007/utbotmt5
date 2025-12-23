# Change: Prevenir Execução Automática do EA ao Iniciar

## Why
O EA atualmente fecha todas as posições abertas e executa uma nova ordem ao ser iniciado, mesmo sem receber um novo sinal. Este comportamento indesejado ocorre porque o EA processa o arquivo `signal.json` existente como se fosse um sinal novo, resultando em perdas potenciais ao interromper operações já em andamento.

## What Changes
- **BREAKING**: Comportamento de inicialização modificado - não fecha mais posições automaticamente
- Adicionar verificação de timestamp para sinais recebidos
- Ignorar completamente sinais existentes no arquivo `signal.json` durante inicialização
- Manter posições existentes até receber um novo sinal válido
- Preservar todas as funcionalidades existentes (hedge, trend continuation, candle confirmation)

## Impact
- Affected specs: `trading-bot` (modificação de comportamento de inicialização)
- Affected code: `tvlucro.mq5`
  - `OnInit()` - Não ler arquivo de sinal existente
  - `OnTimer()` - Validar timestamp do sinal antes de processar
  - `ProcessTradeSignal()` - Adicionar controle para fechar posições apenas com sinal novo
  - Novas funções: `ExtractTimestampFromJSON()`, `IsSignalRecent()`