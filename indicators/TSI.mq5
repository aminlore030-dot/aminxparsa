//+------------------------------------------------------------------+
//|                        TSI.mq5                                   |
//|       Custom True Strength Index (TSI) Indicator                |
//|       Developed by: Mohammadreza Mohammadi                      |
//|       Contact: mr.mhmdi93@gmail.com                             |
//+------------------------------------------------------------------+

#property copyright "Mohammadreza Mohammadi"
#property link      "mr.mhmdi93@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1

//--- Plot settings for TSI Line
#property indicator_label1  "TSI_Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_applied_price PRICE_CLOSE

#include <MovingAverages.mqh>

//--- Input parameters for EMA periods
input int      EMA1 = 25;
input int      EMA2 = 13;

//--- Indicator buffers
double         TSI_LineBuffer[],
               MomBuffer[], 
               AbsMomBuffer[], 
               EMA_MomBuffer[],
               EMA_EMAMomBuffer[],
               EMA_AbsMomBuffer[],
               EMA_EMAAbsMomBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Set buffers for indicator calculation
   SetIndexBuffer(0, TSI_LineBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, MomBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, AbsMomBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, EMA_MomBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, EMA_EMAMomBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, EMA_AbsMomBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, EMA_EMAAbsMomBuffer, INDICATOR_CALCULATIONS);
   
   // Define the starting point of the plot
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, EMA1 + EMA2 - 1);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   
   // Set the indicator short name
   string shortname;
   StringConcatenate(shortname, "TSI(", EMA1, ",", EMA2, ")");
   PlotIndexSetString(0, PLOT_LABEL, shortname);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   // Ensure enough data points are available
   if(rates_total < EMA1 + EMA2)
      return(0);
   
   // Initialize buffers only on the first calculation
   if(prev_calculated == 0)
     {
      for(int i = 0; i < rates_total; i++)
        {
         MomBuffer[i] = 0.0;
         AbsMomBuffer[i] = 0.0;
         EMA_MomBuffer[i] = 0.0;
         EMA_AbsMomBuffer[i] = 0.0;
         EMA_EMAMomBuffer[i] = 0.0;
         EMA_EMAAbsMomBuffer[i] = 0.0;
         TSI_LineBuffer[i] = 0.0;
        }
     }
   
   int first = (prev_calculated == 0) ? 1 : prev_calculated - 1;

   // Calculate Momentum and Absolute Momentum
   for(int i = first; i < rates_total; i++)
     {
      MomBuffer[i] = price[i] - price[i - 1];
      AbsMomBuffer[i] = fabs(MomBuffer[i]);
     }

   // First level smoothing using EMA
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, EMA1, MomBuffer, EMA_MomBuffer);
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, EMA1, AbsMomBuffer, EMA_AbsMomBuffer);

   // Second level smoothing using EMA
   ExponentialMAOnBuffer(rates_total, prev_calculated, EMA1, EMA2, EMA_MomBuffer, EMA_EMAMomBuffer);
   ExponentialMAOnBuffer(rates_total, prev_calculated, EMA1, EMA2, EMA_AbsMomBuffer, EMA_EMAAbsMomBuffer);

   // Compute TSI (True Strength Index)
   first = (prev_calculated == 0) ? EMA1 + EMA2 - 1 : prev_calculated - 1;
   for(int i = first; i < rates_total; i++)
     {
      if(EMA_EMAAbsMomBuffer[i] != 0)
         TSI_LineBuffer[i] = 100 * EMA_EMAMomBuffer[i] / EMA_EMAAbsMomBuffer[i];
      else
         TSI_LineBuffer[i] = 0;
     }

   return(rates_total);
  }
