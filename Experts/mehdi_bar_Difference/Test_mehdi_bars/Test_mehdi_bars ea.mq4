//+------------------------------------------------------------------+
//|                                           Test_mehdi_bars ea.mq4 |
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

extern int bar=1;
double myPoint = 0.00001;

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

      double close = iClose(Symbol(),0,bar);
      double open  = iOpen(Symbol(),0,bar);
      
      double bodysize = MathAbs(open-close)/myPoint;
      
      Comment(bodysize);
   
  }
//+------------------------------------------------------------------+
