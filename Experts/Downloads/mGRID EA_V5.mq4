//+------------------------------------------------------------------+
//|                                        mGRID EA_V5.mq4    |
//|                                              Version 5    | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+


extern int     TakeProfit              = 150;  // In pips

extern bool    EnableStopLoss          = false;

extern int     StopLoss                = 2000;

extern bool    RiskManagamentOn        = false; 

extern double  Lots                    = 0.5;


//=================================Initialization=======================================//  


double         InitialBalance;    

double         Balance;      

double         InitialLots, LotsFactor;

double         Spread;

int            MagicNumber = 2011;

int            LEVELS      = 1;

int            INCREMENT   = 1;

datetime       lastTradeTime=0;

#define        THIS_BAR 0


int init() {

 
  
   InitialBalance = AccountBalance();
   
   InitialLots = Lots;
   
   if(RiskManagamentOn)InitialLots = InitialBalance/100000;
   
   Comment(MarketInfo(Symbol(), MODE_STOPLEVEL));
   

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
   

//====================================Begin Placing Orders================================//
 
   
   Comment(MarketInfo(Symbol(), MODE_STOPLEVEL));
     
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
   if(TakeProfit < Spread)TakeProfit=Spread;
  
   total=OrdersTotal(); 
   
   
  //  if(lastTradeTime != Time[THIS_BAR]) CloseAll();
    
    
    if(total < 1 && lastTradeTime != Time[THIS_BAR])
    {
   
      lastTradeTime = Time[THIS_BAR];
      
      
      if(EnableStopLoss){
      
      for(int cpt=1;cpt<=LEVELS;cpt++)
      {
         OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+cpt*INCREMENT*Point,2,Ask-cpt*INCREMENT*Point-StopLoss*Point,Ask+cpt*INCREMENT*Point+TakeProfit*Point,DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);
         OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-cpt*INCREMENT*Point,2,Bid+cpt*INCREMENT*Point+StopLoss*Point,Bid-cpt*INCREMENT*Point-TakeProfit*Point,DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+3,0);
     
      }
      
      }
      
      else{
      
      for(cpt=1;cpt<=LEVELS;cpt++)
      {
         OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+cpt*INCREMENT*Point,2,0,Ask+cpt*INCREMENT*Point+TakeProfit*Point,DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);
         OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-cpt*INCREMENT*Point,2,0,Bid-cpt*INCREMENT*Point-TakeProfit*Point,DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+3,0);
     
      }
      }
      
    }
   
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