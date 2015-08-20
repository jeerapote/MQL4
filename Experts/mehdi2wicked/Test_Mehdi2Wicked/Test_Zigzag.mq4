//+------------------------------------------------------------------+
//|                                                  Test_Zigzag.mq4 |
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

int ExtDepth=12;
 int ExtDeviation=5;
 int ExtBackstep=3;
 
 
 extern int bar;
 
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
double p0=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,2,bar);
   Comment(p0);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
double p0=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,2,bar);
   Comment(p0);
  }
//+------------------------------------------------------------------+
