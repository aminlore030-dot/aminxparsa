//+------------------------------------------------------------------+
//|                                                Adaptable_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Adaptable RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot ARSI
#property indicator_label1  "ARSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  70.0;          // Overbought
input double               InpOversold       =  30.0;          // Oversold
//--- indicator buffers
double         BufferARSI[];
double         BufferLoss[];
double         BufferGain[];
double         BufferAvgLoss[];
double         BufferAvgGain[];
double         BufferMA[];
//--- global variables
double         overbought;
double         oversold;
int            period_ind;
int            handle_ma;
int            weight_sum_l;
int            weight_sum_g;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<2 ? 2 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferARSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLoss,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferGain,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgLoss,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferAvgGain,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptable RSI ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferARSI,true);
   ArraySetAsSeries(BufferLoss,true);
   ArraySetAsSeries(BufferGain,true);
   ArraySetAsSeries(BufferAvgLoss,true);
   ArraySetAsSeries(BufferAvgGain,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_EMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferARSI,EMPTY_VALUE);
      ArrayInitialize(BufferLoss,0);
      ArrayInitialize(BufferGain,0);
      ArrayInitialize(BufferAvgLoss,0);
      ArrayInitialize(BufferAvgGain,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=BufferMA[i]-BufferMA[i+1];
      if(diff>0)
        {
         BufferLoss[i]=0.;
         BufferGain[i]=diff;
        }
      else
        {
         BufferLoss[i]=-diff;
         BufferGain[i]=0;
        }
     }
   switch(InpMethod)
     {
      case MODE_EMA  :
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferLoss,BufferAvgLoss)==0) return 0;
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferGain,BufferAvgGain)==0) return 0;
      break;
      case MODE_SMMA :
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferLoss,BufferAvgLoss)==0) return 0;
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferGain,BufferAvgGain)==0) return 0;
      break;
      case MODE_LWMA :
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferLoss,BufferAvgLoss,weight_sum_l)==0) return 0;
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferGain,BufferAvgGain,weight_sum_g)==0) return 0;
      break;
      //---MODE_SMA
      default        :
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferLoss,BufferAvgLoss)==0) return 0;
        if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ind,BufferGain,BufferAvgGain)==0) return 0;
      break;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double loss=BufferAvgLoss[i];
      double gain=BufferAvgGain[i];
      BufferARSI[i]=(loss!=0 ? 100.0-100.0/(1.0+gain/loss) : 50);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
