// HttpTrader.mq5
// Expert Advisor to handle HTTP requests and place orders in MetaTrader 5
// Note: MQL5 does not have built-in HTTP server capabilities.
// This EA assumes an external HTTP server or DLL handles the requests.
// For full implementation, use httplib or socket libraries.

#property copyright "Your Name"
#property link      "https://www.example.com"
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- DLL imports
#import "HttpServer.dll"
   void StartHttpServer();
   void StopHttpServer();
   string GetLatestJson();
   void ClearLatestJson();
#endimport

//--- input parameters
input string   SymbolName = "XAUUSD";         // Symbol to trade
input int      MagicNumber = 12345;           // Magic number for orders
input double   RiskPercent = 2.0;             // % do equity por trade
input int      TakeProfitPips = 100;          // TP em pips
input int      StopLossPips = 50;             // SL em pips
input int      PollingIntervalSec = 1;        // Frequência polling (segundos)

CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;

//--- Global variables
string lastProcessedJson = "";
datetime lastProcessedTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Start HTTP Server DLL
    StartHttpServer();
    Print("HTTP Server started on port 5000");

    // Setup timer for polling
    EventSetTimer(PollingIntervalSec);
    Print("Timer set to poll every ", PollingIntervalSec, " second(s)");

    // Setup trading
    trade.SetExpertMagicNumber(MagicNumber);
    symbolInfo.Name(SymbolName);
    if (!symbolInfo.RefreshRates())
    {
        Print("Failed to refresh symbol rates");
        return INIT_FAILED;
    }

    Print("=== HttpTrader EA Initialized ===");
    Print("Symbol: ", SymbolName);
    Print("Magic Number: ", MagicNumber);
    Print("Risk Percent: ", RiskPercent, "%");
    Print("Take Profit: ", TakeProfitPips, " pips");
    Print("Stop Loss: ", StopLossPips, " pips");

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    StopHttpServer();
    Print("=== HttpTrader EA Stopped ===");
    Print("Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Processing moved to OnTimer for polling-based approach
}

//+------------------------------------------------------------------+
//| Timer function for DLL polling                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    string json = GetLatestJson();
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
        ClearLatestJson();
    }
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
                if (positionInfo.Symbol() == SymbolName &&
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
//| Function to calculate volume based on risk percentage            |
//+------------------------------------------------------------------+
double CalculateVolume()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = equity * (RiskPercent / 100.0);

    double tickValue = SymbolInfoDouble(SymbolName, SYMBOL_TRADE_TICK_VALUE);
    double point = SymbolInfoDouble(SymbolName, SYMBOL_POINT);

    // Volume = Risk / (SL em pontos * tick value)
    double volume = riskAmount / (StopLossPips * 10 * point * tickValue);

    // Normalizar
    double minLot = SymbolInfoDouble(SymbolName, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(SymbolName, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(SymbolName, SYMBOL_VOLUME_STEP);

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

    // Converter pips para pontos (1 pip = 10 pontos para XAUUSD)
    double slDistance = StopLossPips * 10 * point;
    double tpDistance = TakeProfitPips * 10 * point;

    double sl = NormalizeDouble(ask - slDistance, digits);
    double tp = NormalizeDouble(ask + tpDistance, digits);

    // Validar stops mínimos
    int minStopLevel = (int)SymbolInfoInteger(SymbolName, SYMBOL_TRADE_STOPS_LEVEL);
    if (minStopLevel > 0)
    {
        double minDistance = minStopLevel * point;
        if (slDistance < minDistance || tpDistance < minDistance)
        {
            Print("ERROR: SL/TP too close. Min distance: ", minDistance);
            return false;
        }
    }

    if (trade.Buy(volume, SymbolName, ask, sl, tp, "WebhookTrade"))
    {
        Print("BUY SUCCESS: Vol=", volume, " Entry=", ask, " SL=", sl, " TP=", tp);
        return true;
    }
    else
    {
        Print("BUY FAILED: ", trade.ResultRetcodeDescription());
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

    // Converter pips para pontos (1 pip = 10 pontos para XAUUSD)
    double slDistance = StopLossPips * 10 * point;
    double tpDistance = TakeProfitPips * 10 * point;

    double sl = NormalizeDouble(bid + slDistance, digits);
    double tp = NormalizeDouble(bid - tpDistance, digits);

    // Validar stops mínimos
    int minStopLevel = (int)SymbolInfoInteger(SymbolName, SYMBOL_TRADE_STOPS_LEVEL);
    if (minStopLevel > 0)
    {
        double minDistance = minStopLevel * point;
        if (slDistance < minDistance || tpDistance < minDistance)
        {
            Print("ERROR: SL/TP too close. Min distance: ", minDistance);
            return false;
        }
    }

    if (trade.Sell(volume, SymbolName, bid, sl, tp, "WebhookTrade"))
    {
        Print("SELL SUCCESS: Vol=", volume, " Entry=", bid, " SL=", sl, " TP=", tp);
        return true;
    }
    else
    {
        Print("SELL FAILED: ", trade.ResultRetcodeDescription());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Function to process incoming JSON (placeholder)                 |
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

    Print("=== Processing Trade Signal ===");
    Print("Action: ", action);

    // 1. Fechar posições
    Print("Closing all positions for ", SymbolName);
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