//+------------------------------------------------------------------------+
//|      AMA "Adaptive Moving Average" beginner tutorial By William210.mq5 |
//|                                                   Copyright 2023, GwDs |
//|                                          Need more help? Contact me on |
//|                               https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"

#property version   "1.03" // Version 962

#property description "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
/*--- Indicator preference */
input group "AMA beginner tutorial to learn"                // Group title
input uchar                g_ama_period      = 9;           // Period of calculation
input uchar                g_fast_ma_period  = 2;           // Period of fast MA
input uchar                g_slow_ma_period  = 30;          // Period of slow MA
input uchar                g_ama_shift       = 0;           // Horizontal shift
input ENUM_APPLIED_PRICE   g_applied_price   = PRICE_CLOSE; // Type of price

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
/*--- Graph placement */
#property indicator_chart_window

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
/* Buffer declaration */
#property   indicator_buffers    1     // Number of buffer displayed

int         g_PtAMA = INVALID_HANDLE;  // Pointer of the iRsi function
double      g_iAMABuffer[];            // Data buffer
#define     g_indexIamaBuffer    0     // Index of buffer

#property   indicator_plots      1     // Number of plot on the graph

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
/*--- Buffer plot characteristics */
#property indicator_label1  "AMA"         // Label
#property indicator_type1   DRAW_LINE     // Plot type
#property indicator_color1  clrRed        // Plot color
#property indicator_style1  STYLE_SOLID   // Plot style
#property indicator_width1  1             // Plot width

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()

{
  Comment( "My apologies, this code is no longer available and I don't know how to remove/hide it from codebase");

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
  return( INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|   OnCalculate                                                    |
//+------------------------------------------------------------------+
int OnCalculate( const int        rates_total,      // Total number of bars to be processed
                 const int        prev_calculated,  // Number of bars calculated in the previous call
                 const datetime   &time[],          // Array of bar times
                 const double     &open[],          // Array of bar open prices
                 const double     &high[],          // Array of bar high prices
                 const double     &low[],           // Array of bar low prices
                 const double     &close[],         // Array of bar close prices
                 const long       &tick_volume[],   // Array of tick volumes for each bar
                 const long       &volume[],        // Array of real volumes for each bar
                 const int        &spread[])        // Array of spreads for each bar

{

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
  return(rates_total);
}

//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)

{
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Raz
  Comment( "");
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
