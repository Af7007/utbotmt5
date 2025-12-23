# TVLucro EA v4.4 - Chart Layout Prevention

## Novidades da v4.4:
- Prevenção de operações em gráfico lateral (side chart)
- Detecção automática de tamanho mínimo do gráfico
- Bloqueio de trading se gráfico inadequado
- Painel visual com status do gráfico

## Novos Parâmetros:
```mql5
//--- Chart Layout Parameters
input bool     CheckChartSize = true;           // Verificar tamanho mínimo do gráfico
input int      MinChartWidth = 400;              // Largura mínima para operar (pixels)
input int      MinChartHeight = 300;             // Altura mínima para operar (pixels)
input bool     AllowSideChart = false;          // Permitir gráfico lateral (false = bloquear)
```

## Comportamento:
- **Modo Normal**: Chart >= 400x300px E não lateral (a menos que permitido)
- **Bloqueio Lateral**: Quando largura < 60% da altura e AllowSideChart=false
- **Bloqueio Tamanho**: Quando dimensões abaixo do mínimo e CheckChartSize=true
- **Recuperação Automática**: Trading retoma quando gráfico fica adequado

## Como usar:
1. Compile o EA no MetaEditor
2. Adicione ao gráfico desejado
3. Configure os parâmetros conforme necessidade
4. O EA exibirá status do gráfico no painel

## Soluções de problemas:
- Se der erro de compilação: salve o arquivo (Ctrl+S) e recompile
- Limpe cache do MetaEditor se necessário
- Verifique se todas as dependências estão incluídas