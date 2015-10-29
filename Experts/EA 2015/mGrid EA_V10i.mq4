//+------------------------------------------------------------------+
//|                                                 mGRID EA_V4x.mq4 |
//|                                                       version  1 |
//|                                                     by Murat aka |
//|                                                     date 2015/10 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Murat Aka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict



//---- input parameters ---------------------------------------------+


extern bool                SLOWKILLSWITCH          =false;
extern bool                EMERGENCYSTOP_Hedge     =false;
extern bool                EMERGENCYSTOP_Close     =false;

extern double              LOTS                    =0.2;
extern bool                EnableDynamicLots       =true;
extern double              DynamicEquityUSD        =1000;
extern double              DynamicEquityLots       =0.1;


extern double              STOPLOSS                =2500;
extern int                 INCREMENT               =80;
extern int                 RETRACEMENT             =150;
extern int                 RANGE                   =2000;
extern double              DIFFERENCE              =150;
extern int                 LotsFactor              =10; 

extern bool                EnableProfitPips        =true;
extern int                 CloseAtProfitPips       =40;
extern int                 CloseAtProfit           =40;
extern bool                EnableRetracement       =true;
extern bool                EnableBolinAndWpr       =false;
extern ENUM_TIMEFRAMES     TIMEFRAME               =PERIOD_M1;
extern bool                EnableFridayClose       =false;
extern int                 FridayCloseTime         =14;
extern int                 FridayLoopCloseTime     =18;

extern bool                UseEntryTimeFrankfurt=true;
extern bool                UseEntryTimeUS=true;
extern int                 EntryTimeFranfurt=6;
extern int                 EntryTimeUS=13;

extern int                 MAGIC                   =1803;



//|.......................................................................................|
//|......................................  Variables .....................................|
//|.......................................................................................|  

bool          key =true;
bool          GridDisabled=false;
bool          retracementDisabled = false;

int           EquityOnMonday;
int           EquityOnFriday;
bool          Enter=true;


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

bool          setup = false;
bool          exit = false;
bool          exitFriday = false;



double        UpperLimit              =1.14;  /*// In pips*/
double        LowerLimit              =1.08;

int           LEVELS                  =300;

double        requiredLots            =300*0.01;

int           TSwap;

double        high,low,difference;

double        old_dynamic_equity_lotsize;

datetime      lastTradeTime=0;

#define       THIS_BAR 0


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
    
    
   high = iHigh("EURUSD",TIMEFRAME,1);
   low  = iLow("EURUSD",TIMEFRAME,1);
   difference = MathAbs(high-low)/Point;
   
   DynamicLots();
 
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)
   {
      EquityOnMonday = AccountEquity();
      exitFriday=false;
      exit = false;
      GridDisabled=false;
      retracementDisabled = false;
      setup = false;
      lastTradeTime = Time[THIS_BAR];
      
   }
   
   if(exit || exitFriday)return 0;
   if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())==16)EquityOnFriday = AccountEquity();
   

   
   if(Bid > UpperLimit || Bid < LowerLimit){
    
      CloseGrid();
      setup = false;
   }
   
   if(!setup){
   
      UpperLimit = Bid+RANGE*Point;
      LowerLimit = Bid-RANGE*Point;
      LEVELS = (UpperLimit-LowerLimit)/Point/INCREMENT;
      requiredLots = LEVELS*LOTS;
      maxLots = Lot(requiredLots);
      setup = true;
   
   }  
  
   if(maxLots < requiredLots){
   
      Comment("not enough money try lotsize of: ",maxLots/(LEVELS*2) );
      return 0;
   } 
  
  
  
   if(EMERGENCYSTOP_Close){
   
        while(OrdersTotal()!=0){
      
         EndSession();
         
        }
        
       exit = true;
       return 0; 
      
   }
   
   
   
   if(EMERGENCYSTOP_Hedge){
   
   
    while(PendBuy > 0 || PendSell > 0){
      CloseGrid();
      CloseAllPending();
      PrintStats();
    }
    
    
    
    double newLot = SOrds*LOTS;
      int ticket=OrderSend(Symbol(),OP_BUY,newLot,Ask,3,0,0,"Hedge",16384,0,clrAqua);
      if(ticket<0)
      {
         ticket=OrderSend(Symbol(),OP_BUY,newLot,Ask,3,0,0,"Hedge",16384,0,clrAqua);
         Print("OrderSend failed with error #",GetLastError());
      }
      else
         Print("OrderSend placed successfully");
    
    newLot = LOrds*LOTS;    
      ticket=OrderSend(Symbol(),OP_SELL,newLot,Bid,3,0,0,"Hedge",16384,0,clrYellow);  
      if(ticket<0)
      {
         ticket=OrderSend(Symbol(),OP_SELL,newLot,Bid,3,0,0,"Hedge",16384,0,clrYellow);
         Print("OrderSend failed with error #",GetLastError());
      }
      else
         Print("OrderSend placed successfully");        
      
       exit = true;
       return 0; 
      
   }
   
   
   
   // do not work on holidays.
   if(EnableFridayClose){ 
   
     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> FridayLoopCloseTime && EquityOnMonday/EquityOnFriday<0.95){
   
        while(OrdersTotal()!=0){
      
         EndSession();
         
        }
        
       exitFriday = true;
       
       return 0; 
      
     }
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
  
   if(INCREMENT<MarketInfo(Symbol(),MODE_STOPLEVEL)+spread) INCREMENT=1+MarketInfo(Symbol(),MODE_STOPLEVEL)+spread;

   
   if(EnableBolinAndWpr){
   
      BolingerAndWPR();  
  
      if(lastTradeTime != Time[THIS_BAR] && wpr < -80 && BolingerLowerBand >= Bid){
    
         CheckBuyGrid();

      } 
   
      if(wpr > -30 && BolingerMidBand <= Bid)CloseGrid();    
   
   }
   else{
       
       if(lastTradeTime != Time[THIS_BAR] && !GridDisabled){
       
       total = OrdersTotal();
       if(total<1 &&  difference > DIFFERENCE && Enter && ((UseEntryTimeFrankfurt && TimeHour(TimeGMT())== EntryTimeFranfurt)  || (UseEntryTimeUS && TimeHour(TimeGMT()) == EntryTimeUS))){
    
       //CheckBuyGrid();
       version4Logic();

       } 
   } 
   
   }  
  
   if(EnableRetracement){
      total = OrdersTotal();
   
      for(int i=total-1;i>=0;i--){
   
       if(OrderSelect(i, SELECT_BY_POS)==true){
 
      
         if((!retracementDisabled && OrderType() == OP_BUY && Ask < OrderOpenPrice()-(RETRACEMENT+INCREMENT)*Point && lastTradeTime != Time[THIS_BAR])){
         
         
         
            CloseGrid();
            CloseAllPending();
            
            GridDisabled=true;
            
         
            
            Print("sell_stop");
            
            
               
            retracementDisabled = true;
            //Print(OrderType());
        

            
            
            break;
          }
            
         }   
        } 
   }
   
   
   PrintStats();
                     
   if(retracementDisabled && lastTradeTime != Time[THIS_BAR] && (lastAskPrice > Ask+INCREMENT/2*Point || lastBidPrice < Bid -INCREMENT/2*Point))Retracement();
   
   if(AccountEquity()>AccountBalance()+CloseAtProfit + TSwap){
      
      retracementDisabled = true;
      lastTradeTime = Time[THIS_BAR];
      
      
      while(OrdersTotal()!=0){
      
         EndSession();
         
      }
      
      if(SLOWKILLSWITCH)exit=true;
      
      /*
      int x=1;
      for(int i= 0 ; i < x; i++){
      
        if(OrdersTotal()!=0){
        
         EndSession();
         x++;
         
        }
      }*/
      
      GridDisabled = false;
      retracementDisabled = false;
      
     
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

               ticket = OrderSend(Symbol(), OP_SELLSTOP, LOTS*LotsFactor, Initial-cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening SELLSTOP order : ",GetLastError());
               
               
               ticket = OrderSend(Symbol(), OP_BUYSTOP, LOTS*LotsFactor, Initial+cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
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


 if(AccountBalance() > initialEquity + DynamicEquityUSD){
     
     
     initialEquity=AccountBalance();
    
     double new_dynamic_equity_lotsize = old_dynamic_equity_lotsize + DynamicEquityLots;
      
     LOTS = new_dynamic_equity_lotsize ;
     
     dynamicFactor = new_dynamic_equity_lotsize/old_dynamic_equity_lotsize; 
     
     old_dynamic_equity_lotsize = LOTS;
     
     CloseAtProfit = CloseAtProfit*dynamicFactor;
 
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

double wpr, BolingerLowerBand, BolingerMidBand; 

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
                                                    2,        // standard deviations
                                                    0,        // bands shift
                                          PRICE_CLOSE,        // applied price
                                           MODE_LOWER,        // line index
                                                    0         // shift
                                                    
                                 );
                                 
                                 
      BolingerMidBand = iBands(
   
                                             Symbol(),        // symbol
                                            TIMEFRAME,        // timeframe
                                                   20,        // averaging period
                                                    2,        // standard deviations
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