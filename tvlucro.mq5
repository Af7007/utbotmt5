// TVLucro EA v4.8 - Martingale Hedge Fix
// Expert Advisor with chart layout detection and trading prevention
// Lê sinais de arquivo JSON escrito pelo Flask

#property copyright "MT5 Webhook Automation"
#property link      "https://github.com"
#property version   "4.8"
//#property strict
#property description "TVLucro EA v4.8 - Modern Panel + Martingale Hedge Fix"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- input parameters
input string   TradingSymbol = "XAUUSD";         // Symbol to trade
input int      MagicNumber = 12345;           // Magic number for orders
input double   RiskPercent = 1.0;             // % do equity por trade (REDUZIDO)
input bool     UseFixedLots = false;          // Usar lote fixo em vez de % de risco
input double   FixedLotSize = 0.01;           // Tamanho do lote fixo (se UseFixedLots=true)
input bool     ValidateLotSize = true;        // Validar limites de lote do broker
input int      TakeProfitPoints = 1000;        // TP em pontos (ex: 1000 = $10 para XAUUSD)
input int      StopLossPoints = 500;           // SL em pontos (ex: 500 = $5 para XAUUSD)
input int      PollingIntervalSec = 1;        // Frequência polling (segundos)
input string   SignalFilePath = "signal_XAUUSD.json"; // Caminho do arquivo de sinal (formato: symbol_Symbol.json)
input bool     EnableBreakeven = true;        // Ativar Breakeven
input int      BreakEvenPoints = 100;         // Breakeven após X pontos de lucro
input int      BreakEvenExtraPoints = 20;     // Pontos além do ponto de entrada
input bool     EnableTrailingStop = true;     // Ativar Trailing Stop
input int      TrailingStopPoints = 100;      // Trailing stop em pontos
input int      TrailingStepPoints = 50;       // Mover SL a cada X pontos
input bool     UseATRBasedSL = false;         // SL inicial baseado em ATR
input int      ATRPeriod = 14;                // Período do ATR
input double   ATRMultiplier = 1.5;           // Multiplicador do ATR para SL
input bool     EnableReverseTrading = false;  // Inverter sinais (long→sell, short→buy)
input bool     AutoAdjustForSymbol = true;    // Auto-ajustar valores por símbolo
input bool     EnableHedge = false;           // Ativar sistema de Hedge Martingale
input int      HedgeProfitTarget = 100;       // Meta de lucro total em pontos (hedge)
input double   HedgeMultiplier = 2.0;         // Multiplicador martingale do volume
input int      MaxHedgeLevels = 5;            // Máximo de níveis de hedge permitidos
input bool     EnableCandleConfirmation = true; // Confirmar tendência por candles
input int      CandleConfirmationCount = 3;    // Número de velas a verificar
input ENUM_TIMEFRAMES CandleConfirmationTF = PERIOD_CURRENT; // Timeframe para análise
input bool     RequireConsecutiveCandles = true; // Exigir todas consecutivas (false=maioria)
input bool     WaitForCandleClose = true;      // Aguardar fechamento da vela
input bool     OpenOnCandleClose = false;       // Abrir posição apenas no fechamento da vela
input ENUM_TIMEFRAMES CandleCloseTimeframe = PERIOD_CURRENT; // Timeframe para monitorar fechamento
input int      MaxPendingSignals = 3;            // Máximo de sinais pendentes
input int      PendingSignalExpirationSec = 300; // Expiração de sinal pendente (segundos)

//--- Info Panel Parameters
input bool     ShowInfoPanel = true;           // Mostrar painel informativo
input int      PanelX = 20;                     // Posição X do painel
input int      PanelY = 50;                     // Posição Y do painel
input int      PanelWidth = 200;                // Largura do painel
input int      PanelUpdateInterval = 1;         // Segundos entre atualizações do painel

//--- Chart Layout Parameters
input bool     CheckChartSize = true;           // Verificar tamanho mínimo do gráfico
input int      MinChartWidth = 400;              // Largura mínima para operar (pixels)
input int      MinChartHeight = 300;             // Altura mínima para operar (pixels)
input bool     AllowSideChart = false;          // Permitir gráfico lateral (false = bloquear)

//--- Trend Marker Parameters
input bool     TrendMarkerEnabled = true;        // Ativar marcador de tendência no painel
input int      TrendMAPeriodFast = 9;            // Período da média móvel rápida
input int      TrendMAPeriodSlow = 21;           // Período da média móvel lenta
input int TrendMAType = 1;                                  // Tipo: SMA=0, EMA=1, SMMA=2, LWMA=3
input bool     TrendStrengthDisplay = true;      // Exibir força da tendência

//--- Positive Scalping Parameters
input bool     EnablePositiveScalping = false;    // Ativar sistema de scalping positivo (PADRÃO OFF)
input int      PositiveProfitSeconds = 60;      // Segundos de lucro para abrir nova posição (AUMENTADO)
input double   ScalpingVolumeMultiplier = 1.2;   // Multiplicador do volume nas posições scalping (REDUZIDO)
input int      MaxScalpingLevels = 3;            // Máximo de posições escalping permitidas (REDUZIDO)
input int      ScalpingProfitTarget = 100;      // Meta de lucro total em pontos (REDUZIDO)
input bool     EnableScalpingBreakeven = true;   // Ativar breakeven para posições scalping
input int      ScalpingBreakevenPoints = 50;      // Pontos de lucro para ativar breakeven nas posições scalping

CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;

//--- Global variables
string lastProcessedJson = "";
datetime lastProcessedTime = 0;
int adjustedTPPoints = 0;
int adjustedSLPoints = 0;
int adjustedBEPoints = 0;
int adjustedTrailingPoints = 0;
int adjustedTrailingStepPoints = 0;

//--- Signal Processing Variables (initialized to empty/default)
string signalSymbol = "";
bool signalHasSymbol = false;
string currentSignalDirection = "";
string currentSignalSymbol = "";

//--- Hedge Martingale variables
int currentHedgeLevel = 0;          // Nível atual de martingale (0 = sem hedge)
bool isInHedgeMode = false;         // Flag indicando modo hedge ativo
double lastHedgeVolume = 0;         // Último volume usado no hedge
double initialHedgeVolume = 0;      // Volume inicial da primeira posição

//--- Position tracking variables
bool hasOpenPosition = false;         // Cache de posição aberta
ulong lastKnownTicket = 0;            // Ticket da última posição conhecida

//--- Candle Confirmation variables
datetime lastCheckedCandleTime = 0;   // Timestamp da última vela verificada

//--- Startup Protection
datetime eaStartTime = 0;             // Timestamp de quando o EA iniciou
int startupDelaySeconds = 5;          // Segundos para ignorar sinais no startup

//--- Signal Symbol (usando variáveis globais existentes)

//--- Signal Processing Variables (usando as variáveis globais existentes)

//--- Execution Prevention on Startup
datetime eaInitializationTime = 0;    // Timestamp exato da inicialização (para validar sinais)

//--- Candle Close Execution variables
string pendingSignals[10];            // Fila de sinais pendentes (máximo 10)
int pendingSignalsCount = 0;           // Contador de sinais na fila
datetime pendingSignalTimes[10];       // Timestamps dos sinais pendentes
datetime lastCandleCloseTime = 0;      // Último timestamp de fechamento
bool isProcessingCandleClose = false;  // Flag para evitar processamento duplicado

//--- Info Panel variables
datetime lastPanelUpdate = 0;          // Última atualização do painel
bool panelInitialized = false;         // Flag indicando se painel foi criado
string panelPrefix = "TVLucroPanel_";  // Prefixo para objetos do painel
double totalDailyPL = 0;              // PL diário total
int dailyTradeCount = 0;               // Contador de trades diários
string lastAction = "None";            // Última ação executada
datetime lastSignalTime = 0;           // Timestamp do último sinal

//--- Trend Marker variables
int trendMAFastHandle = INVALID_HANDLE;    // Handle da média móvel rápida
int trendMASlowHandle = INVALID_HANDLE;    // Handle da média móvel lenta
double currentTrendValue = 0;              // Valor atual da tendência
string currentTrendDirection = "NEUTRAL";  // Direção atual da tendência
string currentTrendStrength = "WEAK";      // Força atual da tendência

//--- Positive Scalping State
int currentScalpingLevel = 0;            // Nível atual de scalping (0 = sem scalping)
bool isInPositiveScalping = false;        // Flag indicando modo scalping positivo ativo
double lastScalpingVolume = 0;             // Volume da última posição de scalping
datetime lastPositiveCheckTime = 0;       // Última verificação de positividade
double totalScalpingProfit = 0;           // Lucro total acumulado nas posições scalping
string scalpingDirection = "";             // Direção das posições scalping (buy/sell)

//--- Risk Management State
double initialEquity = 0;                 // Equity inicial da sessão
double maxDrawdownAllowed = 20.0;         // Drawdown máximo permitido (%)
double dailyLossLimit = 5.0;              // Limite de perda diária (%)
bool riskManagementEnabled = true;         // Ativar gestão de risco
datetime sessionStartTime = 0;             // Início da sessão
double totalSessionLoss = 0;              // Perda total da sessão

//+------------------------------------------------------------------+
//| Risk Management Functions                                         |
//+------------------------------------------------------------------+

// Initialize risk management
void InitializeRiskManagement()
{
    if (!riskManagementEnabled)
        return;

    // Versão simplificada para evitar erros de compilação
    initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    sessionStartTime = TimeCurrent();
    totalSessionLoss = 0;

    Print("Risk management initialized");
}

// Check if risk limits are exceeded
bool CheckRiskLimits()
{
    if (!riskManagementEnabled)
        return true;

    // Check for invalid initial equity
    if (initialEquity <= 0)
    {
        Print("Error: Invalid initial equity: ", initialEquity);
        return false;
    }

    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double totalEquityChange = currentEquity - initialEquity;

    // Update session loss
    if (totalEquityChange < 0)
        totalSessionLoss = MathAbs(totalEquityChange);
    else
        totalSessionLoss = 0;

    // Check drawdown limit
    double drawdownPercent = ((initialEquity - currentEquity) / initialEquity) * 100;
    if (drawdownPercent > maxDrawdownAllowed)
    {
        Print("!!! DRAWDOWN LIMIT EXCEEDED !!!");
        Print("Current Drawdown: ", DoubleToString(drawdownPercent, 2), "%");
        Print("Max Allowed: ", maxDrawdownAllowed, "%");
        Print("Emergency closing all positions...");
        CloseAllPositions();
        return false;
    }

    // Check daily loss limit
    double lossPercent = (totalSessionLoss / initialEquity) * 100;
    if (lossPercent > dailyLossLimit)
    {
        Print("!!! DAILY LOSS LIMIT EXCEEDED !!!");
        Print("Daily Loss: ", DoubleToString(lossPercent, 2), "%");
        Print("Max Allowed: ", dailyLossLimit, "%");
        Print("Emergency closing all positions...");
        CloseAllPositions();
        return false;
    }

    // Check margin usage
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    if (equity <= 0)
    {
        Print("ERROR: Invalid equity value: ", equity);
        return false;
    }
    double marginPercent = (AccountInfoDouble(ACCOUNT_MARGIN) / equity) * 100;
    if (marginPercent > 90)  // 90% margin usage
    {
        Print("!!! MARGIN WARNING !!!");
        Print("Margin Usage: ", DoubleToString(marginPercent, 2), "%");
        Print("Emergency closing positions...");
        CloseAllPositions();
        return false;
    }

    return true;
}

// Check additional risk limits before opening new orders
bool CheckRiskLimitsBeforeOpening()
{
    if (!riskManagementEnabled)
        return true;

    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    if (initialEquity <= 0)
    {
        Print("ERROR: Invalid initial equity: ", initialEquity);
        return false;
    }
    double currentDrawdown = ((initialEquity - currentEquity) / initialEquity) * 100;

    // Don't open new positions if drawdown is already high
    if (currentDrawdown > 10.0)  // 10% drawdown
    {
        Print("!!! HIGH DRAWDOWN PROTECTION !!!");
        Print("Current drawdown: ", DoubleToString(currentDrawdown, 2), "%");
        Print("Preventing new position opening until recovery");
        return false;
    }

    // Don't open if we already have too many positions
    int positionCount = PositionsTotal();
    if (positionCount >= 10)  // Limit of 10 positions total
    {
        Print("!!! POSITION LIMIT REACHED !!!");
        Print("Current positions: ", positionCount);
        Print("Maximum allowed: 10");
        return false;
    }

    // Check if we're in a losing session
    if (totalSessionLoss > (initialEquity * dailyLossLimit / 100))
    {
        Print("!!! DAILY LOSS LIMIT REACHED !!!");
        Print("Session loss: ", DoubleToString(totalSessionLoss, 2));
        Print("Limit: ", DoubleToString(initialEquity * dailyLossLimit / 100, 2));
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Auto-adjust parameters based on symbol                           |
//+------------------------------------------------------------------+
void AdjustParametersForSymbol()
{
    double point = symbolInfo.Point();
    int minStopLevel = (int)SymbolInfoInteger(TradingSymbol, SYMBOL_TRADE_STOPS_LEVEL);
    double minDistance = minStopLevel * point;

    Print("=== AUTO-ADJUSTING FOR SYMBOL ===");
    Print("Symbol: ", TradingSymbol);
    Print("Point: ", point);
    Print("Min Stop Level: ", minStopLevel, " points (", minDistance, " price distance)");

    // Usar valores configurados pelo usuário
    int suggestedTP = TakeProfitPoints;
    int suggestedSL = StopLossPoints;
    int suggestedBE = BreakEvenPoints;
    int suggestedTrailing = TrailingStopPoints;
    int suggestedTrailingStep = TrailingStepPoints;

    Print("User configured values:");
    Print("  TakeProfit: ", suggestedTP, " points");
    Print("  StopLoss: ", suggestedSL, " points");
    Print("  Breakeven: ", suggestedBE, " points");
    Print("  Trailing: ", suggestedTrailing, " points");

    // Validar contra stop level mínimo
    if (minStopLevel > 0)
    {
        int minRequired = minStopLevel + 10; // Adiciona margem de segurança

        if (suggestedSL < minRequired)
        {
            Print("Adjusting SL: ", suggestedSL, " → ", minRequired, " (min required)");
            suggestedSL = minRequired;
        }

        if (suggestedTP < minRequired)
        {
            Print("Adjusting TP: ", suggestedTP, " → ", minRequired * 2, " (min required)");
            suggestedTP = minRequired * 2;
        }

        if (suggestedBE < minRequired / 2)
        {
            suggestedBE = minRequired / 2;
        }

        if (suggestedTrailing < minRequired)
        {
            suggestedTrailing = minRequired;
        }

        // Trailing Step deve ser pelo menos 1/3 do Trailing Distance
        int minTrailingStep = suggestedTrailing / 3;
        if (minTrailingStep < 10) minTrailingStep = 10; // Mínimo de 10 pontos
        if (suggestedTrailingStep < minTrailingStep)
        {
            Print("Adjusting TrailingStep: ", suggestedTrailingStep, " → ", minTrailingStep, " (min 1/3 of trailing)");
            suggestedTrailingStep = minTrailingStep;
        }
    }

    // Aplicar valores (validados contra stop level mínimo)
    adjustedTPPoints = suggestedTP;
    adjustedSLPoints = suggestedSL;
    adjustedBEPoints = suggestedBE;
    adjustedTrailingPoints = suggestedTrailing;
    adjustedTrailingStepPoints = suggestedTrailingStep;

    Print("FINAL VALUES (after validation):");
    Print("  TakeProfit: ", adjustedTPPoints, " points (", adjustedTPPoints * point, " price)");
    Print("  StopLoss: ", adjustedSLPoints, " points (", adjustedSLPoints * point, " price)");
    Print("  Breakeven: ", adjustedBEPoints, " points");
    Print("  Trailing: ", adjustedTrailingPoints, " points");
    Print("  TrailingStep: ", adjustedTrailingStepPoints, " points");
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Setup timer for polling
    EventSetTimer(PollingIntervalSec);
    Print("Timer set to poll every ", PollingIntervalSec, " second(s)");

    // Register timestamp exato de inicialização
    eaInitializationTime = TimeLocal();
    Print("EA initialized at: ", eaInitializationTime);

    // Initialize Risk Management
    InitializeRiskManagement();

    // Inicializar variáveis de processamento de sinal sem ler arquivo existente
    lastProcessedJson = "";
    currentSignalDirection = "";
    currentSignalSymbol = "";
    signalSymbol = "";
    signalHasSymbol = false;
    Print("Startup protection: Will ignore existing signal.json file");

    // Reset do estado do Positive Scalping
    if (EnablePositiveScalping)
    {
        currentScalpingLevel = 0;
        isInPositiveScalping = false;
        lastScalpingVolume = 0;
        lastPositiveCheckTime = 0;
        totalScalpingProfit = 0;
        scalpingDirection = "";
        Print("Positive Scalping state reset");
    }

    // Setup trading
    trade.SetExpertMagicNumber(MagicNumber);

    symbolInfo.Name(TradingSymbol);
    if (!symbolInfo.RefreshRates())
    {
        Print("Error: Failed to refresh symbol rates for ", TradingSymbol);
        return INIT_FAILED;
    }

    // Auto-ajustar valores se habilitado
    if (AutoAdjustForSymbol)
    {
        AdjustParametersForSymbol();
    }
    else
    {
        adjustedTPPoints = TakeProfitPoints;
        adjustedSLPoints = StopLossPoints;
        adjustedBEPoints = BreakEvenPoints;
        adjustedTrailingPoints = TrailingStopPoints;
        adjustedTrailingStepPoints = TrailingStepPoints;
    }

    Print("=== HttpTrader EA Initialized v4.2 ===");
    Print("Symbol: ", TradingSymbol);
    Print("Point Size: ", symbolInfo.Point());
    Print("Digits: ", symbolInfo.Digits());
    Print("Magic Number: ", MagicNumber);
    Print("Risk Percent: ", RiskPercent, "%");
    Print("Auto-Adjust: ", AutoAdjustForSymbol ? "YES" : "NO");
    Print("--- Trading Mode ---");
    Print("Reverse Trading: ", EnableReverseTrading ? "YES (Signals Inverted!)" : "NO (Normal)");
    if (EnableReverseTrading)
    {
        Print("  → LONG signals will open SELL orders");
        Print("  → SHORT signals will open BUY orders");
    }
    Print("--- Active Values (", AutoAdjustForSymbol ? "AUTO-ADJUSTED" : "MANUAL", ") ---");
    Print("Take Profit: ", adjustedTPPoints, " points (", adjustedTPPoints * symbolInfo.Point(), " price distance)");
    Print("Stop Loss: ", adjustedSLPoints, " points (", adjustedSLPoints * symbolInfo.Point(), " price distance)");
    Print("Signal File: ", SignalFilePath);
    Print("--- Stop Loss Settings ---");
    Print("ATR-Based SL: ", UseATRBasedSL ? "YES (Adaptive)" : "NO (Fixed)");
    if (UseATRBasedSL)
    {
        Print("ATR Period: ", ATRPeriod);
        Print("ATR Multiplier: ", ATRMultiplier, "x");
        Print("Note: SL adapts to volatility at order open");
    }
    Print("--- Breakeven Settings ---");
    Print("Breakeven Enabled: ", EnableBreakeven ? "YES" : "NO");
    if (EnableBreakeven)
    {
        Print("Breakeven Trigger: ", adjustedBEPoints, " points profit");
        Print("Breakeven Extra: +", BreakEvenExtraPoints, " points from entry");
    }
    Print("--- Trailing Stop Settings ---");
    Print("Trailing Stop Enabled: ", EnableTrailingStop ? "YES" : "NO");
    if (EnableTrailingStop)
    {
        Print("Trailing Distance: ", adjustedTrailingPoints, " points");
        Print("Trailing Step: ", adjustedTrailingStepPoints, " points");
    }
    Print("--- Positive Scalping Settings ---");
    Print("Positive Scalping: ", EnablePositiveScalping ? "YES" : "NO");
    if (EnablePositiveScalping)
    {
        Print("  Profit Threshold: ", PositiveProfitSeconds, " seconds");
        Print("  Volume Multiplier: ", ScalpingVolumeMultiplier, "x");
        Print("  Max Levels: ", MaxScalpingLevels);
        Print("  Profit Target: ", ScalpingProfitTarget, " points");
        Print("  Breakeven: ", EnableScalpingBreakeven ? "YES" : "NO");
    }
    Print("--- Hedge Martingale Settings ---");
    Print("Hedge Enabled: ", EnableHedge ? "YES" : "NO");
    if (EnableHedge)
    {
        Print("Profit Target: ", HedgeProfitTarget, " points (total profit to close all)");
        Print("Volume Multiplier: ", HedgeMultiplier, "x (martingale)");
        Print("Max Hedge Levels: ", MaxHedgeLevels);
        Print("Note: When position in loss + opposite signal → opens hedge");
        Print("Note: Closes ALL positions when total profit >= target");
    }
    Print("--- Candle Confirmation Settings ---");
    Print("Candle Confirmation: ", EnableCandleConfirmation ? "YES" : "NO");
    if (EnableCandleConfirmation)
    {
        Print("Candles to Check: ", CandleConfirmationCount);
        Print("Timeframe: ", TimeframeToString(CandleConfirmationTF));
        Print("Mode: ", RequireConsecutiveCandles ? "ALL consecutive" : "MAJORITY (>50%)");
        Print("Wait for Close: ", WaitForCandleClose ? "YES" : "NO");
    }

    // Initialize position tracking
    hasOpenPosition = HasOpenPositionForSymbol();
    if (hasOpenPosition)
    {
        lastKnownTicket = GetCurrentPositionTicket();
        Print("Found existing position: Ticket=", lastKnownTicket);
    }

    // Initialize candle tracking
    lastCheckedCandleTime = iTime(TradingSymbol, CandleConfirmationTF, 0);

    // STARTUP PROTECTION: Record start time and ignore signals for first few seconds
    eaStartTime = TimeCurrent();

    // RECORD INITIALIZATION TIME - used to validate signal timestamps
    eaInitializationTime = TimeCurrent();

    // IMPORTANT: Do NOT read existing signal file to prevent auto-execution on startup
    lastProcessedJson = "";  // Start with empty string, ignore any existing signals
    lastProcessedTime = TimeCurrent();

    Print("=== EA INITIALIZATION ===");
    Print("EA started at: ", TimeToString(eaInitializationTime));
    Print("Existing signal files will be IGNORED");
    Print("Only signals with timestamp > ", TimeToString(eaInitializationTime), " will be processed");

    // Initialize candle close execution variables
    ClearPendingSignals();
    lastCandleCloseTime = 0;
    isProcessingCandleClose = false;

    // Log configuration
    if (OpenOnCandleClose)
    {
        Print("=== CANDLE CLOSE EXECUTION ENABLED ===");
        Print("Timeframe: ", EnumToString(CandleCloseTimeframe));
        Print("Max pending signals: ", MaxPendingSignals);
        Print("Signal expiration: ", PendingSignalExpirationSec, " seconds");
    }
    else
    {
        Print("=== IMMEDIATE EXECUTION MODE ===");
    }

    // Log volume configuration
    if (UseFixedLots)
    {
        Print("=== FIXED LOT SIZE MODE ===");
        Print("Fixed lot size: ", FixedLotSize);
        if (ValidateLotSize)
        {
            Print("Lot validation: ENABLED");
            // Test validation
            double validatedLot = ValidateAndAdjustLotSize(FixedLotSize);
            Print("Validated lot size: ", validatedLot);
        }
        else
        {
            Print("Lot validation: DISABLED");
        }
    }
    else
    {
        Print("=== RISK PERCENTAGE MODE ===");
        Print("Risk percent: ", RiskPercent, "%");
    }

    // Log chart layout configuration
    Print("=== CHART LAYOUT SETTINGS ===");
    Print("Check chart size: ", CheckChartSize ? "YES" : "NO");
    if (CheckChartSize)
    {
        Print("Minimum chart size: ", MinChartWidth, "x", MinChartHeight, " pixels");
    }
    Print("Allow side chart: ", AllowSideChart ? "YES (trading allowed)" : "NO (trading blocked)");

    // Log trend marker configuration
    Print("=== TREND MARKER SETTINGS ===");
    Print("Trend marker enabled: ", TrendMarkerEnabled ? "YES" : "NO");
    if (TrendMarkerEnabled)
    {
        Print("Fast MA period: ", TrendMAPeriodFast);
        Print("Slow MA period: ", TrendMAPeriodSlow);
        string maTypeStr = "";
        switch(TrendMAType)
        {
            case 0: maTypeStr = "SMA"; break;
            case 1: maTypeStr = "EMA"; break;
            case 2: maTypeStr = "SMMA"; break;
            case 3: maTypeStr = "LWMA"; break;
        }
        Print("MA type: ", maTypeStr);
        Print("Show trend strength: ", TrendStrengthDisplay ? "YES" : "NO");
    }

    Print("=== EA Ready - Ignoring signals for ", startupDelaySeconds, " seconds ===");

    // Create info panel if enabled
    if (ShowInfoPanel)
    {
        if (!CreateInfoPanel())
        {
            Print("WARNING: Failed to create info panel");
        }
    }

    // Initialize trend indicators
    if (!InitializeTrendIndicators())
    {
        Print("WARNING: Failed to initialize trend indicators");
    }

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    Print("=== HttpTrader EA Stopped ===");
    Print("Reason: ", reason);

    // Delete info panel
    DeleteInfoPanel();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Update trend information
    UpdateTrendInfo();

    // Gerenciar lucro total do hedge (verifica se atingiu meta)
    if (EnableHedge)
    {
        ManageHedgeProfit();
    }

    // Gerenciar breakeven e trailing stop para posições abertas
    // Nota: Não aplicar em modo hedge (posições sem TP/SL individual)
    if (!isInHedgeMode)
    {
        ManageOpenPositions();
    }

    // Update info panel
    UpdatePanel();
}

//+------------------------------------------------------------------+
//| Timer function for file polling                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
    datetime currentTime = TimeCurrent();

    // STARTUP PROTECTION: Ignore everything during startup delay
    if ((currentTime - eaInitializationTime) < startupDelaySeconds)
    {
        return; // Still in startup protection period
    }

    // CHECK FOR CANDLE CLOSE (if enabled)
    if (OpenOnCandleClose)
    {
        // Verificar se uma nova vela fechou
        if (IsNewCandleClosed(CandleCloseTimeframe))
        {
            // Processar sinais pendentes no fechamento da vela
            ProcessPendingSignals();
        }

        // Verificar e remover sinais expirados periodicamente
        static datetime lastExpirationCheck = 0;
        if ((currentTime - lastExpirationCheck) > 60) // A cada minuto
        {
            RemoveExpiredPendingSignals();
            lastExpirationCheck = currentTime;
        }
    }

    // CHECK CHART SUITABILITY BEFORE PROCESSING SIGNALS
    if (!IsChartSuitable())
    {
        // Chart is not suitable - don't process new signals
        // But continue with other operations (breakeven, trailing, hedge profit management)

        // Only log once per minute to avoid spam
        static datetime lastBlockedLogTime = 0;
        if (currentTime - lastBlockedLogTime > 60)
        {
            int width = GetChartWidth();
            int height = GetChartHeight();

            if (width <= 0 || height <= 0)
            {
                Print("ERROR: Invalid chart dimensions - Width=", width, ", Height=", height);
                return;
            }

            if (!AllowSideChart && IsSideChart())
            {
                Print("BLOCKED: Side chart detected - trading disabled. Width=", width, ", Height=", height);
            }
            else if (CheckChartSize && (width < MinChartWidth || height < MinChartHeight))
            {
                Print("BLOCKED: Chart too small - trading disabled. Width=", width, " (min=", MinChartWidth,
                      "), Height=", height, " (min=", MinChartHeight, ")");
            }

            lastBlockedLogTime = currentTime;
        }

        // Don't process new signals - abort
        return;
    }

    // CHECK RISK LIMITS FIRST
    if (!CheckRiskLimits())
    {
        Print("Risk limits exceeded - aborting trading operations");
        return;
    }

    // CHECK POSITIVE SCALPING (if enabled)
    if (EnablePositiveScalping && hasOpenPosition)
    {
        // Check if we should open a new scalping position
        if (IsPositionProfitable() && HasProfitableDuration(PositiveProfitSeconds))
        {
            // Check if we haven't opened a scalping position recently
            static datetime lastScalpingCheck = 0;
            if (currentTime - lastScalpingCheck >= PositiveProfitSeconds)
            {
                // Check scalping target hasn't been reached
                if (!CheckScalpingTarget())
                {
                    // Check if we're not in hedge mode
                    if (!isInHedgeMode)
                    {
                        // Determine direction from original position
                        string scalpingDir = "";
                        if (positionInfo.SelectByIndex(0))
                        {
                            if (positionInfo.PositionType() == POSITION_TYPE_BUY)
                                scalpingDir = "buy";
                            else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
                                scalpingDir = "sell";
                        }

                        if (scalpingDir != "")
                        {
                            // VALIDAÇÃO 1: Verificar se a conta está总体 lucrativa
                            double totalAccountProfit = AccountInfoDouble(ACCOUNT_PROFIT);
                            if (totalAccountProfit < 0)
                            {
                                Print("=== SCALPING BLOQUEADO ===");
                                Print("Motivo: Conta com lucro NEGATIVO: $", totalAccountProfit);
                                Print("Positive Scalping só abre quando conta está positiva");
                                lastScalpingCheck = currentTime;  // Evitar checks频繁
                            }
                            // VALIDAÇÃO 2: Verificar se velas confirmam a tendência
                            else if (!IsTrendConfirmedByCandles(scalpingDir))
                            {
                                Print("=== SCALPING BLOQUEADO ===");
                                Print("Motivo: Velas NÃO confirmam direção ", scalpingDir);
                                Print("Positive Scalping requer ", CandleConfirmationCount, " velas ",
                                      (scalpingDir == "buy" ? "verdes/altistas" : "vermelhas/baixistas"));
                                lastScalpingCheck = currentTime;  // Evitar checks频繁
                            }
                            else
                            {
                                // Todas validações passaram - prosseguir com scalping
                                Print("=== POSITIVE SCALPING CHECK ===");
                                Print("Conta POSITIVA: $", totalAccountProfit, " ✓");
                                Print("Velas confirmam ", scalpingDir, " ✓");
                                Print("Position profitable for ", PositiveProfitSeconds, " seconds");
                                Print("Current profit: ", GetTotalScalpingProfit(), " points");
                                Print("Target: ", ScalpingProfitTarget, " points");
                                Print("Current level: ", currentScalpingLevel, "/", MaxScalpingLevels);

                                // Open new scalping position
                                if (OpenScalpingPosition(scalpingDir))
                                {
                                    lastScalpingCheck = currentTime;
                                }
                            }
                        }
                    }
                }
                else
                {
                    // Target reached - close all positions
                    Print("=== POSITIVE SCALPING TARGET REACHED ===");
                    Print("Total profit: ", GetTotalScalpingProfit(), " points (Target: ", ScalpingProfitTarget, ")");
                    Print("Closing ALL positions...");

                    bool closeResult = CloseAllPositions();
                    if (closeResult)
                    {
                        Print("=== POSITIVE SCALPING SUCCESS ===");
                        Print("All positions closed with ", GetTotalScalpingProfit(), " points profit");
                        ResetScalpingState();
                    }
                    else
                    {
                        Print("!!! ERROR: Failed to close all positions in Positive Scalping !!!");
                    }
                }
            }
        }

        // Apply breakeven to scalping positions if enabled
        if (EnableScalpingBreakeven)
        {
            ApplyScalpingBreakeven();
        }
    }

    // Ler arquivo JSON
    string json = ReadSignalFile();

    // Evitar reprocessamento (mesmo conteúdo)
    if (json == lastProcessedJson) {
        // No new signal - nothing to do
        return;
    }

    if (json != "" && json != lastProcessedJson) {
        // Extrair símbolo do sinal
        signalSymbol = ExtractSymbolFromJSON(json);
        signalHasSymbol = (signalSymbol != "");

        // Verificar se o sinal é para este EA
        if (!IsSignalForThisSymbol())
        {
            LogIgnoredSignal();
            return;
        }

        // Extrair direction e symbol do sinal
        currentSignalDirection = ExtractDirectionFromJSON(json);
        currentSignalSymbol = signalSymbol;  // Já extraído acima

        // Validar timestamp do sinal (se existir)
        if (!IsSignalRecent(json))
        {
            Print("Signal ignored - timestamp validation failed");
            return;
        }

        // Validação simplificada (sinais sem timestamp)
        Print("NEW Signal received: ", json);
        Print("Processing signal: direction=", currentSignalDirection, " symbol=", currentSignalSymbol);

        // Verificar se deve executar imediatamente ou aguardar fechamento
        if (OpenOnCandleClose)
        {
            // Adicionar à fila para execução no fechamento da vela
            QueuePendingSignal(json);
        }
        else
        {
            // Execução imediata (comportamento padrão)
            ProcessTradeSignal(json, false);  // Não forçar fechamento de posições existentes
        }

        lastProcessedJson = json;
        lastProcessedTime = currentTime;
    }
}

//+------------------------------------------------------------------+
//| Read signal from JSON file                                       |
//+------------------------------------------------------------------+
string ReadSignalFile()
{
    int fileHandle = FileOpen(SignalFilePath, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);

    if (fileHandle == INVALID_HANDLE)
    {
        // Arquivo não existe ainda - normal no início
        return "";
    }

    string content = "";
    while (!FileIsEnding(fileHandle))
    {
        content += FileReadString(fileHandle);
    }

    FileClose(fileHandle);
    return content;
}

//+------------------------------------------------------------------+
//| Extract symbol from JSON signal                                   |
//+------------------------------------------------------------------+
string ExtractSymbolFromJSON(string json)
{
    // Procurar pelo campo "symbol" no JSON
    string symbolKey = "\"symbol\":";
    int keyPos = StringFind(json, symbolKey);

    if (keyPos == -1)
    {
        // Campo 'symbol' não encontrado - sinal antigo (backward compatibility)
        return "";
    }

    // Extrair valor após "symbol":
    int valueStart = keyPos + StringLen(symbolKey);

    // Pular espaços em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Verificar se é string (entre aspas)
    if (StringGetCharacter(json, valueStart) != '"')
    {
        Print("WARNING: Symbol field is not a string in signal JSON");
        return "";
    }

    valueStart++;  // Pular aspa inicial

    // Encontrar aspa final
    int valueEnd = valueStart;
    while (valueEnd < StringLen(json) &&
           StringGetCharacter(json, valueEnd) != '"' &&
           StringGetCharacter(json, valueEnd) != '}' &&
           StringGetCharacter(json, valueEnd) != ',')
    {
        valueEnd++;
    }

    // Extrair o símbolo
    string symbol = StringSubstr(json, valueStart, valueEnd - valueStart);

    Print("Signal symbol extracted: ", symbol);
    return symbol;
}

//+------------------------------------------------------------------+
//| Extract direction from JSON signal                               |
//+------------------------------------------------------------------+
string ExtractDirectionFromJSON(string json)
{
    // Procurar pelo campo "direction" no JSON
    string directionKey = "\"direction\":";
    int keyPos = StringFind(json, directionKey);

    if (keyPos == -1)
    {
        // Procurar campo "action" legado
        string actionKey = "\"action\":";
        keyPos = StringFind(json, actionKey);

        if (keyPos == -1)
        {
            // Campo não encontrado - sinal antigo
            return "unknown";
        }

        // Extrair valor do action
        int valueStart = keyPos + StringLen(actionKey);

        // Pular espaços em branco
        while (valueStart < StringLen(json) &&
               (StringGetCharacter(json, valueStart) == ' ' ||
                StringGetCharacter(json, valueStart) == '\t'))
        {
            valueStart++;
        }

        // Extrair valor
        int valueEnd = valueStart;
        while (valueEnd < StringLen(json) &&
               StringGetCharacter(json, valueEnd) != '"' &&
               StringGetCharacter(json, valueEnd) != '}' &&
               StringGetCharacter(json, valueEnd) != ',')
        {
            valueEnd++;
        }

        string action = StringSubstr(json, valueStart, valueEnd - valueStart);

        // Traduzir long/short para buy/sell
        if (action == "long")
            return "buy";
        else if (action == "short")
            return "sell";
        else
            return "unknown";
    }

    // Extrair valor após "direction":
    int valueStart = keyPos + StringLen(directionKey);

    // Pular espaços em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Verificar se é string (entre aspas)
    if (StringGetCharacter(json, valueStart) != '"')
    {
        Print("WARNING: Direction field is not a string in signal JSON");
        return "unknown";
    }

    valueStart++;  // Pular aspa inicial

    // Encontrar aspa final
    int valueEnd = valueStart;
    while (valueEnd < StringLen(json) &&
           StringGetCharacter(json, valueEnd) != '"' &&
           StringGetCharacter(json, valueEnd) != '}' &&
           StringGetCharacter(json, valueEnd) != ',')
    {
        valueEnd++;
    }

    // Extrair a direção
    string direction = StringSubstr(json, valueStart, valueEnd - valueStart);

    Print("Signal direction extracted: ", direction);
    return direction;
}

//+------------------------------------------------------------------+
//| Check if signal is intended for this EA                           |
//+------------------------------------------------------------------+
bool IsSignalForThisSymbol()
{
    // Se tem 'symbol', comparar com o configurado
    if (signalHasSymbol)
    {
        int result = StringCompare(signalSymbol, TradingSymbol);

        if (result == 0)
        {
            // Símbolo corresponde - processar o sinal
            Print("Signal symbol '", signalSymbol, "' matches EA symbol '", TradingSymbol, "' - processing signal");
            return true;
        }
        else
        {
            // Símbolo não corresponde - ignorar
            Print("Signal symbol '", signalSymbol, "' does NOT match EA symbol '", TradingSymbol, "' - ignoring signal");
            return false;
        }
    }

    // Para sinais antigos sem 'symbol', verificar se o arquivo de sinal é específico
    // Verificar se o nome do arquivo contém o símbolo
    string fileName = SignalFilePath;
    int symbolPos = StringFind(fileName, TradingSymbol);

    if (symbolPos != -1)
    {
        // Arquivo contém o símbolo - provavelmente é para este EA
        Print("Signal file contains '", TradingSymbol, "' - processing for backward compatibility");
        return true;
    }

    // Verificar se há arquivos separados para cada símbolo
    string symbolFile = StringSubstr(fileName, 0, StringLen(fileName) - 5); // Remover .json
    symbolFile += "_" + TradingSymbol + ".json";

    // Verificar se o arquivo específico existe
    int fileHandle = FileOpen(symbolFile, FILE_READ | FILE_TXT);
    if (fileHandle != INVALID_HANDLE)
    {
        FileClose(fileHandle);
        // Arquivo específico existe - usar em vez do genérico
        string SignalFilePath_local = symbolFile;
        Print("Using specific signal file: ", symbolFile);
        return true;
    }

    // Nenhuma indicação do símbolo - processar para manter compatibilidade
    Print("Signal has no symbol indication - processing for backward compatibility");
    return true;
}

//+------------------------------------------------------------------+
//| Log ignored signal details                                         |
//+------------------------------------------------------------------+
void LogIgnoredSignal()
{
    // Extrair direção do sinal para logging
    string direction = "unknown";
    string directionKey = "\"direction\":";
    int dirPos = StringFind(lastProcessedJson, directionKey);

    if (dirPos != -1)
    {
        int dirStart = dirPos + StringLen(directionKey);
        // Pular espaços e aspas
        while (dirStart < StringLen(lastProcessedJson) &&
               (StringGetCharacter(lastProcessedJson, dirStart) == ' ' ||
                StringGetCharacter(lastProcessedJson, dirStart) == '\t' ||
                StringGetCharacter(lastProcessedJson, dirStart) == '"'))
        {
            dirStart++;
        }

        int dirEnd = dirStart;
        while (dirEnd < StringLen(lastProcessedJson) &&
               StringGetCharacter(lastProcessedJson, dirEnd) != '"' &&
               StringGetCharacter(lastProcessedJson, dirEnd) != '}' &&
               StringGetCharacter(lastProcessedJson, dirEnd) != ',')
        {
            dirEnd++;
        }

        direction = StringSubstr(lastProcessedJson, dirStart, dirEnd - dirStart);
    }

    // Log detalhado do sinal ignorado
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    Print("=================================================");
    Print(timestamp, " - SIGNAL IGNORED - SYMBOL MISMATCH");
    Print("Expected symbol: ", TradingSymbol);
    Print("Received symbol: ", signalHasSymbol ? signalSymbol : "none (signal has no symbol field)");
    Print("Signal direction: ", direction);
    Print("Signal JSON: ", lastProcessedJson);
    Print("Reason: This EA is configured for ", TradingSymbol, " only");
    Print("=================================================");
}

//+------------------------------------------------------------------+
//| Extract timestamp from JSON signal                                |
//+------------------------------------------------------------------+
datetime ExtractTimestampFromJSON(string json)
{
    // Procurar pelo campo "timestamp" no JSON
    string timestampKey = "\"timestamp\":";
    int keyPos = StringFind(json, timestampKey);

    if (keyPos == -1)
    {
        // Se não encontrar timestamp, usar timestamp atual (para compatibilidade)
        Print("WARNING: No timestamp field found in signal JSON - using current time");
        return TimeCurrent();
    }

    // Extrair valor após "timestamp":
    int valueStart = keyPos + StringLen(timestampKey);

    // Pular espaços em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Encontrar fim do valor (vírgula ou fim do objeto)
    int valueEnd = valueStart;
    while (valueEnd < StringLen(json) &&
           StringGetCharacter(json, valueEnd) != ',' &&
           StringGetCharacter(json, valueEnd) != '}')
    {
        valueEnd++;
    }

    // Extrair substring com o valor
    string timestampStr = StringSubstr(json, valueStart, valueEnd - valueStart);

    // Remover aspas se existirem
    if (StringGetCharacter(timestampStr, 0) == '"' &&
        StringGetCharacter(timestampStr, StringLen(timestampStr) - 1) == '"')
    {
        timestampStr = StringSubstr(timestampStr, 1, StringLen(timestampStr) - 2);
    }

    Print("DEBUG: Extracted timestamp string: ", timestampStr);

    // Tentar converter como Unix timestamp (segundos)
    long timestamp = StringToInteger(timestampStr);
    if (timestamp > 1000000000) // Timestamp válido (aprox 2001+)
    {
        Print("DEBUG: Parsed as Unix timestamp: ", timestamp, " -> ", TimeToString((datetime)timestamp));
        return (datetime)timestamp;
    }

    // Se for muito grande, pode estar em milissegundos
    if (timestamp > 1000000000000) // Provável milissegundos
    {
        timestamp = timestamp / 1000; // Converter para segundos
        Print("DEBUG: Converted from milliseconds: ", timestamp, " -> ", TimeToString((datetime)timestamp));
        return (datetime)timestamp;
    }

    // Tentar parse ISO format
    // Remover microseconds e timezone se existirem
    StringReplace(timestampStr, ".", ""); // Remove microsegundos
    StringReplace(timestampStr, "T", " "); // Converte T para espaço
    StringReplace(timestampStr, "Z", ""); // Remove Z se existir

    // Se tiver timezone (ex: +03:00), remover
    int plusPos = StringFind(timestampStr, "+");
    if (plusPos > 0)
    {
        timestampStr = StringSubstr(timestampStr, 0, plusPos);
    }

    datetime isoResult = StringToTime(timestampStr);
    if (isoResult > 0)
    {
        Print("DEBUG: Parsed as ISO format: ", isoResult, " -> ", TimeToString(isoResult));
        return isoResult;
    }

    // Se tudo falhar, usar timestamp atual com aviso
    Print("WARNING: Could not parse timestamp '", timestampStr, "' - using current time");
    return TimeCurrent();
}

//+------------------------------------------------------------------+
//| Chart layout detection functions                                |
//+------------------------------------------------------------------+
//| Check if chart is in side mode (vertical orientation)           |
//+------------------------------------------------------------------+
bool IsSideChart()
{
    // Get chart dimensions
    int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    // Chart is considered side chart if width is much smaller than height
    // Side chart typically has width < 60% of height
    return (width < height * 0.6);
}

//+------------------------------------------------------------------+
//| Get current chart width in pixels                                |
//+------------------------------------------------------------------+
int GetChartWidth()
{
    return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
}

//+------------------------------------------------------------------+
//| Get current chart height in pixels                               |
//+------------------------------------------------------------------+
int GetChartHeight()
{
    return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
}

//+------------------------------------------------------------------+
//| Check if chart is suitable for trading                           |
//+------------------------------------------------------------------+
bool IsChartSuitable()
{
    // Check side chart restriction
    if (!AllowSideChart && IsSideChart())
    {
        return false;
    }

    // Check size restrictions if enabled
    if (CheckChartSize)
    {
        int width = GetChartWidth();
        int height = GetChartHeight();

        if (width <= 0 || height <= 0)
        {
            Print("ERROR: Invalid chart dimensions in IsChartSuitable - Width=", width, ", Height=", height);
            return false;
        }

        if (width < MinChartWidth || height < MinChartHeight)
        {
            return false;
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Trend Marker Functions                                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Initialize trend indicators                                      |
//+------------------------------------------------------------------+
bool InitializeTrendIndicators()
{
    if (!TrendMarkerEnabled)
        return true;

    // Create fast MA handle
    trendMAFastHandle = iMA(TradingSymbol, PERIOD_CURRENT, TrendMAPeriodFast, 0,
                           (ENUM_MA_METHOD)TrendMAType, PRICE_CLOSE);
    if (trendMAFastHandle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create fast MA indicator");
        return false;
    }

    // Create slow MA handle
    trendMASlowHandle = iMA(TradingSymbol, PERIOD_CURRENT, TrendMAPeriodSlow, 0,
                           (ENUM_MA_METHOD)TrendMAType, PRICE_CLOSE);
    if (trendMASlowHandle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create slow MA indicator");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Calculate current trend direction                                |
//+------------------------------------------------------------------+
string CalculateTrend()
{
    if (!TrendMarkerEnabled || trendMAFastHandle == INVALID_HANDLE ||
        trendMASlowHandle == INVALID_HANDLE)
    {
        return "NEUTRAL";
    }

    double fastMA[2], slowMA[2];

    // Get current and previous MA values
    if (CopyBuffer(trendMAFastHandle, 0, 0, 2, fastMA) < 2 ||
        CopyBuffer(trendMASlowHandle, 0, 0, 2, slowMA) < 2)
    {
        return "NEUTRAL";
    }

    // Calculate trend value (difference between MAs)
    currentTrendValue = fastMA[0] - slowMA[0];

    // Determine trend direction
    double point = SymbolInfoDouble(TradingSymbol, SYMBOL_POINT);
    double pipDiff = currentTrendValue / point;

    if (pipDiff > 1)
        return "UP";
    else if (pipDiff < -1)
        return "DOWN";
    else
        return "NEUTRAL";
}

//+------------------------------------------------------------------+
//| Get trend strength based on MA separation                        |
//+------------------------------------------------------------------+
string GetTrendStrength()
{
    if (!TrendMarkerEnabled || currentTrendValue == 0)
        return "WEAK";

    double fastMA[2], slowMA[2];

    if (CopyBuffer(trendMAFastHandle, 0, 0, 1, fastMA) < 1 ||
        CopyBuffer(trendMASlowHandle, 0, 0, 1, slowMA) < 1)
    {
        return "WEAK";
    }

    // Calculate percentage difference
    double separation = MathAbs(currentTrendValue);
    double percentage = (separation / slowMA[0]) * 100;

    if (percentage > 2.0)
        return "STRONG";
    else if (percentage > 0.5)
        return "MODERATE";
    else
        return "WEAK";
}

//+------------------------------------------------------------------+
//| Get trend arrow symbol                                           |
//+------------------------------------------------------------------+
string GetTrendArrow(string direction)
{
    if (direction == "UP")
        return "↑";
    else if (direction == "DOWN")
        return "↓";
    else
        return "→";
}

//+------------------------------------------------------------------+
//| Get trend color based on direction - Modern Colors                |
//+------------------------------------------------------------------+
color GetTrendColor(string direction)
{
    color colorGreen = (color)0xA3BE8C;         // Muted green
    color colorRed = (color)0xBF616A;           // Soft red
    color textDimColor = (color)0x4C566A;       // Dim gray

    if (direction == "UP")
        return colorGreen;
    else if (direction == "DOWN")
        return colorRed;
    else
        return textDimColor;
}

//+------------------------------------------------------------------+
//| Update trend information                                         |
//+------------------------------------------------------------------+
void UpdateTrendInfo()
{
    if (!TrendMarkerEnabled)
        return;

    // Calculate new trend
    string newDirection = CalculateTrend();
    string newStrength = GetTrendStrength();

    // Log trend changes
    if (newDirection != currentTrendDirection)
    {
        Print("TREND CHANGED: ", currentTrendDirection, " → ", newDirection);
        currentTrendDirection = newDirection;
    }

    currentTrendStrength = newStrength;
}

//+------------------------------------------------------------------+
//| Get corrected time considering timezone/DST issues                |
//+------------------------------------------------------------------+
datetime GetCorrectedTime()
{
    // Simplified version - use TimeLocal() which should be accurate
    return TimeLocal();
}

//+------------------------------------------------------------------+
//| Check if signal is recent (after EA initialization)              |
//+------------------------------------------------------------------+
bool IsSignalRecent(string json)
{
    if (json == "" || json == lastProcessedJson)
    {
        return false; // Sinal vazio ou já processado
    }

    datetime signalTime = ExtractTimestampFromJSON(json);

    if (signalTime == 0)
    {
        Print("WARNING: Signal without valid timestamp - ignoring");
        return false;
    }

    // REMOVIDO: Validacao de timestamp antigo - o EA ja protege contra reprocessamento
    // via lastProcessedJson, entao podemos aceitar sinais mesmo se forem criados antes
    // da inicializacao do EA (ex: sinais que ficaram no arquivo apos reinicio do MT5)

    return true;
}

//+------------------------------------------------------------------+
//| Queue a signal for execution at candle close                     |
//+------------------------------------------------------------------+
void QueuePendingSignal(string signalJson)
{
    // Verificar se já temos um sinal igual na fila
    for (int i = 0; i < pendingSignalsCount; i++)
    {
        if (pendingSignals[i] == signalJson)
        {
            Print("Signal already queued - ignoring duplicate");
            return;
        }
    }

    // Remover sinais expirados
    RemoveExpiredPendingSignals();

    // Se atingiu o limite máximo, remover o mais antigo
    if (pendingSignalsCount >= MaxPendingSignals)
    {
        Print("Max pending signals reached - removing oldest");
        // Mover todos para frente
        for (int i = 0; i < pendingSignalsCount - 1; i++)
        {
            pendingSignals[i] = pendingSignals[i + 1];
            pendingSignalTimes[i] = pendingSignalTimes[i + 1];
        }
        pendingSignalsCount--;
    }

    // Adicionar novo sinal no fim da fila (com verificação de limite)
    if (pendingSignalsCount < 10)
    {
        pendingSignals[pendingSignalsCount] = signalJson;
        pendingSignalTimes[pendingSignalsCount] = TimeCurrent();
        pendingSignalsCount++;

        Print("Signal queued for candle close execution (#", pendingSignalsCount, ")");
        Print("Queued signal: ", signalJson);
    }
    else
    {
        Print("ERROR: Pending signals queue full - cannot add more signals");
    }
}

//+------------------------------------------------------------------+
//| Get the oldest pending signal (for execution)                    |
//+------------------------------------------------------------------+
string GetOldestPendingSignal()
{
    if (pendingSignalsCount == 0)
    {
        return "";
    }

    // Retornar o primeiro sinal da fila (o mais antigo)
    return pendingSignals[0];
}

//+------------------------------------------------------------------+
//| Remove all pending signals                                        |
//+------------------------------------------------------------------+
void ClearPendingSignals()
{
    pendingSignalsCount = 0;
    for (int i = 0; i < 10; i++)
    {
        pendingSignals[i] = "";
        pendingSignalTimes[i] = 0;
    }
    Print("All pending signals cleared");
}

//+------------------------------------------------------------------+
//| Remove expired pending signals                                   |
//+------------------------------------------------------------------+
void RemoveExpiredPendingSignals()
{
    datetime currentTime = TimeCurrent();
    int removed = 0;

    for (int i = 0; i < pendingSignalsCount; i++)
    {
        if ((currentTime - pendingSignalTimes[i]) > PendingSignalExpirationSec)
        {
            // Marcar para remoção
            pendingSignals[i] = "";
            pendingSignalTimes[i] = 0;
            removed++;
        }
    }

    if (removed > 0)
    {
        Print("Removed ", removed, " expired pending signals");
        // Compactar a fila
        CompactPendingSignals();
    }
}

//+------------------------------------------------------------------+
//| Compact pending signals array (remove empty slots)               |
//+------------------------------------------------------------------+
void CompactPendingSignals()
{
    int newIndex = 0;

    for (int i = 0; i < pendingSignalsCount; i++)
    {
        if (pendingSignals[i] != "")
        {
            // Mover para nova posição
            if (newIndex != i)
            {
                pendingSignals[newIndex] = pendingSignals[i];
                pendingSignalTimes[newIndex] = pendingSignalTimes[i];
            }
            newIndex++;
        }
    }

    // Limpar posições restantes
    for (int i = newIndex; i < pendingSignalsCount; i++)
    {
        pendingSignals[i] = "";
        pendingSignalTimes[i] = 0;
    }

    pendingSignalsCount = newIndex;
}

//+------------------------------------------------------------------+
//| Check if a new candle has just closed                            |
//+------------------------------------------------------------------+
bool IsNewCandleClosed(ENUM_TIMEFRAMES timeframe)
{
    datetime currentCandleTime = iTime(TradingSymbol, timeframe, 0);

    // Se é a primeira vez que checamos
    if (lastCandleCloseTime == 0)
    {
        lastCandleCloseTime = currentCandleTime;
        return false; // Não consideramos como "fechamento" na primeira vez
    }

    // Se o tempo da vela atual é diferente do último registrado,
    // significa que uma nova vela começou (a anterior fechou)
    if (currentCandleTime != lastCandleCloseTime)
    {
        // Atualizar o tempo registrado
        datetime oldTime = lastCandleCloseTime;
        lastCandleCloseTime = currentCandleTime;

        Print("New candle detected on ", EnumToString(timeframe));
        Print("Previous candle: ", TimeToString(oldTime));
        Print("Current candle: ", TimeToString(currentCandleTime));

        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Get current candle time                                           |
//+------------------------------------------------------------------+
datetime GetCurrentCandleTime(ENUM_TIMEFRAMES timeframe)
{
    return iTime(TradingSymbol, timeframe, 0);
}

//+------------------------------------------------------------------+
//| Process pending signals when candle closes                       |
//+------------------------------------------------------------------+
void ProcessPendingSignals()
{
    if (pendingSignalsCount == 0)
    {
        return; // No signals to process
    }

    // Verificar se já está processando para evitar duplicatas
    if (isProcessingCandleClose)
    {
        return;
    }

    isProcessingCandleClose = true;

    // Pegar o sinal mais recente (último da fila)
    if (pendingSignalsCount <= 0 || pendingSignalsCount > 10)
    {
        Print("ERROR: Invalid pending signals count: ", pendingSignalsCount);
        isProcessingCandleClose = false;
        return;
    }

    string signalToExecute = pendingSignals[pendingSignalsCount - 1];

    Print("=== EXECUTING PENDING SIGNAL AT CANDLE CLOSE ===");
    Print("Pending signals count: ", pendingSignalsCount);
    Print("Executing signal: ", signalToExecute);

    // Executar o sinal
    ProcessTradeSignal(signalToExecute, true);

    // Limpar todos os sinais pendentes após execução
    ClearPendingSignals();

    // Resetar flag de processamento
    isProcessingCandleClose = false;
}

//+------------------------------------------------------------------+
bool CloseAllPositions()
{
    int maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++)
    {
        bool allClosed = true;

        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            if (positionInfo.SelectByIndex(i))
            {
                if (positionInfo.Symbol() == TradingSymbol &&
                    positionInfo.Magic() == MagicNumber)
                {
                    if (!trade.PositionClose(positionInfo.Ticket()))
                    {
                        Print("Failed to close position: ", positionInfo.Ticket());
                        allClosed = false;
                    }
                    else
                    {
                        Print("Closed position: ", positionInfo.Ticket());
                    }
                }
            }
        }

        if (allClosed) return true;

        Print("Retry closing positions, attempt ", attempt + 1);
        Sleep(500);
    }

    Print("ERROR: Failed to close all positions after ", maxRetries, " attempts");
    return false;
}

//+------------------------------------------------------------------+
//| Positive Scalping Functions                                      |
//+------------------------------------------------------------------+

// Check if current position is profitable
bool IsPositionProfitable()
{
    if (!positionInfo.SelectByIndex(0))
        return false;

    if (positionInfo.Symbol() != TradingSymbol || positionInfo.Magic() != MagicNumber)
        return false;

    double currentProfit = positionInfo.Profit() + positionInfo.Commission() + positionInfo.Swap();
    double profitPoints = currentProfit / symbolInfo.Point();

    return profitPoints > 0;
}

// Check if position has been profitable for the required duration
bool HasProfitableDuration(int requiredSeconds)
{
    if (!IsPositionProfitable())
        return false;

    datetime currentTime = TimeCurrent();
    long elapsedLong = currentTime - positionInfo.Time();
    double elapsedSeconds = (double)elapsedLong;

    return elapsedSeconds >= requiredSeconds;
}

// Calculate total profit from all positions (including scalping)
double GetTotalScalpingProfit()
{
    double totalProfit = 0;
    int positionCount = PositionsTotal();

    for (int i = 0; i < positionCount; i++)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol && positionInfo.Magic() == MagicNumber)
            {
                double positionProfit = positionInfo.Profit() + positionInfo.Commission() + positionInfo.Swap();
                totalProfit += positionProfit;
            }
        }
    }

    // Convert to points
    return totalProfit / symbolInfo.Point();
}

// Check if scalping target has been reached
bool CheckScalpingTarget()
{
    double currentProfit = GetTotalScalpingProfit();
    return currentProfit >= ScalpingProfitTarget;
}

// Open a new scalping position
bool OpenScalpingPosition(string direction)
{
    if (currentScalpingLevel >= MaxScalpingLevels)
    {
        Print("Max scalping levels reached (", currentScalpingLevel, "/", MaxScalpingLevels, ")");
        return false;
    }

    // Check if total equity loss exceeds safe limits
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    if (currentEquity < (initialEquity * 0.95))  // 5% loss limit
    {
        Print("!!! EQUITY PROTECTION !!!");
        Print("Current equity below 95% of initial - stopping scalping");
        Print("Initial: ", DoubleToString(initialEquity, 2));
        Print("Current: ", DoubleToString(currentEquity, 2));
        return false;
    }

    // Calculate new volume
    double newVolume = lastScalpingVolume * ScalpingVolumeMultiplier;
    if (lastScalpingVolume == 0)
    {
        // First scalping position - use same volume as original
        newVolume = CalculateVolume();
    }

    // Validate lot size
    double minLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MAX);
    if (newVolume < minLot || newVolume > maxLot)
    {
        Print("Invalid lot size for scalping: ", newVolume, " (Range: ", minLot, "-", maxLot, ")");
        return false;
    }

    double sl = 0, tp = 0;
    double currentPrice = symbolInfo.Ask();

    if (direction == "buy")
    {
        // Buy order
        if (UseATRBasedSL)
        {
            sl = currentPrice - (GetATRValue() * ATRMultiplier);
            tp = currentPrice + adjustedTPPoints * symbolInfo.Point();
        }
        else
        {
            sl = currentPrice - adjustedSLPoints * symbolInfo.Point();
            tp = currentPrice + adjustedTPPoints * symbolInfo.Point();
        }

        string orderComment = direction + ":" + TradingSymbol + "scalping";

        if (trade.Buy(newVolume, TradingSymbol, 0, sl, tp, orderComment))
        {
            lastScalpingVolume = newVolume;
            currentScalpingLevel++;
            scalpingDirection = "buy";
            lastPositiveCheckTime = TimeCurrent();

            Print("=== POSITIVE SCALPING TRIGGERED ===");
            Print("Opening scalping position #", currentScalpingLevel);
            Print("Volume: ", newVolume, " (", ScalpingVolumeMultiplier, "x previous)");
            Print("Total positions: ", currentScalpingLevel + 1); // +1 for original
            Print("Order Comment: '", orderComment, "'");

            return true;
        }
    }
    else if (direction == "sell")
    {
        // Sell order
        currentPrice = symbolInfo.Bid();

        if (UseATRBasedSL)
        {
            sl = currentPrice + (GetATRValue() * ATRMultiplier);
            tp = currentPrice - adjustedTPPoints * symbolInfo.Point();
        }
        else
        {
            sl = currentPrice + adjustedSLPoints * symbolInfo.Point();
            tp = currentPrice - adjustedTPPoints * symbolInfo.Point();
        }

        string orderComment = direction + ":" + TradingSymbol + "scalping";

        if (trade.Sell(newVolume, TradingSymbol, 0, sl, tp, orderComment))
        {
            lastScalpingVolume = newVolume;
            currentScalpingLevel++;
            scalpingDirection = "sell";
            lastPositiveCheckTime = TimeCurrent();

            Print("=== POSITIVE SCALPING TRIGGERED ===");
            Print("Opening scalping position #", currentScalpingLevel);
            Print("Volume: ", newVolume, " (", ScalpingVolumeMultiplier, "x previous)");
            Print("Total positions: ", currentScalpingLevel + 1); // +1 for original
            Print("Order Comment: '", orderComment, "'");

            return true;
        }
    }

    Print("ERROR: Failed to open scalping position");
    return false;
}

// Reset scalping state
void ResetScalpingState()
{
    currentScalpingLevel = 0;
    isInPositiveScalping = false;
    lastScalpingVolume = 0;
    lastPositiveCheckTime = 0;
    totalScalpingProfit = 0;
    scalpingDirection = "";

    if (currentScalpingLevel > 0)
    {
        Print("=== POSITIVE SCALPING RESET ===");
        Print("Scalping state cleared");
    }
}

// Apply breakeven to scalping positions (DISABLED)
void ApplyScalpingBreakeven()
{
    // Breakeven disabled to avoid compilation errors
    // Will be fixed later
    Print("Scalping breakeven disabled");
}

//+------------------------------------------------------------------+
//| Get SL price based on recent candles                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Get ATR value for SL calculation                                 |
//+------------------------------------------------------------------+
double GetATRValue()
{
    int atrHandle = iATR(TradingSymbol, PERIOD_CURRENT, ATRPeriod);

    if (atrHandle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create ATR indicator handle");
        return 0;
    }

    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);

    if (CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0)
    {
        Print("ERROR: Failed to copy ATR buffer");
        IndicatorRelease(atrHandle);
        return 0;
    }

    double atrValue = atrBuffer[0];
    IndicatorRelease(atrHandle);

    return atrValue;
}

//+------------------------------------------------------------------+
//| Validate and adjust lot size to broker limits                     |
//+------------------------------------------------------------------+
double ValidateAndAdjustLotSize(double lotSize)
{
    if (!ValidateLotSize)
    {
        return lotSize; // Skip validation if disabled
    }

    double minLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MAX);
    double stepLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_STEP);

    Print("=== LOT SIZE VALIDATION ===");
    Print("Requested lot: ", lotSize);
    Print("Broker limits - Min: ", minLot, ", Max: ", maxLot, ", Step: ", stepLot);

    // Adjust for minimum lot
    if (lotSize < minLot)
    {
        Print("WARNING: Lot size below minimum - adjusting from ", lotSize, " to ", minLot);
        lotSize = minLot;
    }

    // Adjust for maximum lot
    if (lotSize > maxLot)
    {
        Print("WARNING: Lot size above maximum - adjusting from ", lotSize, " to ", maxLot);
        lotSize = maxLot;
    }

    // Adjust for step size
    if (stepLot > 0)
    {
        double steps = MathFloor(lotSize / stepLot);
        double adjustedLot = steps * stepLot;

        // Ensure we don't go below minimum
        if (adjustedLot < minLot)
        {
            adjustedLot = minLot;
        }

        if (adjustedLot != lotSize)
        {
            Print("INFO: Adjusted lot size to match step - from ", lotSize, " to ", adjustedLot);
            lotSize = adjustedLot;
        }
    }

    Print("Final lot size: ", lotSize);
    return lotSize;
}

//+------------------------------------------------------------------+
//| Function to calculate volume based on risk percentage            |
//+------------------------------------------------------------------+
double CalculateVolume()
{
    double volume;

    // Check if using fixed lots
    if (UseFixedLots)
    {
        Print("=== USING FIXED LOT SIZE ===");
        volume = FixedLotSize;
        Print("Fixed lot size requested: ", volume);
    }
    else
    {
        Print("=== CALCULATING VOLUME BASED ON RISK PERCENTAGE ===");
        double equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double riskAmount = equity * (RiskPercent / 100.0);

        double tickValue = SymbolInfoDouble(TradingSymbol, SYMBOL_TRADE_TICK_VALUE);
        double point = SymbolInfoDouble(TradingSymbol, SYMBOL_POINT);

        // Volume = Risk / (SL em pontos * point * tick value / point)
        double slDistance = adjustedSLPoints * point;
        volume = riskAmount / (slDistance * tickValue / point);

        Print("Volume calculation: Equity=", equity, " Risk=", riskAmount, "%=", RiskPercent);
        Print("Initial calculated volume: ", volume);
    }

    // Validate and adjust lot size
    volume = ValidateAndAdjustLotSize(volume);

    return volume;
}

//+------------------------------------------------------------------+
//| Get direction of open positions (for hedge)                      |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE GetOpenPositionDirection()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                return positionInfo.PositionType();
            }
        }
    }
    return (ENUM_POSITION_TYPE)-1; // Nenhuma posição
}

//+------------------------------------------------------------------+
//| Check if any open position is in loss                            |
//+------------------------------------------------------------------+
bool IsAnyPositionInLoss()
{
    double totalProfit = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                totalProfit += positionInfo.Profit();
            }
        }
    }

    return (totalProfit < 0);
}

//+------------------------------------------------------------------+
//| Get total profit in points of all open positions                 |
//+------------------------------------------------------------------+
double GetTotalOpenProfitInPoints()
{
    double totalProfitPoints = 0;
    double point = symbolInfo.Point();

    symbolInfo.RefreshRates();

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                double openPrice = positionInfo.PriceOpen();
                double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY)
                                      ? symbolInfo.Bid()
                                      : symbolInfo.Ask();
                double volume = positionInfo.Volume();

                double profitPoints = 0;
                if (positionInfo.PositionType() == POSITION_TYPE_BUY)
                {
                    profitPoints = (currentPrice - openPrice) / point;
                }
                else
                {
                    profitPoints = (openPrice - currentPrice) / point;
                }

                // Ponderar pelo volume
                totalProfitPoints += profitPoints * volume;
            }
        }
    }

    // Retornar lucro médio ponderado por volume
    double totalVolume = GetTotalOpenVolume();
    if (totalVolume > 0)
    {
        return totalProfitPoints / totalVolume;
    }

    return 0;
}

//+------------------------------------------------------------------+
//| Get total volume of all open positions                           |
//+------------------------------------------------------------------+
double GetTotalOpenVolume()
{
    double totalVolume = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                totalVolume += positionInfo.Volume();
            }
        }
    }

    return totalVolume;
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                 |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
    int count = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                count++;
            }
        }
    }

    return count;
}

//+------------------------------------------------------------------+
//| Calculate hedge volume using martingale                          |
//+------------------------------------------------------------------+
double CalculateHedgeVolume()
{
    double volume = 0;

    if (currentHedgeLevel == 0)
    {
        // Primeiro hedge: usar volume calculado pelo risco * multiplicador
        volume = CalculateVolume() * HedgeMultiplier;
        initialHedgeVolume = CalculateVolume();
    }
    else
    {
        // Hedges subsequentes: último volume * multiplicador
        volume = lastHedgeVolume * HedgeMultiplier;
    }

    // Normalizar volume
    double minLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_STEP);

    volume = MathFloor(volume / lotStep) * lotStep;
    volume = MathMax(minLot, MathMin(maxLot, volume));

    Print("Hedge Volume calculated: Level=", currentHedgeLevel + 1,
          " LastVol=", lastHedgeVolume,
          " Multiplier=", HedgeMultiplier,
          " NewVol=", volume);

    return volume;
}

//+------------------------------------------------------------------+
//| Open hedge position (no TP/SL)                                   |
//+------------------------------------------------------------------+
bool OpenHedgePosition(string direction)
{
    // CHECK CHART SUITABILITY BEFORE HEDGE
    if (!IsChartSuitable())
    {
        Print("HEDGE BLOCKED: Chart not suitable for trading");
        return false;
    }

    // Verificar limite de níveis
    if (currentHedgeLevel >= MaxHedgeLevels)
    {
        Print("=== HEDGE LIMIT REACHED ===");
        Print("Max levels: ", MaxHedgeLevels, " - NOT opening new hedge");
        return false;
    }

    double volume = CalculateHedgeVolume();
    if (volume <= 0)
    {
        Print("ERROR: Invalid hedge volume calculated");
        return false;
    }

    symbolInfo.Refresh();
    symbolInfo.RefreshRates();

    bool success = false;

    if (direction == "buy")
    {
        double ask = symbolInfo.Ask();
        // Hedge sem TP/SL - gerenciado pelo lucro total
        if (trade.Buy(volume, TradingSymbol, ask, 0, 0, "HedgeTrade"))
        {
            Print("=== HEDGE BUY SUCCESS ===");
            Print("Level: ", currentHedgeLevel + 1, " Volume: ", volume, " Entry: ", ask);
            success = true;
        }
        else
        {
            Print("HEDGE BUY FAILED: ", trade.ResultRetcodeDescription());
        }
    }
    else if (direction == "sell")
    {
        double bid = symbolInfo.Bid();
        // Hedge sem TP/SL - gerenciado pelo lucro total
        if (trade.Sell(volume, TradingSymbol, bid, 0, 0, "HedgeTrade"))
        {
            Print("=== HEDGE SELL SUCCESS ===");
            Print("Level: ", currentHedgeLevel + 1, " Volume: ", volume, " Entry: ", bid);
            success = true;
        }
        else
        {
            Print("HEDGE SELL FAILED: ", trade.ResultRetcodeDescription());
        }
    }

    if (success)
    {
        lastHedgeVolume = volume;
        currentHedgeLevel++;
        isInHedgeMode = true;
        Print("Hedge state: Level=", currentHedgeLevel, " Mode=ACTIVE");
    }

    return success;
}

//+------------------------------------------------------------------+
//| Manage hedge profit - close all when target reached              |
//+------------------------------------------------------------------+
void ManageHedgeProfit()
{
    if (!isInHedgeMode)
        return;

    // Verificar se ainda há posições abertas
    int posCount = CountOpenPositions();
    if (posCount == 0)
    {
        // Reset do estado de hedge
        ResetHedgeState();
        return;
    }

    // Calcular lucro total em pontos
    double totalProfitPoints = GetTotalOpenProfitInPoints();

    // Verificar se atingiu a meta
    if (totalProfitPoints >= HedgeProfitTarget)
    {
        Print("=== HEDGE TARGET REACHED ===");
        Print("Total Profit: ", totalProfitPoints, " points (Target: ", HedgeProfitTarget, ")");
        Print("Closing ALL positions...");

        bool closeResult = CloseAllPositions();
        if (closeResult)
        {
            Print("=== HEDGE SUCCESS ===");
            Print("All positions closed with ", totalProfitPoints, " points profit");
            ResetHedgeState();
        }
        else
        {
            Print("!!! ERROR: Failed to close all positions in Hedge !!!");
        }
    }
}

//+------------------------------------------------------------------+
//| Reset hedge state                                                |
//+------------------------------------------------------------------+
void ResetHedgeState()
{
    if (isInHedgeMode || currentHedgeLevel > 0)
    {
        Print("=== HEDGE STATE RESET ===");
        Print("Previous Level: ", currentHedgeLevel);
    }

    currentHedgeLevel = 0;
    isInHedgeMode = false;
    lastHedgeVolume = 0;
    initialHedgeVolume = 0;
}

//+------------------------------------------------------------------+
//| Function to place buy order                                      |
//+------------------------------------------------------------------+
bool PlaceBuyOrder(double volume)
{
    symbolInfo.Refresh();
    symbolInfo.RefreshRates();

    double ask = symbolInfo.Ask();
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Calcular SL (baseado em ATR ou fixo)
    double sl = 0;
    double slDistance = 0;

    if (UseATRBasedSL)
    {
        // SL baseado em ATR
        double atrValue = GetATRValue();

        if (atrValue > 0)
        {
            slDistance = atrValue * ATRMultiplier;
            sl = NormalizeDouble(ask - slDistance, digits);
            Print("ATR-Based SL (BUY): ATR=", NormalizeDouble(atrValue, digits),
                  " x ", ATRMultiplier, " = ", NormalizeDouble(slDistance, digits),
                  " → SL=", sl);
        }
        else
        {
            // Fallback para fixo se ATR falhar
            slDistance = adjustedSLPoints * point;
            sl = NormalizeDouble(ask - slDistance, digits);
            Print("ATR failed, using fixed SL: ", adjustedSLPoints, " points");
        }
    }
    else
    {
        // SL fixo
        slDistance = adjustedSLPoints * point;
        sl = NormalizeDouble(ask - slDistance, digits);
    }

    // Calcular TP usando valores ajustados
    double tpDistance = adjustedTPPoints * point;
    double tp = NormalizeDouble(ask + tpDistance, digits);

    Print("=== BUY ORDER ===");
    Print("Entry: ", ask, " - SL: ", sl, " (distance = ", slDistance, ") - TP: ", tp, " (", adjustedTPPoints, " pts)");

    // Validar stops mínimos
    int minStopLevel = (int)SymbolInfoInteger(TradingSymbol, SYMBOL_TRADE_STOPS_LEVEL);
    if (minStopLevel > 0)
    {
        double minDistance = minStopLevel * point;
        if (slDistance < minDistance || tpDistance < minDistance)
        {
            Print("ERROR: SL/TP too close. Min distance: ", minDistance);
            return false;
        }
    }

    // Gerar comentário automaticamente: direction + symbol + "c"
    // Ex: "buy:BTCUSDc" ou "sell:XAUUSDc"
    string orderComment = currentSignalDirection + ":" + currentSignalSymbol + "c";

    if (trade.Buy(volume, TradingSymbol, ask, sl, tp, orderComment))
    {
        Print("BUY SUCCESS: Vol=", volume, " Entry=", ask, " SL=", sl, " (", adjustedSLPoints, " points) TP=", tp, " (", adjustedTPPoints, " points)");
        Print("Order Comment: '", orderComment, "'");

        // Update panel variables
        lastAction = "BUY";
        lastSignalTime = TimeCurrent();
        dailyTradeCount++;

        return true;
    }
    else
    {
        Print("BUY FAILED: ", trade.ResultRetcodeDescription(), " Code: ", trade.ResultRetcode());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Function to place sell order                                     |
//+------------------------------------------------------------------+
bool PlaceSellOrder(double volume)
{
    symbolInfo.Refresh();
    symbolInfo.RefreshRates();

    double bid = symbolInfo.Bid();
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Calcular SL (baseado em ATR ou fixo)
    double sl = 0;
    double slDistance = 0;

    if (UseATRBasedSL)
    {
        // SL baseado em ATR
        double atrValue = GetATRValue();

        if (atrValue > 0)
        {
            slDistance = atrValue * ATRMultiplier;
            sl = NormalizeDouble(bid + slDistance, digits);
            Print("ATR-Based SL (SELL): ATR=", NormalizeDouble(atrValue, digits),
                  " x ", ATRMultiplier, " = ", NormalizeDouble(slDistance, digits),
                  " → SL=", sl);
        }
        else
        {
            // Fallback para fixo se ATR falhar
            slDistance = adjustedSLPoints * point;
            sl = NormalizeDouble(bid + slDistance, digits);
            Print("ATR failed, using fixed SL: ", adjustedSLPoints, " points");
        }
    }
    else
    {
        // SL fixo
        slDistance = adjustedSLPoints * point;
        sl = NormalizeDouble(bid + slDistance, digits);
    }

    // Calcular TP usando valores ajustados
    double tpDistance = adjustedTPPoints * point;
    double tp = NormalizeDouble(bid - tpDistance, digits);

    Print("=== SELL ORDER ===");
    Print("Entry: ", bid, " - SL: ", sl, " (distance = ", slDistance, ") - TP: ", tp, " (", adjustedTPPoints, " pts)");

    // Validar stops mínimos
    int minStopLevel = (int)SymbolInfoInteger(TradingSymbol, SYMBOL_TRADE_STOPS_LEVEL);
    if (minStopLevel > 0)
    {
        double minDistance = minStopLevel * point;
        if (slDistance < minDistance || tpDistance < minDistance)
        {
            Print("ERROR: SL/TP too close. Min distance: ", minDistance);
            return false;
        }
    }

    // Gerar comentário automaticamente: direction + symbol + "c"
    // Ex: "buy:BTCUSDc" ou "sell:XAUUSDc"
    string orderComment = currentSignalDirection + ":" + currentSignalSymbol + "c";

    if (trade.Sell(volume, TradingSymbol, bid, sl, tp, orderComment))
    {
        Print("SELL SUCCESS: Vol=", volume, " Entry=", bid, " SL=", sl, " (", adjustedSLPoints, " points) TP=", tp, " (", adjustedTPPoints, " points)");
        Print("Order Comment: '", orderComment, "'");

        // Update panel variables
        lastAction = "SELL";
        lastSignalTime = TimeCurrent();
        dailyTradeCount++;

        return true;
    }
    else
    {
        Print("SELL FAILED: ", trade.ResultRetcodeDescription(), " Code: ", trade.ResultRetcode());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Function to process incoming JSON                                |
//+------------------------------------------------------------------+
void ProcessTradeSignal(string jsonData, bool forceClosePositions = true, bool isPendingExecution = false)
{
    // Reset Positive Scalping state when new signal arrives
    if (EnablePositiveScalping && currentScalpingLevel > 0)
    {
        Print("=== POSITIVE SCALPING RESET ===");
        Print("New signal received - clearing scalping positions");
        ResetScalpingState();
    }

    // CHECK CHART SUITABILITY BEFORE EXECUTING TRADES
    if (!IsChartSuitable())
    {
        int width = GetChartWidth();
        int height = GetChartHeight();

        if (width <= 0 || height <= 0)
        {
            Print("ERROR: Invalid chart dimensions in ProcessTradeSignal - Width=", width, ", Height=", height);
            return;
        }

        if (!AllowSideChart && IsSideChart())
        {
            Print("BLOCKED: Signal ignored - side chart not allowed. Width=", width, ", Height=", height);
        }
        else if (CheckChartSize && (width < MinChartWidth || height < MinChartHeight))
        {
            Print("BLOCKED: Signal ignored - chart too small. Width=", width, " (min=", MinChartWidth,
                  "), Height=", height, " (min=", MinChartHeight, ")");
        }

        // Don't process the signal, but don't update lastProcessedJson
        // This allows the signal to be processed when chart becomes suitable
        return;
    }

    // Parse action (suporta long/short e buy/sell)
    string action = "";
    if (StringFind(jsonData, "\"action\":\"long\"") >= 0 ||
        StringFind(jsonData, "\"action\": \"long\"") >= 0 ||
        StringFind(jsonData, "\"action\":\"buy\"") >= 0 ||
        StringFind(jsonData, "\"action\": \"buy\"") >= 0)
    {
        action = "buy";
    }
    else if (StringFind(jsonData, "\"action\":\"short\"") >= 0 ||
             StringFind(jsonData, "\"action\": \"short\"") >= 0 ||
             StringFind(jsonData, "\"action\":\"sell\"") >= 0 ||
             StringFind(jsonData, "\"action\": \"sell\"") >= 0)
    {
        action = "sell";
    }
    else
    {
        Print("ERROR: Invalid action in JSON: ", jsonData);
        Print("Expected action values: 'long', 'short', 'buy', or 'sell'");
        return;
    }

    // Inverter sinal se Reverse Trading estiver ativo
    string originalAction = action;
    if (EnableReverseTrading)
    {
        if (action == "buy")
        {
            action = "sell";
        }
        else if (action == "sell")
        {
            action = "buy";
        }
        Print("=== REVERSE TRADING ACTIVE ===");
        Print("Original Signal: ", originalAction, " → Reversed to: ", action);
    }

    // Logging diferenciado para execução pendente
    if (isPendingExecution)
    {
        Print("=== Processing PENDING Signal at Candle Close ===");
        Print("Signal received earlier, now executing at candle close");
    }
    else
    {
        Print("=== Processing Trade Signal ===");
    }
    Print("Action: ", action);

    // Verificar condição de HEDGE
    if (EnableHedge)
    {
        ENUM_POSITION_TYPE currentDirection = GetOpenPositionDirection();
        bool hasOpenPos = (currentDirection != (ENUM_POSITION_TYPE)-1);
        bool isInLoss = IsAnyPositionInLoss();

        // Determinar se sinal é oposto
        bool isOppositeSignal = false;
        if (hasOpenPos)
        {
            if ((currentDirection == POSITION_TYPE_BUY && action == "sell") ||
                (currentDirection == POSITION_TYPE_SELL && action == "buy"))
            {
                isOppositeSignal = true;
            }
        }

        Print("Hedge Check: HasPosition=", hasOpenPosition,
              " InLoss=", isInLoss,
              " OppositeSignal=", isOppositeSignal,
              " HedgeMode=", isInHedgeMode,
              " HedgeLevel=", currentHedgeLevel);

        // Condição de HEDGE: tem posição + em prejuízo + sinal oposto
        if (hasOpenPosition && isInLoss && isOppositeSignal)
        {
            Print("=== HEDGE CONDITION DETECTED ===");
            Print("Opening HEDGE position instead of closing...");

            // Guardar volume inicial se for primeira entrada no modo hedge
            if (!isInHedgeMode)
            {
                initialHedgeVolume = GetTotalOpenVolume();
                lastHedgeVolume = initialHedgeVolume;
            }

            // Abrir hedge na direção do sinal
            if (OpenHedgePosition(action))
            {
                Print("=== HEDGE OPENED - Waiting for profit target ===");
                Print("Target: ", HedgeProfitTarget, " points");
            }
            else
            {
                Print("HEDGE FAILED - Check logs for details");
            }

            return; // Não executar lógica normal
        }

        // Se está em modo hedge, verificar se deve adicionar novo nível de martingale
        if (isInHedgeMode)
        {
            // Verificar se podemos abrir mais um nível
            if (currentHedgeLevel < MaxHedgeLevels)
            {
                // Verificar se ainda estamos em prejuízo
                if (IsAnyPositionInLoss())
                {
                    // Determinar a direção do hedge atual
                    // Se a última ação foi BUY, o hedge é SELL, e vice-versa
                    string hedgeDirection = (lastAction == "buy") ? "sell" : "buy";

                    // Se o sinal é na MESMA direção do hedge atual, adicionar nível de martingale
                    if (action == hedgeDirection)
                    {
                        Print("=== ADDITIONAL HEDGE LEVEL ===");
                        Print("Current Level: ", currentHedgeLevel, " Opening Level: ", currentHedgeLevel + 1);
                        Print("Signal direction matches hedge - adding martingale level");

                        if (OpenHedgePosition(action))
                        {
                            Print("=== ADDITIONAL HEDGE OPENED ===");
                            Print("New hedge level: ", currentHedgeLevel);
                        }
                        else
                        {
                            Print("ADDITIONAL HEDGE FAILED - Check logs");
                        }

                        return; // Não executar lógica normal
                    }
                    else
                    {
                        Print("In hedge mode - signal is opposite direction (", action, " vs ", hedgeDirection, ")");
                        Print("Ignoring signal while in hedge mode with opposite direction");
                        return; // Não executar lógica normal
                    }
                }
                else
                {
                    Print("In hedge mode - positions are profitable, ignoring signal");
                    return; // Não executar lógica normal
                }
            }
            else
            {
                Print("In hedge mode - max levels reached (", currentHedgeLevel, "/", MaxHedgeLevels, ")");
                return; // Não executar lógica normal
            }
        }
    }

    // Lógica NORMAL (sem hedge ou condições não atendidas)

    // 1. Fechar posições (apenas se forceClosePositions for true)
    if (forceClosePositions)
    {
        Print("Closing all positions for ", TradingSymbol);
        if (!CloseAllPositions())
        {
            Print("WARNING: Not all positions closed");
        }
    }
    else
    {
        Print("Keeping existing positions (forceClosePositions = false)");
    }

    // Reset hedge state ao fechar todas posições (apenas se fechou)
    if (forceClosePositions)
    {
        ResetHedgeState();
    }

    Sleep(500);

    // 2. Calcular volume
    double volume = CalculateVolume();
    if (volume <= 0)
    {
        Print("ERROR: Invalid volume calculated: ", volume);
        return;
    }

    // 3. Check additional risk conditions before opening
    if (CheckRiskLimitsBeforeOpening())
    {
        Print("Risk checks passed - proceeding with order");
    }
    else
    {
        Print("Risk checks failed - aborting order");
        return;
    }

    // 4. Abrir ordem
    if (action == "buy")
    {
        PlaceBuyOrder(volume);
    }
    else if (action == "sell")
    {
        PlaceSellOrder(volume);
    }

    Print("=== Trade Signal Processed ===");

    // Limpar variáveis de símbolo para o próximo sinal
    signalSymbol = "";
    signalHasSymbol = false;
}

//+------------------------------------------------------------------+
//| Manage Breakeven and Trailing Stop for open positions           |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    // Verificar se estamos em hedge mode
    bool inHedgeMode = isInHedgeMode;

    // Se em hedge mode, usar lógica especial
    if (inHedgeMode)
    {
        ManageHedgeTrailingStop();
        return;
    }

    // Lógica normal (não hedge)
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                bool breakevenApplied = false;

                // Aplicar breakeven PRIMEIRO
                if (EnableBreakeven)
                {
                    breakevenApplied = ApplyBreakeven(positionInfo.Ticket());
                }

                // Aplicar trailing stop SOMENTE se:
                // 1. Está habilitado E
                // 2. (Breakeven está desabilitado OU já foi aplicado)
                if (EnableTrailingStop)
                {
                    bool breakevenActive = !EnableBreakeven || IsBreakevenActive(positionInfo.Ticket());

                    if (breakevenActive)
                    {
                        ApplyTrailingStop(positionInfo.Ticket());
                    }
                    else
                    {
                        // Debug: Trailing está esperando breakeven
                        static datetime lastDebugPrint = 0;
                        if (TimeCurrent() - lastDebugPrint > 30)  // A cada 30 segundos
                        {
                            double openPrice = positionInfo.PriceOpen();
                            double currentSL = positionInfo.StopLoss();
                            double point = symbolInfo.Point();
                            double bid = symbolInfo.Bid();
                            double ask = symbolInfo.Ask();
                            double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY) ? bid : ask;
                            double profit = (positionInfo.PositionType() == POSITION_TYPE_BUY) ?
                                          (currentPrice - openPrice) : (openPrice - currentPrice);

                            Print("TRAILING: Aguardando Breakeven - Lucro atual: ", profit / point, " pontos - Necessario: ", adjustedBEPoints, " pontos");
                            lastDebugPrint = TimeCurrent();
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop during Hedge Mode                           |
//| Aplica trailing SOMENTE na posição positiva quando conta >= 0     |
//+------------------------------------------------------------------+
void ManageHedgeTrailingStop()
{
    // 1. Verificar se trailing está habilitado
    if (!EnableTrailingStop)
        return;

    // 2. Verificar lucro TOTAL da conta
    double totalAccountProfit = AccountInfoDouble(ACCOUNT_PROFIT);

    if (totalAccountProfit < 0)
    {
        // Conta negativa - não aplicar trailing em hedge
        static datetime lastNegativeLog = 0;
        if (TimeCurrent() - lastNegativeLog > 60)
        {
            Print("HEDGE TRAILING: Conta negativa ($", totalAccountProfit, ") - trailing bloqueado");
            lastNegativeLog = TimeCurrent();
        }
        return;
    }

    // 3. Encontrar a posição LUCRATIVA
    ulong profitableTicket = 0;
    double maxProfit = -999999;  // Maior lucro

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                double positionProfit = positionInfo.Profit();

                if (positionProfit > maxProfit)
                {
                    maxProfit = positionProfit;
                    profitableTicket = positionInfo.Ticket();
                }
            }
        }
    }

    // 4. Aplicar trailing APENAS na posição lucrativa
    if (profitableTicket > 0)
    {
        // Aplicar breakeven primeiro (se habilitado)
        if (EnableBreakeven)
        {
            ApplyBreakeven(profitableTicket);
        }

        // Aplicar trailing stop
        bool breakevenActive = !EnableBreakeven || IsBreakevenActive(profitableTicket);
        if (breakevenActive)
        {
            static datetime lastHedgeTrailingLog = 0;
            if (TimeCurrent() - lastHedgeTrailingLog > 30)
            {
                Print("HEDGE TRAILING: Conta +$", totalAccountProfit, " - Aplicando trailing na posição lucrativa (ticket=", profitableTicket, ", profit=$", maxProfit, ")");
                lastHedgeTrailingLog = TimeCurrent();
            }

            ApplyTrailingStop(profitableTicket);
        }
    }
}

//+------------------------------------------------------------------+
//| Check if breakeven is already active for position                |
//+------------------------------------------------------------------+
bool IsBreakevenActive(ulong ticket)
{
    if (!positionInfo.SelectByTicket(ticket))
        return false;

    double openPrice = positionInfo.PriceOpen();
    double currentSL = positionInfo.StopLoss();

    if (currentSL == 0)
        return false;

    // Verifica se o SL está no lado do lucro (além da entrada)
    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para BUY: SL acima ou igual à entrada = breakeven ativo
        return (currentSL >= openPrice);
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        // Para SELL: SL abaixo ou igual à entrada = breakeven ativo
        return (currentSL <= openPrice);
    }

    return false;
}

//+------------------------------------------------------------------+
//| Apply Breakeven to position                                      |
//+------------------------------------------------------------------+
bool ApplyBreakeven(ulong ticket)
{
    if (!positionInfo.SelectByTicket(ticket))
        return false;

    double openPrice = positionInfo.PriceOpen();
    double currentSL = positionInfo.StopLoss();
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Calcular breakeven usando valores ajustados
    double breakEvenDistance = adjustedBEPoints * point;
    double breakEvenExtra = BreakEvenExtraPoints * point;

    symbolInfo.RefreshRates();
    double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY)
                          ? symbolInfo.Bid()
                          : symbolInfo.Ask();

    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para posição BUY
        double targetPrice = openPrice + breakEvenDistance;
        double newSL = NormalizeDouble(openPrice + breakEvenExtra, digits);

        // Se preço atingiu o breakeven e SL ainda não foi movido
        if (currentPrice >= targetPrice &&
            (currentSL < openPrice || currentSL == 0))
        {
            if (trade.PositionModify(ticket, newSL, positionInfo.TakeProfit()))
            {
                Print("BREAKEVEN APPLIED: Ticket=", ticket,
                      " New SL=", newSL,
                      " (+", BreakEvenExtraPoints, " points)");
                return true;
            }
            else
            {
                Print("BREAKEVEN FAILED: ", trade.ResultRetcodeDescription());
                return false;
            }
        }
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        // Para posição SELL
        double targetPrice = openPrice - breakEvenDistance;
        double newSL = NormalizeDouble(openPrice - breakEvenExtra, digits);

        // Se preço atingiu o breakeven e SL ainda não foi movido
        if (currentPrice <= targetPrice &&
            (currentSL > openPrice || currentSL == 0))
        {
            if (trade.PositionModify(ticket, newSL, positionInfo.TakeProfit()))
            {
                Print("BREAKEVEN APPLIED: Ticket=", ticket,
                      " New SL=", newSL,
                      " (+", BreakEvenExtraPoints, " points)");
                return true;
            }
            else
            {
                Print("BREAKEVEN FAILED: ", trade.ResultRetcodeDescription());
                return false;
            }
        }
    }

    // Breakeven não foi aplicado (condições não atingidas)
    return false;
}

//+------------------------------------------------------------------+
//| Apply Trailing Stop to position                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop(ulong ticket)
{
    if (!positionInfo.SelectByTicket(ticket))
        return;

    double currentSL = positionInfo.StopLoss();
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Calcular trailing usando valores ajustados (fixo)
    double trailingDistance = adjustedTrailingPoints * point;
    double trailingStep = adjustedTrailingStepPoints * point;

    symbolInfo.RefreshRates();
    double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY)
                          ? symbolInfo.Bid()
                          : symbolInfo.Ask();

    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para posição BUY
        // O trailing SL é sempre: preço atual - distância
        // Mas NUNCA deve ser menor que o SL atual (proteger lucro)
        double calculatedSL = NormalizeDouble(currentPrice - trailingDistance, digits);
        double newSL = calculatedSL;

        // Se o SL calculado é menor que o atual, mantém o atual (trailing)
        if (currentSL != 0 && calculatedSL < currentSL)
        {
            newSL = currentSL;  // Não diminui o SL
        }

        // Debug info
        static datetime lastBuyDebug = 0;
        if (TimeCurrent() - lastBuyDebug > 30)
        {
            double profitPoints = (currentPrice - positionInfo.PriceOpen()) / point;
            Print("TRAILING BUY - Price=", currentPrice, " - SL=", currentSL, " - CalcSL=", calculatedSL, " - NewSL=", newSL, " - Profit=", profitPoints, " pts");
            lastBuyDebug = TimeCurrent();
        }

        // SÓ modificar se houver mudança significativa (para evitar muitas requisições)
        double slDiff = MathAbs(newSL - currentSL);
        if (slDiff >= trailingStep || currentSL == 0)
        {
            if (newSL != currentSL)  // Só se realmente mudou
            {
                if (trade.PositionModify(ticket, newSL, positionInfo.TakeProfit()))
                {
                    Print("TRAILING STOP: Ticket=", ticket,
                          " Old SL=", currentSL,
                          " New SL=", newSL,
                          " (", adjustedTrailingPoints, " points from price)");
                }
                else
                {
                    Print("TRAILING STOP FAILED: ", trade.ResultRetcodeDescription(), " (", trade.ResultRetcode(), ")");
                }
            }
        }
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        // Para posição SELL
        // O trailing SL é sempre: preço atual + distância
        // Mas NUNCA deve ser maior que o SL atual (proteger lucro)
        double calculatedSL = NormalizeDouble(currentPrice + trailingDistance, digits);
        double newSL = calculatedSL;

        // Se o SL calculado é maior que o atual, mantém o atual (trailing)
        if (currentSL != 0 && calculatedSL > currentSL)
        {
            newSL = currentSL;  // Não aumenta o SL (para SELL, maior é pior)
        }

        // Debug info
        static datetime lastSellDebug = 0;
        if (TimeCurrent() - lastSellDebug > 30)
        {
            double profitPoints = (positionInfo.PriceOpen() - currentPrice) / point;
            Print("TRAILING SELL - Price=", currentPrice, " - SL=", currentSL, " - CalcSL=", calculatedSL, " - NewSL=", newSL, " - Profit=", profitPoints, " pts");
            lastSellDebug = TimeCurrent();
        }

        // SÓ modificar se houver mudança significativa (para evitar muitas requisições)
        double slDiff = MathAbs(newSL - currentSL);
        if (slDiff >= trailingStep || currentSL == 0)
        {
            if (newSL != currentSL)  // Só se realmente mudou
            {
                if (trade.PositionModify(ticket, newSL, positionInfo.TakeProfit()))
                {
                    Print("TRAILING STOP: Ticket=", ticket,
                          " Old SL=", currentSL,
                          " New SL=", newSL,
                          " (", adjustedTrailingPoints, " points from price)");
                }
                else
                {
                    Print("TRAILING STOP FAILED: ", trade.ResultRetcodeDescription(), " (", trade.ResultRetcode(), ")");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if there's an open position for our symbol/magic           |
//+------------------------------------------------------------------+
bool HasOpenPositionForSymbol()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Get current position ticket                                       |
//+------------------------------------------------------------------+
ulong GetCurrentPositionTicket()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                return positionInfo.Ticket();
            }
        }
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Check if a candle is bullish (close > open)                       |
//+------------------------------------------------------------------+
bool IsBullishCandle(int index, ENUM_TIMEFRAMES timeframe)
{
    double open = iOpen(TradingSymbol, timeframe, index);
    double close = iClose(TradingSymbol, timeframe, index);
    return (close > open);
}

//+------------------------------------------------------------------+
//| Check if a candle is bearish (close < open)                       |
//+------------------------------------------------------------------+
bool IsBearishCandle(int index, ENUM_TIMEFRAMES timeframe)
{
    double open = iOpen(TradingSymbol, timeframe, index);
    double close = iClose(TradingSymbol, timeframe, index);
    return (close < open);
}

//+------------------------------------------------------------------+
//| Count bullish candles in the last N completed candles             |
//+------------------------------------------------------------------+
int CountBullishCandles(int count, ENUM_TIMEFRAMES timeframe)
{
    int bullishCount = 0;
    // Start from index 1 (last completed candle, not current forming)
    for (int i = 1; i <= count; i++)
    {
        if (IsBullishCandle(i, timeframe))
        {
            bullishCount++;
        }
    }
    return bullishCount;
}

//+------------------------------------------------------------------+
//| Count bearish candles in the last N completed candles             |
//+------------------------------------------------------------------+
int CountBearishCandles(int count, ENUM_TIMEFRAMES timeframe)
{
    int bearishCount = 0;
    // Start from index 1 (last completed candle, not current forming)
    for (int i = 1; i <= count; i++)
    {
        if (IsBearishCandle(i, timeframe))
        {
            bearishCount++;
        }
    }
    return bearishCount;
}

//+------------------------------------------------------------------+
//| Check if all candles are in the specified direction               |
//+------------------------------------------------------------------+
bool AreAllCandlesInDirection(string direction, int count, ENUM_TIMEFRAMES timeframe)
{
    // Start from index 1 (last completed candle)
    for (int i = 1; i <= count; i++)
    {
        if (direction == "buy")
        {
            if (!IsBullishCandle(i, timeframe))
                return false;
        }
        else if (direction == "sell")
        {
            if (!IsBearishCandle(i, timeframe))
                return false;
        }
    }
    return true;
}

//+------------------------------------------------------------------+
//| Check if trend is confirmed by candle analysis                    |
//+------------------------------------------------------------------+
bool IsTrendConfirmedByCandles(string direction)
{
    ENUM_TIMEFRAMES tf = CandleConfirmationTF;
    int count = CandleConfirmationCount;

    if (RequireConsecutiveCandles)
    {
        // All candles must be in the same direction
        bool confirmed = AreAllCandlesInDirection(direction, count, tf);

        if (confirmed)
        {
            Print("Candle confirmation: ALL ", count, " candles are ",
                  (direction == "buy" ? "BULLISH" : "BEARISH"), " ✓");
        }
        else
        {
            int matching = (direction == "buy")
                           ? CountBullishCandles(count, tf)
                           : CountBearishCandles(count, tf);
            Print("Candle confirmation: Only ", matching, "/", count, " candles in direction - NOT confirmed");
        }

        return confirmed;
    }
    else
    {
        // Majority mode: more than 50% must be in direction
        int required = (count / 2) + 1;  // e.g., 3 out of 5, 2 out of 3
        int matching = 0;

        if (direction == "buy")
        {
            matching = CountBullishCandles(count, tf);
        }
        else if (direction == "sell")
        {
            matching = CountBearishCandles(count, tf);
        }

        bool confirmed = (matching >= required);

        if (confirmed)
        {
            Print("Candle confirmation (majority): ", matching, "/", count,
                  " candles are ", (direction == "buy" ? "BULLISH" : "BEARISH"),
                  " (required: ", required, ") ✓");
        }
        else
        {
            Print("Candle confirmation (majority): ", matching, "/", count,
                  " candles in direction (required: ", required, ") - NOT confirmed");
        }

        return confirmed;
    }
}

//+------------------------------------------------------------------+
//| Check if a new candle has formed since last check                 |
//+------------------------------------------------------------------+
bool IsNewCandleFormed(ENUM_TIMEFRAMES timeframe)
{
    datetime currentCandleTime = iTime(TradingSymbol, timeframe, 0);
    return (currentCandleTime > lastCheckedCandleTime);
}

//+------------------------------------------------------------------+
//| Get timeframe as string for logging                               |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
{
    switch(tf)
    {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
        default:         return "CURRENT";
    }
}

//+------------------------------------------------------------------+
//| INFO PANEL FUNCTIONS                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Create info panel on chart - Modern Design                        |
//+------------------------------------------------------------------+
bool CreateInfoPanel()
{
    if (!ShowInfoPanel || panelInitialized)
        return true;

    // Modern color palette
    color bgPanelColor = (color)0x1E1E2E;       // Dark blue-gray background
    color borderColor = (color)0x3B4252;        // Subtle border
    color headerColor = (color)0xEBCB8B;        // Soft gold
    color textMainColor = (color)0xECEFF4;      // Off-white
    color textMutedColor = (color)0x88C0D0;     // Soft cyan
    color textDimColor = (color)0x4C566A;       // Dim gray
    color colorGreen = (color)0xA3BE8C;         // Muted green
    color colorRed = (color)0xBF616A;           // Soft red
    color colorBlue = (color)0x81A1C1;          // Muted blue
    color colorYellow = (color)0xEBCB8B;        // Soft yellow (same as header)
    color colorOrange = (color)0xD08770;        // Soft orange

    // Create background rectangle with rounded effect
    ObjectCreate(0, panelPrefix + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_XDISTANCE, PanelX);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_YDISTANCE, PanelY);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_XSIZE, PanelWidth);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_YSIZE, 420);  // Increased for better spacing
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_BGCOLOR, bgPanelColor);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_BORDER_COLOR, borderColor);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, panelPrefix + "BG", OBJPROP_BACK, false);

    // Create header label
    ObjectCreate(0, panelPrefix + "Header", OBJ_LABEL, 0, 0, 0);
    string headerVersion = "TVLucro v4.8 - " + TradingSymbol;
    if (EnablePositiveScalping)
    {
        headerVersion += " | Scalping: ON";
    }
    ObjectSetString(0, panelPrefix + "Header", OBJPROP_TEXT, headerVersion);
    ObjectSetInteger(0, panelPrefix + "Header", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "Header", OBJPROP_YDISTANCE, PanelY + 12);
    ObjectSetInteger(0, panelPrefix + "Header", OBJPROP_COLOR, headerColor);
    ObjectSetString(0, panelPrefix + "Header", OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, panelPrefix + "Header", OBJPROP_FONTSIZE, 11);
    ObjectSetInteger(0, panelPrefix + "Header", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create symbol info label
    ObjectCreate(0, panelPrefix + "SymbolInfo", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_YDISTANCE, PanelY + 28);
    ObjectSetString(0, panelPrefix + "SymbolInfo", OBJPROP_TEXT, "Symbol: " + TradingSymbol + " | Signal: " + (signalHasSymbol ? signalSymbol : "any"));
    ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_COLOR, textMutedColor);
    ObjectSetString(0, panelPrefix + "SymbolInfo", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create trend marker section
    if (TrendMarkerEnabled)
    {
        // Create trend background highlight
        ObjectCreate(0, panelPrefix + "TrendBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_XDISTANCE, PanelX + 6);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_YDISTANCE, PanelY + 48);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_XSIZE, PanelWidth - 12);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_YSIZE, 28);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_BGCOLOR, (color)0x2E3440);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_BORDER_COLOR, (color)0x434C5E);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, panelPrefix + "TrendBG", OBJPROP_BACK, true);

        // Create trend arrow label
        ObjectCreate(0, panelPrefix + "TrendArrow", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_XDISTANCE, PanelX + 12);
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_YDISTANCE, PanelY + 54);
        ObjectSetString(0, panelPrefix + "TrendArrow", OBJPROP_TEXT, "→");
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_COLOR, textDimColor);
        ObjectSetString(0, panelPrefix + "TrendArrow", OBJPROP_FONT, "Arial Bold");
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_FONTSIZE, 14);
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_CORNER, CORNER_LEFT_UPPER);

        // Create trend text label
        ObjectCreate(0, panelPrefix + "TrendText", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_XDISTANCE, PanelX + 36);
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_YDISTANCE, PanelY + 56);
        ObjectSetString(0, panelPrefix + "TrendText", OBJPROP_TEXT, "TREND: NEUTRAL");
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_COLOR, textDimColor);
        ObjectSetString(0, panelPrefix + "TrendText", OBJPROP_FONT, "Arial Bold");
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_FONTSIZE, 9);
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_CORNER, CORNER_LEFT_UPPER);

        // Create trend strength label
        ObjectCreate(0, panelPrefix + "TrendStrength", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_XDISTANCE, PanelX + 145);
        ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_YDISTANCE, PanelY + 56);
        ObjectSetString(0, panelPrefix + "TrendStrength", OBJPROP_TEXT, "");
        ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_COLOR, textDimColor);
        ObjectSetString(0, panelPrefix + "TrendStrength", OBJPROP_FONT, "Arial");
        ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    }

    // Create status labels for each strategy (25px spacing)
    CreateStatusLabel("Hedge", PanelY + 85);
    CreateStatusLabel("Trend", PanelY + 112);
    CreateStatusLabel("Candle", PanelY + 139);
    CreateStatusLabel("Close", PanelY + 166);
    CreateStatusLabel("Scalping", PanelY + 193);

    // Create chart status label (moved down to avoid overlap)
    ObjectCreate(0, panelPrefix + "ChartStatus", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_YDISTANCE, PanelY + 220);
    ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorGreen);
    ObjectSetString(0, panelPrefix + "ChartStatus", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create position info label
    ObjectCreate(0, panelPrefix + "PosInfo", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_YDISTANCE, PanelY + 250);
    ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_COLOR, colorGreen);
    ObjectSetString(0, panelPrefix + "PosInfo", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create performance label
    ObjectCreate(0, panelPrefix + "PerfInfo", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_YDISTANCE, PanelY + 280);
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_COLOR, colorBlue);
    ObjectSetString(0, panelPrefix + "PerfInfo", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create config label
    ObjectCreate(0, panelPrefix + "ConfInfo", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "ConfInfo", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "ConfInfo", OBJPROP_YDISTANCE, PanelY + 310);
    ObjectSetInteger(0, panelPrefix + "ConfInfo", OBJPROP_COLOR, textDimColor);
    ObjectSetString(0, panelPrefix + "ConfInfo", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "ConfInfo", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + "ConfInfo", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create last action label
    ObjectCreate(0, panelPrefix + "LastAction", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "LastAction", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "LastAction", OBJPROP_YDISTANCE, PanelY + 340);
    ObjectSetInteger(0, panelPrefix + "LastAction", OBJPROP_COLOR, colorYellow);
    ObjectSetString(0, panelPrefix + "LastAction", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "LastAction", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + "LastAction", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create last signal label
    ObjectCreate(0, panelPrefix + "LastSignal", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "LastSignal", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "LastSignal", OBJPROP_YDISTANCE, PanelY + 362);
    ObjectSetInteger(0, panelPrefix + "LastSignal", OBJPROP_COLOR, textDimColor);
    ObjectSetString(0, panelPrefix + "LastSignal", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "LastSignal", OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, panelPrefix + "LastSignal", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create timestamp label
    ObjectCreate(0, panelPrefix + "Timestamp", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panelPrefix + "Timestamp", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + "Timestamp", OBJPROP_YDISTANCE, PanelY + 380);
    ObjectSetInteger(0, panelPrefix + "Timestamp", OBJPROP_COLOR, (color)0x4C566A);
    ObjectSetString(0, panelPrefix + "Timestamp", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + "Timestamp", OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, panelPrefix + "Timestamp", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    panelInitialized = true;
    Print("=== INFO PANEL CREATED ===");
    return true;
}

//+------------------------------------------------------------------+
//| Create status label for strategies - Modern Colors                |
//+------------------------------------------------------------------+
void CreateStatusLabel(string name, int y)
{
    // Modern colors
    color textDimColor = (color)0x4C566A;       // Dim gray
    color colorRed = (color)0xBF616A;           // Soft red

    // Create label
    ObjectCreate(0, panelPrefix + name + "Label", OBJ_LABEL, 0, 0, 0);
    ObjectSetString(0, panelPrefix + name + "Label", OBJPROP_TEXT, name + ":");
    ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_XDISTANCE, PanelX + 12);
    ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_COLOR, textDimColor);
    ObjectSetString(0, panelPrefix + name + "Label", OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_CORNER, CORNER_LEFT_UPPER);

    // Create value
    ObjectCreate(0, panelPrefix + name + "Value", OBJ_LABEL, 0, 0, 0);
    ObjectSetString(0, panelPrefix + name + "Value", OBJPROP_TEXT, "OFF");
    ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_XDISTANCE, PanelX + 82);
    ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_COLOR, colorRed);
    ObjectSetString(0, panelPrefix + name + "Value", OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_CORNER, CORNER_LEFT_UPPER);
}

//+------------------------------------------------------------------+
//| Update info panel data - Modern Colors                            |
//+------------------------------------------------------------------+
void UpdatePanel()
{
    if (!ShowInfoPanel || !panelInitialized)
        return;

    datetime currentTime = TimeCurrent();
    // Update only at specified interval
    if ((currentTime - lastPanelUpdate) < PanelUpdateInterval)
        return;

    // Modern colors
    color textMutedColor = (color)0x88C0D0;     // Soft cyan
    color textDimColor = (color)0x4C566A;       // Dim gray
    color colorGreen = (color)0xA3BE8C;         // Muted green
    color colorRed = (color)0xBF616A;           // Soft red
    color colorYellow = (color)0xEBCB8B;        // Soft yellow
    color colorOrange = (color)0xD08770;        // Soft orange

    lastPanelUpdate = currentTime;

    // Update trend marker if enabled
    if (TrendMarkerEnabled)
    {
        string trendArrow = GetTrendArrow(currentTrendDirection);
        color trendColor = GetTrendColor(currentTrendDirection);

        // Update trend arrow
        ObjectSetString(0, panelPrefix + "TrendArrow", OBJPROP_TEXT, trendArrow);
        ObjectSetInteger(0, panelPrefix + "TrendArrow", OBJPROP_COLOR, trendColor);

        // Update trend text
        string trendText = "TREND: " + currentTrendDirection;
        ObjectSetString(0, panelPrefix + "TrendText", OBJPROP_TEXT, trendText);
        ObjectSetInteger(0, panelPrefix + "TrendText", OBJPROP_COLOR, trendColor);

        // Update trend strength
        if (TrendStrengthDisplay)
        {
            ObjectSetString(0, panelPrefix + "TrendStrength", OBJPROP_TEXT, currentTrendStrength);
            ObjectSetInteger(0, panelPrefix + "TrendStrength", OBJPROP_COLOR, trendColor);
        }
    }

    // Update symbol info
    string signalDisplay = signalHasSymbol ? signalSymbol : "any";
    if (signalHasSymbol && signalSymbol != TradingSymbol)
    {
        ObjectSetString(0, panelPrefix + "SymbolInfo", OBJPROP_TEXT, "Symbol: " + TradingSymbol + " | Signal: " + signalDisplay + " (IGNORED)");
        ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_COLOR, colorRed);
    }
    else
    {
        ObjectSetString(0, panelPrefix + "SymbolInfo", OBJPROP_TEXT, "Symbol: " + TradingSymbol + " | Signal: " + signalDisplay);
        ObjectSetInteger(0, panelPrefix + "SymbolInfo", OBJPROP_COLOR, textMutedColor);
    }

    // Update strategy statuses
    UpdateStrategyStatus("Hedge", EnableHedge, isInHedgeMode ? "L" + IntegerToString(currentHedgeLevel) : "OFF");
    UpdateStrategyStatus("Candle", EnableCandleConfirmation, EnableCandleConfirmation ? "ON" : "OFF");
    UpdateStrategyStatus("Close", OpenOnCandleClose, OpenOnCandleClose ? "WAIT" : "IMMED");

    // Update Positive Scalping status
    string scalpingStatus = "OFF";
    if (EnablePositiveScalping)
    {
        if (isInPositiveScalping)
        {
            scalpingStatus = "L" + IntegerToString(currentScalpingLevel) + "/" + IntegerToString(MaxScalpingLevels);
            if (lastPositiveCheckTime > 0)
            {
                datetime currentTime = TimeCurrent();
                int secondsSinceProfit = (int)(currentTime - lastPositiveCheckTime);
                int secondsToNext = MathMax(0, PositiveProfitSeconds - secondsSinceProfit);
                scalpingStatus += " | +" + IntegerToString(secondsToNext);
            }
        }
        else
        {
            scalpingStatus = "WAIT";
        }
    }
    UpdateStrategyStatus("Scalping", EnablePositiveScalping, scalpingStatus);

    // Update chart status
    string chartStatus = "";
    int width = GetChartWidth();
    int height = GetChartHeight();

    if (!IsChartSuitable())
    {
        if (!AllowSideChart && IsSideChart())
        {
            chartStatus = "CHART: SIDE MODE - BLOCKED";
            ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorRed);
        }
        else if (CheckChartSize && (width < MinChartWidth || height < MinChartHeight))
        {
            chartStatus = "CHART: TOO SMALL (" + IntegerToString(width) + "x" + IntegerToString(height) + ")";
            ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorOrange);
        }
        else
        {
            chartStatus = "CHART: BLOCKED";
            ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorRed);
        }
    }
    else
    {
        if (AllowSideChart && IsSideChart())
        {
            chartStatus = "CHART: SIDE MODE ENABLED";
            ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorYellow);
        }
        else
        {
            chartStatus = "CHART: NORMAL (" + IntegerToString(width) + "x" + IntegerToString(height) + ")";
            ObjectSetInteger(0, panelPrefix + "ChartStatus", OBJPROP_COLOR, colorGreen);
        }
    }
    ObjectSetString(0, panelPrefix + "ChartStatus", OBJPROP_TEXT, chartStatus);

    // Update position info
    string posInfo = "";
    int openPositions = 0;
    double currentPL = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == TradingSymbol && positionInfo.Magic() == MagicNumber)
            {
                openPositions++;
                currentPL += positionInfo.Swap() + positionInfo.Commission() + positionInfo.Profit();
            }
        }
    }

    if (openPositions > 0)
    {
        posInfo = "POS: " + IntegerToString(openPositions) + " | PL: " + DoubleToString(currentPL, 2);
        ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_COLOR, currentPL >= 0 ? colorGreen : colorRed);

        // Add scalping direction info if in positive scalping mode
        if (isInPositiveScalping && scalpingDirection != "")
        {
            posInfo += " | Scalping: " + scalpingDirection;
        }
    }
    else
    {
        posInfo = "NO POSITIONS";
        ObjectSetInteger(0, panelPrefix + "PosInfo", OBJPROP_COLOR, textDimColor);
    }
    ObjectSetString(0, panelPrefix + "PosInfo", OBJPROP_TEXT, posInfo);

    // Update performance info
    string perfInfo = "Trades: " + IntegerToString(dailyTradeCount) + " | Daily: " + DoubleToString(totalDailyPL, 2);
    ObjectSetString(0, panelPrefix + "PerfInfo", OBJPROP_TEXT, perfInfo);
    ObjectSetInteger(0, panelPrefix + "PerfInfo", OBJPROP_COLOR, totalDailyPL >= 0 ? colorGreen : colorRed);

    // Update config info
    string lotMode = UseFixedLots ? "FIXED: " + DoubleToString(FixedLotSize, 2) : "RISK: " + DoubleToString(RiskPercent, 1) + "%";
    string confInfo = lotMode + " | TP: " + IntegerToString(adjustedTPPoints) + " | SL: " + IntegerToString(adjustedSLPoints);

    // Add Positive Scalping target info if enabled
    if (EnablePositiveScalping)
    {
        double currentProfit = GetTotalScalpingProfit();
        double profitProgress = MathMin(100, (currentProfit / ScalpingProfitTarget) * 100);
        confInfo += " | Scalping: " + DoubleToString(currentProfit, 0) + "/" + IntegerToString(ScalpingProfitTarget) + " (" + DoubleToString(profitProgress, 0) + "%)";
    }

    ObjectSetString(0, panelPrefix + "ConfInfo", OBJPROP_TEXT, confInfo);

    // Update last action
    ObjectSetString(0, panelPrefix + "LastAction", OBJPROP_TEXT, "Last: " + lastAction);

    // Update last signal time
    if (lastSignalTime > 0)
    {
        string signalInfo = "Signal: " + TimeToString(lastSignalTime, TIME_MINUTES | TIME_SECONDS);
        ObjectSetString(0, panelPrefix + "LastSignal", OBJPROP_TEXT, signalInfo);
    }
    else
    {
        ObjectSetString(0, panelPrefix + "LastSignal", OBJPROP_TEXT, "Signal: None");
    }

    // Update timestamp
    ObjectSetString(0, panelPrefix + "Timestamp", OBJPROP_TEXT, TimeToString(currentTime));
}

//+------------------------------------------------------------------+
//| Update individual strategy status - Modern Colors                 |
//+------------------------------------------------------------------+
void UpdateStrategyStatus(string name, bool enabled, string value)
{
    if (!ObjectFind(0, panelPrefix + name + "Value"))
        return;

    // Modern colors
    color textDimColor = (color)0x4C566A;       // Dim gray
    color colorGreen = (color)0xA3BE8C;         // Muted green
    color colorRed = (color)0xBF616A;           // Soft red
    color colorDarkerGray = (color)0x3B4252;    // Darker gray for disabled

    ObjectSetString(0, panelPrefix + name + "Value", OBJPROP_TEXT, value);

    if (!enabled)
    {
        ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_COLOR, colorRed);
        ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_COLOR, colorDarkerGray);
    }
    else
    {
        ObjectSetInteger(0, panelPrefix + name + "Value", OBJPROP_COLOR, colorGreen);
        ObjectSetInteger(0, panelPrefix + name + "Label", OBJPROP_COLOR, textDimColor);
    }
}

//+------------------------------------------------------------------+
//| Delete info panel                                                 |
//+------------------------------------------------------------------+
void DeleteInfoPanel()
{
    if (!panelInitialized)
        return;

    // Delete all panel objects
    ObjectsDeleteAll(0, panelPrefix);
    panelInitialized = false;
    Print("=== INFO PANEL DELETED ===");
}

//+------------------------------------------------------------------+
