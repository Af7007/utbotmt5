# Teste do Painel Visual

## Parâmetros para Teste
```mql5
ShowInfoPanel = true         // Habilitar painel
PanelX = 20                  // Posição X
PanelY = 50                  // Posição Y
PanelWidth = 200             // Largura
PanelUpdateInterval = 1      // Atualizar a cada segundo
```

## Layout do Painel

```
┌─────────────────────────────────────────┐
│ TVLucro EA v4.3                         │
├─────────────────────────────────────────┤
│ Hedge:     OFF | Trend:     OFF        │
│ Candle:    OFF | Close:     IMMED       │
│ POS: 0 | PL: 0.00                     │
│ Trades: 0 | Daily: 0.00                  │
│ RISK: 2.0% | TP: 1000 | SL: 500         │
│ Last: None                               │
│ Signal: None                             │
│ 12:30:45                                │
└─────────────────────────────────────────┘
```

## Status Indicadores

### Estratégias
- **Hedge**: OFF / L1, L2, L3... (mostra nível atual)
- **Trend**: OFF / buy / sell (última direção)
- **Candle**: OFF / ON (confirmação por velas)
- **Close**: IMMED / WAIT (execução imediata/fechamento)

### Posições
- **POS**: número de posições abertas
- **PL**: profit/loss atual (verde/vermelho)

### Performance
- **Trades**: trades executados hoje
- **Daily**: lucro/prejuízo do dia

### Configuração
- **RISK/FIXED**: modo de cálculo de lote
- **TP/SL**: pontos configurados

### Eventos
- **Last**: última ação executada
- **Signal**: horário do último sinal

## Cores
- Verde claro: estratégia ativa / profit
- Vermelho claro: estratégia inativa / loss
- Dourado: título (coroa)
- Cinza: textos informativos
- Amarelo: última ação
- Azul: performance
- Verde escuro: P&L positivo

## Comportamento Esperado
1. Painel aparece automaticamente ao iniciar EA
2. Atualiza em tempo real (a cada segundo)
3. Posicionado no lado esquerdo superior
4. Fundo semi-transparente com borda cinza
5. Fontes Arial, tamanho variável por importância
6. Muda para alta prioridade quando há posições abertas

## Troubleshooting
- Se o painel não aparecer: verificar ShowInfoPanel=true
- Se informações não atualizarem: verificar OnTick()
- Se houver objetos residuais ao remover EA: DeleteInfoPanel() chamado
- Se sobrepor outros indicadores: ajustar PanelY