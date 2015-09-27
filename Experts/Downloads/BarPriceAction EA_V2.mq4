//+------------------------------------------------------------------+
//|                               BarPriceAction EA_V1.mq4    |
//|                                              Version 2    | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+

extern int     MagicNumber             = 2011;

extern double  Lots                    = 0.25;

extern int     TakeProfit              = 40;  // In pips

extern int     StopLoss                = 5;

extern double  TrailingStop            = 6;

extern double  DISTANCE                = 7;
           

//=================================Initialization=======================================//  


double         InitialBalance;    

double         Balance;      

double         InitialLots, LotsFactor;

double         open,close,difference;

double         Spread;

double         StopLevel;

datetime       lastTradeTime=0;

#define        THIS_BAR 0


bool             morningHours   = (Hour() >  7 && Hour() < 10),
                 afternoonHours =  Hour() > 14 && Hour() < 18,
                 tradingHours   = morningHours || afternoonHours;

int init() {

 
  
   InitialBalance = AccountBalance();
   
   InitialLots = Lots;
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


           morningHours   = TimeHour(TimeGMT()) >  1 && TimeHour(TimeGMT()) < 12;
                 afternoonHours =  TimeHour(TimeGMT()) > 14 && TimeHour(TimeGMT()) < 20;
                 tradingHours   = morningHours || afternoonHours;


   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   Lots = Lot(Lots);
   
   int cnt, ticket, total;
   

     


//====================================Begin Placing Orders================================//
 
   open  = iOpen(Symbol(),PERIOD_CURRENT,1);
   close = iClose(Symbol(),PERIOD_CURRENT,1);
   
  // difference = fabs(open-close)/Point;
  
  difference = DISTANCE;
  
 // TrailingStop = DISTANCE;
   
   //Comment(difference);
   
   Comment(MarketInfo(Symbol(), MODE_STOPLEVEL));
   
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
   if(TakeProfit < Spread)TakeProfit=Spread;
  
   total=OrdersTotal(); 
   
   
    if(lastTradeTime != Time[THIS_BAR]) CloseAll();
   
    if(total<1 && lastTradeTime != Time[THIS_BAR] /*&& difference > 0 && difference < 5*//*&& iVolume(NULL,0,0)==1*/ ){
    
         
    
         if(Bid > iOpen(Symbol(),PERIOD_CURRENT,0)+(difference*Point)){
         
          ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,NormalizeDouble(Bid-Point-StopLoss*Point,Digits),NormalizeDouble(Bid+TakeProfit*Point,Digits),"BarPriceAction",MagicNumber,0,Blue);
          if(ticket>0 )
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
          else Print("Error opening BUY order : ",GetLastError()); 
         
         
         }
   
   
   
         if(Bid < iOpen(Symbol(),PERIOD_CURRENT,0)-(difference*Point)){
         
         
          ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,NormalizeDouble(Ask+StopLoss*Point,Digits),NormalizeDouble(Ask-TakeProfit*Point,Digits),"BarPriceAction",MagicNumber+1,0,Red);
          if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
          else Print("Error opening SELL order : ",GetLastError()); 
        
         
         }
   }
   
   
 //  Trailing();
 //  BreakEven();
 
   
   return(0);
  }
  
//========================================Broker Digit Conversion=============================//

  


//===================================== CHECK PROFIT ==================================//


//===================================== Move to Breakeven ==================================//



int Trailing(){

bool fine;

int pos = OrdersTotal()-1;
if( OrderSelect(pos,SELECT_BY_POS) ) {
    if( OrderType()==OP_BUY && OrderStopLoss()+DISTANCE*Point < Bid ) {
        fine  = OrderModify(OrderTicket(),OrderOpenPrice(),Ask-Point*TrailingStop,OrderTakeProfit(),0);
    }
    else if( OrderType()==OP_SELL && OrderStopLoss()-DISTANCE*Point > Bid) {
        fine = OrderModify(OrderTicket(),OrderOpenPrice(),Bid+Point*TrailingStop,OrderTakeProfit(),0);
    }
    
    if(!fine)
    Print("Error in OrderModify. Error code=",GetLastError());
}


}


int BreakEven(){

bool fine;

int pos = OrdersTotal()-1;
if( OrderSelect(pos,SELECT_BY_POS) ) {
    if( OrderType()==OP_BUY && OrderOpenPrice()+ (Spread+25)*Point < Bid ) {
        fine  = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Point*(Spread+5),OrderTakeProfit(),0);
    }
    else if( OrderType()==OP_SELL && OrderOpenPrice()-(Spread+25)*Point > Ask) {
        fine = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Point*(Spread+5),OrderTakeProfit(),0);
    }
    
    if(!fine)
    Print("Error in OrderModify. Error code=",GetLastError());
}


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
   double Free   =AccountFreeMargin();         // Free margin
//----------------------------------------------------------------------------- 3 --
   if (dLots>0)                                 // Volume is explicitly set..
     {                                         // ..check it
      double Money=dLots*One_Lot;               // Order cost
      if(Money<=AccountFreeMargin())           // Free margin covers it..
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