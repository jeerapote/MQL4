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
   
   datetime lastTradeTime_sell;
   datetime buySignalTime;
   datetime sellSignalTime;
   
   extern double  Tolerance = 0.0010;
   
   bool setup_complete_sell= false;
   bool order_complete_sell= false;
 
 
    double   Percent1 = 0.236;
    double   Percent2 = 0.5;
    double   Percent3 = 0.51;
    double   Percent4 = -2;
    double   Percent5 = -1;
   
    int ticket_sell;
   
    double fib0_sell;
    double fib100_sell;
    double fib236_sell;
    double fib50_sell;
    double fib51_sell;
    double fib200_sell;
    double fib_100_sell;
      
    double Lot = 0.1;
    double Price_sell ;
    double SL_sell ;
    double TP_sell ;
    
    int type_buy=0;
    int type_sell=1;
    
    
   //extern double   Percent1 =-2;
   
   
      double xazz_Sell_signal_Last;
      double xazz_Buy_signal_Last;
      double xazz_Sell_signal_Now ;
      double xazz_Buy_signal_Now ;
      
      
      
int OnInit()
  {
//---

  
 
   
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
   
   
   if(xazz_Buy_signal_Now != 2147483647  && xazz_Buy_signal_Now < xazz_Sell_signal_Last-Tolerance && !setup_complete_sell && lastTradeTime_sell != Time[THIS_BAR])
   {
   
       fib0_sell = xazz_Buy_signal_Last;
       fib100_sell = xazz_Sell_signal_Last;
       fib236_sell = NormalizeDouble(Bid+(fib100_sell-Bid)*Percent1,Digits);
       fib50_sell = NormalizeDouble(Bid+(fib100_sell-Bid)*Percent2,Digits);
       fib51_sell = NormalizeDouble(Bid+(fib100_sell-Bid)*Percent3,Digits);
       fib200_sell = NormalizeDouble(Bid+(fib100_sell-Bid)*Percent4,Digits);
       fib_100_sell =  NormalizeDouble(Bid+(fib100_sell-Bid)*Percent5,Digits);
      
       
       Lot = 0.1;
       Price_sell = fib0_sell;
       SL_sell = fib51_sell;
       TP_sell = fib_100_sell;
      
       setup_complete_sell=true;
       lastTradeTime_sell = Time[THIS_BAR];
       Print("setup ",xazz_Buy_signal_Now);
   }
   
   
  
   
   
   
   
   if(Bid > fib236_sell && !order_complete_sell && setup_complete_sell && OrdersTotal()< 1)// && lastTradeTime != Time[THIS_BAR])
    { 
      // Print(first_condition);
      Print("order ",Bid);
      ticket_sell = OrderSend(Sym, OP_SELLSTOP, Lot, Price_sell, 0, SL_sell, TP_sell);
      order_complete_sell= true;
      //setup_complete=false;
      //lastTradeTime = Time[THIS_BAR]; 
               
    }
    
    
    if(Bid > fib50_sell && !tradeExited(ticket_sell))
    {
    
      bool Ans=OrderDelete(ticket_sell);
      order_complete_sell=false;
      setup_complete_sell=false;
    
      
    }
    
    if(OrdersTotal() < 1 )
    {
     // order_complete=false;
     // setup_complete=false;  
     
    } 
    if(buySignalTime<sellSignalTime)
    {
       order_complete_sell=false;
       setup_complete_sell=false; 
       if( OrdersTotal()>=1)CloseAll(type_sell);
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


int CloseAll(int typ){

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    if(typ == type_buy)
    
    {
    
       switch(type)
       {
         //Close opened long positions
         case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                             break;
         
      
         
         case OP_BUYSTOP   : result = OrderDelete(OrderTicket());
                             
       }
    }
    
    
    if(typ==type_sell)
    {
    
         switch(type)
          {
            //Close opened short positions
            case OP_SELL       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                                break;
            
                    
            case OP_SELLSTOP   : result = OrderDelete(OrderTicket());
                                
          }
     
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}