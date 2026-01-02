# Change: Continuous Martingale Based on Last Opened Lot

## Why

O EA atual usa um multiplicador fixo baseado no lote inicial (`HedgeLotMultiplier * FixedLotSize`), o que significa que todas as ordens de hedge abrem com o mesmo tamanho de lote multiplicado. O usuário quer um verdadeiro sistema de martingale onde cada nova ordem multiplica o lote da **última ordem aberta**, criando uma progressão exponencial (1x, 1.5x, 2.25x, 3.375x...).

## What Changes

- Adicionar modo de martingale contínuo que multiplica o lote da última ordem aberta
- Adicionar parâmetro de configuração para ativar/desativar o martingale contínuo
- Rastrear o último lote aberto por direção (buy/sell)
- Calcular o próximo lote como: `ultimoLoteAberto * multiplicador`
- Manter compatibilidade com o modo atual (multiplicador fixo)

## Impact

- Affected specs: `martingale` (nova capability)
- Affected code: `tvlucrogrid.mq5` - funções `ExecuteGridOrder`, `ExecuteGridOrderWithMultiplier`, `CalculateVolume`
- Breaking changes: Não (será aditivo, com parâmetro para ativar novo comportamento)
