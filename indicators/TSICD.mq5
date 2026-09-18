//+------------------------------------------------------------------+
//|                        TSICD.mq5                                 |
//|       Custom True Strength Index with Double Confirmation        |
//|       Developed by: Mohammadreza Mohammadi                       |
//|       Contact: mr.mhmdi93@gmail.com                              |
//+------------------------------------------------------------------+

#property copyright "Mohammadreza Mohammadi" // Copyright notice for the indicator
#property link      "mr.mhmdi93@gmail.com"    // Contact email for the developer
#property version   "1.00"                    // Version number of the indicator
#property indicator_separate_window           // Indicator will be displayed in a separate window
#property indicator_buffers 8                 // Total number of buffers used in the indicator
#property indicator_plots   2                 // Number of plots (lines) to be drawn

//--- Settings for the TSI Line plot
#property indicator_label1  "TSI"             // Label for the TSI line in the chart
#property indicator_type1   DRAW_LINE         // Type of plot: continuous line
#property indicator_color1  clrRed            // Color of the TSI line
#property indicator_style1  STYLE_SOLID       // Style of the TSI line: solid
#property indicator_width1  1                 // Width of the TSI line

//--- Settings for the Signal Line plot
#property indicator_label2  "Signal"          // Label for the Signal line in the chart
#property indicator_type2   DRAW_LINE         // Type of plot: continuous line
#property indicator_color2  clrBlue           // Color of the Signal line
#property indicator_style2  STYLE_SOLID       // Style of the Signal line: solid
#property indicator_width2  1                 // Width of the Signal line

#property indicator_applied_price PRICE_CLOSE // Price type used for calculations: closing price

#include <MovingAverages.mqh>                  // Include the MovingAverages library for EMA calculations

//--- Input parameters for customization by the user
input int      EMA1 = 25;       // Period for the first Exponential Moving Average (EMA)
input int      EMA2 = 13;       // Period for the second Exponential Moving Average (EMA)
input int      SignalEMA = 9;   // Period for the Signal Line EMA

//--- Indicator buffers to store calculated data
double         TSI_LineBuffer[],        // Buffer to hold the TSI line values
               SignalBuffer[],          // Buffer to hold the Signal line values
               MomBuffer[],             // Buffer to store raw momentum values
               AbsMomBuffer[],          // Buffer to store absolute momentum values
               EMA_MomBuffer[],         // Buffer for the first EMA applied to momentum
               EMA_EMAMomBuffer[],      // Buffer for the second EMA applied to momentum
               EMA_AbsMomBuffer[],      // Buffer for the first EMA applied to absolute momentum
               EMA_EMAAbsMomBuffer[];   // Buffer for the second EMA applied to absolute momentum

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Assign buffers to store indicator data and intermediate calculations
   SetIndexBuffer(0, TSI_LineBuffer, INDICATOR_DATA);         // Buffer 0: Stores TSI line data for plotting
   SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);           // Buffer 1: Stores Signal line data for plotting
   SetIndexBuffer(2, MomBuffer, INDICATOR_CALCULATIONS);      // Buffer 2: Stores momentum for internal use
   SetIndexBuffer(3, AbsMomBuffer, INDICATOR_CALCULATIONS);   // Buffer 3: Stores absolute momentum for internal use
   SetIndexBuffer(4, EMA_MomBuffer, INDICATOR_CALCULATIONS);  // Buffer 4: First EMA of momentum
   SetIndexBuffer(5, EMA_EMAMomBuffer, INDICATOR_CALCULATIONS); // Buffer 5: Second EMA of momentum
   SetIndexBuffer(6, EMA_AbsMomBuffer, INDICATOR_CALCULATIONS); // Buffer 6: First EMA of absolute momentum
   SetIndexBuffer(7, EMA_EMAAbsMomBuffer, INDICATOR_CALCULATIONS); // Buffer 7: Second EMA of absolute momentum
   
   //--- Define where the plotting should start based on EMA periods
   int draw_begin = EMA1 + EMA2 - 1; // Minimum bars needed before plotting begins
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, draw_begin); // Set starting point for TSI line
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, draw_begin); // Set starting point for Signal line
   
   //--- Set precision for displayed values
   IndicatorSetInteger(INDICATOR_DIGITS, 2); // Display TSI and Signal values with 2 decimal places
   
   //--- Create a short name for the indicator based on input parameters
   string shortname; // Variable to store the indicator's short name
   StringConcatenate(shortname, "TSICD(", EMA1, ",", EMA2, ",", SignalEMA, ")"); // Format: TSICD(EMA1,EMA2,SignalEMA)
   IndicatorSetString(INDICATOR_SHORTNAME, shortname); // Assign the short name to the indicator
   
   //--- Set labels for the plotted lines
   PlotIndexSetString(0, PLOT_LABEL, "TSI");    // Label for the TSI line
   PlotIndexSetString(1, PLOT_LABEL, "Signal"); // Label for the Signal line
   
   return(INIT_SUCCEEDED); // Return success to indicate proper initialization
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,        // Total number of bars in the chart
                const int prev_calculated,    // Number of bars already calculated in the previous call
                const int begin,              // Starting point of the data (unused here)
                const double &price[])        // Array of price data (close prices)
  {
   //--- Check if there are enough bars for calculation
   if(rates_total < EMA1 + EMA2) // Ensure enough data points for EMA1 + EMA2 periods
      return(0); // Exit if insufficient data
   
   //--- Initialize all buffers to zero on the first run
   if(prev_calculated == 0) // First call or chart reset
     {
      for(int i = 0; i < rates_total; i++) // Loop through all bars
        {
         MomBuffer[i] = 0.0;            // Reset momentum buffer
         AbsMomBuffer[i] = 0.0;         // Reset absolute momentum buffer
         EMA_MomBuffer[i] = 0.0;        // Reset first EMA of momentum
         EMA_AbsMomBuffer[i] = 0.0;     // Reset first EMA of absolute momentum
         EMA_EMAMomBuffer[i] = 0.0;     // Reset second EMA of momentum
         EMA_EMAAbsMomBuffer[i] = 0.0;  // Reset second EMA of absolute momentum
         TSI_LineBuffer[i] = 0.0;       // Reset TSI line buffer
         SignalBuffer[i] = 0.0;         // Reset Signal line buffer
        }
     }
   
   //--- Determine the starting point for calculations
   int first = (prev_calculated == 0) ? 1 : prev_calculated - 1; // Start from bar 1 on first run, otherwise continue from last calculated

   //--- Step 1: Calculate Momentum and Absolute Momentum
   for(int i = first; i < rates_total; i++) // Loop through bars to calculate momentum
     {
      MomBuffer[i] = price[i] - price[i - 1]; // Momentum: difference between current and previous close price
      AbsMomBuffer[i] = fabs(MomBuffer[i]);    // Absolute Momentum: absolute value of momentum
     }

   //--- Step 2: Apply first level of smoothing with EMA
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, EMA1, MomBuffer, EMA_MomBuffer);       // First EMA on momentum
   ExponentialMAOnBuffer(rates_total, prev_calculated, 1, EMA1, AbsMomBuffer, EMA_AbsMomBuffer); // First EMA on absolute momentum

   //--- Step 3: Apply second level of smoothing with EMA
   ExponentialMAOnBuffer(rates_total, prev_calculated, EMA1, EMA2, EMA_MomBuffer, EMA_EMAMomBuffer);       // Second EMA on momentum
   ExponentialMAOnBuffer(rates_total, prev_calculated, EMA1, EMA2, EMA_AbsMomBuffer, EMA_EMAAbsMomBuffer); // Second EMA on absolute momentum

   //--- Step 4: Calculate the True Strength Index (TSI)
   first = (prev_calculated == 0) ? EMA1 + EMA2 - 1 : prev_calculated - 1; // Adjust starting point for TSI calculation
   for(int i = first; i < rates_total; i++) // Loop to compute TSI values
     {
      if(EMA_EMAAbsMomBuffer[i] != 0) // Avoid division by zero
         TSI_LineBuffer[i] = 100 * EMA_EMAMomBuffer[i] / EMA_EMAAbsMomBuffer[i]; // TSI formula: (EMA2 of Mom / EMA2 of AbsMom) * 100
      else
         TSI_LineBuffer[i] = 0; // Set TSI to zero if denominator is zero
     }

   //--- Step 5: Calculate the Signal Line as EMA of TSI
   int begin_signal = EMA1 + EMA2 - 1; // Starting point for Signal line calculation
   ExponentialMAOnBuffer(rates_total, prev_calculated, begin_signal, SignalEMA, TSI_LineBuffer, SignalBuffer); // EMA of TSI for Signal line

   return(rates_total); // Return the total number of bars processed
  }
