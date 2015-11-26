//+------------------------------------------------------------------+
//|                                                      1pip_ea.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


int bar=1;
int ticket_buy;
int ticket_sell;
double myPoint=0.00001;

int           Tally,LOrds,send,
SOrds,PendBuy,PendSell;

double upperLimit = 100;
double lowerLimit = 50;

string Sym=Symbol();

int count=0;

//extern double StopLossFactor=8;
//extern double TakeProfitFactor=4;
extern double pipsAbove=0.0002;
extern double pipsBelow=0.0002;
extern int difference=30;
extern double TakeProfit=20;
extern double Lot=0.1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--
/* ticket_buy = OrderSend(Sym, OP_BUYSTOP, Lot,Ask, 0, 0, 0);
      ticket_sell = OrderSend(Sym, OP_SELLSTOP, Lot, Bid, 0, 0 , 0);
      CloseAll_Buy();
      CloseAll_Sell();
      */
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

   double high  = iHigh(Symbol(),0,bar);
   double low   = iLow(Symbol(),0,bar);

   double bodysize=MathAbs(high-low)/Point;

   if(iVolume(NULL,0,0)==1 && bodysize<upperLimit && bodysize>lowerLimit)
     {

      ticket_buy=OrderSend(Sym,OP_BUYSTOP,Lot,high,0,0,high+TakeProfit*Point);
      ticket_sell=OrderSend(Sym,OP_SELLSTOP,Lot,low,0,0,low-TakeProfit*Point);

     }

   if(LOrds>0 || SOrds>0)
     {

      int cpt,total=OrdersTotal();

      for(cpt=0;cpt<total;cpt++)
        {

         OrderSelect(cpt,SELECT_BY_POS);
         if(OrderSymbol()==Symbol() && OrderType()>1){
             
             ENUM_ORDER_TYPE orderType = OrderType();
             
             OrderDelete(OrderTicket());
             if(orderType==OP_BUYSTOP){
               OrderSend(Sym,OP_BUYSTOP,LotsAdded(),high,0,0,high+TakeProfit*Point);
             
             }
                          
             if(orderType==OP_SELLSTOP){
               OrderSend(Sym,OP_SELLSTOP,LotsAdded(),low,0,0,low-TakeProfit*Point);
             
             }
             
             
             
         }    
        }
    
     }

   if(OrdersTotal()<2)
     {

      EndSession();

     }


  }
//============ LOTS ADDED FUNCTION: EXTREME MEASURE TO DETERMINE LOTS TO BE ADDED TO COMPENSATE FOR MISSING TP AT MA HIT ======================//
//------------------------------------------ WE GUARANTEE PROFIT AT MA HIT WITH THIS EXTREME LOGIC -----------------------------

double LotsAdded()
  {

   double lotsCompensation;

   double profit=10;

/*   for(int cnt=0;cnt<OrdersTotal();cnt++)
     {

      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

      if(OrderType()==OP_SELL)
        {
         profit=Bid-OrderOpenPrice();
        }

      if(OrderType()==OP_BUY)
        {
         profit=OrderOpenPrice()-Ask;
        }
     }
     
     */

   lotsCompensation=(MathAbs(Tally))/((profit*Point)*MarketInfo(Symbol(),MODE_LOTSIZE));

   return lotsCompensation;

  }
//==================== FUNCTION EndSession CLOSES EVERY OPEN ORDER; WITH PROFITABLE ONES FIRST ======================== 

bool EndSession()
  {

   int cpt,total=OrdersTotal();

   for(cpt=0;cpt<total;cpt++)
     {
      //Sleep(3000);
      OrderSelect(cpt,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderProfit() > 0) OrderClose(OrderTicket(),OrderLots(),Bid,3);
      if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderProfit() > 0) OrderClose(OrderTicket(),OrderLots(),Ask,3);

     }

   for(cpt=0;cpt<total;cpt++)
     {
      //Sleep(3000);
      OrderSelect(cpt,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==MAGIC) OrderClose(OrderTicket(),OrderLots(),Bid,3);

     }

   for(cpt=0;cpt<total;cpt++)
     {
      //Sleep(3000);
      OrderSelect(cpt,SELECT_BY_POS);
      if(OrderSymbol()==Symbol() && OrderType()>1 ) OrderDelete(OrderTicket());
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,3);
      if(OrderSymbol()==Symbol() && OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3);

     }

   return(true);
  }
//========== FUNCTION PrintStats

void PrintStats()
  {
   int y,total;

   Tally      =0;
   LOrds      =0;
   SOrds      =0;
   PendBuy    =0;
   PendSell   =0;
   TSwap      =0;

   total=OrdersTotal();

   for(y=0;y<total;y++)
     {
      OrderSelect(y,SELECT_BY_POS);
      if(OrderSymbol()==Symbol())
        {

         if(OrderType()==OP_BUY)
           {
            LOrds++;
            Tally=Tally+OrderProfit();
            TSwap=TSwap + OrderSwap();

           }
         if(OrderType()==OP_SELL)
           {
            SOrds++;
            Tally=Tally+OrderProfit();
            TSwap=TSwap + OrderSwap();

           }
         if(OrderType()==OP_SELLSTOP)
           {
            PendSell++;

           }
         if(OrderType()==OP_BUYSTOP)
           {
            PendBuy++;

           }

        }//Symbol
     }//for loop

//  Comment("Float: ",Tally," Longs: ",LOrds," Shorts: ",SOrds);

  }//void
//---

/*
      double close = iClose(Symbol(),0,bar);
      double open  = iOpen(Symbol(),0,bar);
      double high  = iHigh(Symbol(),0,bar);
      double low   = iLow(Symbol(),0,bar);
      
      double bodysize = (open-close)/myPoint;
      
      Comment(bodysize);
      
      */
//--------------------------------------------------------------- 5 --

/*
 
 bool bearish;
 bool bullish;
 
 if(bodysize < (-1*difference))bearish=true;
 else bearish=false; 
 
 if(bodysize > difference )bullish=true;
 else bullish=false; 
   
*/
///------------Condition 1, buy----------------
/* 
  if(bullish==true && tradeExited(ticket_buy))
   {
   
   /*   TakeProfit=MathAbs(bodysize)/ TakeProfitFactor;
      StopLoss=TakeProfit/ StopLossFactor;
      
       CloseAll_Buy();
      
      if(iVolume(NULL,0,0)==1)
     // ticket = OrderSend(Sym, OP_BUYSTOP, Lot, high, 0, StopLoss, TakeProfit);
       ticket_sell = OrderSend(Sym, OP_SELLSTOP, Lot, low, 0, high+pipsAbove , low-pipsBelow);
       
      
      //return(10);//buy
   
   }
*/
//----------------------------------------------------------------------------
//---------------------------------------------------------------------------

/*

//---------------- condition 1, sell --------------------------------
  if(bearish==true && tradeExited(ticket_sell) )
  {
      //TakeProfit=MathAbs(bodysize)/TakeProfitFactor;
      //StopLoss=TakeProfit/StopLossFactor;
     
      if(iVolume(NULL,0,0)==1)
     
      CloseAll_Sell();
       ticket_buy = OrderSend(Sym, OP_BUYSTOP, Lot, high, 0, low-pipsBelow, high+pipsAbove);
      //return(20);//buy
   
  }
  
  */

//====================================================================
//--------------------------------------


// }
//+------------------------------------------------------------------+

bool tradeExited(int OrderTicketNumber)
  {

   for(int trade=OrdersHistoryTotal()-1;trade>=0;trade--)
     {
      OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

      if(OrderTicket()==OrderTicketNumber)
        {
         return(true);
         break;
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAll_Sell()
  {

   int total=OrdersTotal();
   for(int i=total-1;i>=0;i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      int type=OrderType();

      bool result=false;

      switch(type)
        {
         //Close opened long positions
         // case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
         //break;

         //Close opened short positions
         case OP_SELL      : result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
         break;

         case OP_SELLSTOP  : result=OrderDelete(OrderTicket());

        }

      if(result==false)
        {
         Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
         Sleep(3000);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAll_Buy()
  {

   int total=OrdersTotal();
   for(int i=total-1;i>=0;i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      int type=OrderType();

      bool result=false;

      switch(type)
        {
         //Close opened long positions
         case OP_BUY       : result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
         break;

         //Close opened short positions
         // case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
         break;

         case OP_BUYSTOP   : result=OrderDelete(OrderTicket());

        }

      if(result==false)
        {
         Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
         Sleep(3000);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
