//+------------------------------------------------------------------+
//|                                                         ASAR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Advance Parabolic Time/Price System"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot SARUP
#property indicator_label1  "ASAR UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SARDN
#property indicator_label2  "ASAR DN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enum
enum ENUM_PRICE_MODE
  {
   PRICE_MODE_DEF,      // Defined
   PRICE_MODE_HL        // High/Low
  };
//--- input parameters
input ENUM_PRICE_MODE      InpPriceMode      =  PRICE_MODE_DEF;   // Price mode
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // Applied price
input double               InpStart          =  0.02;             // Start
input double               InpStep           =  0.002;            // Step
input double               InpMax            =  0.2;              // Max
input double               InpFilter         =  0.0;              // Filter
input double               InpMinChange      =  0.0;              // Min change
//--- indicator buffers
double         BufferSARUP[];
double         BufferSARDN[];
double         BufferMA[];
double         BufferAF[];
double         BufferTrend[];
//--- global variables
double         HighValue[10],LowValue[10],HiPrice[10],LoPrice[10];
double         start;
double         step;
double         max;
double         filter;
double         min_change;
datetime       last_time;
bool           first_start;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   start=(InpStart<0 ? 0 : InpStart);
   step=(InpStep<0.0001 ? 0.0001 : InpStep);
   max=(InpMax<0.002 ? 0.002 : InpMax);
   min_change=(InpMinChange<0 ? 0 : InpMinChange);
   filter=InpFilter;
   first_start=true;
   last_time=0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSARUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSARDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTrend,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ASAR ("+(string)start+","+(string)step+","+(string)max+","+(string)min_change+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSARUP,true);
   ArraySetAsSeries(BufferSARDN,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferAF,true);
   ArraySetAsSeries(BufferTrend,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA (1) object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferSARUP,EMPTY_VALUE);
      ArrayInitialize(BufferSARDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferAF,0);
      ArrayInitialize(BufferTrend,1);
     }

//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(last_time<time[i])
        {
         HighValue[2]=HighValue[1]; HighValue[1]=HighValue[0];
         LowValue[2]=LowValue[1];   LowValue[1]=LowValue[0];
         HiPrice[2]=HiPrice[1];     HiPrice[1]=HiPrice[0];
         LoPrice[2]=LoPrice[1];     LoPrice[1]=LoPrice[0];
         last_time=time[i];
        }
      if(InpPriceMode==PRICE_MODE_HL)
        {
         HiPrice[0]=high[i];
         LoPrice[0]=low[i];
        }
      else
         LoPrice[0]=HiPrice[0]=BufferMA[i];
      
      if(i==rates_total-2 && first_start)
        {
         BufferTrend[i]=1;
         HighValue[1]=HiPrice[1];
         HighValue[0]=fmax(HiPrice[0],HighValue[1]);
         LowValue[1]=LoPrice[1];
         LowValue[0]=fmin(LoPrice[0],LowValue[1]);
         BufferAF[i]=start;
         BufferSARUP[i]=LowValue[0];
         BufferSARDN[i]=EMPTY_VALUE;
         first_start=false;
         continue;
        }
      
      HighValue[0]=HighValue[1];
      LowValue[0]=LowValue[1];
      BufferTrend[i]=BufferTrend[i+1];
      BufferAF[i]=BufferAF[i+1];

      if(BufferTrend[i+1]>0.)
        {
         if(BufferTrend[i+1]==BufferTrend[i+2])
           {
            if(HighValue[1]>HighValue[2])
               BufferAF[i]=BufferAF[i+1]+step;
            if(BufferAF[i]>max)
               BufferAF[i]=max;
            if(HighValue[1]<HighValue[2])
               BufferAF[i]=start;
           }
         else
            BufferAF[i]=BufferAF[i+1];
         BufferSARUP[i]=BufferSARUP[i+1]+BufferAF[i]*(HighValue[1]-BufferSARUP[i+1]);
         if(BufferSARUP[i]>LoPrice[1])
            BufferSARUP[i]=LoPrice[1];
         if(BufferSARUP[i]>LoPrice[2])
            BufferSARUP[i]=LoPrice[2];
        }
      else
        {
         if(BufferTrend[i+1]<0)
           {
            if(BufferTrend[i+1]==BufferTrend[i+2])
              {
               if(LowValue[1]<LowValue[2])
                  BufferAF[i]=BufferAF[i+1]+step;
               if(BufferAF[i]>max)
                  BufferAF[i]=max;
               if(LowValue[1]>LowValue[2])
                  BufferAF[i]=start;
              }
            else
               BufferAF[i]=BufferAF[i+1];
            BufferSARDN[i]=BufferSARDN[i+1]+BufferAF[i]*(LowValue[1]-BufferSARDN[i+1]);
            if(BufferSARDN[i]<HiPrice[1])
               BufferSARDN[i]=HiPrice[1];
            if(BufferSARDN[i]<HiPrice[2])
               BufferSARDN[i]=HiPrice[2];
           }
        }

      if(HiPrice[0]>HighValue[0])
         HighValue[0]=HiPrice[0];
      if(LoPrice[0]<LowValue[0])
         LowValue[0]=LoPrice[0];

      if(min_change>0)
        {
         if(BufferSARUP[i]-BufferSARUP[i+1]<min_change*Point() && BufferSARUP[i]>0 && BufferSARUP[i+1]>0)
            BufferSARUP[i]=BufferSARUP[i+1];
         if(BufferSARDN[i+1]-BufferSARDN[i]<min_change*Point() && BufferSARDN[i]>0 && BufferSARDN[i+1]>0)
            BufferSARDN[i]=BufferSARDN[i+1];
        }

      if(BufferTrend[i]<0 && HiPrice[0]>=BufferSARDN[i]+filter*Point())
        {
         BufferTrend[i]=1;
         BufferSARUP[i]=LowValue[0];
         BufferSARDN[i]=EMPTY_VALUE;
         BufferAF[i]=start;
         LowValue[0]=LoPrice[0];
         HighValue[0]=HiPrice[0];
        }
      else
        {
         if(BufferTrend[i]>0 && LoPrice[0]<=BufferSARUP[i]-filter*Point())
           {
            BufferTrend[i]=-1;
            BufferSARDN[i]=HighValue[0];
            BufferSARUP[i]=EMPTY_VALUE;
            BufferAF[i]=start;
            LowValue[0]=LoPrice[0];
            HighValue[0]=HiPrice[0];
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
