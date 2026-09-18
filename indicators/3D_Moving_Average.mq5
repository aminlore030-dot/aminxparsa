//+------------------------------------------------------------------+
//|                                            3D Moving Avarage.mq5 |
//|                                    Copyright 2020, Nikolai Semko |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Nikolai Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"
#property version   "1.04"
#include <Canvas\iCanvas.mqh> //https://www.mql5.com/ru/code/22164
#property indicator_chart_window
#property indicator_plots   1
#property indicator_buffers 1


double  _Close[];
int Ma=0;
int stepMa=10;
int Size=0;
int _a,_b,X,Y,_x,_y;
double max, min;
double _r;
int per=1;
double K;
bool _c=true;
static int ss=150;
double SIN[],COS[];
//+------------------------------------------------------------------+
//|                                                                  |
//+---------------------------------б--------------------------------+
int OnInit() {
   ChartSetInteger(0,CHART_FOREGROUND,true);
   ChartSetInteger(0,CHART_SHOW,false);
   GetData();
   Canvas.TextColor=0xFFFFFFFF;
   _r=_Height/2;
   per=2*_Height;
   ArrayResize(SIN,per);
   ArrayResize(COS,per);
   K=100*_Height;
   X=_Width/2;
   Y=_Height/2;
   if (stepMa<1) stepMa = 1;
   if (stepMa>100) stepMa = 100;
   for(int i=0; i<per; i++) {
      SIN[i]=sin(i*2*M_PI/per);
      COS[i]=cos(i*2*M_PI/per);
   }
   nMA();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   if (reason<2)ChartSetInteger(0,CHART_SHOW,true);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[]) {
   if (rates_total!=prev_calculated) { GetData(); nMA();}
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if (id==CHARTEVENT_CHART_CHANGE) GetData();
   if(sparam=="46") {
      if (_c) _c=false;   // если нажата клавиша C(c) переключаем цветовой режим
      else _c=true;
      nMA();
   }
   if (id==CHARTEVENT_MOUSE_MOVE)  {
      if(_MouseX>_Width-30 && _MouseY>0) {
         ss=_MouseY;
         stepMa=1+ss/15;
      }
      nMA();
   }
}
//+------------------------------------------------------------------+
void nMA() {
   if (Size<10) GetData();
   Canvas.Erase(0xFF000000);
   double S=0;
   double A[];
   ArrayResize(A,Ma);
   if (_MouseX<_Width-40) {
      _a=(_Width/2  - _MouseX + 5*per)%per;
      _b=(_Height/2 - _MouseY + 5*per)%per;
   }
   int MA=Ma-(Ma-1)%stepMa;
   if (MA>Size) return;
   for(int i=Size-1; i>=Size-MA; i--) S+=_Close[i];
   for(int Per=MA; Per>0;) {
      double s=S;
      uint Clr=Grad((double)Per/MA);
      int j=0;
      for(int i=Size-1; i>=0; i--) {
         double Y1=s/Per;
         j=Size-1-i;
         if (j<Ma) A[j]=Y1;
         else break;
         if(i-Per>=0) s=s+_Close[i-Per]-_Close[i];
         else break;
      }
      DrawIndicatorLine(Per,A,Clr,0,j);

      for(j=0; j<stepMa && Per >0; j++) {
            S=S-_Close[Size-Per];
            Per--;
         }
   }
   uint clr1=0xFF3A3A3A;
   uint clr2=0xFF5A5A5A;
   uint clr3=0xFF7A7A7A;
   
   if (_MouseX>_Width-30) {
   clr1=0xFF4A4A4A;
   clr2=0xFF7A7A7A;
   clr3=0xFF9A9A9A;
   }
   
   Canvas.FillRectangle( _Width-16,0,_Width-1,_Height-1,clr1);
   Canvas.FillRectangle( _Width-16,ss+20,_Width-1,ss-20,clr2);
   Canvas.LineHorizontal( _Width-16,_Width-1,ss,clr3);
   Canvas.LineHorizontal( _Width-16,_Width-1,ss+1,clr3);
   _CommXY(_Width-45,ss-10,(string)stepMa);
   
   Canvas.Update();
}
//+------------------------------------------------------------------+
uint Grad(double p) {
   static uint Col[6]= {0xFF0000FF,0xFF00FFFF,0xFF00FF00,0xFFFFFF00,0xFFFF0000,0xFFFF00FF};
   if(p>0.9999) return Col[5];
   if(p<0.0001) return Col[0];
   p=p*5;
   int n=(int)p;
   double k=p-n;
   argb c1,c2;
   c1.clr=Col[n];
   c2.clr=Col[n+1];
   return ARGB(255,c1.c[2]+uchar(k*(c2.c[2]-c1.c[2])+0.5),
               c1.c[1]+uchar(k*(c2.c[1]-c1.c[1])+0.5),
               c1.c[0]+uchar(k*(c2.c[0]-c1.c[0])+0.5));
}
//+------------------------------------------------------------------+
void DrawIndicatorLine(int z, double &arr[], uint clr, int barStart=INT_MIN, int barEnd=INT_MAX, int shift=0) {
   if (barStart<0) barStart=0;
   if (barEnd>_Width-40) barEnd=_Width-40;
   int n=barEnd-barStart;
   barStart+=shift;
   barEnd+=shift;
   double x=(double)Ma-X;
   double y=_Y(arr[0])-Y;
   _3D(x,y,z);
   int pre_x=_x;
   int pre_y=_y;
   Canvas.PixelSet(_x,_y-100,clr);
   x--;
   for(int i=1; i<n; i++, x--) {
      y=Canvas.Y(arr[i])-Y;
      if (_c) clr=Grad((arr[i]-min)/(max-min));
      //clr = TRGB(255-uchar(105+150.0*z/Ma),clr&0x00FFFFFF);
      _3D(x,y,z);
      if(fabs(y-pre_y)>1) Canvas.Line(_x,_y-100,pre_x,pre_y-100,clr);
      else Canvas.PixelSet(_x,_y-100,clr);
      pre_y=_y;
      pre_x=_x;
   }
}
//+------------------------------------------------------------------+
void _3D(double x, double y, int z) {
   if (_a <0 || _b<0 || _a>=per || _b>=per) return;
   double x1=x*COS[_a]+z*SIN[_a];
   double z1=-x*SIN[_a]+z*COS[_a];
   double y1=y*COS[_b]+z1*SIN[_b];
   double z2=-y*SIN[_b]+z1*COS[_b];
   z2=z2+_r;
   _x=Round(X+K*x1/(z2+K));
   _y=Round(Y+K*y1/(z2+K));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetData() {
   Ma=_Width-40;
   Size=CopyClose(_Symbol,_Period,0,Ma+Ma,_Close);
   if (Size<Ma+Ma) Ma=Size/2;
   if (Size<2) {Ma=1; return;}
   max = _Close[ArrayMaximum(_Close,Size-1-Ma,Ma)];
   min = _Close[ArrayMinimum(_Close,Size-1-Ma,Ma)];
   W.dy_pix= (max-min)/_Height;
   W.Y_max=max;
   W.Y_min=min;
   W.dx_pix=1;
}
//+------------------------------------------------------------------+
