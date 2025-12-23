// TVLucro EA v4.4 - Chart Layout Prevention
// Expert Advisor with chart layout detection and trading prevention
// L^e sinais de arquivo JSON escrito pelo Flask

#property copyright "MT5 Webhook Automation"
#property link      "https://github.com"
#property version   "4.5"
#property strict
#property description "TVLucro EA v4.5 with Trend Marker"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- input parameters
input string   TradingSymbol = "XAUUSD";         // Symbol to trade
input int      MagicNumber = 12345;           // Magic number for orders
input double   RiskPercent = 2.0;             // % do equity por trade
input bool     UseFixedLots = false;          // Usar lote fixo em vez de % de risco
input double   FixedLotSize = 0.01;            // Tamanho do lote fixo (se UseFixedLots=true)
input bool     ValidateLotSize = true;         // Validar limites de lote do broker
input int      TakeProfitPoints = 1000;       // TP em pontos (ex: 1000 = $10 para XAUUSD)
input int      StopLossPoints = 500;          // SL em pontos (ex: 500 = $5 para XAUUSD)
input int      PollingIntervalSec = 1;        // Frequ^encia polling (segundos)
input string   SignalFilePath = "signal.json"; // Caminho do arquivo de sinal
input bool     EnableBreakeven = true;        // Ativar Breakeven
input int      BreakEvenPoints = 100;         // Breakeven ap'os X pontos de lucro
input int      BreakEvenExtraPoints = 20;     // Pontos al'em do ponto de entrada
input bool     EnableTrailingStop = true;     // Ativar Trailing Stop
input int      TrailingStopPoints = 100;      // Trailing stop em pontos
input int      TrailingStepPoints = 50;       // Mover SL a cada X pontos
input bool     UseATRBasedSL = false;         // SL inicial baseado em ATR
input int      ATRPeriod = 14;                // Per'iodo do ATR
input double   ATRMultiplier = 1.5;           // Multiplicador do ATR para SL
input bool     EnableReverseTrading = false;  // Inverter sinais (long->sell, short->buy)
input bool     AutoAdjustForSymbol = true;    // Auto-ajustar valores por s'imbolo
input bool     EnableHedge = false;           // Ativar sistema de Hedge Martingale
input int      HedgeProfitTarget = 100;       // Meta de lucro total em pontos (hedge)
input double   HedgeMultiplier = 2.0;         // Multiplicador martingale do volume
input int      MaxHedgeLevels = 5;            // M'aximo de n'iveis de hedge permitidos
input bool     EnableTrendContinuation = true; // Reentrar ap'os TP em tend^encias
input int      TrendContinuationDelaySec = 60; // Segundos antes de reentrar
input int      MaxConsecutiveReentries = 3;    // M'aximo de reentradas seguidas
input double   ReentryRiskPercent = 1.5;       // % risco para reentradas (menor que principal)
input bool     EnableCandleConfirmation = true; // Confirmar tend^encia por candles
input int      CandleConfirmationCount = 3;    // N'umero de velas a verificar
input ENUM_TIMEFRAMES CandleConfirmationTF = PERIOD_CURRENT; // Timeframe para an'alise
input bool     RequireConsecutiveCandles = true; // Exigir todas consecutivas (false=maioria)
input bool     WaitForCandleClose = true;      // Aguardar fechamento da vela
input bool     OpenOnCandleClose = false;       // Abrir posic~ao apenas no fechamento da vela
input ENUM_TIMEFRAMES CandleCloseTimeframe = PERIOD_CURRENT; // Timeframe para monitorar fechamento
input int      MaxPendingSignals = 3;            // M'aximo de sinais pendentes
input int      PendingSignalExpirationSec = 300; // Expirac~ao de sinal pendente (segundos)

//--- Info Panel Parameters
input bool     ShowInfoPanel = true;           // Mostrar painel informativo
input int      PanelX = 20;                     // Posic~ao X do painel
input int      PanelY = 50;                     // Posic~ao Y do painel
input int      PanelWidth = 200;                // Largura do painel
input int      PanelUpdateInterval = 1;         // Segundos entre atualizac~oes do painel

//--- Chart Layout Parameters
input bool     CheckChartSize = true;           // Verificar tamanho m'inimo do gr'afico
input int      MinChartWidth = 400;              // Largura m'inima para operar (pixels)
input int      MinChartHeight = 300;             // Altura m'inima para operar (pixels)
input bool     AllowSideChart = false;          // Permitir gr'afico lateral (false = bloquear)

//--- Trend Marker Parameters
input bool     TrendMarkerEnabled = true;        // Ativar marcador de tend^encia no painel
input int      TrendMAPeriodFast = 9;            // Per'iodo da m'edia m'ovel r'apida
input int      TrendMAPeriodSlow = 21;           // Per'iodo da m'edia m'ovel lenta
input ENUM_MA_METHOD TrendMAType = MODE_EMA;     // Tipo: SMA=0, EMA=1, SMMA=2, LWMA=3
input bool     TrendStrengthDisplay = true;      // Exibir forca da tend^encia

//--- Positive Scalping Parameters
input bool     EnablePositiveScalping = false;   // Ativar sistema de scalping positivo
input int      PositiveProfitSeconds = 15;      // Segundos de lucro para abrir nova posic~ao
input double   ScalpingVolumeMultiplier = 1.5;   // Multiplicador do volume nas posic~oes scalping
input int      MaxScalpingLevels = 5;            // M'aximo de posic~oes escalping permitidas
input int      ScalpingProfitTarget = 200;       // Meta de lucro total em pontos (todas as posic~oes)
input bool     EnableScalpingBreakeven = true;   // Ativar breakeven para posic~oes scalping
input int      ScalpingBreakevenPoints = 50;     // Pontos de lucro para ativar breakeven nas posic~oes scalping

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

//--- Hedge Martingale variables
int currentHedgeLevel = 0;          // N'ivel atual de martingale (0 = sem hedge)
bool isInHedgeMode = false;         // Flag indicando modo hedge ativo
double lastHedgeVolume = 0;         // 'Ultimo volume usado no hedge
double initialHedgeVolume = 0;      // Volume inicial da primeira posic~ao

//--- Trend Continuation variables
string lastTradeDirection = "";       // "buy" ou "sell"
datetime lastTradeCloseTime = 0;      // Timestamp do fechamento
double lastTradeProfit = 0;           // Lucro do 'ultimo trade
bool lastTradeWasWin = false;         // Se fechou com lucro
int consecutiveReentries = 0;         // Contador de reentradas
bool hasOpenPosition = false;         // Cache de posic~ao aberta
ulong lastKnownTicket = 0;            // Ticket da 'ultima posic~ao conhecida

//--- Candle Confirmation variables
datetime lastCheckedCandleTime = 0;   // Timestamp da 'ultima vela verificada

//--- Startup Protection
datetime eaStartTime = 0;             // Timestamp de quando o EA iniciou
int startupDelaySeconds = 5;          // Segundos para ignorar sinais no startup

//--- Signal Symbol
string signalSymbol = "";             // S'imbolo do sinal recebido
bool signalHasSymbol = false;         // Se o sinal cont'em campo 'symbol'

//--- Signal Processing Variables
string currentSignalDirection = "";   // Direction do sinal atual (buy/sell)
string currentSignalSymbol = "";      // Symbol do sinal atual

//--- Execution Prevention on Startup
datetime eaInitializationTime = 0;    // Timestamp exato da inicializac~ao (para validar sinais)

//--- Candle Close Execution variables
string pendingSignals[10];            // Fila de sinais pendentes (m'aximo 10)
int pendingSignalsCount = 0;           // Contador de sinais na fila
datetime pendingSignalTimes[10];       // Timestamps dos sinais pendentes
datetime lastCandleCloseTime = 0;      // 'Ultimo timestamp de fechamento
bool isProcessingCandleClose = false;  // Flag para evitar processamento duplicado

//--- Info Panel variables
datetime lastPanelUpdate = 0;          // 'Ultima atualizac~ao do painel
bool panelInitialized = false;         // Flag indicando se painel foi criado
string panelPrefix = "TVLucroPanel_";  // Prefixo para objetos do painel
double totalDailyPL = 0;              // PL di'ario total
int dailyTradeCount = 0;               // Contador de trades di'arios
string lastAction = "None";            // 'Ultima ac~ao executada
datetime lastSignalTime = 0;           // Timestamp do 'ultimo sinal

//--- Trend Marker variables
int trendMAFastHandle = INVALID_HANDLE;    // Handle da m'edia m'ovel r'apida
int trendMASlowHandle = INVALID_HANDLE;    // Handle da m'edia m'ovel lenta
double currentTrendValue = 0;              // Valor atual da tend^encia
string currentTrendDirection = "NEUTRAL";  // Direc~ao atual da tend^encia
string currentTrendStrength = "WEAK";      // Forca atual da tend^encia

//--- Positive Scalping State
int currentScalpingLevel = 0;            // N'ivel atual de scalping (0 = sem scalping)
bool isInPositiveScalping = false;        // Flag indicando modo scalping positivo ativo
double lastScalpingVolume = 0;             // Volume da 'ultima posic~ao de scalping
datetime lastPositiveCheckTime = 0;       // 'Ultima verificac~ao de positividade
double totalScalpingProfit = 0;           // Lucro total acumulado nas posic~oes scalping
string scalpingDirection = "";             // Direc~ao das posic~oes scalping (buy/sell)

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

    // Usar valores configurados pelo usu'ario
    int suggestedTP = TakeProfitPoints;
    int suggestedSL = StopLossPoints;
    int suggestedBE = BreakEvenPoints;
    int suggestedTrailing = TrailingStopPoints;

    Print("User configured values:");
    Print("  TakeProfit: ", suggestedTP, " points");
    Print("  StopLoss: ", suggestedSL, " points");
    Print("  Breakeven: ", suggestedBE, " points");
    Print("  Trailing: ", suggestedTrailing, " points");

    // Validar contra stop level m'inimo
    if (minStopLevel > 0)
    {
        int minRequired = minStopLevel + 10; // Adiciona margem de seguranca

        if (suggestedSL < minRequired)
        {
            Print("Adjusting SL: ", suggestedSL, " -> ", minRequired, " (min required)");
            suggestedSL = minRequired;
        }

        if (suggestedTP < minRequired)
        {
            Print("Adjusting TP: ", suggestedTP, " -> ", minRequired * 2, " (min required)");
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
    }

    // Aplicar valores (validados contra stop level m'inimo)
    adjustedTPPoints = suggestedTP;
    adjustedSLPoints = suggestedSL;
    adjustedBEPoints = suggestedBE;
    adjustedTrailingPoints = suggestedTrailing;

    Print("FINAL VALUES (after validation):");
    Print("  TakeProfit: ", adjustedTPPoints, " points (", adjustedTPPoints * point, " price)");
    Print("  StopLoss: ", adjustedSLPoints, " points (", adjustedSLPoints * point, " price)");
    Print("  Breakeven: ", adjustedBEPoints, " points");
    Print("  Trailing: ", adjustedTrailingPoints, " points");
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Setup timer for polling
    EventSetTimer(PollingIntervalSec);
    Print("Timer set to poll every ", PollingIntervalSec, " second(s)");

    // Register timestamp exato de inicializac~ao
    eaInitializationTime = TimeCurrent();
    Print("EA Initialization Time: ", eaInitializationTime);

    // Inicializar vari'aveis de processamento de sinal sem ler arquivo existente
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
        Print("Failed to refresh symbol rates");
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
        Print("  -> LONG signals will open SELL orders");
        Print("  -> SHORT signals will open BUY orders");
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
        Print("Trailing Step: ", TrailingStepPoints, " points");
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
        Print("Note: When position in loss + opposite signal -> opens hedge");
        Print("Note: Closes ALL positions when total profit >= target");
    }
    Print("--- Trend Continuation Settings ---");
    Print("Trend Continuation: ", EnableTrendContinuation ? "YES" : "NO");
    if (EnableTrendContinuation)
    {
        Print("Reentry Delay: ", TrendContinuationDelaySec, " seconds");
        Print("Max Reentries: ", MaxConsecutiveReentries);
        Print("Reentry Risk: ", ReentryRiskPercent, "%");
        Print("--- Candle Confirmation Settings ---");
        Print("Candle Confirmation: ", EnableCandleConfirmation ? "YES" : "NO");
        if (EnableCandleConfirmation)
        {
            Print("Candles to Check: ", CandleConfirmationCount);
            Print("Timeframe: ", TimeframeToString(CandleConfirmationTF));
            Print("Mode: ", RequireConsecutiveCandles ? "ALL consecutive" : "MAJORITY (>50%)");
            Print("Wait for Close: ", WaitForCandleClose ? "YES" : "NO");
        }
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

    // Initialize trend continuation state to prevent auto-trigger on startup
    lastTradeWasWin = false;
    lastTradeDirection = "";
    lastTradeCloseTime = 0;
    consecutiveReentries = 0;

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
        CreateInfoPanel();
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

    // Check for position closure (trend continuation feature)
    if (EnableTrendContinuation && !isInHedgeMode)
    {
        CheckPositionClosure();
    }

    // Gerenciar lucro total do hedge (verifica se atingiu meta)
    if (EnableHedge)
    {
        ManageHedgeProfit();
    }

    // Gerenciar breakeven e trailing stop para posic~oes abertas
    // Nota: N~ao aplicar em modo hedge (posic~oes sem TP/SL individual)
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

        // Don't process new signals, but still check for trend continuation (which should also check chart)
        if (!isInHedgeMode && ShouldReenterTrend())
        {
            ExecuteTrendContinuation();
        }
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
                            Print("=== POSITIVE SCALPING CHECK ===");
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
                else
                {
                    // Target reached - close all positions
                    Print("=== POSITIVE SCALPING TARGET REACHED ===");
                    Print("Total profit: ", GetTotalScalpingProfit(), " points (Target: ", ScalpingProfitTarget, ")");
                    Print("Closing ALL positions...");

                    if (CloseAllPositions())
                    {
                        Print("=== POSITIVE SCALPING SUCCESS ===");
                        Print("All positions closed with ", GetTotalScalpingProfit(), " points profit");
                        ResetScalpingState();
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

    // Evitar reprocessamento (mesmo conte'udo)
    if (json == lastProcessedJson) {
        // No new signal - check for trend continuation reentry (only if not in hedge mode)
        if (!isInHedgeMode && ShouldReenterTrend())
        {
            ExecuteTrendContinuation();
        }
        return;
    }

    if (json != "" && json != lastProcessedJson) {
        // Extrair s'imbolo do sinal
        signalSymbol = ExtractSymbolFromJSON(json);
        signalHasSymbol = (signalSymbol != "");

        // Verificar se o sinal 'e para este EA
        if (!IsSignalForThisSymbol())
        {
            LogIgnoredSignal();
            return;
        }

        // Extrair direction e symbol do sinal
        currentSignalDirection = ExtractDirectionFromJSON(json);
        currentSignalSymbol = signalSymbol;  // J'a extra'ido acima

        // Validar timestamp do sinal (se existir)
        if (!IsSignalRecent(json))
        {
            Print("Signal ignored - timestamp validation failed");
            return;
        }

        // Validac~ao simplificada (sinais sem timestamp)
        Print("NEW Signal received: ", json);
        Print("Processing signal: direction=", currentSignalDirection, " symbol=", currentSignalSymbol);

        // Verificar se deve executar imediatamente ou aguardar fechamento
        if (OpenOnCandleClose)
        {
            // Adicionar `a fila para execuc~ao no fechamento da vela
            QueuePendingSignal(json);
        }
        else
        {
            // Execuc~ao imediata (comportamento padr~ao)
            ProcessTradeSignal(json, false);  // N~ao forcar fechamento de posic~oes existentes
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
        // Arquivo n~ao existe ainda - normal no in'icio
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
        // Campo 'symbol' n~ao encontrado - sinal antigo (backward compatibility)
        return "";
    }

    // Extrair valor ap'os "symbol":
    int valueStart = keyPos + StringLen(symbolKey);

    // Pular espacos em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Verificar se 'e string (entre aspas)
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

    // Extrair o s'imbolo
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
            // Campo n~ao encontrado - sinal antigo
            return "unknown";
        }

        // Extrair valor do action
        int valueStart = keyPos + StringLen(actionKey);

        // Pular espacos em branco
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

    // Extrair valor ap'os "direction":
    int valueStart = keyPos + StringLen(directionKey);

    // Pular espacos em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Verificar se 'e string (entre aspas)
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

    // Extrair a direc~ao
    string direction = StringSubstr(json, valueStart, valueEnd - valueStart);

    Print("Signal direction extracted: ", direction);
    return direction;
}

//+------------------------------------------------------------------+
//| Check if signal is intended for this EA                           |
//+------------------------------------------------------------------+
bool IsSignalForThisSymbol()
{
    // Se n~ao tem campo 'symbol', 'e um sinal antigo - processar (backward compatibility)
    if (!signalHasSymbol)
    {
        Print("Signal has no 'symbol' field - processing for backward compatibility");
        return true;
    }

    // Se tem 'symbol', comparar com o configurado
    int result = StringCompare(signalSymbol, TradingSymbol);

    if (result == 0)
    {
        // S'imbolo corresponde - processar o sinal
        Print("Signal symbol '", signalSymbol, "' matches EA symbol '", TradingSymbol, "' - processing signal");
        return true;
    }
    else
    {
        // S'imbolo n~ao corresponde - ignorar
        Print("Signal symbol '", signalSymbol, "' does NOT match EA symbol '", TradingSymbol, "' - ignoring signal");
        return false;
    }
}

//+------------------------------------------------------------------+
//| Log ignored signal details                                         |
//+------------------------------------------------------------------+
void LogIgnoredSignal()
{
    // Extrair direc~ao do sinal para logging
    string direction = "unknown";
    string directionKey = "\"direction\":";
    int dirPos = StringFind(lastProcessedJson, directionKey);

    if (dirPos != -1)
    {
        int dirStart = dirPos + StringLen(directionKey);
        // Pular espacos e aspas
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
        // Se n~ao encontrar timestamp, usar timestamp atual (para compatibilidade)
        Print("WARNING: No timestamp field found in signal JSON - using current time");
        return TimeCurrent();
    }

    // Extrair valor ap'os "timestamp":
    int valueStart = keyPos + StringLen(timestampKey);

    // Pular espacos em branco
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Encontrar fim do valor (v'irgula ou fim do objeto)
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
    if (timestamp > 1000000000) // Timestamp v'alido (aprox 2001+)
    {
        Print("DEBUG: Parsed as Unix timestamp: ", timestamp, " -> ", TimeToString((datetime)timestamp));
        return (datetime)timestamp;
    }

    // Se for muito grande, pode estar em milissegundos
    if (timestamp > 1000000000000) // Prov'avel milissegundos
    {
        timestamp = timestamp / 1000; // Converter para segundos
        Print("DEBUG: Converted from milliseconds: ", timestamp, " -> ", TimeToString((datetime)timestamp));
        return (datetime)timestamp;
    }

    // Tentar parse ISO format
    // Remover microseconds e timezone se existirem
    StringReplace(timestampStr, ".", ""); // Remove microsegundos
    StringReplace(timestampStr, "T", " "); // Converte T para espaco
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
                           TrendMAType, PRICE_CLOSE);
    if (trendMAFastHandle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create fast MA indicator");
        return false;
    }

    // Create slow MA handle
    trendMASlowHandle = iMA(TradingSymbol, PERIOD_CURRENT, TrendMAPeriodSlow, 0,
                           TrendMAType, PRICE_CLOSE);
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
        return "^";
    else if (direction == "DOWN")
        return "V";
    else
        return "->";
}

//+------------------------------------------------------------------+
//| Get trend color based on direction                               |
//+------------------------------------------------------------------+
color GetTrendColor(string direction)
{
    if (direction == "UP")
        return clrLime;
    else if (direction == "DOWN")
        return clrRed;
    else
        return clrGray;
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
        Print("TREND CHANGED: ", currentTrendDirection, " -> ", newDirection);
        currentTrendDirection = newDirection;
    }

    currentTrendStrength = newStrength;
}

//+------------------------------------------------------------------+
//| Check if signal is recent (after EA initialization)              |
//+------------------------------------------------------------------+
bool IsSignalRecent(string json)
{
    if (json == "" || json == lastProcessedJson)
    {
        return false; // Sinal vazio ou j'a processado
    }

    datetime signalTime = ExtractTimestampFromJSON(json);

    if (signalTime == 0)
    {
        Print("WARNING: Signal without valid timestamp - ignoring");
        return false;
    }

    // Verificar se o sinal 'e mais recente que a inicializac~ao do EA
    if (signalTime <= eaInitializationTime)
    {
        Print("Signal timestamp (", TimeToString(signalTime),
              ") is older than EA initialization (", TimeToString(eaInitializationTime),
              ") - ignoring old signal");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Queue a signal for execution at candle close                     |
//+------------------------------------------------------------------+
void QueuePendingSignal(string signalJson)
{
    // Verificar se j'a temos um sinal igual na fila
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

    // Se atingiu o limite m'aximo, remover o mais antigo
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

    // Adicionar novo sinal no fim da fila
    pendingSignals[pendingSignalsCount] = signalJson;
    pendingSignalTimes[pendingSignalsCount] = TimeCurrent();
    pendingSignalsCount++;

    Print("Signal queued for candle close execution (#", pendingSignalsCount, ")");
    Print("Queued signal: ", signalJson);
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
            // Marcar para remoc~ao
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
            // Mover para nova posic~ao
            if (newIndex != i)
            {
                pendingSignals[newIndex] = pendingSignals[i];
                pendingSignalTimes[newIndex] = pendingSignalTimes[i];
            }
            newIndex++;
        }
    }

    // Limpar posic~oes restantes
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

    // Se 'e a primeira vez que checamos
    if (lastCandleCloseTime == 0)
    {
        lastCandleCloseTime = currentCandleTime;
        return false; // N~ao consideramos como "fechamento" na primeira vez
    }

    // Se o tempo da vela atual 'e diferente do 'ultimo registrado,
    // significa que uma nova vela comecou (a anterior fechou)
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

    // Verificar se j'a est'a processando para evitar duplicatas
    if (isProcessingCandleClose)
    {
        return;
    }

    isProcessingCandleClose = true;

    // Pegar o sinal mais recente ('ultimo da fila)
    string signalToExecute = pendingSignals[pendingSignalsCount - 1];

    Print("=== EXECUTING PENDING SIGNAL AT CANDLE CLOSE ===");
    Print("Pending signals count: ", pendingSignalsCount);
    Print("Executing signal: ", signalToExecute);

    // Executar o sinal
    ProcessTradeSignal(signalToExecute, true);

    // Limpar todos os sinais pendentes ap'os execuc~ao
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
    double elapsedSeconds = (double)(currentTime - positionInfo.Time());

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

// Apply breakeven to scalping positions (TEMPORARILY DISABLED)
void ApplyScalpingBreakeven()
{
    // Breakeven functionality temporarily disabled for compilation
    // TODO: Fix PositionType() method issue
    Print("Scalping breakeven is temporarily disabled");
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
    return (ENUM_POSITION_TYPE)-1; // Nenhuma posic~ao
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

    // Retornar lucro m'edio ponderado por volume
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
        // Hedges subsequentes: 'ultimo volume * multiplicador
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

    // Verificar limite de n'iveis
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

    // Verificar se ainda h'a posic~oes abertas
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

        if (CloseAllPositions())
        {
            Print("=== HEDGE SUCCESS ===");
            Print("All positions closed with ", totalProfitPoints, " points profit");
            ResetHedgeState();
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
                  " -> SL=", sl);
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
    Print("Entry: ", ask, " | SL: ", sl, " (distance = ", slDistance, ") | TP: ", tp, " (", adjustedTPPoints, " pts)");

    // Validar stops m'inimos
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

    // Gerar coment'ario automaticamente: direction + symbol + "c"
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
                  " -> SL=", sl);
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
    Print("Entry: ", bid, " | SL: ", sl, " (distance = ", slDistance, ") | TP: ", tp, " (", adjustedTPPoints, " pts)");

    // Validar stops m'inimos
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

    // Gerar coment'ario automaticamente: direction + symbol + "c"
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
        Print("Original Signal: ", originalAction, " -> Reversed to: ", action);
    }

    // Logging diferenciado para execuc~ao pendente
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

    // Reset trend continuation state on new signal
    if (EnableTrendContinuation)
    {
        if (consecutiveReentries > 0)
        {
            Print("New signal received - resetting reentry counter from ", consecutiveReentries, " to 0");
        }
        consecutiveReentries = 0;
        lastTradeWasWin = false;  // Cancel any pending reentry
    }

    // Verificar condic~ao de HEDGE
    if (EnableHedge)
    {
        ENUM_POSITION_TYPE currentDirection = GetOpenPositionDirection();
        bool hasOpenPos = (currentDirection != (ENUM_POSITION_TYPE)-1);
        bool isInLoss = IsAnyPositionInLoss();

        // Determinar se sinal 'e oposto
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

        // Condic~ao de HEDGE: tem posic~ao + em preju'izo + sinal oposto
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

            // Abrir hedge na direc~ao do sinal
            if (OpenHedgePosition(action))
            {
                Print("=== HEDGE OPENED - Waiting for profit target ===");
                Print("Target: ", HedgeProfitTarget, " points");
            }
            else
            {
                Print("HEDGE FAILED - Check logs for details");
            }

            return; // N~ao executar l'ogica normal
        }

        // Se est'a em modo hedge mas recebeu mesmo sinal ou posic~ao em lucro
        if (isInHedgeMode)
        {
            Print("In hedge mode but conditions changed - continuing normal flow");
        }
    }

    // L'ogica NORMAL (sem hedge ou condic~oes n~ao atendidas)

    // 1. Fechar posic~oes (apenas se forceClosePositions for true)
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

    // Reset hedge state ao fechar todas posic~oes (apenas se fechou)
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

    // 3. Abrir ordem
    if (action == "buy")
    {
        PlaceBuyOrder(volume);
    }
    else if (action == "sell")
    {
        PlaceSellOrder(volume);
    }

    Print("=== Trade Signal Processed ===");

    // Limpar vari'aveis de s'imbolo para o pr'oximo sinal
    signalSymbol = "";
    signalHasSymbol = false;
}

//+------------------------------------------------------------------+
//| Manage Breakeven and Trailing Stop for open positions           |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
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
                // 1. Est'a habilitado E
                // 2. (Breakeven est'a desabilitado OU j'a foi aplicado)
                if (EnableTrailingStop)
                {
                    if (!EnableBreakeven || IsBreakevenActive(positionInfo.Ticket()))
                    {
                        ApplyTrailingStop(positionInfo.Ticket());
                    }
                }
            }
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

    // Verifica se o SL est'a no lado do lucro (al'em da entrada)
    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para BUY: SL acima ou igual `a entrada = breakeven ativo
        return (currentSL >= openPrice);
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        // Para SELL: SL abaixo ou igual `a entrada = breakeven ativo
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
        // Para posic~ao BUY
        double targetPrice = openPrice + breakEvenDistance;
        double newSL = NormalizeDouble(openPrice + breakEvenExtra, digits);

        // Se preco atingiu o breakeven e SL ainda n~ao foi movido
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
        // Para posic~ao SELL
        double targetPrice = openPrice - breakEvenDistance;
        double newSL = NormalizeDouble(openPrice - breakEvenExtra, digits);

        // Se preco atingiu o breakeven e SL ainda n~ao foi movido
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

    // Breakeven n~ao foi aplicado (condic~oes n~ao atingidas)
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
    double trailingStep = TrailingStepPoints * point;

    symbolInfo.RefreshRates();
    double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY)
                          ? symbolInfo.Bid()
                          : symbolInfo.Ask();

    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para posic~ao BUY
        double newSL = NormalizeDouble(currentPrice - trailingDistance, digits);

        // S'o mover SL se:
        // 1. Novo SL 'e maior que o atual (ou SL n~ao existe)
        // 2. Diferenca 'e maior que o step configurado
        if (newSL > currentSL || currentSL == 0)
        {
            if ((newSL - currentSL) >= trailingStep || currentSL == 0)
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
                    Print("TRAILING STOP FAILED: ", trade.ResultRetcodeDescription());
                }
            }
        }
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        // Para posic~ao SELL
        double newSL = NormalizeDouble(currentPrice + trailingDistance, digits);

        // S'o mover SL se:
        // 1. Novo SL 'e menor que o atual (ou SL n~ao existe)
        // 2. Diferenca 'e maior que o step configurado
        if (newSL < currentSL || currentSL == 0)
        {
            if ((currentSL - newSL) >= trailingStep || currentSL == 0)
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
                    Print("TRAILING STOP FAILED: ", trade.ResultRetcodeDescription());
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
//| Get position direction as string                                  |
//+------------------------------------------------------------------+
string GetPositionDirectionStr(ulong ticket)
{
    if (positionInfo.SelectByTicket(ticket))
    {
        if (positionInfo.PositionType() == POSITION_TYPE_BUY)
            return "buy";
        else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
            return "sell";
    }
    return "";
}

//+------------------------------------------------------------------+
//| Check for position closure and record result                      |
//+------------------------------------------------------------------+
void CheckPositionClosure()
{
    bool currentlyHasPosition = HasOpenPositionForSymbol();

    // Position was just closed
    if (hasOpenPosition && !currentlyHasPosition)
    {
        // Get trade result from history
        RecordTradeResult();
        hasOpenPosition = false;
        lastKnownTicket = 0;
    }
    // Position was just opened
    else if (!hasOpenPosition && currentlyHasPosition)
    {
        hasOpenPosition = true;
        lastKnownTicket = GetCurrentPositionTicket();

        // Record direction of new position
        if (lastKnownTicket > 0)
        {
            lastTradeDirection = GetPositionDirectionStr(lastKnownTicket);
            Print("Position opened: Ticket=", lastKnownTicket, " Direction=", lastTradeDirection);
        }
    }
}

//+------------------------------------------------------------------+
//| Record result of closed trade from history                        |
//+------------------------------------------------------------------+
void RecordTradeResult()
{
    // Select deals from history for today
    datetime startOfDay = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    HistorySelect(startOfDay, TimeCurrent());

    int totalDeals = HistoryDealsTotal();
    double profit = 0;
    string direction = lastTradeDirection;  // Use stored direction
    bool foundDeal = false;

    // Look for the most recent closed deal with our magic number
    for (int i = totalDeals - 1; i >= 0; i--)
    {
        ulong dealTicket = HistoryDealGetTicket(i);
        if (dealTicket > 0)
        {
            long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            long dealEntry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

            // Only look at exit deals for our symbol/magic
            if (dealMagic == MagicNumber &&
                dealSymbol == TradingSymbol &&
                dealEntry == DEAL_ENTRY_OUT)
            {
                profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
                profit += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
                profit += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);

                // Get direction from deal type
                long dealType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
                // DEAL_TYPE_SELL means closing a BUY, DEAL_TYPE_BUY means closing a SELL
                if (dealType == DEAL_TYPE_SELL)
                    direction = "buy";
                else if (dealType == DEAL_TYPE_BUY)
                    direction = "sell";

                foundDeal = true;
                break;
            }
        }
    }

    if (foundDeal)
    {
        lastTradeProfit = profit;
        lastTradeWasWin = (profit > 0);
        lastTradeDirection = direction;
        lastTradeCloseTime = TimeCurrent();

        Print("=== TRADE CLOSED ===");
        Print("Direction: ", lastTradeDirection);
        Print("Profit: ", lastTradeProfit);
        Print("Result: ", lastTradeWasWin ? "WIN" : "LOSS");

        if (lastTradeWasWin)
        {
            Print("Trend continuation timer started: ", TrendContinuationDelaySec, " seconds");
        }
        else
        {
            // Reset reentry counter on loss
            consecutiveReentries = 0;
            Print("Loss detected - reentry counter reset");
        }
    }
}

//+------------------------------------------------------------------+
//| Check if should execute trend continuation reentry                |
//+------------------------------------------------------------------+
bool ShouldReenterTrend()
{
    // Feature must be enabled
    if (!EnableTrendContinuation)
        return false;

    // Must have closed a winning trade
    if (!lastTradeWasWin)
        return false;

    // Must not have a position open
    if (HasOpenPositionForSymbol())
        return false;

    // Must have a valid direction
    if (lastTradeDirection == "")
        return false;

    // Must not exceed max reentries
    if (consecutiveReentries >= MaxConsecutiveReentries)
    {
        if (consecutiveReentries == MaxConsecutiveReentries)
        {
            Print("Max consecutive reentries reached (", MaxConsecutiveReentries, ") - waiting for new signal");
            consecutiveReentries++;  // Increment to avoid repeating message
        }
        return false;
    }

    // Check time elapsed since close
    datetime currentTime = TimeCurrent();
    int secondsElapsed = (int)(currentTime - lastTradeCloseTime);

    if (secondsElapsed < TrendContinuationDelaySec)
        return false;

    // Candle confirmation check (if enabled)
    if (EnableCandleConfirmation)
    {
        // Check if we should wait for candle close
        if (WaitForCandleClose)
        {
            if (!IsNewCandleFormed(CandleConfirmationTF))
            {
                // Still waiting for current candle to close
                return false;
            }
        }

        // Check if candles confirm the trend
        if (!IsTrendConfirmedByCandles(lastTradeDirection))
        {
            // Trend not confirmed by candles - don't reenter yet
            return false;
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Calculate volume for reentry (with potentially lower risk)        |
//+------------------------------------------------------------------+
double CalculateReentryVolume()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = equity * (ReentryRiskPercent / 100.0);

    double tickValue = SymbolInfoDouble(TradingSymbol, SYMBOL_TRADE_TICK_VALUE);
    double point = SymbolInfoDouble(TradingSymbol, SYMBOL_POINT);

    double slDistance = adjustedSLPoints * point;
    double volume = riskAmount / (slDistance * tickValue / point);

    // Normalize
    double minLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_STEP);

    volume = MathFloor(volume / lotStep) * lotStep;
    volume = MathMax(minLot, MathMin(maxLot, volume));

    Print("Reentry volume: Equity=", equity, " Risk=", riskAmount, " (", ReentryRiskPercent, "%) Volume=", volume);

    return volume;
}

//+------------------------------------------------------------------+
//| Execute trend continuation reentry                                |
//+------------------------------------------------------------------+
void ExecuteTrendContinuation()
{
    // CHECK CHART SUITABILITY BEFORE TREND CONTINUATION
    if (!IsChartSuitable())
    {
        Print("TREND CONTINUATION BLOCKED: Chart not suitable for trading");
        return;
    }

    Print("=== TREND CONTINUATION REENTRY ===");
    Print("Direction: ", lastTradeDirection);
    Print("Reentry #", consecutiveReentries + 1, " of max ", MaxConsecutiveReentries);

    double volume = CalculateReentryVolume();
    if (volume <= 0)
    {
        Print("ERROR: Invalid reentry volume: ", volume);
        return;
    }

    bool success = false;

    if (lastTradeDirection == "buy")
    {
        success = PlaceBuyOrder(volume);
    }
    else if (lastTradeDirection == "sell")
    {
        success = PlaceSellOrder(volume);
    }

    if (success)
    {
        consecutiveReentries++;
        // Reset win flag to prevent immediate re-reentry
        lastTradeWasWin = false;
        // Update last checked candle time
        lastCheckedCandleTime = iTime(TradingSymbol, CandleConfirmationTF, 0);
        Print("Trend continuation successful. Total reentries: ", consecutiveReentries);
    }
    else
    {
        Print("Trend continuation FAILED");
    }
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
                  (direction == "buy" ? "BULLISH" : "BEARISH"), " 