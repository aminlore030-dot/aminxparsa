//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Adx trend filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'160,231,160',C'231,160,160'
#property indicator_label2  "Adx trend histogram"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrGray,clrLimeGreen,clrGreen,clrRed,clrMaroon
#property indicator_width2  2
#property indicator_label3  "Adx trend"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGray,clrLimeGreen,clrRed
#property indicator_width3  2
//
//---
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
//
//---
//
input double          AdxVmaPeriod      = 10;             // AdxVma period
input enPrices        AdxVmaPrice       = pr_close;       // Price
input int             SmoothPeriod      = 5;              // Smoothing period (<=1 for no smoothing)
//
//---
//
double  val[],valc[],valfu[],valfd[],histo[],histoc[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,valfu ,INDICATOR_DATA);
   SetIndexBuffer(1,valfd ,INDICATOR_DATA);
   SetIndexBuffer(2,histo ,INDICATOR_DATA);
   SetIndexBuffer(3,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,val   ,INDICATOR_DATA);
   SetIndexBuffer(5,valc  ,INDICATOR_COLOR_INDEX);
      for (int k=0; k<2; k++) PlotIndexSetInteger(k,PLOT_SHOW_DATA,false);
      IndicatorSetString(INDICATOR_SHORTNAME,"Adx trend ("+string(AdxVmaPeriod)+","+string(SmoothPeriod)+")");
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double trendup,trenddn;
         iAdxvma(getPrice(AdxVmaPrice,open,close,high,low,i,rates_total),AdxVmaPeriod,i,rates_total,trendup,trenddn,1);
         val[i]    = (trendup>0) ? iSmooth(trendup,SmoothPeriod,0,i,rates_total,0) : iSmooth(trenddn,SmoothPeriod,0,i,rates_total,0);
         valc[i]   = (trendup>0) ? 1 : (trenddn>0) ? 2 : (i>0) ? valc[i-1] : 0; 
         valfu[i]  = (trendup>0) ? val[i] : 0;
         valfd[i]  = (trendup>0) ? 0 : val[i];
         histo[i]  = val[i];
         histoc[i] = (i>0) ? (valc[i]==1) ? (val[i]>val[i-1]) ? 1 : 2 : (val[i]<val[i-1]) ? 4 : 3 : 0;
   }      
   return(i);
}


//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _adxvmaInstances     2
#define _adxvmaInstancesSize 7
double  _adxvmaWork[][_adxvmaInstances*_adxvmaInstancesSize];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6

double iAdxvma(double price, double period, int i, int bars, double& trendp, double& trendm, int instanceNo=0)
{
   if (ArrayRange(_adxvmaWork,0)!=bars) ArrayResize(_adxvmaWork,bars); instanceNo*=_adxvmaInstancesSize;
   
   //
   //
   //
   //
   //
   
   for (int k=0; k<7; k++) _adxvmaWork[i][instanceNo+k] = price;
   if (period>1)
   {
      double diff = (i>0) ? _adxvmaWork[i][instanceNo+_adxvmaWprc]-_adxvmaWork[i-1][instanceNo+_adxvmaWprc] : 0;
      double tpdm = (diff>0) ?  diff : 0;
      double tmdm = (diff<0) ? -diff : 0;
         _adxvmaWork[i][instanceNo+_adxvmaWpdm] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWpdm]+tpdm)/period : tpdm;
         _adxvmaWork[i][instanceNo+_adxvmaWmdm] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWmdm]+tmdm)/period : tmdm;

      double trueRange = _adxvmaWork[i][instanceNo+_adxvmaWpdm]+_adxvmaWork[i][instanceNo+_adxvmaWmdm];
      double tpdi      = (trueRange>0) ? _adxvmaWork[i][instanceNo+_adxvmaWpdm]/trueRange : 0;
      double tmdi      = (trueRange>0) ? _adxvmaWork[i][instanceNo+_adxvmaWmdm]/trueRange : 0;
         _adxvmaWork[i][instanceNo+_adxvmaWpdi] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWpdi]+tpdi)/period : tpdi;
         _adxvmaWork[i][instanceNo+_adxvmaWmdi] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWmdi]+tmdi)/period : tmdi;
                                         trendp = _adxvmaWork[i][instanceNo+_adxvmaWpdi]-0.5;
                                         trendm = _adxvmaWork[i][instanceNo+_adxvmaWmdi]-0.5;
   
      //
      //
      //
      //
      //
      
      double tout  = 0; 
         if ((_adxvmaWork[i][instanceNo+_adxvmaWpdi]+_adxvmaWork[i][instanceNo+_adxvmaWmdi])>0) 
               tout = MathAbs(_adxvmaWork[i][instanceNo+_adxvmaWpdi]-_adxvmaWork[i][instanceNo+_adxvmaWmdi])/(_adxvmaWork[i][instanceNo+_adxvmaWpdi]+_adxvmaWork[i][instanceNo+_adxvmaWmdi]);
                              _adxvmaWork[i][instanceNo+_adxvmaWout] = (i>0) ? ((period-1.0)*_adxvmaWork[i-1][instanceNo+_adxvmaWout]+tout)/period : tout;

      double thi = (i>0) ? MathMax(_adxvmaWork[i][instanceNo+_adxvmaWout],_adxvmaWork[i-1][instanceNo+_adxvmaWout]) : _adxvmaWork[i][instanceNo+_adxvmaWout];
      double tlo = (i>0) ? MathMin(_adxvmaWork[i][instanceNo+_adxvmaWout],_adxvmaWork[i-1][instanceNo+_adxvmaWout]) : _adxvmaWork[i][instanceNo+_adxvmaWout];
         for (int k = 2; k<period && i-k>=0; k++)
         {
            thi = MathMax(_adxvmaWork[i-k][instanceNo+_adxvmaWout],thi);
            tlo = MathMin(_adxvmaWork[i-k][instanceNo+_adxvmaWout],tlo);
         }            
      double vi = ((thi-tlo)>0) ? (_adxvmaWork[i][instanceNo+_adxvmaWout]-tlo)/(thi-tlo) : 0;
                                   _adxvmaWork[i][instanceNo+_adxvmaWval] = (i>0) ? ((period-vi)*_adxvmaWork[i-1][instanceNo+_adxvmaWval]+vi*_adxvmaWork[i][instanceNo+_adxvmaWprc])/period : price;

   }          
   
   //
   //
   //
   //
   //
   
   return(_adxvmaWork[i][instanceNo+_adxvmaWval]);
}
//
//---
//
#define _smoothInstances     1
#define _smoothInstancesSize 10
double m_wrk[][_smoothInstances*_smoothInstancesSize];
int    m_size=0;
//
//---
//
double iSmooth(double price,double length,double phase,int r,int bars,int instanceNo=0)
  {
   #define bsmax  5
   #define bsmin  6
   #define volty  7
   #define vsum   8
   #define avolty 9

   if(ArrayRange(m_wrk,0)!=bars) ArrayResize(m_wrk,bars); if(ArrayRange(m_wrk,0)!=bars) return(price); instanceNo*=_smoothInstancesSize;
   if(r==0 || length<=1) { int k=0; for(; k<7; k++) m_wrk[r][instanceNo+k]=price; for(; k<10; k++) m_wrk[r][instanceNo+k]=0; return(price); }

//
//---
//

   double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1   = MathMax(len1-2.0,0.5);
   double del1   = price - m_wrk[r-1][instanceNo+bsmax];
   double del2   = price - m_wrk[r-1][instanceNo+bsmin];
   int    forBar = MathMin(r,10);

   m_wrk[r][instanceNo+volty]=0;
   if(MathAbs(del1) > MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del1);
   if(MathAbs(del1) < MathAbs(del2)) m_wrk[r][instanceNo+volty] = MathAbs(del2);
   m_wrk[r][instanceNo+vsum]=m_wrk[r-1][instanceNo+vsum]+(m_wrk[r][instanceNo+volty]-m_wrk[r-forBar][instanceNo+volty])*0.1;

//
//---
//

   m_wrk[r][instanceNo+avolty]=m_wrk[r-1][instanceNo+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(m_wrk[r][instanceNo+vsum]-m_wrk[r-1][instanceNo+avolty]);
   double dVolty=(m_wrk[r][instanceNo+avolty]>0) ? m_wrk[r][instanceNo+volty]/m_wrk[r][instanceNo+avolty]: 0;
   if(dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if(dVolty < 1)                      dVolty = 1.0;

//
//---
//

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if(del1 > 0) m_wrk[r][instanceNo+bsmax] = price; else m_wrk[r][instanceNo+bsmax] = price - Kv*del1;
   if(del2 < 0) m_wrk[r][instanceNo+bsmin] = price; else m_wrk[r][instanceNo+bsmin] = price - Kv*del2;

//
//---
//

   double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
   double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
   double alpha = MathPow(beta,pow2);

   m_wrk[r][instanceNo+0] = price + alpha*(m_wrk[r-1][instanceNo+0]-price);
   m_wrk[r][instanceNo+1] = (price - m_wrk[r][instanceNo+0])*(1-beta) + beta*m_wrk[r-1][instanceNo+1];
   m_wrk[r][instanceNo+2] = (m_wrk[r][instanceNo+0] + corr*m_wrk[r][instanceNo+1]);
   m_wrk[r][instanceNo+3] = (m_wrk[r][instanceNo+2] - m_wrk[r-1][instanceNo+4])*MathPow((1-alpha),2) + MathPow(alpha,2)*m_wrk[r-1][instanceNo+3];
   m_wrk[r][instanceNo+4] = (m_wrk[r-1][instanceNo+4] + m_wrk[r][instanceNo+3]);

//
//---
//

   return(m_wrk[r][instanceNo+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
  }
//
//---
//
#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}