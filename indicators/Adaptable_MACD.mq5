//+------------------------------------------------------------------+
//|                                               Adaptable_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SIG
#property indicator_label2  "SIG"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot HIST
#property indicator_label3  "HIST"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,       // Yes
   INPUT_NO    =  0        // No
  };
//--- input parameters
input uint                 InpPeriodFastMA   =  12;            // Fast MA period
input uint                 InpPeriodSlowMA   =  26;            // Slow MA period
input uint                 InpPeriodSignalMA =  9;             // Signal line period
input ENUM_MA_METHOD       InpMethodFastMA   =  MODE_SMA;      // Fast MA calculation method
input ENUM_MA_METHOD       InpMethodSlowMA   =  MODE_SMA;      // Slow MA calculation method
input ENUM_MA_METHOD       InpMethodSignal   =  MODE_SMA;      // Signal line calculation method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input ENUM_INPUT_YES_NO    InpAbsValue       =  INPUT_YES;     // Use absolute values
//--- indicator buffers
double   BufferMACD[];
double   BufferSIG[];
double   BufferHIST[];
double   BufferColors[];
double   BufferFastMA[];
double   BufferSlowMA[];
//--- global variables
int      period_fast_ma;
int      period_slow_ma;
int      period_signal;
int      handle_fast_ma;
int      handle_slow_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast_ma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_slow_ma=int(InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   period_signal=int(InpPeriodSignalMA<1 ? 1 : InpPeriodSignalMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSIG,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHIST,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferFastMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSlowMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptable MACD("+(string)period_fast_ma+","+(string)period_slow_ma+","+(string)period_signal+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSIG,true);
   ArraySetAsSeries(BufferHIST,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFastMA,true);
   ArraySetAsSeries(BufferSlowMA,true);
//--- create handle of Fast and Slow MA
   ResetLastError();
   handle_fast_ma=iMA(NULL,PERIOD_CURRENT,period_fast_ma,0,InpMethodFastMA,InpAppliedPrice);
   if(handle_fast_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_slow_ma=iMA(NULL,PERIOD_CURRENT,period_slow_ma,0,InpMethodSlowMA,InpAppliedPrice);
   if(handle_slow_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSIG,EMPTY_VALUE);
      ArrayInitialize(BufferHIST,EMPTY_VALUE);
      ArrayInitialize(BufferFastMA,EMPTY_VALUE);
      ArrayInitialize(BufferSlowMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_fast_ma,0,0,count,BufferFastMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_slow_ma,0,0,count,BufferSlowMA);
   if(copied!=count) return 0;
//--- Расчёт MACD
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMACD[i]=(InpAbsValue ? BufferFastMA[i]-BufferSlowMA[i] : (BufferFastMA[i]-BufferSlowMA[i])/(BufferSlowMA[i]!=0 ? BufferSlowMA[i] : DBL_MIN));
//--- Расчёт сигнальной линии и гистограммы
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSIG[i]=MAOnArray(BufferMACD,0,period_signal,0,InpMethodSignal,i);
      BufferHIST[i]=BufferMACD[i]-BufferSIG[i];
      if(BufferHIST[i]>BufferHIST[i+1])
         BufferColors[i]=0;
      else
         BufferColors[i]=1;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double MAOnArray(double &array[],int total,int period,int ma_shift,int ma_method,int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
//---
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1;i<period;i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2) buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos;i<period;i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1;i<=period;i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0) break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default: return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
