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

 
 
   string Sym="EURUSD";

   #define THIS_BAR 0


   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   datetime lastTradeTime;
   datetime buySignalTime;
   datetime sellSignalTime;
   
   extern double  Tolerance = 0.0010;
   
   bool setup_complete= false;
   bool order_complete= false;
 
 
    double   Percent1 = 0.236;
    double   Percent2 = 0.5;
    double   Percent3 = 0.51;
    double   Percent4 = -2;
    double   Percent5 = -1;
   
    int ticket;
   
    double fib0;
    double fib100;
    double fib236;
    double fib50;
    double fib51;
    double fib200;
    double fib_100;
      
    double Lot = 0.1;
    double Price ;
    double SL ;
    double TP ;
    
    
   //extern double   Percent1 =-2;
   
   
      double xazz_Sell_signal_Last;
      double xazz_Buy_signal_Last;
      double xazz_Sell_signal_Now ;
      double xazz_Buy_signal_Now ;
      
      
      
int OnInit()
  {
//---

  
 ticket = OrderSend(Sym, OP_SELLSTOP, Lot, Price, 0, SL, TP);
 CloseAll();
   
/*   if(xazz_Buy_signal_Last < xazz_Sell_signal_Last-Tolerance)
   {
      ticket = OrderSend(Sym, OP_SELLSTOP, Lot, Price, 0, SL, TP);
      bool Ans=OrderDelete(ticket);
   }
   */
  // Comment(xazz_test);
   
   //2147483647
   
   
   
 
 
 
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

   xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 1); //
   xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 1); //

   if(xazz_Buy_signal_Now != 2147483647)
   {
      xazz_Buy_signal_Last= xazz_Buy_signal_Now; 
      buySignalTime=Time[THIS_BAR];
      //Print("works");
   }
 
  
   if(xazz_Sell_signal_Now != 2147483647)
   {
      xazz_Sell_signal_Last = xazz_Sell_signal_Now;
      sellSignalTime=Time[THIS_BAR];
   } 
   
   
   if(xazz_Sell_signal_Now != 2147483647  && xazz_Sell_signal_Now > xazz_Buy_signal_Last+Tolerance && !setup_complete && lastTradeTime != Time[THIS_BAR])
   {
   
       fib0 = xazz_Sell_signal_Last;
       fib100 = xazz_Buy_signal_Last;
       fib236 = NormalizeDouble(fib0-(fib0-fib100)*Percent1,Digits);
       fib50 = NormalizeDouble(fib0-(fib0-fib100)*Percent2,Digits);
       fib51 = NormalizeDouble(fib0-(fib0-fib100)*Percent3,Digits);
       fib200 = NormalizeDouble(fib0-(fib0-fib100)*Percent4,Digits);
       fib_100 =  NormalizeDouble(fib0-(fib0-fib100)*Percent5,Digits);
      
       
       Lot = 0.1;
       Price = fib0;
       SL = fib51;
       TP = fib_100;
      
       setup_complete=true;
       lastTradeTime = Time[THIS_BAR];
       Print("setup ",xazz_Sell_signal_Now);
   }
   
   
  
   
   
   
   
   if(Bid < fib236 && !order_complete && setup_complete && OrdersTotal()< 1)// && lastTradeTime != Time[THIS_BAR])
    { 
      // Print(first_condition);
      Print("order ",Bid);
      trade();
      order_complete= true;
      //setup_complete=false;
      //lastTradeTime = Time[THIS_BAR]; 
               
    }
    
    
    if(Bid < fib50 && !tradeExited(ticket))
    {
    
      bool Ans=OrderDelete(ticket);
      order_complete=false;
      setup_complete=false;
    
      
    }
    
    if(OrdersTotal() < 1 )
    {
     // order_complete=false;
     // setup_complete=false;  
     
    } 
    if(buySignalTime>sellSignalTime)
    {
       order_complete=false;
       setup_complete=false; 
       if( OrdersTotal()>=1)CloseAll();
    }



//---
   
   
  }
//+------------------------------------------------------------------+


bool tradeExited(int OrderTicketNumber)
{


for(int trade=OrdersTotal()-1;trade>=0;trade--)
{
 if(OrderSelect(trade, SELECT_BY_POS)==true)
 {
 if(OrderTicket()==OrderTicketNumber)
 {
  return(false);
  break;
 }
 }
}
return(true);
}

int trade()
{

    
    if(didProfit() ) ticket = OrderSend(Sym, OP_BUYSTOP, Lot, Price, 0, SL, TP);
    
    if(!didProfit() )
    {
      ticket = OrderSend(Sym, OP_SELLSTOP, Lot, Bid, 0, TP, SL);
    }
    
    return(0);

}

bool didProfit()
{

  int trade=OrdersHistoryTotal()-1;
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  
  if(OrderType()==OP_BUY && OrderProfit()>= 0)return(true);
  else if(OrderType()==OP_SELL && OrderProfit() < 0 ) return(true);
  else return(false);
  
}



int CloseAll(){

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
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
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