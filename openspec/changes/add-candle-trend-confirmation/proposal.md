# Change: Add Candle Trend Confirmation

## Why
Atualmente, a feature de Trend Continuation reentra após um timer fixo sem verificar se o mercado ainda está em tendência. Isso pode resultar em reentradas em momentos de reversão ou consolidação, gerando trades perdedores.

A confirmação por candles garante que:
1. O mercado ainda está se movendo na direção esperada
2. As últimas N velas fecharam na mesma direção (bullish ou bearish)
3. A reentrada só ocorre após o fechamento de uma vela confirmando a tendência

## What Changes
- Adicionar verificação de direção das últimas N velas antes de reentrar
- Aguardar fechamento de vela (não entrar no meio de uma vela)
- Configurar número de velas a verificar (ex: 3 velas)
- Configurar timeframe para análise (pode ser diferente do gráfico atual)
- Opção para exigir velas consecutivas ou maioria

## Impact
- Affected specs: trading-bot (trend continuation enhancement)
- Affected code: tvlucro.mq5, tv.mq5 (novas funções de análise de candles)
