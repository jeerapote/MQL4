//+------------------------------------------------------------------+
//|                                                     Engulfer.mq4 |
//|                                                       version  1 |
//|                                                             by X |
//|                                                     date 2015/11 |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "X"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//---- input parameters ---------------------------------------------+

extern double              LOTS                     = 2;
extern bool                EnableDynamicLots        = true;
extern double              DynamicEquityUSD         = 1000;
extern double              DynamicEquityLots        = 0.1;
extern double              MAXLOTSIZE               = 1000;

extern double              StrongTrendPips                      = 1000;
extern double              StrongTrendTPBuffer                  = 500;
extern double              compensationLowerLimitUSD            = 200;
extern double              compensationProfitUSD                = 300;
extern double              compensationMAXLOTSIZE_per_Position  = 38;
extern double              compensationUNITLOTSIZE_per_Position = 20;           

extern int                 high_look_back_bars      = 30;
extern int                 MovingPeriod             = 1440;
extern int                 ma_offset                = 200;

extern bool                EnableFridayClose        = true;
extern int                 FridayCloseTime          = 18;

extern int                 INCREMENT                = 100;
extern int                 LEVELS                   = 10 ;

extern ENUM_TIMEFRAMES     TIMEFRAME                = PERIOD_M1;
extern int                 MAGIC                    = 1803;

extern int                 BreakEvenAt              = 40;
extern int                 TakeProfit               = 40;
extern bool                enableBreakEven          = false;
extern int                 StopLoss                 = 40;
extern int                 TrailingStop             = 40;
extern bool                enableTrailingStop       = false;

extern int                 range_look_back_bars     = 0;
extern double              stoploss_                = 250;
extern double              increment_               = 8;
extern double              R                        = 1.5;
extern int                 sl_offset                = 30;
extern int                 CloseAtProfit            = 40;

//|.......................................................................................|
//|......................................  Variables .....................................|
//|.......................................................................................|  


int           Tally, LOrds,send,
              SOrds, PendBuy, PendSell;
int           Spread;
int           StopLevel;
int           ticket;

double        initialLots;
double        initialEquity;

double        maxLots=0;
double        dynamicFactor;

double        lastAskPrice;
double        lastBidPrice;

bool          exit       = false;
bool          exitFriday = false;

bool          condition_1  =false;
bool          condition_2  =false;
bool          condition_3  =false;
bool          condition_4  =false;
bool          condition_5  =false;
bool          condition_6  =false;

bool          condition_1_buy = false;
bool          condition_2_buy = false;
bool          condition_3_buy = false;
bool          condition_4_buy = false;
bool          condition_5_buy = false;
bool          condition_6_buy = false;

bool          dont_open_buys  = false;
bool          dont_open_sells = false;

double        UpperLimit              = 1.14;  /*// In pips*/
double        LowerLimit              = 1.08;

double        requiredLots            = 300*0.01;
int           TSwap;

double        high_last,low_last,high_end, low_end, difference_last;
double        open_last, close_last;

bool          trig_1 = true;
bool          trig_2 = false;

double        MA_crossPrice;

double        old_dynamic_equity_lotsize;

datetime      lastTradeTime           = 0;

#define       THIS_BAR 0
#define       LAST_BAR 1
#define       END_BAR  2

/*
|---------------------------------------------------------------------------------------|
|-----------------------------------   Initialization   --------------------------------|
|---------------------------------------------------------------------------------------| 
*/

int init()
  {
//+------------------------------------------------------------------+ 
    
  initialLots   = LOTS;
  initialEquity = AccountEquity();  
  old_dynamic_equity_lotsize = LOTS; 
        
//+------------------------------------------------------------------+
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+

int deinit()
  {
   return(0);
  }
  
  
  
  
  
/*
|---------------------------------------------------------------------------------------|
|=====================================EA Start Function=================================|
|---------------------------------------------------------------------------------------|
*/


int start(){     


 

   
//===================================== DO NOT WORK ON HOLIDAYS LOGIC==================================// 
   
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)
   {
      exitFriday=false;
      lastTradeTime = Time[THIS_BAR];
   }
   
   if(exitFriday)return 0;
    
    /*
   if(maxLots < requiredLots){   
     // Comment("not enough money try lotsize of: ",maxLots/(LEVELS*2) );
      return 0;
   } */

   // do not work on holidays.
   if(EnableFridayClose){ 
   
     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> FridayCloseTime && AccountEquity() >= AccountBalance()){
  
        while(OrdersTotal()!=0){      
         EndSession();         
        }
      
       exitFriday = true;
       return 0;
  
     }
    
   }
  


    
   high_last   = iHigh(Symbol(),TIMEFRAME,LAST_BAR);
   low_last    = iLow(Symbol(),TIMEFRAME,LAST_BAR);   
   high_end    = iHigh(Symbol(),TIMEFRAME,END_BAR);
   low_end     = iLow(Symbol(),TIMEFRAME,END_BAR);      
   open_last   = iOpen(Symbol(),TIMEFRAME,LAST_BAR);
   close_last  = iClose(Symbol(),TIMEFRAME,LAST_BAR);   
   difference_last = MathAbs(high_last-low_last)/Point;
   
          
   condition_1 = false;
   condition_2 = false;
   condition_3 = false;
   condition_4 = false;
   condition_5 = false;
   condition_6 = false;
   
   condition_1_buy = false;
   condition_2_buy = false;
   condition_3_buy = false;
   condition_4_buy = false;
   condition_5_buy = false;
   condition_6_buy = false;
     
   condition_1 = (high_last > high_end) && (low_last < low_end);
   condition_2 = (last_X_high_bars());
   condition_3 = (difference_X_bars());
   condition_4 = (open_last > close_last);
   condition_5 = (Bid < low_last);
   condition_6 = (Bid - ma_offset*Point > iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0));
      
   condition_1_buy = (high_last > high_end) && (low_last < low_end);
   condition_2_buy = (last_X_high_bars_buy());
   condition_3_buy = (difference_X_bars());
   condition_4_buy = (open_last < close_last);
   condition_5_buy = (Ask < low_last);
   condition_6_buy = (Ask + ma_offset*Point < iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0));


//===================================== STRONG TREND EXIT LOGIC==================================//   

   double ma;

//--- go trading only for first ticks of new bar
   if(Volume[0]>1){
//--- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0);
//--- get Moving Average Cross Price
   if(Open[1]>ma && Close[1]<ma)
     {
          MA_crossPrice = Bid;
     }
//--- get Moving Average Cross Price
   if(Open[1]<ma && Close[1]>ma)
     {
          MA_crossPrice = Bid;      
     }
//---
}

//--------------------------STRONG TREND (NON-MA) EARLY EXIT LOGIC------------------------------------
         
   if(Bid < MA_crossPrice-StrongTrendPips*Point && OrdersTotal()>0 && Tally-StrongTrendTPBuffer > 0){
      
     while(OrdersTotal()>0)EndSession();
      
   }
   if(Ask > MA_crossPrice+StrongTrendPips*Point && OrdersTotal()>0 && Tally-StrongTrendTPBuffer > 0){
   
     while(OrdersTotal()>0)EndSession();
   
   }

//--------------------------STRONG TREND MA TAKE PROFIT RE-CALC EXIT LOGIC-----------------------------
   
//if(OrdersTotal()<1)trig_1 =true;
   if(OrdersTotal() > 0 && lastTradeTime!= Time[THIS_BAR] && checkProfit() < compensationLowerLimitUSD && trig_1){
   
       Alert("Compensation Triggered: ", checkProfit(), "new lots: " + LotsAdded());       
       double newLots_from_MA = LotsAdded();
       
       if(newLots_from_MA > compensationMAXLOTSIZE_per_Position){
               
           send = MathCeil(newLots_from_MA/compensationUNITLOTSIZE_per_Position);
           newLots_from_MA=compensationUNITLOTSIZE_per_Position;
       }
              
      for(int i=0; i<=send; i++){ 
       
       if(checkOrderType()==OP_BUY){
         
         ticket = OrderSend(Symbol(),OP_BUY,newLots_from_MA,Ask,2,0,0,0,MAGIC,0);

         if(ticket>0){
          lastTradeTime = Time[THIS_BAR];
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Buy order opened : ",OrderOpenPrice());
         }
         else Print("Error opening Buy order : ",GetLastError()); 
           
       }
       
       if(checkOrderType()==OP_SELL){
                
         ticket = OrderSend(Symbol(),OP_SELL,newLots_from_MA,Bid,2,0,0,0,MAGIC,0);

         if(ticket>0){
          lastTradeTime = Time[THIS_BAR];
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
         }
         else Print("Error opening Sell order : ",GetLastError()); ;
           
       }
       
       trig_1 = false;
       trig_2 = true;       
             
      }
      
      send = 0;
   
   }
   
//if(OrdersTotal()<1)trig=true;
   if(OrdersTotal() > 0 && lastTradeTime!= Time[THIS_BAR] && checkProfit() < compensationLowerLimitUSD && trig_2){
   
       Alert("Compensation Triggered: ", checkProfit(), "new lots: " + LotsAdded());       
       double newLots_from_MA = LotsAdded();
       
       if(newLots_from_MA > compensationMAXLOTSIZE_per_Position){
               
           send = MathCeil(newLots_from_MA/compensationUNITLOTSIZE_per_Position);
           newLots_from_MA=compensationUNITLOTSIZE_per_Position;
       }
              
      for(int i=0; i<=send; i++){ 
       
       if(checkOrderType()==OP_BUY){
         
         ticket = OrderSend(Symbol(),OP_BUY,newLots_from_MA,Ask,2,0,0,0,MAGIC,0);

         if(ticket>0){
          lastTradeTime = Time[THIS_BAR];
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Buy order opened : ",OrderOpenPrice());
         }
         else Print("Error opening Buy order : ",GetLastError()); 
           
       }
       
       if(checkOrderType()==OP_SELL){
                
         ticket = OrderSend(Symbol(),OP_SELL,newLots_from_MA,Bid,2,0,0,0,MAGIC,0);

         if(ticket>0){
          lastTradeTime = Time[THIS_BAR];
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
         }
         else Print("Error opening Sell order : ",GetLastError()); ;
           
       }
       
       trig_2 = false;
       trig_1 = true;       
             
      }
      
      send = 0;
   
   }

//===================================== PRIMARY ENTRY CONDITIONS AND ORDER EXECUTION LOGIC==================================// 

/*
|---------------------------------------------------------------------------------------|
|---------------------------------- Begin Placing Orders -------------------------------|
|---------------------------------------------------------------------------------------|
*/
   
   if(!dont_open_sells && condition_1 && condition_2 /*&& condition_3*/ && condition_4 /*&& condition_5*/ && condition_6 && lastTradeTime!= Time[THIS_BAR]){
     
     dont_open_buys = true;
     //double StopLoss = high_last + sl_offset*Point;//BolingerUpperBand;
     //double TakeProfit = Ask-(R*(MathAbs(Bid-StopLoss)));
        
     ticket = OrderSend(Symbol(),OP_SELL,LOTS,Bid,2,0,0,0,MAGIC,0);

     if(ticket>0){
      lastTradeTime = Time[THIS_BAR];
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
     }
     else Print("Error opening Sell order : ",GetLastError()); 
   
     for(int cpt=1;cpt<=LEVELS;cpt++)
     {
      /*
         ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(Ask+cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(Ask+cpt*INCREMENT*Point+TakeProfit*Point,Digits),DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUYSTOP order : ",GetLastError());        
        */ 
         
         ticket = OrderSend(Symbol(),OP_SELLLIMIT,LOTS,NormalizeDouble(Bid+cpt*INCREMENT*Point,Digits),2,0,0,DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC+3,0);
         
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELLSTOP order : ",GetLastError());     
     }  
   /*
     ticket = OrderSend(Symbol(),OP_SELL,LOTS,Bid,2,StopLoss,TakeProfit,0,MAGIC,0);
     if(ticket>0){
      lastTradeTime = Time[THIS_BAR];
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
     }
     else Print("Error opening Sell order : ",GetLastError());     
     */   
   }
   
if(!dont_open_buys && condition_1_buy && condition_2_buy /*&& condition_3*/ && condition_4_buy /*&& condition_5*/ && condition_6_buy && lastTradeTime!= Time[THIS_BAR]){
   
   dont_open_sells = true;
   
     ticket = OrderSend(Symbol(),OP_BUY,LOTS,Ask,2,0,0,0,MAGIC,0);

     if(ticket>0){
      lastTradeTime = Time[THIS_BAR];
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Buy order opened : ",OrderOpenPrice());
     }
     else Print("Error opening Buy order : ",GetLastError()); 
   
     for(int cpt=1;cpt<=LEVELS;cpt++)
     {
      /*
         ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(Ask+cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(Ask+cpt*INCREMENT*Point+TakeProfit*Point,Digits),DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUYSTOP order : ",GetLastError());
        */ 
         
         ticket = OrderSend(Symbol(),OP_BUYLIMIT,LOTS,NormalizeDouble(Ask-cpt*INCREMENT*Point,Digits),2,0,0,DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC+3,0);
         
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELLSTOP order : ",GetLastError());
     
     }
   /*
     ticket = OrderSend(Symbol(),OP_SELL,LOTS,Bid,2,StopLoss,TakeProfit,0,MAGIC,0);
     if(ticket>0){
      lastTradeTime = Time[THIS_BAR];
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
     }
     else Print("Error opening Sell order : ",GetLastError());     
     */   
   }

//--------------------------ORDER APPENDAGES-----------------------------
      
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
   if(enableBreakEven)BreakEven();
   if(enableTrailingStop)TrailingTakeProfit();
   
   DynamicLots();


//--------------------------REGULAR MA EXIT LOGIC-----------------------------
   
   if(dont_open_buys && Bid < iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0) && AccountEquity() > AccountBalance()){
    
    while(OrdersTotal()>0){
     EndSession();   
    }    
    dont_open_buys = false;
    dont_open_sells = false;
   }
     
   if(dont_open_sells && Ask > iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0) && AccountEquity() > AccountBalance()){
    
    while(OrdersTotal()>0){
     EndSession();   
    }
    
    dont_open_buys = false;
    dont_open_sells = false;    
   }
   

  
/*
|---------------------------------------------------------------------------------------|
|---------------------------------- Other Order Scrap Details --------------------------|
|---------------------------------------------------------------------------------------|
*/
  
   int ticket, cpt, profit, total=0;
   double spread=(Ask-Bid)/Point, InitialPrice=0;
//----
   
   PrintStats();
   
       /*              
   if(AccountEquity()>AccountBalance()+CloseAtProfit + TSwap){
      
      lastTradeTime = Time[THIS_BAR];     
           
      while(OrdersTotal()!=0){    
         EndSession();         
      }      
    }
    */

//+------------------------------- STATS ON SCREEN DISPLAY AID -----------------------------------+   

    Comment(
            Space(),
            "ENGULFER_COMPENSATION EXPERT ADVISOR",Space(),
            "FX Acc Server:",AccountServer(),Space(),
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),Space(),
            "MA TradeSet Profit: ",checkProfit(),Space(),
            "MA Compensation Lots Added: ",LotsAdded(),Space(),
            "Account Balance:  $",AccountBalance(),Space(),
            "FreeMargin: $",AccountFreeMargin(),Space(),
            "Total Orders Open: ",OrdersTotal(),Space(),          
            "Lot size in the base currency=",MarketInfo(Symbol(),MODE_LOTSIZE),Space(),
            "Lots:  ",LOTS,Space(),
            "Pip Spread:  ",MarketInfo("EURUSD",MODE_SPREAD),Space(),
            "Leverage: ",AccountLeverage(),Space(),
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),Space(),                                                                        
            "Float: ",Tally," Longs: ",LOrds," Shorts: ",SOrds,Space(),
            "SellStops: ",PendSell," BuyStops: ",PendBuy," TotalSwap: ",TSwap );                                   
   return(0);
        
}


//+------------------------------------------------------------------+
//| End of start function                                            |
//+------------------------------------------------------------------+


/*
|---------------------------------------------------------------------------------------|
|----------------------------------   Custom functions   -------------------------------|
|---------------------------------------------------------------------------------------|
*/

//===================================== CHECK OrderType ==================================//


ENUM_ORDER_TYPE checkOrderType(){

      ENUM_ORDER_TYPE orderType;
       
      for(int cnt=0;cnt<OrdersTotal();cnt++){
       
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       
       if(OrderType()==OP_SELL){         
         orderType = OP_SELL;           
       }
             
       if(OrderType()==OP_BUY){         
         orderType = OP_BUY;           
       }
      } 
      
     return orderType; 
}     
      

//===================================== CHECK PROFIT ==================================//


double checkProfit(){

 double profit = 0.01;
  
      for(int cnt=0;cnt<OrdersTotal();cnt++)
      
      {
     
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY){
         
           profit += (iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0)
           -OrderOpenPrice())*OrderLots()*MarketInfo(Symbol(),MODE_LOTSIZE) ;
                    
        }
            
      }
            
      for(int cnt=0;cnt<OrdersTotal();cnt++)
      
      {
     
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_SELL){
         
           profit += (-1*(iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0)
           -OrderOpenPrice())*OrderLots()*MarketInfo(Symbol(),MODE_LOTSIZE)) ;
                    
        }
            
      }
 
 return profit;

}


//============ LOTS ADDED FUNCTION: EXTREME MEASURE TO DETERMINE LOTS TO BE ADDED TO COMPENSATE FOR MISSING TP AT MA HIT ======================//
//------------------------------------------ WE GUARANTEE PROFIT AT MA HIT WITH THIS EXTREME LOGIC -----------------------------

double LotsAdded(){

 double lotsCompensation;
 
 double profit = 1;

      for(int cnt=0;cnt<OrdersTotal();cnt++){
       
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       
       if(OrderType()==OP_SELL){         
         profit =  Bid - iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0);           
       }
             
       if(OrderType()==OP_BUY){         
         profit =  iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0) - Ask;           
       }
      } 
       
       lotsCompensation = ( (-1*Tally)+compensationProfitUSD )/(profit*MarketInfo(Symbol(),MODE_LOTSIZE));
              
 return lotsCompensation;

}


//===================================PROFIT FUNCTION FOR MA TRADE SET=============================//
//------------- WE SEE INTO THE FUTURE TO KNOW OUR POTETIAL PROFIT AT MA HIT WITH THIS LOGIC --------------------
//------ BY REVERSE ENGINEERING THE POTENTIAL PROFIT OF ALL OPEN POSITIONS IF WE WERE TO HIT MA NOW -------------

double Profit(){

 double profit = 0;
  
      for(int cnt=0;cnt<OrdersTotal();cnt++)
      {
     
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY){         
           profit += OrderProfit() ;                    
        }
            
      }
            
      for(int cnt=0;cnt<OrdersTotal();cnt++)
      {
     
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_SELL){         
           profit +=  OrderProfit();           
        }
            
      }
 
 
 return profit;

}



//===========================BREAK EVEN FUNCTION: RUN FOR ALL OPEN ORDERS=============================//
  
void BreakEven(){

double tsl;
double sl;
bool fine = true;

for(int i = 0; i < OrdersTotal(); i++) {
if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
    if( OrderType()==OP_BUY && OrderOpenPrice()+ (Spread+BreakEvenAt+StopLevel)*Point < Bid ) {
         
        tsl = OrderStopLoss();
        sl  = NormalizeDouble(OrderOpenPrice()+Point*(Spread+StopLevel),Digits); 
        
        if(tsl < sl){ Print("breakeven buy", tsl);
        fine  = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);}
    }
    
    if( OrderType()==OP_SELL && OrderOpenPrice()-(Spread+BreakEvenAt+StopLevel)*Point > Ask ) {
    
        tsl = OrderStopLoss(); 
        sl  = NormalizeDouble(OrderOpenPrice()-Point*(Spread+StopLevel),Digits); 
               
        if(tsl > sl || tsl == 0 ){ Print("breakeven sell",tsl);
        fine = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);}
    }
    
    if(!fine)
    Print("Error in BreakEven(). Error code=",GetLastError());
}

}
}


//===================================== TRAILING STOP FUNCTION: RUN FOR ALL OPEN ORDERS ==================================//

void TrailingTakeProfit(){

  int total = OrdersTotal();
 
  double tsl;

  double sl;

  bool fine=true;

  for(int i=total-1;i>=0;i--){
  
   if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
    
       if( OrderType()==OP_BUY && OrderOpenPrice()+ (TrailingStop+Spread+StopLevel)*Point < Bid ) {
                  
         tsl = OrderStopLoss()+TrailingStop*Point;
         sl  = NormalizeDouble(Bid-Point*(Spread+StopLevel+TakeProfit),Digits); 
        
         if(tsl < sl)
         fine  = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
         
       }
       else if( OrderType()==OP_SELL && OrderOpenPrice()-(TrailingStop+Spread+StopLevel)*Point > Ask) {
    
         tsl = OrderStopLoss()-TrailingStop*Point; 
         sl  = NormalizeDouble(Ask+Point*(Spread+StopLevel+TakeProfit),Digits); 
       
         if(tsl > sl || tsl < 0)
         fine = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
       }
    
       if(!fine)
       Print("Error in TrailingTakeProfit(). Error code=",GetLastError()); 
   }   
  }
    
}


//========== FUNCTION difference_X_bars() CALCULATES THE RANGE OF CURRENT BAR AND COMPARES IT WITH THE RANGES OF THE LAST X BARS ===========

bool difference_X_bars(){

   bool con = true;
   
   for(int i=3; i <= range_look_back_bars; i++){
      
      double high = iHigh(Symbol(),TIMEFRAME,i);
      double low  = iLow(Symbol(),TIMEFRAME, i);
      double dif = MathAbs(high-low)/Point;
      if(difference_last < dif)return false;
   
   }   

  return con;
}


//========== FUNCTION last_X_high_bars CALCULATES THE HIGH OF CURRENT BAR AND COMPARES IT WITH THE HIGHS OF THE LAST X BARS ===========

bool last_X_high_bars(){

  bool con = true;
    
  for(int i=3; i <= high_look_back_bars; i++){
  
    double high = iHigh(Symbol(),TIMEFRAME,i);
    if(high_last < high)return false;
  
  }

  return con;
}

bool last_X_high_bars_buy(){

  bool con = true;
    
  for(int i=3; i <= high_look_back_bars; i++){
  
    double low = iLow(Symbol(),TIMEFRAME,i);
    if(low_last < low)return false;
  
  }

  return con;
}


//========== THIS FUNCTION version4Logic()IS NOT CALLED OR EMPLOYED IN THE ENGULFER ALGO === IT IS A VESTIGEAL FUNCTION FROM 10X ALGO 

void version4Logic(){

   double InitialPrice=Ask;
   LEVELS = 1;
   for(int cpt=1;cpt<=LEVELS;cpt++)
      {
         //OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,SellGoal-spread*Point,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,BuyGoal+spread*Point,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         OrderSend(Symbol(),OP_BUY,LOTS,Ask,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
     
      }
      
}      

//========== FUNCTION Retracement IS NOT CALLED OR EMPLOYED IN THE ENGULFER ALGO === IT IS A VESTIGEAL FUNCTION FROM 10X ALGO

int Retracement(){

       double Initial = Ask;       
       lastAskPrice = Ask;
       lastBidPrice = Bid;    
       
            for(int cpt=1;cpt<=2;cpt++){

               ticket = OrderSend(Symbol(), OP_SELLSTOP, LOTS, Initial-cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening SELLSTOP order : ",GetLastError());
                              
               ticket = OrderSend(Symbol(), OP_BUYSTOP, LOTS, Initial+cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening BUYSTOP order : ",GetLastError());
               
            }
                
       return 0;
}

//========= FUNCTION LotCalculation ====== NOT CALLED

double Lot(double dLots)                         // User-defined function
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



//======== FUNCTION Dynamic Lots: USED TO DYNAMICALLY INCREASE LOTSIZE FOR NEW TRADES WITH RISE IN EQUITY =========
//------------------- WE INCREASE LOTSIZE PER X USD BY Y LOTS TILL Z MAX LOTS; X,Y,Z ARE EXTERNS -------------
//----------------------- DynamicEquityUSD; DynamicEquityLots; MAXLOTSIZE RESPECTIVELY 

int DynamicLots(){

if (EnableDynamicLots){

if(AccountBalance() > initialEquity + DynamicEquityUSD){     
     
     initialEquity=AccountBalance();
    
     if (old_dynamic_equity_lotsize <= MAXLOTSIZE){
     
     double new_dynamic_equity_lotsize = old_dynamic_equity_lotsize + DynamicEquityLots;
      
     LOTS = new_dynamic_equity_lotsize ;
     
     dynamicFactor = new_dynamic_equity_lotsize/old_dynamic_equity_lotsize; 
     
     old_dynamic_equity_lotsize = LOTS;
     
     CloseAtProfit = CloseAtProfit*dynamicFactor;}
 
 }
}

   return 0;

}

//========== FUNCTION whiteSpace

string Space(){

    return  "\n                                                                                                  "
            "                                                                                                    "
            "                                                                                                    ";


}

//========== FUNCTION DisableGrid: NOT CALLED ==========

int CloseGrid(){

int total = OrdersTotal();

for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    
    int Profit = OrderProfit();
    
    if(Profit< 0 || Profit > 0 || OrderMagicNumber() != MAGIC)continue;

    bool result = true;
    
    switch(type)
    {
     
      case OP_BUYSTOP   : result =  OrderDelete(OrderTicket());
                          break;
      
      case OP_SELLSTOP  : result =  OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close,CloseAllPending. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  return 0;
}


//========== FUNCTION Indicators: NOT CALLED =====================================

double wpr, BolingerLowerBand, BolingerMidBand, BolingerUpperBand; 

int BolingerAndWPR(){

      wpr =  iWPR(
   
                        Symbol(),        // symbol
                       TIMEFRAME,        // timeframe
                              14,        // period
                               1         // shift
                  );
               
   
      BolingerLowerBand = iBands(
   
                                             Symbol(),        // symbol
                                            TIMEFRAME,        // timeframe
                                                   20,        // averaging period
                                                   10,        // standard deviations
                                                    0,        // bands shift
                                          PRICE_CLOSE,        // applied price
                                           MODE_LOWER,        // line index
                                                    0         // shift
                                                    
                                 );
                                 
      BolingerUpperBand = iBands(
   
                                             Symbol(),        // symbol
                                            TIMEFRAME,        // timeframe
                                                   20,        // averaging period
                                                   10,        // standard deviations
                                                    0,        // bands shift
                                          PRICE_CLOSE,        // applied price
                                           MODE_UPPER,        // line index
                                                    0         // shift
                                                    
                                 );
                                 
                                 
      BolingerMidBand = iBands(
   
                                             Symbol(),        // symbol
                                            TIMEFRAME,        // timeframe
                                                   20,        // averaging period
                                                   10,        // standard deviations
                                                    0,        // bands shift
                                          PRICE_CLOSE,        // applied price
                                            MODE_MAIN,        // line index
                                                    0         // shift
                                                    
                              );  
                                  
    return 0;
                                  
}


//========== FUNCTION Close Pending Orders: CLOSES ALL PENDING ORDERS WHEN CALLED ==================


int CloseAllPending(){

int total = OrdersTotal();

for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    
    int Profit = OrderProfit();
    
    bool result = true;
    
    switch(type)
    {

      
      case OP_BUYSTOP   : result =  OrderDelete(OrderTicket());
                          break;
      
      case OP_SELLSTOP  : result =  OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close,CloseAllPending. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  return 0;
}


//==================== FUNCTION EndSession CLOSES EVERY OPEN ORDER; WITH PROFITABLE ONES FIRST ======================== 

bool EndSession()
{

   int cpt, total=OrdersTotal();
   
   
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
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() == MAGIC) OrderClose(OrderTicket(),OrderLots(),Bid,3);
    
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

void PrintStats(){
  int y, total;  
    
    Tally      =0;
    LOrds      =0;
    SOrds      =0;
    PendBuy    =0;
    PendSell   =0;
    TSwap      =0;
    
    total = OrdersTotal();  

      for(y=0;y<total;y++) {
         OrderSelect(y,SELECT_BY_POS);
            if(OrderSymbol() == Symbol()){ 
                            
                               
                               if(OrderType()==OP_BUY){
                               LOrds++;
                               Tally=Tally+OrderProfit();
                               TSwap=TSwap + OrderSwap();
                               
                               }
                               if(OrderType()==OP_SELL){
                               SOrds++;
                               Tally=Tally+OrderProfit();
                               TSwap=TSwap + OrderSwap();
                               
                               }
                               if(OrderType()==OP_SELLSTOP){
                               PendSell++;
                               
                               }
                               if(OrderType()==OP_BUYSTOP){
                               PendBuy++;
                               
                               }
                                       
            }//Symbol
       }//for loop
      
     //  Comment("Float: ",Tally," Longs: ",LOrds," Shorts: ",SOrds);

}//void