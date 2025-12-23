// Test to check the brace balance
#include <Trade\Trade.mqh>

input bool CheckChartSize = true;
input int MinChartWidth = 400;
input int MinChartHeight = 300;
input bool AllowSideChart = false;

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