//+------------------------------------------------------------------+
//| TVLucroGrid EA v1.0 - Grid Strategy with Profit Target           |
//| Expert Advisor that opens orders every 5 seconds until $100 target |
//| Compatible with existing webhook receiver                           |
//+------------------------------------------------------------------+
#property copyright "TVLucroGrid Automation"
#property link      "https://github.com"
#property version   "1.0"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- Input Parameters - Basic Settings
input string   TradingSymbol = "XAUUSD";         // Symbol to trade
input int      MagicNumber = 54321;           // Magic number (different from tvlucro)
input double   RiskPercent = 1.0;             // % of equity per order
input bool     UseFixedLots = true;           // Use fixed lots instead of risk % - CHANGED TO TRUE
input double   FixedLotSize = 0.01;           // Fixed lot size (if UseFixedLots=true)
input bool     ValidateLotSize = true;        // Validate broker lot limits
input int      TakeProfitPoints = 1000;        // TP in points (e.g., 1000 = $10 for XAUUSD)
input int      StopLossPoints = 1000;           // SL in points (e.g., 500 = $5 for XAUUSD)

//--- Grid Settings
input int      PollingIntervalSec = 0;        // Signal polling frequency (seconds) - 0 = FASTEST
input string   SignalFilePath = "signal_XAUUSD.json"; // Signal file path (works for both XAUUSD and XAUUSDc)
input int      GridIntervalSeconds = 1;       // Interval between grid orders (seconds) - FASTER FOR HEDGE
input double   ProfitTargetMoney = 20.0;      // Total profit target ($) - REDUCED FOR SAFETY
input int      MaxGridOrders = 10;             // Maximum orders per direction - REDUCED FOR SAFETY
input bool     CloseAllOnTarget = true;        // Close all when target reached

//--- Hedge Strategy (NEVER closes in loss, always waits for profit)
input bool     EnableHedgeMode = true;         // Enable hedge mode (opens new direction without closing old)
input double   HedgeProfitTarget = 50.0;       // Close ALL when total profit reaches this amount ($) - INCREASED FOR MORE MARTINGALE
input double   HedgeLotMultiplier = 1.5;       // Multiply lot size for hedge positions - DEFAULT 1.5x (SAFER)

//--- Continuous Martingale (True Martingale Progression)
input bool     EnableContinuousMartingale = false;  // Enable true martingale (each order multiplies LAST order's lot)
input double   MartingaleMultiplier = 1.5;          // Multiplier for each subsequent order (1.5 = 50% increase)

//--- Protection
input double   MaxDrawdownPercent = 5.0;      // Maximum drawdown (% of equity) - REDUCED FOR SAFETY
input double   MaxLossPerOrder = 10.0;         // Maximum loss per order ($) - REDUCED
input double   MaxDailyLoss = 50.0;            // Maximum daily loss ($) - Stop trading if reached

//--- Trailing Stop
input bool     EnableTrailingStop = true;      // Enable trailing stop for profitable positions
input int      TrailingStartPoints = 200;      // Start trailing after X points profit
input int      TrailingStopPoints = 100;       // Trailing stop distance in points
input int      TrailingStepPoints = 50;        // Move SL every X points

//--- Visual Panel
input bool     ShowInfoPanel = true;           // Show info panel
input int      PanelX = 20;
input int      PanelY = 50;
input int      PanelWidth = 220;

//--- Global Variables - Grid State
string activeSymbol = "";              // Active symbol (from chart, auto-detects XAUUSD/XAUUSDc)
string currentDirection = "";          // Current direction: "buy" or "sell"
datetime lastGridOrderTime = 0;        // Last grid order timestamp
int currentGridLevel = 0;              // Current grid level (order count)
bool targetReached = false;            // If $100 target was reached

//--- Hedge State
bool inHedgeMode = false;              // If currently in hedge mode (both directions open)
string hedgeOldDirection = "";         // The old direction before hedge
datetime hedgeStartTime = 0;           // When hedge mode started
int hedgeNewLevel = 0;                 // Grid level in NEW direction (hedge orders)

//--- Continuous Martingale State
double lastBuyLotSize = 0.0;           // Last lot size opened for BUY orders
double lastSellLotSize = 0.0;          // Last lot size opened for SELL orders
int buyMartingaleLevel = 0;            // Martingale level for BUY direction
int sellMartingaleLevel = 0;           // Martingale level for SELL direction

//--- Signal Control
string lastProcessedJson = "";         // Last processed JSON
datetime lastSignalTime = 0;           // Last signal timestamp
string pendingDirection = "";          // Pending direction for reversal

//--- Statistics
int totalOrdersOpened = 0;            // Total orders opened in session
double maxProfitReached = 0;          // Maximum profit reached
double maxDrawdownReached = 0;        // Maximum drawdown reached
double dailyStartBalance = 0;         // Account balance at start of day
bool tradingStopped = false;           // Trading stopped if daily loss limit reached

//--- Trade Objects
CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;

//--- Panel Variables - DISABLED
//string panelPrefix = "TVGridPanel_";
//bool panelInitialized = false;
//datetime lastPanelUpdate = 0;
//int PanelUpdateInterval = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                       |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize trade objects
    trade.SetExpertMagicNumber(MagicNumber);
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_IOC);

    // Use the symbol from the current chart (auto-detects XAUUSD or XAUUSDc)
    activeSymbol = _Symbol;
    symbolInfo.Name(activeSymbol);

    Print("=== TVLucroGrid EA v1.0 Started ===");
    Print("Chart Symbol: ", activeSymbol, " (configured: ", TradingSymbol, ")");
    Print("Magic Number: ", MagicNumber);
    Print("Grid Interval: ", GridIntervalSeconds, " seconds");
    Print("Profit Target: $", ProfitTargetMoney);
    Print("Max Grid Orders: ", MaxGridOrders);
    Print("Hedge Lot Multiplier: x", HedgeLotMultiplier);
    Print("Continuous Martingale: ", EnableContinuousMartingale ? "ENABLED" : "DISABLED");
    if (EnableContinuousMartingale)
        Print("Martingale Multiplier: x", MartingaleMultiplier, " (true progression)");

    // Verify symbol info is valid
    if (!symbolInfo.RefreshRates())
    {
        Print("ERROR: Failed to refresh symbol rates for ", activeSymbol);
        return(INIT_FAILED);
    }

    Print("Symbol Info Valid: Ask=", symbolInfo.Ask(), " Bid=", symbolInfo.Bid());

    // Initialize panel
    //if (ShowInfoPanel)
    //{
    //    CreateInfoPanel();
    //}

    // Set up timer for main loop
    // Note: Timer must be at least 1 second. If PollingIntervalSec is 0, use 1 for fastest execution.
    int timerInterval = (PollingIntervalSec <= 0) ? 1 : PollingIntervalSec;
    if (!EventSetTimer(timerInterval))
    {
        Print("ERROR: Failed to set timer!");
        return(INIT_FAILED);
    }

    Print("Timer configured: ", timerInterval, " second(s) (PollingIntervalSec=", PollingIntervalSec, ")");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Kill timer
    EventKillTimer();

    // Clean up panel
    //if (ShowInfoPanel)
    //{
    //    DeleteInfoPanel();
    //}

    Print("=== TVLucroGrid EA v1.0 Stopped ===");
    Print("Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Timer function - Main loop                                        |
//+------------------------------------------------------------------+
void OnTimer()
{
    // DAILY LOSS LIMIT: Check if we hit the daily loss limit
    static datetime lastDayCheck = 0;
    datetime currentTime = TimeCurrent();

    // Reset daily balance at start of new day
    MqlDateTime timeStruct;
    TimeToStruct(currentTime, timeStruct);
    if (timeStruct.hour == 0 && timeStruct.min == 0 && timeStruct.sec == 0)
    {
        dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        tradingStopped = false;
        Print("=== NEW DAY === Daily balance reset to: $", dailyStartBalance);
    }

    // Initialize daily balance on first run
    if (dailyStartBalance == 0)
    {
        dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }

    // Check if daily loss limit exceeded
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double dailyPnL = currentBalance - dailyStartBalance;

    if (dailyPnL < -MaxDailyLoss && !tradingStopped)
    {
        Print("========================================");
        Print("!!! MAXIMUM DAILY LOSS REACHED !!!");
        Print("Daily P&L: $", dailyPnL, " Limit: $", -MaxDailyLoss);
        Print("TRADING STOPPED. EA will not open more orders today.");
        Print("========================================");
        tradingStopped = true;
        CloseAllPositions();
        return;
    }

    // Don't trade if stopped
    if (tradingStopped)
    {
        static datetime lastStoppedLog = 0;
        if (currentTime - lastStoppedLog >= 60)
        {
            Print("TRADING STOPPED - Daily loss: $", dailyPnL, " Limit: $", -MaxDailyLoss);
            lastStoppedLog = currentTime;
        }
        return;
    }

    // HEARTBEAT: Show EA is running every 30 seconds
    static datetime lastHeartbeat = 0;
    if (currentTime - lastHeartbeat >= 30)
    {
        double dailyPnL = AccountInfoDouble(ACCOUNT_BALANCE) - dailyStartBalance;
        string hb = "=== HEARTBEAT === EA running | Dir: " + currentDirection +
                    " | Hedge: " + (inHedgeMode ? "YES" : "NO") +
                    " | Daily P&L: $" + DoubleToString(dailyPnL, 2);
        if (EnableContinuousMartingale && currentDirection != "")
        {
            int level = GetMartingaleLevel(currentDirection);
            double lastLot = GetLastLotSize(currentDirection);
            hb += " | Martingale Lvl: " + IntegerToString(level) + " | Last Lot: " + DoubleToString(lastLot, 3);
        }
        Print(hb);
        lastHeartbeat = currentTime;
    }

    // Update panel
    //if (ShowInfoPanel)
    //{
    //    UpdateInfoPanel();
    //}

    // 1. Read signal file
    string jsonContent = ReadSignalFile();


    // 2. Check if signal changed
    bool isNewSignal = (jsonContent != "" && jsonContent != lastProcessedJson);

    if (isNewSignal)
    {
        Print("================================================================================");
        Print("=== NEW SIGNAL DETECTED ===");

        // 2.1. Extract and validate symbol
        string signalSymbol = ExtractSymbolFromJSON(jsonContent);

        if (!IsSignalForThisSymbol(signalSymbol))
        {
            lastProcessedJson = jsonContent;
            return;
        }

        string signalDirection = ExtractDirectionFromJSON(jsonContent);

        // CRITICAL: Show what direction was extracted
        if (signalDirection == "buy")
            Print(">>> DIRECTION CONFIRMED: BUY (will open BUY orders) <<<");
        else if (signalDirection == "sell")
            Print(">>> DIRECTION CONFIRMED: SELL (will open SELL orders) <<<");
        else
            Print(">>> ERROR: Invalid direction extracted: '", signalDirection, "' <<<");

        if (signalDirection != "")
        {
            Print("=== SIGNAL RECEIVED ===");
            Print("Signal Direction: ", signalDirection);
            Print("Current Direction: ", currentDirection);
            Print("Hedge Mode: ", inHedgeMode ? "YES" : "NO");
            Print("Positions: ", PositionsTotal());
            lastSignalTime = TimeCurrent();

            // 3. If no direction (first signal)
            if (currentDirection == "" && !inHedgeMode)
            {
                Print(">>> FIRST SIGNAL - Opening in direction: ", signalDirection);

                if (ExecuteGridOrder(signalDirection))
                {
                    currentDirection = signalDirection;
                    lastProcessedJson = jsonContent;
                    Print("Grid started. Direction: ", currentDirection);
                }
            }
            // 4. Already have direction - check for reversal
            else
            {
                Print("Already trading. Current: ", currentDirection, " Signal: ", signalDirection);

                // Check if signal is opposite direction
                bool isOppositeSignal = (signalDirection != currentDirection);

                if (isOppositeSignal)
                {
                    // Check for losing positions - if yes, use HEDGE mode
                    int losingPositions = 0;
                    int totalPositions = 0;
                    double totalUnrealizedPL = 0;

                    for (int i = PositionsTotal() - 1; i >= 0; i--)
                    {
                        if (positionInfo.SelectByIndex(i))
                        {
                            if (positionInfo.Symbol() == activeSymbol &&
                                positionInfo.Magic() == MagicNumber)
                            {
                                totalPositions++;
                                double posProfit = positionInfo.Profit();
                                totalUnrealizedPL += posProfit;
                                if (posProfit < 0)
                                {
                                    losingPositions++;
                                }
                                Print("POSITION CHECK: Ticket=", positionInfo.Ticket(), " Profit=", posProfit);
                            }
                        }
                    }

                    double myProfit = GetMyTotalProfit();

                    Print("=== SIGNAL REVERSAL CHECK ===");
                    Print("Total Positions: ", totalPositions, " Losing: ", losingPositions);
                    Print("Total Unrealized P&L: $", totalUnrealizedPL);
                    Print("MY Profit (EA only): $", myProfit);
                    Print("In Hedge Mode: ", inHedgeMode ? "YES" : "NO");

                    // If has losing positions, ALWAYS enter HEDGE mode (never close losing positions)
                    if (losingPositions > 0 && !inHedgeMode)
                    {
                        Print("=== ENTERING HEDGE MODE (WEBHOOK) ===");
                        Print("Opposite signal received but has ", losingPositions, " losing positions");
                        Print("Old Direction: ", currentDirection, " | New Direction: ", signalDirection);
                        Print("Current Profit: $", myProfit);
                        Print("Opening NEW direction positions WITHOUT closing old ones");
                        Print("HEDGE LOT MULTIPLIER: x", HedgeLotMultiplier);

                        // Set hedge state
                        hedgeOldDirection = currentDirection;
                        hedgeStartTime = TimeCurrent();
                        hedgeNewLevel = 0;
                        inHedgeMode = true;

                        // Update current direction to NEW direction (for new orders)
                        currentDirection = signalDirection;

                        // Reset martingale for NEW direction (start fresh)
                        ResetMartingaleLevel(currentDirection);
                        if (currentDirection == "buy")
                            lastBuyLotSize = 0.0;
                        else
                            lastSellLotSize = 0.0;

                        // Open first order in NEW direction with MARTINGALE (multiplied lot) - IMMEDIATE
                        if (ExecuteGridOrderWithMultiplier(currentDirection, HedgeLotMultiplier))
                        {
                            Print("HEDGE MODE ACTIVATED (webhook) with x", HedgeLotMultiplier, " MARTINGALE");
                            Print("Old positions remain open. Adding positions in ", currentDirection);
                            Print("Will exit hedge when profit >= $", HedgeProfitTarget);
                        }
                        else
                        {
                            Print("FAILED to open hedge order - retrying immediately...");
                            // Retry immediately on failure
                            Sleep(100);
                            ExecuteGridOrderWithMultiplier(currentDirection, HedgeLotMultiplier);
                        }

                        lastProcessedJson = jsonContent;
                        return;
                    }

                    // If all positions profitable OR hedge disabled, do normal reversal
                    if (ShouldReverseDirection(signalDirection))
                    {
                        Print("=== REVERSAL TRIGGERED ===");
                        Print("Closing all and reversing to: ", signalDirection);

                        if (CloseAllPositions())
                        {
                            Sleep(1000);

                            if (ExecuteGridOrder(signalDirection))
                            {
                                currentDirection = signalDirection;
                                targetReached = false;
                                lastProcessedJson = jsonContent;
                                Print("Reversal complete. New direction: ", currentDirection);
                            }
                        }
                    }
                    else
                    {
                        Print("Signal ignored - reversal conditions not met");
                        lastProcessedJson = jsonContent;
                    }
                }
                else
                {
                    Print("Signal ignored - same direction or auto-reverse disabled");
                    lastProcessedJson = jsonContent;
                }
            }
        }
    }

    // 5. If we have a direction, manage grid
    if (currentDirection != "")
    {
        // 5.0 Check if we still have positions - if not, reset grid state
        int positionCount = 0;
        for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
            if (positionInfo.SelectByIndex(i))
            {
                if (positionInfo.Symbol() == activeSymbol &&
                    positionInfo.Magic() == MagicNumber)
                {
                    positionCount++;
                }
            }
        }

        // Update currentGridLevel to match actual position count
        if (currentGridLevel != positionCount)
        {
            currentGridLevel = positionCount;
        }

        // If no positions but we think we have a direction, reset
        if (positionCount == 0 && currentDirection != "")
        {
            Print("=== NO POSITIONS FOUND ===");
            Print("Grid state reset. Waiting for new signal.");
            ResetGridState();
            return;
        }

        double myProfit = GetMyTotalProfit();

        // 5.05 HEDGE MODE: Check if we should exit hedge mode with profit
        if (inHedgeMode)
        {
            Print("=== HEDGE MODE ACTIVE ===");
            Print("Old Direction: ", hedgeOldDirection, " | New Direction: ", currentDirection);
            Print("Old Level: ", currentGridLevel, " | New Level: ", hedgeNewLevel);
            Print("MY Profit (EA only): $", myProfit);

            bool shouldExitHedge = false;
            string exitReason = "";

            // Exit hedge if profit target reached
            if (myProfit >= HedgeProfitTarget)
            {
                shouldExitHedge = true;
                exitReason = "Hedge profit target reached";
            }

            if (shouldExitHedge)
            {
                Print("=== EXITING HEDGE MODE ===");
                Print("Reason: ", exitReason);
                Print("Closing ALL positions with profit: $", myProfit);

                if (CloseAllPositions())
                {
                    Sleep(1000);
                    ResetGridState();
                    // Don't open new orders - wait for fresh signal
                    Print("Hedge closed. Waiting for new signal.");
                    return;
                }
            }
        }

        // 5.1 Check if target reached (skip main target if in hedge mode)
        if (!inHedgeMode && myProfit >= ProfitTargetMoney)
        {
            Print("=== TARGET REACHED ===");
            Print("Profit: $", myProfit, " Target: $", ProfitTargetMoney);

            if (CloseAllOnTarget)
            {
                CloseAllPositions();
                ResetGridState();
                Print("All positions closed. Grid reset.");
            }

            return;
        }

        // 5.2 Check if should add grid order
        if (ShouldAddGridOrder())
        {
            Print("=== ADDING GRID ORDER ===");
            Print("Current Level: ", currentGridLevel, " Direction: ", currentDirection, " Hedge Mode: ", inHedgeMode ? "YES" : "NO");

            // Execute grid order with MARTINGALE when in hedge mode
            bool orderResult;
            if (inHedgeMode)
            {
                orderResult = ExecuteGridOrderWithMultiplier(currentDirection, HedgeLotMultiplier);
            }
            else
            {
                orderResult = ExecuteGridOrder(currentDirection);
            }

            if (orderResult)
            {
                Print("Grid order added. New level: ", currentGridLevel);
            }
        }

        // 5.3 Check stop loss for individual positions
        CheckStopLoss();

        // 5.4 Manage trailing stop for profitable positions (DISABLED in hedge mode)
        if (!inHedgeMode)
        {
            ManageTrailingStop();
        }
    }
}

//+------------------------------------------------------------------+
//| Read signal file from Common Files directory                        |
//+------------------------------------------------------------------+
string ReadSignalFile()
{
    int fileHandle = FileOpen(SignalFilePath, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON|FILE_SHARE_READ|FILE_SHARE_WRITE);

    if (fileHandle == INVALID_HANDLE)
    {
        // File doesn't exist yet - not an error
        static datetime lastFileErrorLog = 0;
        if (TimeCurrent() - lastFileErrorLog >= 30)
        {
            Print("Cannot open signal file: ", SignalFilePath);
            lastFileErrorLog = TimeCurrent();
        }
        return "";
    }

    // Read entire file line by line
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
    // Function body - extract symbol from JSON
    string symbolKey = "\"symbol\":";
    int keyPos = StringFind(json, symbolKey);

    if (keyPos == -1)
    {
        return "";
    }

    int valueStart = keyPos + StringLen(symbolKey);

    // Skip whitespace
    while (valueStart < StringLen(json) &&
           (StringGetCharacter(json, valueStart) == ' ' ||
            StringGetCharacter(json, valueStart) == '\t'))
    {
        valueStart++;
    }

    // Check if it's a string
    if (StringGetCharacter(json, valueStart) != '"')
    {
        return "";
    }

    valueStart++;  // Skip opening quote

    // Find closing quote
    int valueEnd = valueStart;
    while (valueEnd < StringLen(json) &&
           StringGetCharacter(json, valueEnd) != '"' &&
           StringGetCharacter(json, valueEnd) != '}' &&
           StringGetCharacter(json, valueEnd) != ',')
    {
        valueEnd++;
    }

    string symbol = StringSubstr(json, valueStart, valueEnd - valueStart);
    return symbol;
}

//+------------------------------------------------------------------+
//| Normalize symbol by removing trailing 'c' suffix                    |
//+------------------------------------------------------------------+
string NormalizeSymbol(string sym)
{
    string result = sym;
    // Remove trailing 'c' if present (XAUUSDc -> XAUUSD)
    if (StringLen(result) > 0 && StringGetCharacter(result, StringLen(result) - 1) == 'c')
    {
        result = StringSubstr(result, 0, StringLen(result) - 1);
    }
    return result;
}

//+------------------------------------------------------------------+
//| Check if signal is for this EA's symbol                               |
//+------------------------------------------------------------------+
bool IsSignalForThisSymbol(string signalSymbol)
{
    // If signal has no symbol field, accept it (backward compatibility)
    if (signalSymbol == "")
        return true;

    string normalizedSignal = NormalizeSymbol(signalSymbol);
    string normalizedTrading = NormalizeSymbol(TradingSymbol);

    // Compare normalized symbols
    int result = StringCompare(normalizedSignal, normalizedTrading);
    if (result == 0)
    {
        return true;
    }

    Print("Signal IGNORED - Symbol mismatch: '", signalSymbol, "' != '", TradingSymbol, "'");
    return false;
}

//+------------------------------------------------------------------+
//| Extract direction from JSON                                         |
//+------------------------------------------------------------------+
string ExtractDirectionFromJSON(string jsonContent)
{
    string direction = "";

    // Try to find "action" field first (legacy format)
    int actionPos = StringFind(jsonContent, "\"action\"");

    if (actionPos >= 0)
    {
        int colonPos = StringFind(jsonContent, ":", actionPos);

        if (colonPos > 0)
        {
            // Find the opening quote after the colon (skip whitespace)
            int quoteStart = StringFind(jsonContent, "\"", colonPos);

            if (quoteStart > 0)
            {
                // Find the closing quote
                int quoteEnd = StringFind(jsonContent, "\"", quoteStart + 1);

                if (quoteEnd > 0)
                {
                    string actionValue = StringSubstr(jsonContent, quoteStart + 1, quoteEnd - quoteStart - 1);
                    StringToLower(actionValue);

                    // Convert to buy/sell
                    if (actionValue == "long" || actionValue == "buy")
                        direction = "buy";
                    else if (actionValue == "short" || actionValue == "sell")
                        direction = "sell";
                }
            }
        }
    }

    return direction;
}

//+------------------------------------------------------------------+
//| Check if should add grid order                                     |
//+------------------------------------------------------------------+
bool ShouldAddGridOrder()
{
    // Check interval
    if (TimeCurrent() - lastGridOrderTime < GridIntervalSeconds)
        return false;

    // In hedge mode, check NEW direction level; otherwise check total level
    int ordersToAdd = inHedgeMode ? hedgeNewLevel : currentGridLevel;

    // Check max orders
    if (ordersToAdd >= MaxGridOrders)
    {
        Print("Max grid orders reached: ", MaxGridOrders, " (Hedge mode: ", inHedgeMode, ")");
        return false;
    }

    // Check drawdown limit (using THIS EA's profit only, not total account)
    double myProfit = GetMyTotalProfit();
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double maxLoss = equity * (MaxDrawdownPercent / 100.0);

    if (myProfit < -maxLoss)
    {
        Print("Drawdown limit reached: $", myProfit, " Max loss: $", -maxLoss);
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Check if should reverse direction                                  |
//+------------------------------------------------------------------+
bool ShouldReverseDirection(string newSignalDirection)
{
    Print("ShouldReverseDirection: new=", newSignalDirection, " current=", currentDirection);

    // Must be opposite direction
    if (newSignalDirection == currentDirection)
    {
        Print("BLOCK: Same direction");
        return false;
    }

    // If we reach here, all positions are profitable (hedge mode check is done before calling this function)
    Print("=== REVERSAL TRIGGERED ===");
    Print("- New signal direction: ", newSignalDirection, " (opposite of ", currentDirection, ")");
    Print("- Will close ALL positions and reverse direction");

    return true;
}

//+------------------------------------------------------------------+
//| Check if current positions are profitable                          |
//+------------------------------------------------------------------+
bool AreCurrentPositionsProfitable()
{
    int profitableCount = 0;
    int totalCount = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == activeSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                totalCount++;
                if (positionInfo.Profit() > 0)
                    profitableCount++;
            }
        }
    }

    // Consider profitable if at least half are in profit
    return (totalCount > 0 && profitableCount >= totalCount / 2);
}

//+------------------------------------------------------------------+
//| Execute grid order                                                |
//+------------------------------------------------------------------+
bool ExecuteGridOrder(string direction)
{
    // Normalize direction to lowercase
    StringToLower(direction);

    // CRITICAL: Validate direction before executing
    if (direction != "buy" && direction != "sell")
    {
        Print("ERROR: Invalid direction '", direction, "' - must be 'buy' or 'sell'");
        return false;
    }

    double volume = CalculateVolume(1.0, direction);

    if (volume <= 0)
    {
        Print("ERROR: Invalid volume calculated: ", volume);
        return false;
    }

    // CRITICAL: Refresh symbol rates and verify they're valid
    if (!symbolInfo.RefreshRates())
    {
        Print("ERROR: Failed to refresh symbol rates for ", activeSymbol);
        return false;
    }

    double ask = symbolInfo.Ask();
    double bid = symbolInfo.Bid();

    // Verify prices are valid
    if (ask <= 0 || bid <= 0)
    {
        Print("ERROR: Invalid prices - Ask=", ask, " Bid=", bid, " Symbol=", activeSymbol);
        Print("ERROR: symbolInfo may not be properly initialized!");
        return false;
    }

    bool success = false;

    if (direction == "buy")
    {
        Print(">>> EXECUTING BUY ORDER <<<");

        double sl = StopLossPoints > 0 ? NormalizeDouble(ask - StopLossPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;
        double tp = TakeProfitPoints > 0 ? NormalizeDouble(ask + TakeProfitPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;

        if (trade.Buy(volume, activeSymbol, ask, sl, tp, "TVGrid"))
        {
            Print("BUY ORDER OPENED: Volume=", volume, " Price=", ask, " SL=", sl, " TP=", tp);
            success = true;
        }
        else
        {
            uint error = trade.ResultRetcode();
            Print("BUY ORDER FAILED. Error code: ", error, " Description: ", trade.ResultRetcodeDescription());
        }
    }
    else if (direction == "sell")
    {
        Print(">>> EXECUTING SELL ORDER <<<");

        double bid = symbolInfo.Bid();
        double sl = StopLossPoints > 0 ? NormalizeDouble(bid + StopLossPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;
        double tp = TakeProfitPoints > 0 ? NormalizeDouble(bid - TakeProfitPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;

        if (trade.Sell(volume, activeSymbol, bid, sl, tp, "TVGrid"))
        {
            Print("SELL ORDER OPENED: Volume=", volume, " Price=", bid, " SL=", sl, " TP=", tp);
            success = true;
        }
        else
        {
            Print("SELL ORDER FAILED: ", trade.ResultRetcodeDescription());
        }
    }

    if (success)
    {
        lastGridOrderTime = TimeCurrent();
        currentGridLevel++;

        // In hedge mode, also track new direction level separately
        if (inHedgeMode)
        {
            hedgeNewLevel++;
            Print("HEDGE: New level=", hedgeNewLevel, " Total level=", currentGridLevel);
        }

        // Update martingale tracking
        if (EnableContinuousMartingale)
        {
            UpdateLastLotSize(direction, volume);
            int level = GetMartingaleLevel(direction);
            double multiplierFromBase = volume / FixedLotSize;
            Print("MARTINGALE Level ", level, ": ", volume, " lot (", multiplierFromBase, "x base)");
        }

        totalOrdersOpened++;
    }

    return success;
}

//+------------------------------------------------------------------+
//| Execute grid order with lot multiplier (for hedge)                |
//+------------------------------------------------------------------+
bool ExecuteGridOrderWithMultiplier(string direction, double lotMultiplier = 1.0)
{
    Print("=== ExecuteGridOrderWithMultiplier CALLED ===");
    Print("Direction: ", direction, " | Multiplier: ", lotMultiplier);

    // Normalize direction to lowercase
    StringToLower(direction);

    // CRITICAL: Validate direction before executing
    if (direction != "buy" && direction != "sell")
    {
        Print("ERROR: Invalid direction '", direction, "' - must be 'buy' or 'sell'");
        return false;
    }

    double volume = CalculateVolume(lotMultiplier, direction);
    Print("Calculated Volume: ", volume, " (FixedLotSize=", FixedLotSize, " Multiplier=", lotMultiplier, ")");

    if (volume <= 0)
    {
        Print("ERROR: Invalid volume calculated: ", volume);
        return false;
    }

    // Check if market is open for trading
    long tradeMode = SymbolInfoInteger(activeSymbol, SYMBOL_TRADE_MODE);
    if (tradeMode != SYMBOL_TRADE_MODE_FULL)
    {
        Print("ERROR: Market not open for trading. Trade mode: ", tradeMode);
        return false;
    }

    // Verify volume is within broker limits BEFORE sending order
    double minLot = SymbolInfoDouble(activeSymbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(activeSymbol, SYMBOL_VOLUME_MAX);
    if (volume < minLot || volume > maxLot)
    {
        Print("ERROR: Volume OUT OF BROKER LIMITS! Requested=", volume, " Min=", minLot, " Max=", maxLot);
        return false;
    }

    // CRITICAL: Refresh symbol rates and verify they're valid
    if (!symbolInfo.RefreshRates())
    {
        Print("ERROR: Failed to refresh symbol rates for ", activeSymbol);
        return false;
    }

    double ask = symbolInfo.Ask();
    double bid = symbolInfo.Bid();

    // Verify prices are valid
    if (ask <= 0 || bid <= 0)
    {
        Print("ERROR: Invalid prices - Ask=", ask, " Bid=", bid, " Symbol=", activeSymbol);
        Print("ERROR: symbolInfo may not be properly initialized!");
        return false;
    }

    bool success = false;

    if (direction == "buy")
    {
        Print(">>> EXECUTING BUY ORDER (HEDGE x", lotMultiplier, ") Volume=", volume, " <<<");

        double sl = StopLossPoints > 0 ? NormalizeDouble(ask - StopLossPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;
        double tp = TakeProfitPoints > 0 ? NormalizeDouble(ask + TakeProfitPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;

        if (trade.Buy(volume, activeSymbol, ask, sl, tp, "TVGrid"))
        {
            Print("BUY ORDER OPENED: Volume=", volume, " Price=", ask, " SL=", sl, " TP=", tp);
            success = true;
        }
        else
        {
            uint error = trade.ResultRetcode();
            Print("BUY ORDER FAILED. Error code: ", error, " Description: ", trade.ResultRetcodeDescription());
        }
    }
    else if (direction == "sell")
    {
        Print(">>> EXECUTING SELL ORDER (HEDGE x", lotMultiplier, ") Volume=", volume, " <<<");

        double bid = symbolInfo.Bid();
        double sl = StopLossPoints > 0 ? NormalizeDouble(bid + StopLossPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;
        double tp = TakeProfitPoints > 0 ? NormalizeDouble(bid - TakeProfitPoints * symbolInfo.Point(), symbolInfo.Digits()) : 0;

        if (trade.Sell(volume, activeSymbol, bid, sl, tp, "TVGrid"))
        {
            Print("SELL ORDER OPENED: Volume=", volume, " Price=", bid, " SL=", sl, " TP=", tp);
            success = true;
        }
        else
        {
            Print("SELL ORDER FAILED: ", trade.ResultRetcodeDescription());
        }
    }

    if (success)
    {
        lastGridOrderTime = TimeCurrent();
        currentGridLevel++;

        // In hedge mode, also track new direction level separately
        if (inHedgeMode)
        {
            hedgeNewLevel++;
            Print("HEDGE: New level=", hedgeNewLevel, " Total level=", currentGridLevel);
        }

        // Update martingale tracking
        if (EnableContinuousMartingale)
        {
            UpdateLastLotSize(direction, volume);
            int level = GetMartingaleLevel(direction);
            double multiplierFromBase = volume / FixedLotSize;
            Print("MARTINGALE Level ", level, ": ", volume, " lot (", multiplierFromBase, "x base)");
        }

        totalOrdersOpened++;
    }

    return success;
}

//+------------------------------------------------------------------+
//| Get last lot size for direction (continuous martingale)            |
//+------------------------------------------------------------------+
double GetLastLotSize(string direction)
{
    StringToLower(direction);
    if (direction == "buy")
        return lastBuyLotSize;
    else if (direction == "sell")
        return lastSellLotSize;
    return 0.0;
}

//+------------------------------------------------------------------+
//| Update last lot size for direction (continuous martingale)         |
//+------------------------------------------------------------------+
void UpdateLastLotSize(string direction, double lot)
{
    StringToLower(direction);
    if (direction == "buy")
    {
        lastBuyLotSize = lot;
        buyMartingaleLevel++;
    }
    else if (direction == "sell")
    {
        lastSellLotSize = lot;
        sellMartingaleLevel++;
    }
}

//+------------------------------------------------------------------+
//| Get martingale level for direction                                 |
//+------------------------------------------------------------------+
int GetMartingaleLevel(string direction)
{
    StringToLower(direction);
    if (direction == "buy")
        return buyMartingaleLevel;
    else if (direction == "sell")
        return sellMartingaleLevel;
    return 0;
}

//+------------------------------------------------------------------+
//| Reset martingale level for direction                               |
//+------------------------------------------------------------------+
void ResetMartingaleLevel(string direction)
{
    StringToLower(direction);
    if (direction == "buy")
        buyMartingaleLevel = 0;
    else if (direction == "sell")
        sellMartingaleLevel = 0;
}

//+------------------------------------------------------------------+
//| Calculate volume for trade                                          |
//+------------------------------------------------------------------+
double CalculateVolume(double multiplier = 1.0, string direction = "")
{
    double volume;

    // Continuous Martingale Mode: multiply LAST order's lot, not base lot
    if (EnableContinuousMartingale && direction != "")
    {
        double lastLot = GetLastLotSize(direction);

        if (lastLot > 0)
        {
            // Multiply last lot by martingale multiplier
            volume = lastLot * MartingaleMultiplier;
            Print("CONTINUOUS MARTINGALE: Last lot=", lastLot, " x ", MartingaleMultiplier, " = ", volume);
        }
        else
        {
            // First order in this direction - use base lot
            volume = FixedLotSize;
            Print("CONTINUOUS MARTINGALE: First order (no previous lot), using base: ", volume);
        }
    }
    else if (UseFixedLots)
    {
        volume = FixedLotSize;
    }
    else
    {
        double equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double riskAmount = equity * (RiskPercent / 100.0);

        double tickValue = SymbolInfoDouble(activeSymbol, SYMBOL_TRADE_TICK_VALUE);
        double slValue = StopLossPoints * tickValue;

        if (slValue > 0 && tickValue > 0)
        {
            volume = riskAmount / slValue;
        }
        else
        {
            volume = 0.01; // Default
        }
    }

    // Apply legacy multiplier (for hedge orders when NOT using continuous martingale)
    if (!EnableContinuousMartingale && multiplier != 1.0)
    {
        volume = volume * multiplier;
        Print("LOT MULTIPLIER: Volume multiplied by ", multiplier, " = ", volume);
    }

    // Validate lot size
    if (ValidateLotSize)
    {
        double minLot = SymbolInfoDouble(activeSymbol, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(activeSymbol, SYMBOL_VOLUME_MAX);
        double lotStep = SymbolInfoDouble(activeSymbol, SYMBOL_VOLUME_STEP);

        Print("LOT VALIDATION: Before=", volume, " Min=", minLot, " Max=", maxLot, " Step=", lotStep);

        volume = MathFloor(volume / lotStep) * lotStep;

        // Cap at broker maximum (important for martingale!)
        if (volume > maxLot)
        {
            Print("WARNING: Volume ", volume, " exceeds broker max ", maxLot, " - CAPPING at max");
            volume = maxLot;
        }
        volume = MathMax(minLot, volume);

        Print("LOT VALIDATION: After=", volume);
    }

    // CRITICAL: Check for NaN or invalid volume
    if (volume <= 0 || volume != volume)  // NaN check: NaN != NaN
    {
        Print("ERROR: Invalid volume after calculation: ", volume, " - Using default 0.01");
        volume = 0.01;
    }

    Print("FINAL VOLUME: ", volume);

    return volume;
}

//+------------------------------------------------------------------+
//| Get total profit from THIS EA's positions only (filtered by MagicNumber) |
//+------------------------------------------------------------------+
double GetMyTotalProfit()
{
    double totalProfit = 0.0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == activeSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                totalProfit += positionInfo.Profit();
            }
        }
    }

    return totalProfit;
}

//+------------------------------------------------------------------+
//| Close all positions                                                |
//+------------------------------------------------------------------+
bool CloseAllPositions()
{
    int closedCount = 0;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == activeSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                ulong ticket = positionInfo.Ticket();
                if (trade.PositionClose(ticket))
                {
                    closedCount++;
                }
                else
                {
                    Print("FAILED to close position ", ticket, ": ", trade.ResultRetcodeDescription());
                }
            }
        }
    }

    return (closedCount > 0);
}

//+------------------------------------------------------------------+
//| Check stop loss for individual positions                            |
//+------------------------------------------------------------------+
void CheckStopLoss()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == activeSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                double profit = positionInfo.Profit();

                // Check if loss exceeds limit
                if (profit < -MaxLossPerOrder)
                {
                    Print("STOP LOSS TRIGGERED: Position ", positionInfo.Ticket(),
                          " Loss: $", profit, " Max: $", -MaxLossPerOrder);

                    trade.PositionClose(positionInfo.Ticket());
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage trailing stop for profitable positions                     |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    if (!EnableTrailingStop)
        return;

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == activeSymbol &&
                positionInfo.Magic() == MagicNumber)
            {
                ulong ticket = positionInfo.Ticket();
                double openPrice = positionInfo.PriceOpen();
                double currentSL = positionInfo.StopLoss();
                double point = symbolInfo.Point();
                int digits = symbolInfo.Digits();

                // Get current price
                symbolInfo.RefreshRates();

                if (positionInfo.PositionType() == POSITION_TYPE_BUY)
                {
                    double bid = symbolInfo.Bid();
                    double profitPoints = (bid - openPrice) / point;

                    // Only trail if profitable enough
                    if (profitPoints >= TrailingStartPoints)
                    {
                        double newSL = NormalizeDouble(bid - TrailingStopPoints * point, digits);

                        // Only move SL if it's better than current SL by at least TrailingStep
                        if (currentSL == 0 || (newSL - currentSL) / point >= TrailingStepPoints)
                        {
                            if (currentSL == 0 || newSL > currentSL)
                            {
                                trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
                                Print("TRAILING STOP (BUY): Ticket=", ticket,
                                      " OldSL=", currentSL, " NewSL=", newSL,
                                      " Bid=", bid, " Profit=", profitPoints, " points");
                            }
                        }
                    }
                }
                else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
                {
                    double ask = symbolInfo.Ask();
                    double profitPoints = (openPrice - ask) / point;

                    // Only trail if profitable enough
                    if (profitPoints >= TrailingStartPoints)
                    {
                        double newSL = NormalizeDouble(ask + TrailingStopPoints * point, digits);

                        // Only move SL if it's better (lower) than current SL by at least TrailingStep
                        if (currentSL == 0 || (currentSL - newSL) / point >= TrailingStepPoints)
                        {
                            if (currentSL == 0 || newSL < currentSL)
                            {
                                trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
                                Print("TRAILING STOP (SELL): Ticket=", ticket,
                                      " OldSL=", currentSL, " NewSL=", newSL,
                                      " Ask=", ask, " Profit=", profitPoints, " points");
                            }
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Reset grid state                                                   |
//+------------------------------------------------------------------+
void ResetGridState()
{
    currentDirection = "";
    lastGridOrderTime = 0;
    currentGridLevel = 0;
    targetReached = false;
    lastProcessedJson = "";

    // Reset hedge state
    inHedgeMode = false;
    hedgeOldDirection = "";
    hedgeStartTime = 0;
    hedgeNewLevel = 0;

    // Reset martingale state
    lastBuyLotSize = 0.0;
    lastSellLotSize = 0.0;
    buyMartingaleLevel = 0;
    sellMartingaleLevel = 0;
}
//+------------------------------------------------------------------+
