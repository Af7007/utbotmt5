# Proposta: Compras Múltiplas por Positividade (Scalping Positivo)

## Visão Geral
Implementar uma nova versão de compras múltiplas que abre novas posições sempre que a posição atual permanecer positiva por mais de 15 segundos, com foco em atingir uma meta em pontos de lucro, similar ao sistema de hedge existente.

## Problema a Resolver
O sistema atual de hedge só abre posições contrárias quando há prejuízo. Propõe-se um sistema agressivo de "scalping positivo" que capitaliza movimentos favoráveis continuamente.

## Benefícios
- Maximiza lucros em tendências fortes
- Aumenta exposição em trades vencedores
- Automatiza o processo de "martingale positivo"
- Meta clara de lucro em pontos
- Redução de risco por não aumentar expoção em prejuízo

## Características Principais
- Abre novas posições a cada 15 segundos de positividade
- Mantém direção da posição original (não inverte)
- Volume crescente com opção de multiplicador
- Meta de lucro total em pontos
- Proteção contra exageros com limite de posições
- Pausa automaticamente ao atingir meta

## Impacto
- Modificação significativa no comportamento de trading
- Potencialmente mais lucro (mas também mais risco)
- Similar ao hedge mas para posições vencedoras
- Requer ajuste de parâmetros dedicados