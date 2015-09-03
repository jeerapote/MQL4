//+------------------------------------------------------------------+
//|                          Support - Resistance - Price Action.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input double   ref=0.0;
input double   lots=0.1;
input double   tp=15;
input double   sl=15;
input bool   UsePattern1bullish=true;
input bool   UsePattern2bullish=true;
input bool   UsePattern3bullish=true;
input bool   UsePattern1bearish=true;
input bool   UsePattern2bearish=true;
input bool   UsePattern3bearish=true;
//---
int refhit=0;
int orderopen=0;
//---
int ticket;
bool close1;
bool modify1;
//---
int digit1=Digits();
int dig;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//---
   dig=digit1-1;
//---- Candle1 OHLC
   double O1=NormalizeDouble(iOpen(Symbol(),PERIOD_M1,2),dig);
   double H1=NormalizeDouble(iHigh(Symbol(),PERIOD_M1,2),dig);
   double L1=NormalizeDouble(iLow(Symbol(),PERIOD_M1,2),dig);
   double C1=NormalizeDouble(iClose(Symbol(),PERIOD_M1,2),dig);
//---- Candle2 OHLC
   double O2=NormalizeDouble(iOpen(Symbol(),PERIOD_M1,1),dig);
   double H2=NormalizeDouble(iHigh(Symbol(),PERIOD_M1,1),dig);
   double L2=NormalizeDouble(iLow(Symbol(),PERIOD_M1,1),dig);
   double C2=NormalizeDouble(iClose(Symbol(),PERIOD_M1,1),dig);
//---- Candle3 OHLC
   double O3=NormalizeDouble(iOpen(Symbol(),PERIOD_M1,0),dig);
   double H3=NormalizeDouble(iHigh(Symbol(),PERIOD_M1,0),dig);
   double L3=NormalizeDouble(iLow(Symbol(),PERIOD_M1,0),dig);
   double C3=NormalizeDouble(iClose(Symbol(),PERIOD_M1,0),dig);
//---- Check to see if Reference Price (ref) is reached
   if(refhit==0)
     {
      if((H3==ref) || (L3==ref) || ((H3>ref) && (L3<ref)) || ((L2<ref) && (H3>=ref)) || ((H2>ref) && (L3<=ref)))
        {
         refhit=1;
         return(0);
        }
     }
//---- Check for patterns if no position has been opened
   if(orderopen==0)
     {
      //--- Pattern 1 - bullish 
      if(refhit==1 && C1>=O1 && L1<O1 && ((O1-L1)>(C1-O1)) && C2>=O2 && C2>H1 && L2>L1 && C2>ref)
        {
         ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,Bid-(sl*10*Point),Bid+(tp*10*Point));
         orderopen=1;
         return(0);
        }
      //--- Pattern 2 - bullish
      if(refhit==1 && C1<O1 && C2>O2 && ((O1-C1)>(H1-O1)) && ((O1-C1)>(C1-L1)) && ((C2-O2)>(H2-C2)) && ((C2-O2)>(O2-L2)) && O2<=C1 && O2>=L1 && C2>=O1 && C2<=H1 && C2>ref)
        {
         ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,Bid-(sl*10*Point),Bid+(tp*10*Point));
         orderopen=1;
         return(0);
        }
      //--- Pattern 3 - bullish
      if(refhit==1 && C1>O1 && ((C2-O2)>=(H2-C2)) && C2>O2 && C2>C1 && C1>ref && C2>ref)
        {
         ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,5,Bid-(sl*10*Point),Bid+(tp*10*Point));
         orderopen=1;
         return(0);
        }
      //---- Pattern 1 - bearish
      if(refhit==1 && C1<=O1 && H1>O1 && ((H1-O1)>(O1-C1)) && C2<=O2 && C2<L1 && H2<H1 && C2<ref)
        {
         ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,5,Ask+(sl*10*Point),Ask-(tp*10*Point));
         orderopen=1;
         return(0);
        }
      //---- Pattern 2 - bearish
      if(refhit==1 && C1>O1 && C2<O2 && ((C1-O1)>(H1-C1)) && ((C1-O1)>(O1-L1)) && ((O2-C2)>(H2-O2)) && ((O2-C2)>(C2-L2)) && O2>=C1 && O2<=H1 && C2<=O1 && C2>=L1 && C2<ref)
        {
         ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,5,Ask+(sl*10*Point),Ask-(tp*10*Point));
         orderopen=1;
         return(0);
        }
      //---- Pattern 3 - bearish
      if(refhit==1 && C1<O1 && ((O2-C2)>=(C2-L2)) && C2<O2 && C2<C1 && C1<ref && C2<ref)
        {
         ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,5,Ask+(sl*10*Point),Ask-(tp*10*Point));
         orderopen=1;
         return(0);
        }
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
