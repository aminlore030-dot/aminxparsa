//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Chaos zone"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen,clrRed,clrForestGreen,clrDarkOrange,clrDarkGray
#property indicator_width1  2

input ENUM_APPLIED_PRICE Price        =  PRICE_CLOSE;  // Price
input int                inMaLength1  =  3;            // Fast ma period
input ENUM_MA_METHOD     inMaMode1    =  MODE_LWMA;    // Fast ma method
input int                inMaLength2  =  8;            // Medium ma period
input ENUM_MA_METHOD     inMaMode2    =  MODE_LWMA;    // Medium ma method
input int                inMaLength3  = 14;            // Slow ma period
input ENUM_MA_METHOD     inMaMode3    =  MODE_LWMA;    // Slow ma method
double  chigh[],clow[],copen[],cclose[],ccolor[];
int _ma1Handle,_ma2Handle,_ma3Handle;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,copen,INDICATOR_DATA);
   SetIndexBuffer(1,chigh,INDICATOR_DATA);
   SetIndexBuffer(2,clow,INDICATOR_DATA);
   SetIndexBuffer(3,cclose,INDICATOR_DATA);
   SetIndexBuffer(4,ccolor,INDICATOR_COLOR_INDEX);

   _ma1Handle = iMA(_Symbol,0,inMaLength1,0,inMaMode1,Price); if(_ma1Handle==INVALID_HANDLE) { return(INIT_FAILED); }
   _ma2Handle = iMA(_Symbol,0,inMaLength2,0,inMaMode2,Price); if(_ma2Handle==INVALID_HANDLE) { IndicatorRelease(_ma1Handle); return(INIT_FAILED); }
   _ma3Handle = iMA(_Symbol,0,inMaLength3,0,inMaMode3,Price); if(_ma3Handle==INVALID_HANDLE) { IndicatorRelease(_ma1Handle); IndicatorRelease(_ma2Handle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"3 MAs Market");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if(BarsCalculated(_ma1Handle)<rates_total) return(prev_calculated);
   if(BarsCalculated(_ma2Handle)<rates_total) return(prev_calculated);
   if(BarsCalculated(_ma3Handle)<rates_total) return(prev_calculated);
   double _ma1Val[2],_ma2Val[2],_ma3Val[2];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      chigh[i]  = high[i];
      clow[i]   = low[i];
      copen[i]  = open[i];
      cclose[i] = close[i];
      int _ma1Copied = CopyBuffer(_ma1Handle,0,time[i],2,_ma1Val);
      int _ma2Copied = CopyBuffer(_ma2Handle,0,time[i],2,_ma2Val);
      int _ma3Copied = CopyBuffer(_ma3Handle,0,time[i],2,_ma3Val);
      if(_ma1Copied==2 && _ma2Copied==2 && _ma3Copied==2)
        {
         bool Cond1 = _ma1Val[1] > _ma2Val[1] && _ma2Val[1] > _ma3Val[1] && _ma1Val[1] > _ma1Val[0];
         bool Cond2 = _ma1Val[1] > _ma2Val[1] && _ma2Val[1] < _ma3Val[1] && _ma1Val[1] > _ma1Val[0];
         bool Cond3 = _ma1Val[1] < _ma2Val[1] && _ma2Val[1] < _ma3Val[1] && _ma1Val[1] < _ma1Val[0];
         bool Cond4 = _ma1Val[1] < _ma2Val[1] && _ma2Val[1] > _ma3Val[1] && _ma1Val[1] < _ma1Val[0];
         ccolor[i]=(Cond1) ? 0 :(Cond2) ? 2 :(Cond3) ? 1 :(Cond4) ? 3 : 4;
        }
     }
   return(i);
  }
//+------------------------------------------------------------------+
