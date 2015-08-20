//+------------------------------------------------------------------+
//|                                          Test_WickPercentage.mq4 |
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

extern int bar, type;
int OnInit()
  {
//---
   
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
    double   engulf = iCustom(NULL,0,"Strategy2/WickPercentage",99, type, bar); //
    double close = iClose(Symbol(),0,bar);
    double open  = iOpen(Symbol(),0,bar);
   if(type==0) Comment(" engulf= ",engulf, " open=", open);
   if(type==1) Comment(" engulf= ",engulf, " close=", close);
  
  
  /*
 int n, i, bar; 
   double p0, p1, p2, p3, p4, p5;
   
   int wickedBuy_indicator=0;
   int wickedSell_indicator=1;
  
    double
 TVI, TVI_Last;
 
 double Tolerance=0.0003;
   i=0;
   
      while(n<5)
      {
      if(p0!=0) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(NULL,0,"Strategy2/WickPercentage", wickedBuy_indicator, i); //
      if(n==2){bar = i;}
      if(p0!=0) {n+=1; }
      i++;
      }
      
   
   Comment(" p3= ",p3);
   */
  }
//+------------------------------------------------------------------+
