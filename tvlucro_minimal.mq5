// TVLucro EA - Minimal Version for Testing
#property copyright "MT5 Webhook Automation"
#property version   "4.5"
#include <Trade\Trade.mqh>

//--- Global variables
CTrade trade;
input string TradingSymbol = "XAUUSD";
input int MagicNumber = 12345;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   Print("EA initialized successfully");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   Print("Timer tick");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Empty for now
}