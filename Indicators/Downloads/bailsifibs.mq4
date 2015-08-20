//+------------------------------------------------------------------+
//|                                                         Fibs.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property  indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Yellow
#property indicator_color8 Yellow
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2


extern int   StartBar = 0;
extern int   BarsBack = 50;
extern int MA_1_Calc_Period=10;
extern int MA_2_Calc_Period=30;
extern double   Percent1 = 0.25;
extern double   Percent2 = 0.382;
extern double   Percent3 = 0.618;
extern double   Percent4 = 0.75;
extern double   Extension1 = 1.618;

int ExtCountedBars=0;
double
fib_1[],
fib_2[],
fib_3[],
fib_4[],
fib_5[],
fib_6[],
fib_7[],
MA_1,
MA_2;
bool Trend_up;

void DeleteAllObjects()
{
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringFind(name,"Fibs",0)>-1) ObjectDelete(name);
      
      WindowRedraw();
   }
}

void CalcFibo()
{
  
  DeleteAllObjects();
  
  MA_1 = iMA(NULL,PERIOD_H1,MA_1_Calc_Period,0,MODE_EMA,PRICE_TYPICAL,0);
  MA_2 = iMA(NULL,PERIOD_H1,MA_2_Calc_Period,0,MODE_EMA,PRICE_TYPICAL,0);

  if(MA_2 > MA_1)
  {
      Trend_up=false;
  }
  
  if(MA_2 < MA_1)
  {
      Trend_up=true;
  }
  
  int lowest_bar = iLowest(NULL,0,MODE_LOW,BarsBack,StartBar);
  int highest_bar = iHighest(NULL,0,MODE_HIGH,BarsBack,StartBar);
  
  double higher_point = 0;
  double lower_point = 0;
  higher_point=High[highest_bar];
  lower_point=Low[lowest_bar];
  
  int i = 0;
  
  double Retrace1 = Percent1;
  double Retrace2 = Percent2;
  double Retrace3 = Percent3;
  double Retrace4 = Percent4;
  double Exten1 = Extension1;

if(Trend_up)
  {
      for(i = 0; i < 500; i++)
      {
         fib_1[i] = higher_point;
         fib_2[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace1,Digits);
         fib_3[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace2,Digits);
         fib_4[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace3,Digits);
         fib_5[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace4,Digits);
         fib_6[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Exten1,Digits);
         fib_7[i] = lower_point;
          
      }
  }
  else
  {
      for(i = 0; i < 500; i++)
      {
         fib_7[i] = higher_point;
         fib_6[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace1,Digits);
         fib_5[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace2,Digits);
         fib_4[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace3,Digits);
         fib_3[i] = NormalizeDouble(lower_point+(higher_point-lower_point)*Retrace4,Digits);
         fib_2[i] = NormalizeDouble(higher_point-(higher_point-lower_point)*Exten1,Digits);
         fib_1[i] = lower_point;
      }
      DeleteAllObjects();
   }  
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
//---- indicator buffers mapping

    SetIndexBuffer(0,fib_1);
    SetIndexBuffer(1,fib_2);
    SetIndexBuffer(2,fib_3);
    SetIndexBuffer(3,fib_4);
    SetIndexBuffer(4,fib_5);
    SetIndexBuffer(5,fib_6);
    SetIndexBuffer(6,fib_7);
//----
    return(0);
   }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteAllObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 CalcFibo();
  return(0);
}
//+------------------------------------------------------------------+