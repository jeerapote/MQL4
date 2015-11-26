//+------------------------------------------------------------------+
//|                                                      bars_ea.mq4 |
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
      double myPoint = 0.00001;
      
      string Sym="EURUSD";
      
      int count = 0;
      
      //extern double StopLossFactor=8;
      //extern double TakeProfitFactor=4;
      extern double pipsAbove=0.0002;
      extern double pipsBelow=0.0002;
      extern int difference=30;
      extern double Lot=0.1;
      
      
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      ticket_buy = OrderSend(Sym, OP_BUYSTOP, Lot,Ask, 0, 0, 0);
      ticket_sell = OrderSend(Sym, OP_SELLSTOP, Lot, Bid, 0, 0 , 0);
      CloseAll_Buy();
      CloseAll_Sell();
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
      double high  = iHigh(Symbol(),0,bar);
      double low   = iLow(Symbol(),0,bar);
      
      double bodysize = (open-close)/myPoint;
      
      Comment(bodysize);
//--------------------------------------------------------------- 5 --
  
 
 

 
 bool bearish;
 bool bullish;
 
 if(bodysize < (-1*difference))bearish=true;
 else bearish=false; 
 
 if(bodysize > difference )bullish=true;
 else bullish=false; 
   

   ///------------Condition 1, buy----------------
  
  if(bullish==true && tradeExited(ticket_buy))
   {
   
   /*   TakeProfit=MathAbs(bodysize)/ TakeProfitFactor;
      StopLoss=TakeProfit/ StopLossFactor;
      */
       CloseAll_Buy();
      
      if(iVolume(NULL,0,0)==1)
     // ticket = OrderSend(Sym, OP_BUYSTOP, Lot, high, 0, StopLoss, TakeProfit);
       ticket_sell = OrderSend(Sym, OP_SELLSTOP, Lot, low, 0, high+pipsAbove , low-pipsBelow);
       
      
      //return(10);//buy
   
   }

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------



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
  
  
  
   
//====================================================================
//--------------------------------------

   
  }
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

int CloseAll_Sell(){

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
     // case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          //break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;
                 
      case OP_SELLSTOP  : result = OrderDelete(OrderTicket()); 
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}



int CloseAll_Buy(){

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
     // case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;
      
      case OP_BUYSTOP   : result = OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}
