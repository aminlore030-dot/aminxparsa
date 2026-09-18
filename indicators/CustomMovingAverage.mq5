//+------------------------------------------------------------------+
//|                        CustomMA.mq5                              |
//|      Custom Moving Average (MA) Indicator                        |
//|      Developed by: Mohammadreza Mohammadi                        |
//|      Contact: mr.mhmdi93@gmail.com                               |
//+------------------------------------------------------------------+

#property copyright "Mohammadreza Mohammadi"
#property link      "mr.mhmdi93@gmail.com"
#property version   "1.00"
#property indicator_chart_window  // Indicator will be shown in the main chart window
#property indicator_buffers 1   // Show only one buffer (the MA line)
#property indicator_plots   1   // Display one plot (line)

//--- Indicator labels and styles
#property indicator_label1  "Custom MA Line"
#property indicator_type1   DRAW_LINE  // Draw as a line
#property indicator_color1  clrBlue    // Line color
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2         // Line thickness

//--- Input parameters for the MA periods
input int MA_Period = 14;        // Period for the Moving Average
input ENUM_MA_METHOD MA_Method = MODE_SMA; // Type of MA (SMA, EMA, etc.)
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE;  // Applied price (Close, Open, etc.)

//--- Buffer for the MA line
double MA_LineBuffer[];

//+------------------------------------------------------------------+
//| Initialization function for setting up the indicator            |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set the buffer for the MA line
   SetIndexBuffer(0, MA_LineBuffer, INDICATOR_DATA);

   // Set the short name for the indicator
   string shortname;
   StringConcatenate(shortname, "Custom MA(", MA_Period, ", ", MA_Method, ")");
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Calculation function for the MA indicator                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[])
{
   // Ensure enough data points are available for calculation
   if (rates_total < MA_Period)
      return(0);

   // Define the starting index for the calculation
   int start = prev_calculated - 1;
   if (prev_calculated == 0)
   {
      start = MA_Period;
   }

   // Loop through the data to calculate the moving average
   for (int i = start; i < rates_total; i++)
   {
      double sum = 0;
      
      // For SMA, calculate the average of the last 'MA_Period' prices
      if (MA_Method == MODE_SMA)
      {
         for (int j = 0; j < MA_Period; j++)
         {
            sum += price[i - j];
         }
         MA_LineBuffer[i] = sum / MA_Period;
      }
      
      // For EMA, apply the exponential weighting formula
      else if (MA_Method == MODE_EMA)
      {
         double alpha = 2.0 / (MA_Period + 1);
         if (i == start)
         {
            // Initialize EMA with the first simple moving average (SMA)
            sum = 0;
            for (int j = 0; j < MA_Period; j++)
            {
               sum += price[i - j];
            }
            MA_LineBuffer[i] = sum / MA_Period;  // Start with SMA for the first value
         }
         else
         {
            MA_LineBuffer[i] = alpha * price[i] + (1 - alpha) * MA_LineBuffer[i - 1];
         }
      }
      
      // For SMMA, apply the smoothed moving average formula
      else if (MA_Method == MODE_SMMA)
      {
         if (i == start)
         {
            // Initialize SMMA with the first SMA
            sum = 0;
            for (int j = 0; j < MA_Period; j++)
            {
               sum += price[i - j];
            }
            MA_LineBuffer[i] = sum / MA_Period;  // Start with SMA for the first value
         }
         else
         {
            MA_LineBuffer[i] = (MA_LineBuffer[i - 1] * (MA_Period - 1) + price[i]) / MA_Period;
         }
      }
      
      // For LWMA, apply the linear weighted moving average formula
      else if (MA_Method == MODE_LWMA)
      {
         double weightSum = 0;
         double weightedSum = 0;
         for (int j = 0; j < MA_Period; j++)
         {
            weightSum += (MA_Period - j);
            weightedSum += price[i - j] * (MA_Period - j);
         }
         MA_LineBuffer[i] = weightedSum / weightSum;
      }
   }

   return(rates_total);
}
