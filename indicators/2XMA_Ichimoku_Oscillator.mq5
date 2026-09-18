//+---------------------------------------------------------------------+
//|                                         2XMA_Ichimoku_Oscillator.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property description "Осциллятор, построенный на разности двух сглаженных, разнопериодных линиях Tenkan-Sen в виде цветной гистограммы"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+ 
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrTeal,clrBlueViolet,clrGray,clrIndianRed,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "2Ichimoku XM Oscillator"
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum MODE_PRICE //Тип константы
  {
   OPEN = 0,     //По ценам открытия
   LOW,          //По минимумам
   HIGH,         //По максимумам
   CLOSE         //По ценам закрытия
  };
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint Up_period1=6; //1 период, используемый для вычисления наивысшего значения цены
input uint Dn_period1=6; //1 период, используеммый для вычисления наинизшего значения цены
//----
input uint Up_period2=9; //2 период, используемый для вычисления наивысшего значения цены
input uint Dn_period2=9; //2 период, используеммый для вычисления наинизшего значения цены
//---- 
input MODE_PRICE Up_mode1=HIGH;  //1 таймсерия для поиска максимумов 
input MODE_PRICE Dn_mode1=LOW;   //1 таймсерия для поиска минимумов 
//---- 
input MODE_PRICE Up_mode2=HIGH;  //2 таймсерия для поиска максимумов 
input MODE_PRICE Dn_mode2=LOW;   //2 таймсерия для поиска минимумов  
//---- 
input Smooth_Method XMA1_Method=MODE_SMA_; //1 метод усреднения
input Smooth_Method XMA2_Method=MODE_SMA_; //2 метод усреднения
//----
input int XLength1=25; //1 глубина сглаживания 
input int XLength2=80; //2 глубина сглаживания
//----                  
input int XPhase=15; //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//---- 
input int Shift=0; // сдвиг индикатора  по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ColorBuffer[],ExtLineBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int XMA1_Handle,XMA2_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
   CXMA XMA;
//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=int(MathMax(Up_period1,Dn_period1));
   min_rates_1+=GetStartBars(XMA1_Method,XLength1,XPhase);
   int min_rates_2=int(MathMax(Up_period2,Dn_period2));
   min_rates_2+=GetStartBars(XMA2_Method,XLength2,XPhase);
   min_rates_total=int(MathMax(min_rates_1,min_rates_2));

//---- получение хендла индикатора XMA_Ichimoku 1
   XMA1_Handle=iCustom(Symbol(),PERIOD_CURRENT,"XMA_Ichimoku",
                       Up_period1,Dn_period1,Up_mode1,Dn_mode1,XMA1_Method,XLength1,XPhase,0,0);
   if(XMA1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XMA_Ichimoku 1");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора XMA_Ichimoku 2
   XMA2_Handle=iCustom(Symbol(),PERIOD_CURRENT,"XMA_Ichimoku",
                       Up_period2,Dn_period2,Up_mode2,Dn_mode2,XMA2_Method,XLength2,XPhase,0,0);
   if(XMA2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XMA_Ichimoku 2");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ColorBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname="2 Ichimoku XMA Oscillator";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Проверка количества баров на достаточность для расчёта
   if(BarsCalculated(XMA1_Handle)<rates_total
      || BarsCalculated(XMA2_Handle)<rates_total
      || min_rates_total>rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,bar,to_copy;
   double XMA1[],XMA2[];

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(XMA1,true);
   ArraySetAsSeries(XMA2,true);

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
      ColorBuffer[rates_total-1]=2;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(XMA1_Handle,0,0,to_copy,XMA1)<=0) return(RESET);
   if(CopyBuffer(XMA2_Handle,0,0,to_copy,XMA2)<=0) return(RESET);


//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer[bar]=(XMA1[bar]-XMA2[bar])/_Point;
     }

   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- Основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double clr=2;
      int bar1=bar+1;

      if(ExtLineBuffer[bar]>=0)
        {
         if(ExtLineBuffer[bar]>ExtLineBuffer[bar1]) clr=0;
         if(ExtLineBuffer[bar]<ExtLineBuffer[bar1]) clr=1;
         if(ExtLineBuffer[bar]==ExtLineBuffer[bar1]) clr=ColorBuffer[bar1];
        }

      if(ExtLineBuffer[bar]<0)
        {
         if(ExtLineBuffer[bar]<ExtLineBuffer[bar1]) clr=4;
         if(ExtLineBuffer[bar]>ExtLineBuffer[bar1]) clr=3;
         if(ExtLineBuffer[bar]==ExtLineBuffer[bar1]) clr=ColorBuffer[bar1];
        }
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
