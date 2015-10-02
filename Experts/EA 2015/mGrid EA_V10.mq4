//+------------------------------------------------------------------+
//|                                                 mGRID EA_V10.mq4 |
//|                                                       version 10 |
//|                                                     by Murat aka |
//|                                                     date 2015/10 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Murat Aka"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//---- input parameters ---------------------------------------------+


extern double              LOTS                    =2;
extern double              UpperLimit              =0.14;  // In pips
extern double              LowerLimit              =0.08;
extern int                 LEVELS                  =300;
extern int                 RETRACEMENT             =150;
extern int                 CloseAtProfit           =4;
extern bool                EnableBolinAndWpr       =false;
extern bool                EnableFridayClose       =false;
extern int                 MAGIC                   =1803;



//|.......................................................................................|
//|......................................  Variables .....................................|
//|.......................................................................................|  

bool          key =true;
bool          GridDisabled=false;

int           EquityOnMonday;
int           EquityOnFriday;
bool          Enter=true;

int           Tally, LOrds,
              SOrds, PendBuy, PendSell;
int           Spread;
int           StopLevel;
int           ticket;
int           INCREMENT;

int           TSwap;

double        high,low,difference;

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
    
 
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)EquityOnMonday = AccountEquity();
   if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())==16)EquityOnFriday = AccountEquity();
   
   INCREMENT= (UpperLimit-LowerLimit)/Point/LEVELS;
  
  
  
   // do not work on holidays.
   if(EnableFridayClose){ 
   
     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> 16 && EquityOnMonday/EquityOnFriday<0.95){
   
       EndSession();
       return(0);
  
     }
  
     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> 10 && AccountEquity() >= AccountBalance()){
  
       EndSession();
       return(0);
  
     }
    
   }
  
  
/*
|---------------------------------------------------------------------------------------|
|---------------------------------- Begin Placing Orders -------------------------------|
|---------------------------------------------------------------------------------------|
*/
  
   int ticket, cpt, profit, total=0, BuyGoalProfit, SellGoalProfit, PipsLot;
   double ProfitTarget=INCREMENT*2, BuyGoal=0, SellGoal=0, spread=(Ask-Bid)/Point, InitialPrice=0;
//----
  
   if(INCREMENT<MarketInfo(Symbol(),MODE_STOPLEVEL)+spread) INCREMENT=1+MarketInfo(Symbol(),MODE_STOPLEVEL)+spread;

   
   if(EnableBolinAndWpr){
   
      BolingerAndWPR();  
  
      if(lastTradeTime != Time[THIS_BAR] && wpr < -80 && BolingerLowerBand <= Bid){
    
         CheckBuyGrid();

      } 
   
      if(wpr > -30 && BolingerMidBand <= Bid)CloseGrid();    
   
   }
   else{
       
       if(lastTradeTime != Time[THIS_BAR] && !GridDisabled){
    
         CheckBuyGrid();

       } 
   }   
  
   
   total = OrdersTotal();
   
   for(int i=total-1;i>=0;i--){
   
       if(OrderSelect(i, SELECT_BY_POS)==true){
 
      
         if(/*(LOrds>3 && lastTradeTime != Time[THIS_BAR] ) ||*/ (OrderType() == OP_BUY && Ask < OrderOpenPrice()-(RETRACEMENT+INCREMENT)*Point && lastTradeTime != Time[THIS_BAR])){
         
            //CloseAllPending();
            
            GridDisabled=true;
         
            double Initial = Ask;
            Print("sell_stop");
            //Print(OrderType());
        
            for(cpt=1;cpt<=4;cpt++){

               ticket = OrderSend(Symbol(), OP_SELLSTOP, LOTS*2, Initial-cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening SELLSTOP order : ",GetLastError());
               
               
               ticket = OrderSend(Symbol(), OP_BUYSTOP, LOTS*2, Initial+cpt*INCREMENT*Point, 2, 0, 0, "comment", 1000, 0);
               if(ticket>0){
                  lastTradeTime = Time[THIS_BAR];
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
               }
               else Print("Error opening BUYSTOP order : ",GetLastError());
               
            }
            break;
          }
            
            
        } 
   }
   
   PrintStats();
   
   if(AccountEquity()>AccountBalance()+CloseAtProfit + TSwap){
      
      lastTradeTime = Time[THIS_BAR]+1200;
      GridDisabled=false;
      EndSession();
      return 0;
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
            "Total Orders History: ",OrdersHistoryTotal(),Space(),            
            "Symbol: ", Symbol(),Space(),
            "Price:  ",NormalizeDouble(Bid,4),Space(),
            "Pip Spread:  ",MarketInfo("EURUSD",MODE_SPREAD),Space(),
            "Increment=" + INCREMENT,Space(),
            "Lots:  ",LOTS,Space(),
            "Levels: " + LEVELS,Space(),                                                                           
            "Float: ",Tally," Longs: ",LOrds," Shorts: ",SOrds, " SellStops: ",PendSell,Space(),
            "BuyStops: ",PendBuy," SetSwap: ",TSwap );
            
            
            
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
                       PERIOD_M5,        // timeframe
                              14,        // period
                               1         // shift
                  );
               
   
      BolingerLowerBand = iBands(
   
                                             Symbol(),        // symbol
                                            PERIOD_M5,        // timeframe
                                                   20,        // averaging period
                                                    2,        // standard deviations
                                                    0,        // bands shift
                                          PRICE_CLOSE,        // applied price
                                           MODE_LOWER,        // line index
                                                    0         // shift
                                                    
                                 );
                                 
                                 
      BolingerMidBand = iBands(
   
                                             Symbol(),        // symbol
                                            PERIOD_M5,        // timeframe
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
                                 ,0
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
      Sleep(3000);
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()>1) OrderDelete(OrderTicket());
      else if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderProfit() > 0) OrderClose(OrderTicket(),OrderLots(),Bid,3);
      else if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderProfit() > 0) OrderClose(OrderTicket(),OrderLots(),Ask,3);

      
   }
   
      for(cpt=0;cpt<total;cpt++)
   {
      Sleep(3000);
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()>1) OrderDelete(OrderTicket());
      else if(OrderSymbol()==Symbol() && OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,3);
      else if(OrderSymbol()==Symbol() && OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3);
      
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