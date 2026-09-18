//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "ATR without approximation"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue

//
//
//

input int inpAtrPeriod = 14; // ATR period

double val[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);

      //
      //
      //
      
      iAtr.init(inpAtrPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR ("+(string)inpAtrPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++) 
   { 
      val[i] = iAtr.calculate(high,low,close,i,rates_total); 
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

class CAtr
{
   private :
         int    m_period;
         struct sAtrStruct
         {
            double tr;
            double sum;
         };
         sAtrStruct m_array[];
         int        m_arraySize;
   public :
      CAtr() : m_period(1), m_arraySize(-1) { return; }
     ~CAtr()                                { return; }
     
     //
     //---
     //
     
     void init(int period)
         {
            m_period = (period>1) ? period : 1;
         }
      template <typename T>         
      double calculate(T& high[], T& low[],T& close[], int i, int bars)
         {
            if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
             
               double t_high = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) : high[i];
               double t_low  = (i>0) ? (low[i] <close[i-1] ? low[i]  : close[i-1]) : low[i];
               
                  m_array[i].tr = t_high-t_low;
                  if (i>m_period)
                        { m_array[i].sum = m_array[i-1].sum-m_array[i-m_period].tr+m_array[i].tr; }
                  else  { m_array[i].sum = m_array[i].tr; for (int k=1; k<m_period && i>=k; k++) m_array[i].sum += m_array[i-k].tr; }
            return (m_array[i].sum/(double)m_period);
         }   
};
CAtr iAtr;