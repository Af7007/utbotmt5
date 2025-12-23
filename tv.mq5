// HttpTraderSimple.mq5
// Expert Advisor SIMPLIFICADO - SEM DLL
// Lê sinais de arquivo JSON escrito pelo Flask

#property copyright "MT5 Webhook Automation"
#property link      "https://github.com"
#property version   "4.1"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- input parameters
input string   TradingSymbol = "XAUUSD";         // Symbol to trade
input int      MagicNumber = 12345;           // Magic number for orders
input double   RiskPercent = 2.0;             // % do equity por trade
input int      TakeProfitPoints = 1000;       // TP em pontos (ex: 1000 = $10 para XAUUSD)
input int      StopLossPoints = 500;          // SL em pontos (ex: 500 = $5 para XAUUSD)
input int      PollingIntervalSec = 1;        // Frequência polling (segundos)
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
input bool     EnableTrendContinuation = true; // Reentrar após TP em tendências
input int      TrendContinuationDelaySec = 60; // Segundos antes de reentrar
input int      MaxConsecutiveReentries = 3;    // Máximo de reentradas seguidas
input double   ReentryRiskPercent = 1.5;       // % risco para reentradas (menor que principal)

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

//--- Trend Continuation variables
string lastTradeDirection = "";       // "buy" ou "sell"
datetime lastTradeCloseTime = 0;      // Timestamp do fechamento
double lastTradeProfit = 0;           // Lucro do último trade
bool lastTradeWasWin = false;         // Se fechou com lucro
int consecutiveReentries = 0;         // Contador de reentradas
bool hasOpenPosition = false;         // Cache de posição aberta
ulong lastKnownTicket = 0;            // Ticket da última posição conhecida

//--- Startup Protection
datetime eaStartTime = 0;             // Timestamp de quando o EA iniciou
int startupDelaySeconds = 5;          // Segundos para ignorar sinais no startup

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
    }

    // Aplicar valores (validados contra stop level mínimo)
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

    Print("=== HttpTrader EA Initialized v4.1 ===");
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
    Print("Signal File: ", GetSignalFilePath());
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
    Print("--- Trend Continuation Settings ---");
    Print("Trend Continuation: ", EnableTrendContinuation ? "YES" : "NO");
    if (EnableTrendContinuation)
    {
        Print("Reentry Delay: ", TrendContinuationDelaySec, " seconds");
        Print("Max Reentries: ", MaxConsecutiveReentries);
        Print("Reentry Risk: ", ReentryRiskPercent, "%");
    }

    // Initialize position tracking
    hasOpenPosition = HasOpenPositionForSymbol();
    if (hasOpenPosition)
    {
        lastKnownTicket = GetCurrentPositionTicket();
        Print("Found existing position: Ticket=", lastKnownTicket);
    }

    // IMPORTANT: Initialize lastProcessedJson with current file content
    // to avoid processing old signals on EA startup
    lastProcessedJson = ReadSignalFile();
    lastProcessedTime = TimeCurrent();
    if (lastProcessedJson != "")
    {
        Print("Ignoring existing signal file on startup: ", lastProcessedJson);
    }

    // Initialize trend continuation state to prevent auto-trigger on startup
    lastTradeWasWin = false;
    lastTradeDirection = "";
    lastTradeCloseTime = 0;
    consecutiveReentries = 0;

    Print("=== EA Ready - Waiting for NEW signals only ===");

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
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for position closure (trend continuation feature)
    if (EnableTrendContinuation)
    {
        CheckPositionClosure();
    }

    // Gerenciar breakeven e trailing stop para posições abertas
    ManageOpenPositions();
}

//+------------------------------------------------------------------+
//| Timer function for file polling                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Ler arquivo JSON
    string json = ReadSignalFile();
    datetime currentTime = TimeCurrent();

    // Evitar reprocessamento (timestamp < 5 segundos)
    if (json == lastProcessedJson && (currentTime - lastProcessedTime) < 5) {
        // No new signal - check for trend continuation reentry
        if (ShouldReenterTrend())
        {
            ExecuteTrendContinuation();
        }
        return;
    }

    if (json != "" && json != lastProcessedJson) {
        Print("Signal received: ", json);
        ProcessTradeSignal(json);
        lastProcessedJson = json;
        lastProcessedTime = currentTime;
    }
}

//+------------------------------------------------------------------+
//| Get signal file path based on symbol                             |
//+------------------------------------------------------------------+
string GetSignalFilePath()
{
    return "signal_" + TradingSymbol + ".json";
}

//+------------------------------------------------------------------+
//| Read signal from JSON file                                       |
//+------------------------------------------------------------------+
string ReadSignalFile()
{
    string signalPath = GetSignalFilePath();
    int fileHandle = FileOpen(signalPath, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);

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
//| Function to close all positions for current symbol               |
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
//| Function to calculate volume based on risk percentage            |
//+------------------------------------------------------------------+
double CalculateVolume()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = equity * (RiskPercent / 100.0);

    double tickValue = SymbolInfoDouble(TradingSymbol, SYMBOL_TRADE_TICK_VALUE);
    double point = SymbolInfoDouble(TradingSymbol, SYMBOL_POINT);

    // Volume = Risk / (SL em pontos * point * tick value / point)
    double slDistance = adjustedSLPoints * point;
    double volume = riskAmount / (slDistance * tickValue / point);

    // Normalizar
    double minLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(TradingSymbol, SYMBOL_VOLUME_STEP);

    volume = MathFloor(volume / lotStep) * lotStep;
    volume = MathMax(minLot, MathMin(maxLot, volume));

    Print("Volume calculated: Equity=", equity, " Risk=", riskAmount, " Volume=", volume);

    return volume;
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
    Print("Entry: ", ask, " | SL: ", sl, " (distance = ", slDistance, ") | TP: ", tp, " (", adjustedTPPoints, " pts)");

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

    if (trade.Buy(volume, TradingSymbol, ask, sl, tp, "WebhookTrade"))
    {
        Print("BUY SUCCESS: Vol=", volume, " Entry=", ask, " SL=", sl, " (", adjustedSLPoints, " points) TP=", tp, " (", adjustedTPPoints, " points)");
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
    Print("Entry: ", bid, " | SL: ", sl, " (distance = ", slDistance, ") | TP: ", tp, " (", adjustedTPPoints, " pts)");

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

    if (trade.Sell(volume, TradingSymbol, bid, sl, tp, "WebhookTrade"))
    {
        Print("SELL SUCCESS: Vol=", volume, " Entry=", bid, " SL=", sl, " (", adjustedSLPoints, " points) TP=", tp, " (", adjustedTPPoints, " points)");
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
void ProcessTradeSignal(string jsonData)
{
    // Parse action (simples com StringFind)
    string action = "";
    if (StringFind(jsonData, "\"action\":\"buy\"") >= 0 ||
        StringFind(jsonData, "\"action\": \"buy\"") >= 0)
    {
        action = "buy";
    }
    else if (StringFind(jsonData, "\"action\":\"sell\"") >= 0 ||
             StringFind(jsonData, "\"action\": \"sell\"") >= 0)
    {
        action = "sell";
    }
    else
    {
        Print("ERROR: Invalid action in JSON: ", jsonData);
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

    Print("=== Processing Trade Signal ===");
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

    // 1. Fechar posições
    Print("Closing all positions for ", TradingSymbol);
    if (!CloseAllPositions())
    {
        Print("WARNING: Not all positions closed");
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
                // 1. Está habilitado E
                // 2. (Breakeven está desabilitado OU já foi aplicado)
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
    double trailingStep = TrailingStepPoints * point;

    symbolInfo.RefreshRates();
    double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY)
                          ? symbolInfo.Bid()
                          : symbolInfo.Ask();

    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        // Para posição BUY
        double newSL = NormalizeDouble(currentPrice - trailingDistance, digits);

        // Só mover SL se:
        // 1. Novo SL é maior que o atual (ou SL não existe)
        // 2. Diferença é maior que o step configurado
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
        // Para posição SELL
        double newSL = NormalizeDouble(currentPrice + trailingDistance, digits);

        // Só mover SL se:
        // 1. Novo SL é menor que o atual (ou SL não existe)
        // 2. Diferença é maior que o step configurado
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
string GetPositionDirection(ulong ticket)
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
            lastTradeDirection = GetPositionDirection(lastKnownTicket);
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
        Print("Trend continuation successful. Total reentries: ", consecutiveReentries);
    }
    else
    {
        Print("Trend continuation FAILED");
    }
}

//+------------------------------------------------------------------+
