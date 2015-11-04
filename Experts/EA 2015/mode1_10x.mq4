//+------------------------------------------------------------------+
//|                                                 mGRID EA_V10.mq4 |
//|                                                   version 10X_v6 |
//|                                                     by           |
//|                                                     date 2015/10 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "X"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/* 
1. I commented out part of Friday Loop Close Logic
2. I created MaxLotsAllowed
3. I created order_freq variable to control v4 order frequency
4. I created v4_buygridspace_factor and v4_sellgridspace_factor to control grid spacing for v4 to differ from v6 grid spacing
5. I fixed Dynamic Lots logic by adding the extern as an off-on switch for the function.
6. I created Logic to limit v4 lotsize by reseting LotsFactor once v4_SIZE is exceeded.
7. I separated buy and sell lotsfactors.

extern double              v4_order_freq           =0.5;      //The lower the order_freq, the higher the order frequency
extern double              v4_buygridspace_factor  =1;        //Creates multiples or fractions of v6 buy grid space for v4 logic
extern double              v4_sellgridspace_factor =1;        //Creates multiples or fractions of v6 sell grid space for v4 logic 
*/

//---- input parameters ---------------------------------------------+


extern bool                SLOWKILLSWITCH          =false;
extern bool                EMERGENCYSTOP_Hedge     =false;
extern bool                EMERGENCYSTOP_Close     =false;

extern double              LOTS                    =0.25;
//extern double              LotsFactor              =10;
extern double              SELLLotsFactor          =10;
extern double              BUYLotsFactor           =10;
extern double              v6_MAXLOTSIZE           =10;
extern double              v4_BUYMAXLOTSIZE        =10;
extern double              v4_SELLMAXLOTSIZE       =10; 
extern bool                EnableDynamicLots       =true;
extern bool                EnableDynamicLotsFactor =true;
extern double              DynamicEquityUSD        =1000;
extern double              DynamicEquityLots       =0.1;

extern double              STOPLOSS                =2500;
extern int                 INCREMENT               =20;
extern int                 RETRACEMENT             =200;
extern int                 RANGE                   =200;
extern int                 CloseAtProfit           =50;

extern double              v4_order_freq           =0.5;      
extern double              v4_buygridspace_factor  =1;        
extern double              v4_sellgridspace_factor =1;        

extern ENUM_TIMEFRAMES     TIMEFRAME               =PERIOD_M1;
extern bool                EnableFridayClose       =false;
extern int                 FridayCloseTime         =16;
extern int                 FridayLoopCloseTime     =18;

extern int                 MAGIC                   =1803;
extern bool                EnableRetracement       =true;
extern bool                EnableBolinAndWpr       =false;


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
    
    
   
   
   DynamicLots();
 
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)
   {
      EquityOnMonday = AccountEquity();
      exitFriday=false;
      
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
   if(EnableFridayClose){/* 
   
     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> FridayLoopCloseTime && EquityOnMonday/EquityOnFriday<0.95){
   
        while(OrdersTotal()!=0){
      
         EndSession();
         
        }
        
       exitFriday = true;
       
       return 0; 
      
     }*/
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
  
   int cpt, profit, total, ticket = 0;
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
    
         CheckBuyGrid();

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
                     
   if(retracementDisabled && lastTradeTime != Time[THIS_BAR] && (lastAskPrice > Ask+INCREMENT*v4_order_freq*Point || lastBidPrice < Bid -INCREMENT*v4_order_freq*Point))Retracement();
   
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
            "mGRID EA 10X_version 6B",Space(),
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
            //"RECTIFIED LotsFactor : ",LotsFactor,Space(),
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


int Retracement(){

       double Initial = Ask;
       
       lastAskPrice = Ask;
       lastBidPrice = Bid;
       
      if (EnableDynamicLotsFactor&&LOTS*SELLLotsFactor>v4_SELLMAXLOTSIZE){SELLLotsFactor=SELLLotsFactor/2;Print("RECTIFIED LotsFactor : ",SELLLotsFactor);}
      if (EnableDynamicLotsFactor&&LOTS*BUYLotsFactor>v4_BUYMAXLOTSIZE){BUYLotsFactor=BUYLotsFactor/2;Print("RECTIFIED LotsFactor : ",BUYLotsFactor);} 
              
            for(int cpt=1;cpt<=2;cpt++){

               ticket = OrderSend(Symbol(), OP_SELLSTOP, LOTS*SELLLotsFactor, Initial-cpt*INCREMENT*v4_sellgridspace_factor*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening SELLSTOP order : ",GetLastError());
               
               
               ticket = OrderSend(Symbol(), OP_BUYSTOP, LOTS*BUYLotsFactor, Initial+cpt*INCREMENT*v4_buygridspace_factor*Point, 2, 0, 0, "comment", 1000, 0);
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

     if (old_dynamic_equity_lotsize <= v6_MAXLOTSIZE)
     {double new_dynamic_equity_lotsize = old_dynamic_equity_lotsize + DynamicEquityLots;
      
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