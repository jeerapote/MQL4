//+------------------------------------------------------------------+
//|                                              Test_Zigzag_TVI.mq4 |
//|                                                        murat aka |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "murat aka"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   extern double  Tolerance = 0.0010;
   extern double   Percent1 = 0.236;
   //extern double   Percent1 =-2;
   
   
      double xazz_Sell_signal_Last = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 1); //
      double xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 1); //
      double xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 0); //
      double xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 0); //
      
      
      
int OnInit()
  {
//---


   int ExtDepth=12;
   int ExtDeviation=5;
   int ExtBackstep=3;
   int n, i, bar, bar4; 
   double p0, p1, p2, p3, p4, p5;
  
   double
            TVI, TVI_Last;
 
   i=0;
   
      while(n<5)
      {
      if(p0>0) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,0,i);
      if(n==2){bar = i;}
      if(n==0){bar4=i;} 
      if(p0>0) {n+=1; }
      i++;
      }
      
   TVI_Last = iCustom(NULL,0,"TVI_v2",5,5,5, 1, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
   
   xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar); //
   xazz_Sell_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar); //
   
   xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar4); //
   xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar4); //
   
  // Comment( "p2: ",p2, " ", xazz_Buy_signal_Last, " ", xazz_Buy_signal_Now," ", xazz_Sell_signal_Last," ",xazz_Sell_signal_Now);
   
  // double Retrace1 = Percent1;
   
  // double fib = NormalizeDouble(Bid-(Bid-xazz_Buy_signal_Now)*Retrace1,Digits);
   double fib236 = NormalizeDouble(xazz_Buy_signal_Now+(p3-xazz_Buy_signal_Now)*Percent1,Digits);
   double zigzag_length = NormalizeDouble(p3-xazz_Buy_signal_Now,Digits);
   
  // Comment(Bid-(zigzag_length/5));
  Comment("Fib ",fib236);
   
   
   
 
 
 
//---


   return(INIT_SUCCEEDED);
  }
  
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

//---
   
   
  }
//+------------------------------------------------------------------+
