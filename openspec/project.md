# Project Context

## Purpose
Sistema de automação de trading para MetaTrader 5 que recebe sinais via webhook 24/7 e executa ordens imediatamente, com gestão automática de posições (fechando posição anterior ao abrir nova).

## Tech Stack
- **MetaTrader 5 (MQL5)** - Plataforma de trading e execução de ordens
- **C++ (DLL)** - Servidor HTTP local para comunicação entre Flask e MT5
- **Python 3.x** - Flask server para receber webhooks externos
- **Flask** - Web framework para endpoint de webhooks
- **Windows Sockets (WinSock2)** - Comunicação TCP/IP no DLL

## Project Conventions

### Code Style
- **MQL5**: PascalCase para funções (PlaceBuyOrder), camelCase para variáveis locais
- **Python**: PEP 8, snake_case, type hints quando possível
- **C++**: camelCase para variáveis, PascalCase para funções exportadas
- Comentários em português ou inglês de forma consistente
- Logs detalhados com timestamps e níveis (INFO, ERROR, WARNING)

### Architecture Patterns
- **Event-Driven**: Webhook → Flask → DLL → EA polling → Order execution
- **Polling Pattern**: EA faz polling da DLL a cada 1 segundo via OnTimer()
- **Single Responsibility**: Cada componente tem papel específico
  - Flask: Receber e validar webhooks externos
  - DLL: Armazenar sinais e servir via interface C
  - EA: Executar lógica de trading e gestão de ordens
- **Fail-Safe**: Sistema de retry, validações, e logs em múltiplas camadas

### Trading Logic
- **Signal Flow**: long → buy, short → sell
- **Position Management**: Sempre fechar posições existentes antes de abrir nova
- **Risk Management**: Volume calculado por % do equity (padrão: 2%)
- **TP/SL**: Valores fixos em pips (padrão: 100 pips TP, 50 pips SL)
- **Magic Number**: Identificação única para rastreamento de ordens (padrão: 12345)

### Testing Strategy
- **Unit Tests**: Testar funções críticas (CalculateVolume, parsing JSON)
- **Integration Tests**: Testar fluxo completo (webhook → execução)
- **Manual Testing**: Curl para enviar sinais de teste
- **Strategy Tester**: Validar lógica de trading no MT5
- **Edge Cases**: Testar falhas (DLL offline, saldo insuficiente, spread alto)

### Git Workflow
- Branch `main` para código em produção
- Commits descritivos em português
- Estrutura: `tipo: descrição` (ex: "feat: adicionar cálculo de volume")
- Testar localmente antes de commit

## Domain Context

### Trading Terminology
- **Long/Short**: Direção da operação (long = compra, short = venda)
- **TP (Take Profit)**: Preço alvo para lucro
- **SL (Stop Loss)**: Preço limite para perda
- **Pip**: Menor unidade de variação de preço (para XAUUSD, 1 pip = 10 pontos)
- **Lot/Volume**: Tamanho da posição (0.01 = micro lot)
- **Equity**: Saldo + lucro/prejuízo não realizado
- **Magic Number**: ID único para identificar ordens do EA
- **Spread**: Diferença entre Ask e Bid

### MetaTrader 5 Specifics
- **Expert Advisor (EA)**: Robô de trading em MQL5
- **OnTimer()**: Função chamada periodicamente (configurável)
- **OnTick()**: Função chamada a cada tick de preço
- **Trade Library**: CTrade, CSymbolInfo, CPositionInfo
- **DLL Import**: Permite chamar funções de bibliotecas externas
- **Strategy Tester**: Ferramenta de backtesting do MT5

### Webhook Integration
- Webhook externo (ex: TradingView) envia POST para Flask
- Payload esperado: `{"action": "long"}` ou `{"action": "short"}`
- Flask traduz e normaliza para: `{"action": "buy", "timestamp": "..."}`
- Sistema opera 24/7, processando sinais em tempo real

## Important Constraints

### Technical Constraints
- MT5 não tem servidor HTTP nativo - requer DLL externa
- DLL só funciona em Windows (WinSock2)
- DLL deve estar em `MQL5\Libraries\` e ter permissão explícita
- Polling tem latência mínima de 1 segundo (timer interval)
- MQL5 não tem parser JSON nativo - usar StringFind() ou biblioteca externa

### Business Constraints
- Sistema deve operar 24/7 - requer VPS
- Apenas 1 posição aberta por vez (fechar anterior ao abrir nova)
- Risk management obrigatório (% equity limitado)
- TP/SL sempre definidos (não operar sem proteção)

### Regulatory Constraints
- Broker deve permitir automated trading
- Verificar regulamentação local sobre bots de trading
- Logs detalhados para auditoria

## External Dependencies

### Required Services
- **MetaTrader 5 Terminal** - Plataforma de execução
- **Broker MT5** - Servidor de trading (com permissão para EAs)
- **Webhook Provider** - Serviço externo enviando sinais (ex: TradingView)
- **VPS Windows** (produção) - Para rodar MT5 e Flask 24/7

### Required Software
- **Visual Studio 2019+** ou MinGW-w64 - Para compilar DLL C++
- **Python 3.8+** - Para Flask server
- **ngrok** (dev) ou servidor com SSL (prod) - Expor Flask para internet

### Python Dependencies
```
Flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
flask-limiter==3.5.0
```

### MQL5 Libraries
- Trade.mqh - Funções de trading
- SymbolInfo.mqh - Informações de símbolos
- PositionInfo.mqh - Informações de posições
- JAson.mqh (opcional) - Parser JSON robusto

### System Libraries
- ws2_32.lib (Windows) - WinSock2 para sockets TCP/IP
- kernel32.lib (Windows) - Funções do sistema Windows

## File Structure
```
C:\utbot\
├── HttpServer.cpp          # DLL servidor HTTP (porta 5000)
├── HttpTrader.mq5          # Expert Advisor principal
├── webhook_receiver.py     # Flask server (porta 8080)
├── mt5_trader.py           # Script de teste manual
├── requirements.txt        # Dependências Python
├── .env                    # Configurações (API keys, URLs)
├── README.md               # Documentação do projeto
├── docs/
│   └── metatrader5.md      # Documentação técnica MT5
├── logs/                   # Logs do sistema
│   ├── webhook.log         # Logs do Flask
│   └── WebhookTrader.log   # Logs do EA
└── openspec/
    └── project.md          # Este arquivo
```

## Performance Targets
- **Latência total**: < 2 segundos (webhook → execução)
- **Uptime**: 99%+ (com monitoramento e alertas)
- **Taxa de sucesso**: > 95% (ordens executadas com sucesso)
- **Processamento**: Suportar até 10 sinais/minuto

## Security Considerations
- **API Key Authentication** no Flask (Bearer token)
- **IP Whitelist** (opcional) para webhooks conhecidos
- **Rate Limiting** (10 sinais/minuto) para evitar spam
- **HTTPS obrigatório** em produção (via ngrok ou Let's Encrypt)
- **Magic Number único** para isolar ordens do EA
- **Logs sensíveis** não devem conter senhas ou API keys
