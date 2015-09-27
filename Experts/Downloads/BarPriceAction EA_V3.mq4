//+------------------------------------------------------------------+
//|                               BarPriceAction EA_V3.mq4    |
//|                                              Version 3    | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+


extern int     TakeProfit              = 150;  // In pips


//=================================Initialization=======================================//  


double         InitialBalance;    

double         Balance;      

double         InitialLots, LotsFactor;

double         Spread;

double         point;

int            StopLevel;

int            MagicNumber = 2011;

int            LEVELS      = 1;

int            INCREMENT   = 1;

double         Lots;

datetime       lastTradeTime=0;

#define        THIS_BAR 0


int init() {

 
  
   InitialBalance = AccountBalance();
   
   InitialLots = InitialBalance/100000;
   
   Comment(MarketInfo(Symbol(), MODE_STOPLEVEL)*10000);
   

   return(0);
}

int deinit() {
   return(0);
}

//===================================Broker Recognition=================================//


//=====================================Trade Session=====================================//


//======================================Time Control=====================================//


//====================================EA Start Function==================================//



int start()
  {


   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   Lots = Lot(Lots);
   
   int cnt, ticket, total;
   
   point = Point/0.00002;
   
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   //if (StopLoss < StopLevel) StopLoss = StopLevel;
   
   if (TakeProfit < StopLevel) TakeProfit = StopLevel;
   
   if (INCREMENT < StopLevel) INCREMENT = StopLevel;
   

//====================================Begin Placing Orders================================//
 
   
   //Comment(MarketInfo(Symbol(), MODE_STOPLEVEL));
     
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
  
  
   total=OrdersTotal(); 
   
   
   
  //  if(lastTradeTime != Time[THIS_BAR]) CloseAll();
    
    
    if(total < 1 && lastTradeTime != Time[THIS_BAR])
    {
   
      
      for(int cpt=1;cpt<=LEVELS;cpt++)
      {
      
         ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(Ask+cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(Ask+cpt*INCREMENT*Point+TakeProfit*Point,Digits),DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUYSTOP order : ",GetLastError());
        
         
         
         ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,NormalizeDouble(Bid-cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(Bid-cpt*INCREMENT*Point-TakeProfit*Point,Digits),DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+3,0);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELLSTOP order : ",GetLastError());
     
      }
    }
    
    
        Comment("GRID BarPriceAction ver 3.0\n",
            "FX Acc Server:",AccountServer(),"\n",
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),"\n",
            "Minimum Lot Sizing: ",MarketInfo(Symbol(),MODE_MINLOT),"\n",
            "Account Balance:  $",AccountBalance(),"\n",
            "FreeMargin: $",AccountFreeMargin(),"\n",
            "Total Orders Open: ",OrdersTotal(),"\n",
            "Total Orders History: ",OrdersHistoryTotal(),"\n",            
            "Symbol: ", Symbol(),"\n",
            "Price:  ",NormalizeDouble(Bid,4),"\n",
            "Pip Spread:  ",MarketInfo("EURUSD",MODE_SPREAD),"\n",
            "Lots:  ",Lots,"\n",
            "StopLevel: ",StopLevel,"\n",
            "Leverage: ",AccountLeverage(),"\n",
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),"\n",
            "Point: ", Digits,"\n",
            "Freezelevel: ",MarketInfo(Symbol(),MODE_FREEZELEVEL),"\n");
   
   return(0);
   
  }
  
//========================================Broker Digit Conversion=============================//

  


//===================================== CHECK PROFIT ==================================//


//===================================== Move to Breakeven ==================================//


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
      
      case OP_BUYSTOP   : result =  OrderDelete(OrderTicket());
                          break;
      
      case OP_SELLSTOP  : result =  OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}


//===================================== Lot Size ==================================//


double Lot(double dLots)                                     // User-defined function
  {
  
 
   double Lots_New;
   string Symb   =Symbol();                    // Symbol
   double One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);//!-lot cost
   double Min_Lot=MarketInfo(Symb,MODE_MINLOT);// Min. amount of lots
   double Step   =MarketInfo(Symb,MODE_LOTSTEP);//Step in volume changing
   double Free   =AccountFreeMargin()*0.9;         // Free margin
//----------------------------------------------------------------------------- 3 --
   if (dLots>0)                                 // Volume is explicitly set..
     {                                         // ..check it
      double Money=dLots*One_Lot;               // Order cost
      if(Money<=AccountFreeMargin()*0.9)           // Free margin covers it..
         Lots_New=dLots;                        // ..accept the set one
      else                                     // If free margin is not enough..
         Lots_New=MathFloor(Free/One_Lot/Step)*Step;// Calculate lots
     }
//----------------------------------------------------------------------------- 4 --

    
//----------------------------------------------------------------------------- 5 --
   if (Lots_New < Min_Lot)                     // If it is less than allowed..
      Lots_New=Min_Lot;                        // .. then minimum
   
   return Lots_New;                               // Exit user-defined function
  }