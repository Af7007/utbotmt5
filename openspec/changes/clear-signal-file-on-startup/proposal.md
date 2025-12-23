# Change: Apagar signal.json ao Iniciar o EA

## Why
O EA está processando sinais antigos do arquivo signal.json quando é iniciado, o que pode causar execuções indesejadas de ordens baseadas em sinais expirados. Isso representa um risco significativo pois:

1. Sinais antigos podem ser executados imediatamente ao iniciar o EA
2. Não há garantia de que o sinal antigo ainda é válido
3. Pode resultar em perdas financeiras por executar operações desatualizadas
4. Comportamento inesperado do usuário que espera um estado limpo ao iniciar

Apagar o arquivo signal.json na inicialização garante que apenas sinais novos, recebidos após o EA estar completamente iniciado, serão processados.

## What Changes
- Adicionar opção para apagar automaticamente o arquivo signal.json ao iniciar
- Implementar verificação de segurança antes de apagar (backup opcional)
- Adicionar logging para informar quando o arquivo foi apagado
- Preservar comportamento atual através de configuração (opcional)

## Impact
- Affected specs: `trading-bot` (melhoria de segurança na inicialização)
- Affected code: `tvlucro.mq5`
  - Adicionar novo input: `ClearSignalFileOnStartup`
  - `OnInit()` - Adicionar código para apagar signal.json
  - Função auxiliar: `DeleteSignalFile()`