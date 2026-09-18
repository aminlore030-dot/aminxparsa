//+------------------------------------------------------------------+
//|                        MACD.mq5                                  |
//|      Custom Moving Average Convergence Divergence Indicator      |
//|      Developed by: Mohammadreza Mohammadi                        |
//|      Contact: mr.mhmdi93@gmail.com                               |
//+------------------------------------------------------------------+

#property copyright "Mohammadreza Mohammadi"
#property link      "mr.mhmdi93@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Defining MACD Line Properties
#property indicator_label1  "MACD Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Defining Signal Line Properties
#property indicator_label2  "Signal Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Defining Histogram Properties
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGreen
#property indicator_width3  3

#include <MovingAverages.mqh>

//--- Input Parameters for MACD Calculation
input int FastEMAPeriod = 12;  // Fast EMA Period
input int SlowEMAPeriod = 26;  // Slow EMA Period
input int SignalPeriod  = 9;   // Signal EMA Period

//--- Indicator Buffers
double MACDLineBuffer[], SignalLineBuffer[], HistogramBuffer[];

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   // Assign buffers to indicator data
   SetIndexBuffer(0, MACDLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SignalLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HistogramBuffer, INDICATOR_DATA);

   // Set the short name of the indicator
   string shortname;
   StringConcatenate(shortname, "MACD(", FastEMAPeriod, ",", SlowEMAPeriod, ",", SignalPeriod, ")");
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| MACD Calculation Function                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   // Check if there are enough data points for calculation
   if (rates_total < SlowEMAPeriod + SignalPeriod)
      return 0;

   // Declare and resize EMA buffers
   double FastEMA[], SlowEMA[];
   ArrayResize(FastEMA, rates_total);
   ArrayResize(SlowEMA, rates_total);
   
   // Compute Fast and Slow EMAs
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, FastEMAPeriod, price, FastEMA);
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, SlowEMAPeriod, price, SlowEMA);

   // Compute MACD Line (Difference between Fast and Slow EMA)
   for (int i = prev_calculated; i < rates_total; i++)
   {
      MACDLineBuffer[i] = FastEMA[i] - SlowEMA[i];
   }

   // Compute Signal Line (EMA of MACD Line)
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, SignalPeriod, MACDLineBuffer, SignalLineBuffer);

   // Compute Histogram (Difference between MACD Line and Signal Line)
   for (int i = prev_calculated; i < rates_total; i++)
   {
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
   }

   return rates_total;
}
