//+------------------------------------------------------------------+
//|                                              ADX Smoothed.mq5    |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#property version   "1.01"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//---- plot DiPlus
#property indicator_label1  "Di Plus"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---- plot DiMinus
#property indicator_label2  "Di Minus"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//---- plot ADX
#property indicator_label3  "ADX"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//---- indicator level
#property indicator_level1 25
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//---- input parameters
input int    per = 14;          // Period
input double alpha1 = 0.25;     // Alpha1 Smoothing
input double alpha2 = 0.33;     // Alpha2 Smoothing
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE; // Price Type
//---- buffers
double DiPlusFinal[];
double DiMinusFinal[];
double ADXFinal[];
double DIPlusLead[];
double DIMinusLead[];
double ADXLead[];
//---- handles
int adx_handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0, DiPlusFinal, INDICATOR_DATA);
   SetIndexBuffer(1, DiMinusFinal, INDICATOR_DATA);
   SetIndexBuffer(2, ADXFinal, INDICATOR_DATA);
   SetIndexBuffer(3, DIPlusLead, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, DIMinusLead, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, ADXLead, INDICATOR_CALCULATIONS);

//---- set arrays as series immediately for consistency
   ArraySetAsSeries(DiPlusFinal, true);
   ArraySetAsSeries(DiMinusFinal, true);
   ArraySetAsSeries(ADXFinal, true);
   ArraySetAsSeries(DIPlusLead, true);
   ArraySetAsSeries(DIMinusLead, true);
   ArraySetAsSeries(ADXLead, true);

//---- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

//---- set short name
   IndicatorSetString(INDICATOR_SHORTNAME, "ADX(" + string(per) + ") Smoothed");

//---- create ADX handle
   adx_handle = iADX(_Symbol, _Period, per);
   if(adx_handle == INVALID_HANDLE)
     {
      Print("Failed to create ADX handle");
      return(INIT_FAILED);
     }

//---- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(adx_handle != INVALID_HANDLE)
      IndicatorRelease(adx_handle);
  }
//+------------------------------------------------------------------+
//| Custom indicator calculation function                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- check for enough bars
   if(rates_total <= per + 1)
      return(0);

//---- calculate start position
   int start;

// Initialize arrays with adequate size
   if(prev_calculated == 0)
     {
      // Initialize all buffers to zero
      ArrayInitialize(DiPlusFinal, 0.0);
      ArrayInitialize(DiMinusFinal, 0.0);
      ArrayInitialize(ADXFinal, 0.0);
      ArrayInitialize(DIPlusLead, 0.0);
      ArrayInitialize(DIMinusLead, 0.0);
      ArrayInitialize(ADXLead, 0.0);

      // Start calculation from period+1 to have enough data
      start = rates_total - per - 1;
     }
   else
      start = rates_total - prev_calculated;

// Bound check
   if(start < 0)
      start = 0;
   if(start > rates_total - 2)
      start = rates_total - 2;

//---- get ADX data
   double plus_di[];
   double minus_di[];
   double adx[];

// Allocate arrays with sufficient size
   ArrayResize(plus_di, rates_total);
   ArrayResize(minus_di, rates_total);
   ArrayResize(adx, rates_total);

// Set arrays as series for consistent indexing
   ArraySetAsSeries(plus_di, true);
   ArraySetAsSeries(minus_di, true);
   ArraySetAsSeries(adx, true);

//---- copy ADX data
   if(CopyBuffer(adx_handle, 1, 0, rates_total, plus_di) <= 0)
     {
      Print("Failed to copy +DI data");
      return(prev_calculated);
     }

   if(CopyBuffer(adx_handle, 2, 0, rates_total, minus_di) <= 0)
     {
      Print("Failed to copy -DI data");
      return(prev_calculated);
     }

   if(CopyBuffer(adx_handle, 0, 0, rates_total, adx) <= 0)
     {
      Print("Failed to copy ADX data");
      return(prev_calculated);
     }

//---- first smoothing
   for(int i = start; i >= 0; i--)
     {
      // Make sure we don't access beyond array bounds
      if(i + 1 >= rates_total)
         continue;

      // Calculate first smoothing with safe indexing
      DIPlusLead[i] = 2 * plus_di[i] + (alpha1 - 2) * plus_di[i + 1] +
                      (1 - alpha1) * DIPlusLead[i + 1];

      DIMinusLead[i] = 2 * minus_di[i] + (alpha1 - 2) * minus_di[i + 1] +
                       (1 - alpha1) * DIMinusLead[i + 1];

      ADXLead[i] = 2 * adx[i] + (alpha1 - 2) * adx[i + 1] +
                   (1 - alpha1) * ADXLead[i + 1];
     }

//---- second smoothing
   for(int i = start; i >= 0; i--)
     {
      // Make sure we don't access beyond array bounds
      if(i + 1 >= rates_total)
         continue;

      // Calculate second smoothing with safe indexing
      DiPlusFinal[i] = alpha2 * DIPlusLead[i] + (1 - alpha2) * DiPlusFinal[i + 1];
      DiMinusFinal[i] = alpha2 * DIMinusLead[i] + (1 - alpha2) * DiMinusFinal[i + 1];
      ADXFinal[i] = alpha2 * ADXLead[i] + (1 - alpha2) * ADXFinal[i + 1];
     }

//---- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+