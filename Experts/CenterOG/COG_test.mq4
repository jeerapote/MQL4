//+------------------------------------------------------------------+
//|                                                     COG_test.mq4 |
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

int barsback=500;
int OnInit()
  {
//---
     double COG_upper_green = iCustom(NULL,0,"Market/Center of Gravity",barsback, 1, 0); 
   double COG_blue = iCustom(NULL,0,"Market/Center of Gravity",barsback, 0, 0);
   double COG_lower_green = iCustom(NULL,0,"Market/Center of Gravity",barsback, 2, 0);
   
    double COG_lower_brown = iCustom(NULL,0,"Market/Center of Gravity",barsback,4, 0);
    double COG_upper_brown = iCustom(NULL,0,"Market/Center of Gravity",barsback, 3, 0);
   
   Comment("upper: ",COG_upper_brown, " lower: ", COG_lower_brown, " blue: ", COG_blue);
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
  double COG_upper_green = iCustom(NULL,0,"Market/Center of Gravity",barsback, 1, 0); 
   double COG_blue = iCustom(NULL,0,"Market/Center of Gravity",barsback, 0, 0);
   double COG_lower_green = iCustom(NULL,0,"Market/Center of Gravity",barsback, 2, 0);
   
    double COG_lower_brown = iCustom(NULL,0,"Market/Center of Gravity",barsback,4, 0);
    double COG_upper_brown = iCustom(NULL,0,"Market/Center of Gravity",barsback, 3, 0);
   
  // Comment("upper: ",COG_upper_brown, " lower: ", COG_lower_brown, " blue: ", COG_blue);
   Comment(Bid+0.00031," "," ", COG_upper_green, " ",COG_blue, " ",((COG_upper_green-COG_blue)*10000*10));
  }
//+------------------------------------------------------------------+
