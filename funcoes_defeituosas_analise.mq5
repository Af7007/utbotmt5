// Funções defeituosas isoladas para análise posterior
// Extraído de tvlucro.mq5

//+------------------------------------------------------------------+
//| Função problemática 1: InitializeRiskManagement                   |
//+------------------------------------------------------------------+
void InitializeRiskManagement()
{
    if (!riskManagementEnabled)
        return;

    initialEquity = (double)AccountEquity();
    sessionStartTime = (datetime)TimeCurrent();
    totalSessionLoss = 0;

    Print("=== RISK MANAGEMENT INITIALIZED ===");
    Print("Initial Equity: ", DoubleToString(initialEquity, 2));
    Print("Max Drawdown Allowed: ", maxDrawdownAllowed, "%");
    Print("Daily Loss Limit: ", dailyLossLimit, "%");
}

//+------------------------------------------------------------------+
//| Função problemática 2: CheckRiskLimits                          |
//+------------------------------------------------------------------+
bool CheckRiskLimits()
{
    if (!riskManagementEnabled)
        return true;

    // Check drawdown limit
    double currentEquity = (double)AccountEquity();
    if (currentEquity < (initialEquity * 0.95))  // 5% loss limit
    {
        Print("!!! EQUITY PROTECTION !!!");
        Print("Current equity below 95% of initial - stopping scalping");
        Print("Initial: ", DoubleToString(initialEquity, 2));
        Print("Current: ", DoubleToString(currentEquity, 2));
        return false;
    }

    // Check daily loss limit
    double dailyLossPercent = ((initialEquity - currentEquity) / initialEquity) * 100;
    if (dailyLossPercent > dailyLossLimit)
    {
        Print("!!! DAILY LOSS LIMIT REACHED !!!");
        Print("Daily Loss: ", DoubleToString(dailyLossPercent, 2), "%");
        Print("Limit: ", DoubleToString(dailyLossLimit, 2), "%");
        return false;
    }

    // Check margin usage
    double equity = AccountEquity();
    if (equity <= 0)
    {
        Print("ERROR: Invalid equity value: ", equity);
        return false;
    }
    double marginPercent = (AccountMargin() / equity) * 100;
    if (marginPercent > 90)  // 90% margin usage
    {
        Print("!!! MARGIN WARNING !!!");
        Print("Margin Usage: ", DoubleToString(marginPercent, 2), "%");
        Print("Emergency closing positions...");
        CloseAllPositions();
        return false;
    }

    // All checks passed
    return true;
}

//+------------------------------------------------------------------+
//| Função problemática 3: CheckRiskLimitsBeforeOpening             |
//+------------------------------------------------------------------+
bool CheckRiskLimitsBeforeOpening()
{
    if (!riskManagementEnabled)
        return true;

    double currentEquity = (double)AccountEquity();
    if (initialEquity <= 0)
    {
        Print("ERROR: Invalid initial equity: ", initialEquity);
        return false;
    }
    double currentDrawdown = ((initialEquity - currentEquity) / initialEquity) * 100;

    // Don't open new positions if drawdown is already high
    if (currentDrawdown > 10.0)  // 10% drawdown
    {
        Print("!!! HIGH DRAWDOWN WARNING !!!");
        Print("Current drawdown: ", DoubleToString(currentDrawdown, 2), "%");
        Print("New positions disabled until recovery");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Função problemática 4: GetATRValue (com timestamp)              |
//+------------------------------------------------------------------+
double GetATRValue(string symbol, int timeframe, int period)
{
    double atrBuffer[];
    ArrayResize(atrBuffer, period);

    if (CopyBuffer(iATR(symbol, timeframe, period), 0, 0, period, atrBuffer) <= 0)
    {
        Print("ERROR: Failed to copy ATR buffer for ", symbol);
        return 0;
    }

    return atrBuffer[0];
}

//+------------------------------------------------------------------+
//| Função problemática 5: HasProfitableDuration (conversão datetime)|
//+------------------------------------------------------------------+
bool HasProfitableDuration(int ticket, int requiredSeconds)
{
    CPositionInfo positionInfo;
    if (!positionInfo.SelectByTicket(ticket))
    {
        Print("ERROR: Failed to select position ", ticket);
        return false;
    }

    // Conversão problemática detectada
    datetime currentTime = TimeCurrent();
    long elapsedLong = currentTime - positionInfo.Time();
    double elapsedSeconds = (double)elapsedLong;

    return elapsedSeconds >= requiredSeconds;
}