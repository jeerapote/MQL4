//+------------------------------------------------------------------+
//|                                       OBV, TVI, Price_Div_EA.mq4 |
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
//---Gadi_OBV_v2.2 for EA.mq4

double OBV = iCustom(NULL,0,"Gadi_OBV_v2.2 for EA", 0, 0);
   double TVI_Last = iCustom(NULL,0,"TVI_v2",5,5,5, 4, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
    Comment(OBV);
   
   
  }
//+------------------------------------------------------------------+
