# Change: Add Trend Continuation Feature

## Why
Atualmente, quando o bot fecha uma posição com lucro (TP), ele aguarda um novo sinal do webhook. Em tendências fortes e contínuas, isso resulta em perda de oportunidade pois o preço continua se movendo na mesma direção sem gerar novo sinal imediato.

## What Changes
- Adicionar timer de reentrada que monitora quanto tempo passou desde o último trade fechado com lucro
- Armazenar direção e resultado do último trade (win/loss)
- Implementar lógica de reentrada automática se:
  - Último trade fechou com lucro (TP ou breakeven+)
  - Nenhum novo sinal recebido dentro do período configurável (ex: 60 segundos)
  - Não há posição aberta
- Permitir configurar número máximo de reentradas consecutivas
- Opção para habilitar/desabilitar a feature

## Impact
- Affected specs: trading-bot (new capability)
- Affected code: tv.mq5 (OnTimer, variáveis globais, novas funções)
