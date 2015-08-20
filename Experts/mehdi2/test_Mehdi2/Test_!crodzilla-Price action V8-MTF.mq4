//+------------------------------------------------------------------+
//|                          Test_!crodzilla-Price action V8-MTF.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //!crodzilla-Price action V8-MTF
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
 // int   engulf = iCustom(NULL,0,"Strategy2/Engulfing Bar Alert v1.2_FGB", 0, 0); //
   
 //  Comment(" engulf= ",engulf);
 
 
 int n, i, bar; 
   double p0, p1, p2, p3, p4, p5;
   
 int crodzillaSell_indicator=1;
 int crodzillaBuy_indicator=0;  
  
    double
 TVI, TVI_Last;
 
 double Tolerance=0.0003;
   i=0;
   
      while(n<5)
      {
      if(p0!=2147483647) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(NULL,0,"Strategy2/!crodzilla-Price action V8-MTF", crodzillaBuy_indicator, i); //
      if(n==2){bar = i;}
      if(p0!=2147483647) {n+=1; }
      i++;
      }
    
    double crodzilla_signal = p4;  
   
   Comment(" crodzilla= ",crodzilla_signal);
  // engulf = iCustom(NULL,0,"Strategy2/Engulfing Bar Alert v1.2_FGB", 0, 0); //
  }
//+------------------------------------------------------------------+
