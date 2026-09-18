//+------------------------------------------------------------------+
//|                        Alligator for beginners by William210.mq5 |
//|                                             Copyright 2023, GwDs |
//|                                    Need more help? Contact me on |
//|                         https://www.mql5.com/fr/users/william210 |
//+------------------------------------------------------------------+

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

#property copyright "Copyright 2023, GwDs"
#property version   "1.02" // Version 926

#property description "Search all my free or paid codes with William210"

#property description "\nAlligator beginner tutorial to learn"
#property description "Questions about the code? ask me in MP"
#property description "Contact me on https://www.mql5.com/fr/users/william210"
#property description "Code request? https://www.mql5.com/en/forum/453288"

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Indicator preference
input group "Alligator beginner tutorial to learn"         // Group title
input uchar                g_jaw_period    = 13;           // Period of the Jaw line
input uchar                g_jaw_shift     = 8;            // Shift of the Jaw line
input uchar                g_teeth_period  = 8;            // Period of the Teeth line
input uchar                g_teeth_shift   = 5;            // Shift of the Teeth line
input uchar                g_lips_period   = 5;            // Period of the Lips line
input uchar                g_lips_shift    = 3;            // Shift of the Lips line
input ENUM_MA_METHOD       g_MA_method     = MODE_SMMA;    // Method of averaging of the Alligator lines
input ENUM_APPLIED_PRICE   g_applied_price = PRICE_MEDIAN; // Type of price used for calculation of Alligator

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Graph placement
#property indicator_chart_window    // Plot on the graph

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  Buffer declaration
#property   indicator_buffers                3  // Number of buffer displayed

int         g_PtAlligator = INVALID_HANDLE;     // Pointer of the iRsi function

double      g_JawsBuffer[];                     // Data buffer jaws
#define     g_IndexJawsBuffer                0  // Index of Jaws

double      g_TeethBuffer[];                    // Data buffer teeth
#define     g_IndexTeethBuffer               1  // Index of teeth

double      g_LipsBuffer[];                     // Data buffer lips
#define     g_IndexLipsBuffe                 2  // Index of lips

#property   indicator_plots                  3  // Number of plot on the graph

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- Buffer plot characteristics
//--- plot Jaws
#property indicator_label1  "Jaws"        // Label
#property indicator_type1   DRAW_LINE     // Plot type
#property indicator_color1  clrBlue       // Color
#property indicator_style1  STYLE_SOLID   // Plot style    
#property indicator_width1  1             // Plot width
//--- plot Teeth
#property indicator_label2  "Teeth"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lips
#property indicator_label3  "Lips"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()

{
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- handle Creation
  g_PtAlligator = iAlligator( _Symbol, _Period,
                              g_jaw_period, g_jaw_shift,
                              g_teeth_period, g_teeth_shift,
                              g_lips_period, g_lips_shift,
                              g_MA_method,
                              g_applied_price
                            );

// --- Control of pointer creation
  if( g_PtAlligator == INVALID_HANDLE)

  {
    PrintFormat( "%s: Error when creating Alligator pointer",
                 __FUNCTION__
               );
    return( INIT_FAILED);
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Transforms the array into display buffer
  SetIndexBuffer( g_IndexJawsBuffer, g_JawsBuffer, INDICATOR_DATA);

  {
    PrintFormat( "%s: Error %d SetIndexBuffer( g_BuffADXMinus)",
                 __FUNCTION__, GetLastError()
               );
  }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- g_TeethBuffer buffer
  SetIndexBuffer(g_IndexTeethBuffer, g_TeethBuffer, INDICATOR_DATA);

  {
    PrintFormat( "%s: Error %d SetIndexBuffer( g_BuffADXMinus)",
                 __FUNCTION__, GetLastError()
               );
  }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// --- g_LipsBuffer buffer
  SetIndexBuffer(g_IndexLipsBuffe, g_LipsBuffer, INDICATOR_DATA);

  {
    PrintFormat( "%s: Error %d SetIndexBuffer( g_BuffADXMinus)",
                 __FUNCTION__, GetLastError()
               );
  }

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Lag to give the illusion of a prediction
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// Shiift the buffer g_JawsBuffer
  PlotIndexSetInteger( g_IndexJawsBuffer, PLOT_SHIFT, g_jaw_shift);

  {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)",
                 __FUNCTION__, GetLastError()
               );
  }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// Shiift the buffer g_TeethBuffer
  PlotIndexSetInteger( g_IndexTeethBuffer, PLOT_SHIFT, g_teeth_shift);

  {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)",
                 __FUNCTION__, GetLastError()
               );
  }

//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// Shiift the buffer g_LipsBuffer
  PlotIndexSetInteger( g_IndexLipsBuffe,  PLOT_SHIFT, g_lips_shift);

  {
    PrintFormat( "%s: Error %d PlotIndexSetInteger( g_indexiMA)",
                 __FUNCTION__, GetLastError()
               );
  }

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
// Variables
  int i_Diff = 0; // The correct number of bars to copy

//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- With this code, the average is only updated when a new bar is opened
  if( prev_calculated < rates_total)

  {
    i_Diff = rates_total - prev_calculated;

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    // --- Copy history data to g_TeethBuffer buffer
    if ( CopyBuffer( g_PtAlligator, g_IndexJawsBuffer,  - g_jaw_shift, i_Diff, g_JawsBuffer) < 0)

    {
      PrintFormat("%s: Data recovery error for jaws",
                  __FUNCTION__);
      return (0);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    // --- g_TeethBuffer buffer
    if ( CopyBuffer( g_PtAlligator, g_IndexTeethBuffer, - g_teeth_shift, i_Diff, g_TeethBuffer) < 0)

    {
      PrintFormat("%s: Data recovery error for teeth",
                  __FUNCTION__);
      return (0);
    }

    //+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    // --- g_LipsBuffer buffer
    if ( CopyBuffer( g_PtAlligator, g_IndexLipsBuffe, - g_lips_shift, i_Diff, g_LipsBuffer) < 0)

    {
      PrintFormat("%s: Data recovery error for lips",
                  __FUNCTION__);
      return (0);
    }
  }

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
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
// --- Deleting handle if valid
  if( g_PtAlligator != INVALID_HANDLE)

  {
    //  release the indicator resource
    IndicatorRelease( g_PtAlligator);
    g_PtAlligator = INVALID_HANDLE;
  }
}
//+------------------------------------------------------------------+
//| The End, That’s All Folks!                                       |
//+------------------------------------------------------------------+
//+-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-__-
//+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
