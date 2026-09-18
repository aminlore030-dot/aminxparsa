//+------------------------------------------------------------------+
//|                                                          BOP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Balance of Power oscillator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot BOP
#property indicator_label1  "BOP"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodAct      =  14;         // Period
input uint              InpPeriodRng      =  28;         // Range
input ENUM_INPUT_YES_NO InpUseLastPeriod  =  INPUT_YES;  // Use last period
//--- indicator buffers
double         BufferBOP[];
double         BufferColors[];
//--- global variables
int            period_act;
int            period_rng;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_act=int(InpPeriodAct<1 ? 1 : InpPeriodAct);
   period_rng=int(InpPeriodRng<1 ? 1 : InpPeriodRng);
   period_max=fmax(period_act,period_rng);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBOP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Balance of Power ("+(string)period_act+","+(string)period_rng+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBOP,true);
   ArraySetAsSeries(BufferColors,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferBOP,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int shift=(InpUseLastPeriod ? 0 : 1);
      int bh=Highest(period_rng,i+shift);
      int bl=Lowest(period_rng,i+shift);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=high[bh];
      double min=low[bl];
      BufferBOP[i]=(max!=min ? (close[i]-open[i+period_act-1])/(max-min) : 0);
      BufferColors[i]=(close[i]>min+(max-min)/2.0 ? 0 : 1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
