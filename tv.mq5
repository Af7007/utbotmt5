// HttpTraderSimple.mq5
// Expert Advisor SIMPLIFICADO - SEM DLL
// Lê sinais de arquivo JSON escrito pelo Flask

#property copyright "MT5 Webhook Automation"
#property link      "https://github.com"
#property version   "3.5"
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
input string   SignalFilePath = "signal.json"; // Caminho do arquivo de sinal
input bool     EnableBreakeven = true;        // Ativar Breakeven
input int      BreakEvenPoints = 100;         // Breakeven após X pontos de lucro
input int      BreakEvenExtraPoints = 20;     // Pontos além do ponto de entrada
input bool     EnableTrailingStop = true;     // Ativar Trailing Stop
input int      TrailingStopPoints = 100;      // Trailing stop em pontos (fixo)
input int      TrailingStepPoints = 50;       // Mover SL a cada X pontos
input bool     UseDynamicTrailing = false;    // Trailing dinâmico baseado em ATR
input int      ATRPeriod = 14;                // Período do ATR
input double   ATRMultiplier = 2.0;           // Multiplicador do ATR
input bool     EnableReverseTrading = false;  // Inverter sinais (long→sell, short→buy)
input bool     AutoAdjustForSymbol = true;    // Auto-ajustar valores por símbolo
input bool     UseCandleBasedSL = false;      // SL baseado em candles
input int      CandleLookback = 1;            // Quantos candles olhar (1 = último)
input int      CandleSLMarginPoints = 20;     // Margem além do Low/High (pontos)

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

    // Valores sugeridos baseados no símbolo
    int suggestedTP = TakeProfitPoints;
    int suggestedSL = StopLossPoints;
    int suggestedBE = BreakEvenPoints;
    int suggestedTrailing = TrailingStopPoints;

    // Detectar tipo de símbolo e ajustar
    if (StringFind(TradingSymbol, "BTC") >= 0 || StringFind(TradingSymbol, "BTCUSD") >= 0)
    {
        // BTCUSD: preço ~$90,000, precisa stops maiores
        suggestedTP = 10000;   // $100
        suggestedSL = 5000;    // $50
        suggestedBE = 1000;    // $10
        suggestedTrailing = 2000; // $20
        Print("Detected: BTCUSD - Using larger stop values");
    }
    else if (StringFind(TradingSymbol, "XAU") >= 0 || StringFind(TradingSymbol, "GOLD") >= 0)
    {
        // XAUUSD: preço ~$2650, stops padrão são OK
        suggestedTP = 1000;    // $10
        suggestedSL = 500;     // $5
        suggestedBE = 100;     // $1
        suggestedTrailing = 100; // $1
        Print("Detected: XAUUSD - Using default values");
    }
    else if (StringFind(TradingSymbol, "EUR") >= 0 || StringFind(TradingSymbol, "USD") >= 0)
    {
        // Forex: valores pequenos
        suggestedTP = 200;     // 20 pips
        suggestedSL = 100;     // 10 pips
        suggestedBE = 30;      // 3 pips
        suggestedTrailing = 50; // 5 pips
        Print("Detected: Forex - Using smaller values");
    }

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

    // Aplicar valores ajustados
    adjustedTPPoints = suggestedTP;
    adjustedSLPoints = suggestedSL;
    adjustedBEPoints = suggestedBE;
    adjustedTrailingPoints = suggestedTrailing;

    Print("ADJUSTED VALUES:");
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

    Print("=== HttpTrader EA Initialized v3.5 ===");
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
        Print("Dynamic Trailing: ", UseDynamicTrailing ? "YES (ATR-Based)" : "NO (Fixed)");
        if (UseDynamicTrailing)
        {
            Print("ATR Period: ", ATRPeriod);
            Print("ATR Multiplier: ", ATRMultiplier, "x");
        }
        else
        {
            Print("Trailing Distance: ", adjustedTrailingPoints, " points");
            Print("Trailing Step: ", TrailingStepPoints, " points");
        }
    }
    Print("--- Candle-Based SL Settings ---");
    Print("Candle-Based SL: ", UseCandleBasedSL ? "YES" : "NO");
    if (UseCandleBasedSL)
    {
        Print("Lookback Candles: ", CandleLookback);
        Print("Margin: ", CandleSLMarginPoints, " points");
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
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
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
double GetCandleBasedSL(bool isBuy)
{
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Encontrar o low/high mais extremo nos últimos X candles
    double extremePrice = 0;

    for (int i = 1; i <= CandleLookback; i++)
    {
        double candleHigh = iHigh(TradingSymbol, PERIOD_CURRENT, i);
        double candleLow = iLow(TradingSymbol, PERIOD_CURRENT, i);

        if (isBuy)
        {
            // Para BUY: encontrar o LOW mais baixo
            if (extremePrice == 0 || candleLow < extremePrice)
            {
                extremePrice = candleLow;
            }
        }
        else
        {
            // Para SELL: encontrar o HIGH mais alto
            if (extremePrice == 0 || candleHigh > extremePrice)
            {
                extremePrice = candleHigh;
            }
        }
    }

    // Adicionar margem
    double margin = CandleSLMarginPoints * point;
    double slPrice = 0;

    if (isBuy)
    {
        slPrice = NormalizeDouble(extremePrice - margin, digits);
        Print("Candle-Based SL (BUY): Lowest Low = ", extremePrice,
              " - Margin (", CandleSLMarginPoints, " pts) = SL ", slPrice);
    }
    else
    {
        slPrice = NormalizeDouble(extremePrice + margin, digits);
        Print("Candle-Based SL (SELL): Highest High = ", extremePrice,
              " + Margin (", CandleSLMarginPoints, " pts) = SL ", slPrice);
    }

    return slPrice;
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

    // Calcular SL (baseado em candles ou fixo)
    double sl = 0;
    double slDistance = 0;

    if (UseCandleBasedSL)
    {
        sl = GetCandleBasedSL(true);
        slDistance = ask - sl;
    }
    else
    {
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

    // Calcular SL (baseado em candles ou fixo)
    double sl = 0;
    double slDistance = 0;

    if (UseCandleBasedSL)
    {
        sl = GetCandleBasedSL(false);
        slDistance = sl - bid;
    }
    else
    {
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
//| Get ATR value for dynamic trailing                               |
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
//| Apply Trailing Stop to position                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop(ulong ticket)
{
    if (!positionInfo.SelectByTicket(ticket))
        return;

    double currentSL = positionInfo.StopLoss();
    double point = symbolInfo.Point();
    int digits = symbolInfo.Digits();

    // Calcular trailing usando valores ajustados OU ATR dinâmico
    double trailingDistance;
    int trailingPointsUsed;

    if (UseDynamicTrailing)
    {
        // Modo dinâmico: usa ATR
        double atrValue = GetATRValue();

        if (atrValue > 0)
        {
            trailingDistance = atrValue * ATRMultiplier;
            trailingPointsUsed = (int)(trailingDistance / point);
            Print("Dynamic Trailing: ATR=", NormalizeDouble(atrValue, digits),
                  " x ", ATRMultiplier, " = ", NormalizeDouble(trailingDistance, digits),
                  " (", trailingPointsUsed, " points)");
        }
        else
        {
            // Fallback para fixo se ATR falhar
            trailingDistance = adjustedTrailingPoints * point;
            trailingPointsUsed = adjustedTrailingPoints;
            Print("Dynamic Trailing: ATR failed, using fixed ", trailingPointsUsed, " points");
        }
    }
    else
    {
        // Modo fixo tradicional
        trailingDistance = adjustedTrailingPoints * point;
        trailingPointsUsed = adjustedTrailingPoints;
    }

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
                          " (", trailingPointsUsed, " points from price)");
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
                          " (", trailingPointsUsed, " points from price)");
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
