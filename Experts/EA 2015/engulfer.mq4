//+------------------------------------------------------------------+
//|                                                     engulfer.mq4 |
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
//The lower ORDER_FREQ, the higher the order frequency

extern double              LOTS                     = 2;
extern bool                EnableDynamicLots        = true;
extern double              DynamicEquityUSD         = 1000;
extern double              DynamicEquityLots        = 0.1;
extern double              MAXLOTSIZE               = 100;

extern double              stoploss_                = 250;
extern double              increment_               = 8;

extern double              R                        = 1.5;
extern int                 sl_offset                = 30;
extern int                 ma_offset                = 200;

extern int                 MovingPeriod             = 1440;

extern int                 CloseAtProfit            = 40;

extern int                 high_look_back_bars      = 30;
extern int                 range_look_back_bars     = 10;

extern bool                EnableFridayClose        = false;
extern int                 FridayCloseTime          = 18;

extern ENUM_TIMEFRAMES     TIMEFRAME                = PERIOD_M1;
extern int                 MAGIC                    = 1803;




//|.......................................................................................|
//|......................................  Variables .....................................|
//|.......................................................................................|  

double INCREMENT      = increment_*10;

double STOPLOSS       = stoploss_*10;


int           Tally, LOrds,
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



double        UpperLimit              = 1.14;  /*// In pips*/
double        LowerLimit              = 1.08;

int           LEVELS                  = 300;

double        requiredLots            = 300*0.01;

int           TSwap;

double        high_last,low_last,high_end, low_end, difference_last;

double        open_last, close_last;


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
    
   
  // Comment(wpr+" "+BolingerLowerBand);
  initialLots = LOTS;
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
    
    
   high_last = iHigh(Symbol(),TIMEFRAME,LAST_BAR);
   low_last  = iLow(Symbol(),TIMEFRAME,LAST_BAR);
   
   high_end  = iHigh(Symbol(),TIMEFRAME,END_BAR);
   low_end   = iLow(Symbol(),TIMEFRAME,END_BAR);
   
   
   open_last   = iOpen(Symbol(),TIMEFRAME,LAST_BAR);
   close_last  = iClose(Symbol(),TIMEFRAME,LAST_BAR);
   
   difference_last = MathAbs(high_last-low_last)/Point;
   
    
   
   
   condition_1 = false;
   condition_2 = false;
   condition_3 = false;
   condition_4 = false;
   condition_5 = false;
   condition_6 = false;
   
  
   condition_1 = (high_last > high_end) && (low_last < low_end);
   condition_2 = (last_X_high_bars());
   condition_3 = (difference_X_bars());
   condition_4 = (open_last > close_last);
   condition_5 = (Bid < low_last);
   condition_6 = (Bid - ma_offset*Point > iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0));
   
   
   if(condition_1 && condition_2 /*&& condition_3*/ && condition_4 && condition_5 && condition_6 && lastTradeTime!= Time[THIS_BAR]){
     
     
     //BolingerAndWPR();
     double StopLoss = high_last + sl_offset*Point;//BolingerUpperBand;
     double TakeProfit = Ask-(R*(MathAbs(Bid-StopLoss)));
     ticket = OrderSend(Symbol(),OP_SELL,LOTS,Bid,2,StopLoss,TakeProfit,0,MAGIC,0);
     
     

     if(ticket>0){
      lastTradeTime = Time[THIS_BAR];
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Sell order opened : ",OrderOpenPrice());
     }
     else Print("Error opening Sell order : ",GetLastError());     
     
   
   }
   
   
   DynamicLots();
 
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)
   {

      exitFriday=false;
      exit = false;
      lastTradeTime = Time[THIS_BAR];
      
   }
   
   if(exit || exitFriday)return 0;
 
    
  
   if(maxLots < requiredLots){
   
      Comment("not enough money try lotsize of: ",maxLots/(LEVELS*2) );
      return 0;
   } 
   

     
      
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
  
  
/*
|---------------------------------------------------------------------------------------|
|---------------------------------- Begin Placing Orders -------------------------------|
|---------------------------------------------------------------------------------------|
*/
  
   int ticket, cpt, profit, total=0;
   double spread=(Ask-Bid)/Point, InitialPrice=0;
//----
  

   
   PrintStats();
   
                     
   if(AccountEquity()>AccountBalance()+CloseAtProfit + TSwap){
      
      lastTradeTime = Time[THIS_BAR];     
           
      while(OrdersTotal()!=0){    
         EndSession();         
      }
      
    }
   
//+------------------------------------------------------------------+   

    Comment(
            Space(),
            "mGRID EXPERT ADVISOR ver 2.0",Space(),
            "FX Acc Server:",AccountServer(),Space(),
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),Space(),
            "Minimum Lot Sizing: ",MarketInfo(Symbol(),MODE_MINLOT),Space(),
            "Account Balance:  $",AccountBalance(),Space(),
            "FreeMargin: $",AccountFreeMargin(),Space(),
            "Total Orders Open: ",OrdersTotal(),Space(),          
            "Price:  ",NormalizeDouble(Bid,4),Space(),
            "Pip Spread:  ",MarketInfo("EURUSD",MODE_SPREAD),Space(),
            "Leverage: ",AccountLeverage(),Space(),
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),Space(),
            "Increment=" + INCREMENT,Space(),
            "Lots:  ",LOTS,Space(),
            "Levels: " + LEVELS,Space(),                                                                           
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

//========== FUNCTION difference_X_bars()
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


//========== FUNCTION last_X_high_bars

bool last_X_high_bars(){

  bool con = true;
  
  
  for(int i=3; i <= high_look_back_bars; i++){
  
    double high = iHigh(Symbol(),TIMEFRAME,i);
    if(high_last < high)return false;
  
  }


  return con;
}










//========== FUNCTION version4Logic();
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


//========== FUNCTION Retracement
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



//========== FUNCTION LotCalculation

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




//========== FUNCTION Dynamic Lots

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

//========== FUNCTION DisableGrid

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


//========== FUNCTION Indicators

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

//========== FUNCTION set Grid

int CheckBuyGrid(){

       int total = OrdersTotal();

       for(int cpt=1;cpt<=LEVELS;cpt++)
       {
         bool foundbuy  = false;
                  
         for(int i=total-1;i>=0;i--){
          
          if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ){
          
            if((OrderType() == OP_BUYSTOP || OrderType() == OP_BUY) 
            && OrderOpenPrice() == NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits) 
            || OrderTakeProfit() == NormalizeDouble(LowerLimit+cpt*INCREMENT*Point+INCREMENT*Point,Digits)){
          
               foundbuy = true;
         
            }
        
          }
         }
         
         if(!foundbuy && NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits)> Ask+(INCREMENT+StopLevel)*Point){
         
              ticket=OrderSend(
              
                                 Symbol()
                                 ,OP_BUYSTOP
                                 ,LOTS
                                 ,NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits)
                                 ,2
                                 ,NormalizeDouble(Bid-STOPLOSS*Point,Digits)
                                 ,0//NormalizeDouble(LowerLimit+cpt*INCREMENT*Point+INCREMENT*Point,Digits)
                                 ,DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS))
                                 ,MAGIC
                                 ,0
                                 
                               );  
              if(ticket>0){
               lastTradeTime = Time[THIS_BAR];
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
              }
              else Print("Error opening BUYSTOP order : ",GetLastError());
          }         

       }

  return 0;
}


//========== FUNCTION Close Pending Orders

int CloseAllPending(){

int total = OrdersTotal();

for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    
    int Profit = OrderProfit();
    
    if(Profit< 0 || Profit > 0 || OrderMagicNumber() != 1000)continue;

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

//========== FUNCTION CloseAll 

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