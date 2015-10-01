//+------------------------------------------------------------------+
//|                                      SugarCOG EA_V1.mq4   |
//|                                               Version 1   | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+



extern double  Lots                    = 0.5;

extern int     StopLoss                = 500;

extern int     Tolerance               = 100;

extern bool    RiskManagamentOn        = true;

extern bool    EmergencyStop           = false;




//|.......................................................................................|
//|......................................  Variables .....................................|
//|.......................................................................................|  


double         InitialBalance;    

double         Balance;      

double         InitialLots, LotsFactor;

double         Spread;


double         COG_upper_green;
double         COG_blue ;
double         COG_lower_green ;
double         COG_lower_brown; 
double         COG_upper_brown ;

int            EquityOnMonday;

int            EquityOnFriday;

int            StopLevel;

int            ticket, total;


int            MagicNumber       = 2015;


int            BarsBack          = 125;

datetime       lastTradeTime     =0;

#define        THIS_BAR 0




/*
|---------------------------------------------------------------------------------------|
|-----------------------------------   Initialization   --------------------------------|
|---------------------------------------------------------------------------------------| 
*/


int init() {
   
   InitialBalance = AccountBalance();
   
   InitialLots = Lots;
   
   if(RiskManagamentOn)InitialLots = InitialBalance/100000;
   
   Comment(MarketInfo(Symbol(), MODE_STOPLEVEL));
   
   return(0);
}

//----------------------------------------------------------------------------- 5 --


int deinit() {
   return(0);
}




/*
|---------------------------------------------------------------------------------------|
|---------------------------------------------------------------------------------------|
|---------------------------------------------------------------------------------------|
*///==================================EA Start Function================================//


int start()
  {

   COG_upper_green   = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 1, 0); 
   COG_blue          = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 0, 0);
   COG_lower_green   = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 2, 0);
   COG_lower_brown   = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 4, 0);
   COG_upper_brown   = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 3, 0);
    
    
   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   Lots = Lot(Lots);
   
   
   if(EmergencyStop){
   
      CloseAll();
      return 0;
   
   }
   
   
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   

/*
|---------------------------------------------------------------------------------------|
|---------------------------------- Begin Placing Orders -------------------------------|
|---------------------------------------------------------------------------------------|
*/



 
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
   total=OrdersTotal(); 
   
    
   if(lastTradeTime != Time[THIS_BAR])
   {
    
    CloseAllPending();
    if(CountBuySell()>0)return 0;
    
    
         ticket=OrderSend(
         
            Symbol()
            ,OP_BUYLIMIT
            ,Lots
            ,StrToDouble(DoubleToStr(COG_lower_green-Tolerance*Point, Digits))//NormalizeDouble(COG_lower_green-Tolerance*Point,Digits)
            ,2
            ,0/*NormalizeDouble(Ask-cpt*INCREMENT*Point-StopLoss*Point,Digits)*/
            ,NormalizeDouble(COG_blue,Digits)
            ,DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber
            ,0
            
         );
         
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUYSTOP order : ",GetLastError());
        
         
         
         ticket=OrderSend(
         
            Symbol()
            ,OP_SELLLIMIT
            ,Lots
            ,StrToDouble(DoubleToStr(COG_upper_green+Tolerance*Point, Digits))//NormalizeDouble(COG_upper_green+Tolerance*Point,Digits)
            ,2
            ,NormalizeDouble(COG_upper_green+StopLoss*Point,Digits)
            ,NormalizeDouble(COG_blue,Digits)
            ,DoubleToStr(Bid,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber
            ,0
         
         );
         
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELLSTOP order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELLSTOP order : ",GetLastError());
     
   }
    
     
      
   
 //----------------------------------------------------------------------------- 5 --
    
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
            "Pip Spread:  ",MarketInfo(Symbol(),MODE_SPREAD),"\n",
            "Lots:  ",Lots,"\n",
            "StopLevel: ",StopLevel,"\n",
            "Leverage: ",AccountLeverage(),"\n",
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),"\n",
            "Point: ", Digits,"\n",
            "Freezelevel: ",MarketInfo(Symbol(),MODE_FREEZELEVEL),"\n");
   
   return(0);
   
  }



//==========================================================================================//
//===================================== Emergency Stop =====================================//
//==========================================================================================//



int CloseAll(){

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    
    if(OrderMagicNumber() != MagicNumber)continue;
    bool result = true;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;
      
      case OP_BUYLIMIT   : result =  OrderDelete(OrderTicket());
                          break;
      
      case OP_SELLLIMIT  : result =  OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}

//===================================== Count Pending ==================================//

int CountBuySell(){

int count = 0;

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = true;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : count++;
                          break;
      
      //Close opened short positions
      case OP_SELL      : count++;
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , "CloseAll(), failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(count);
}

//=============================================================================================//
//===================================== Close Pending Orders ==================================//
//=============================================================================================//


int CloseAllPending(){

int total = OrdersTotal();

for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    
    int Profit = OrderProfit();
    
    if(Profit< 0 || Profit > 0)continue;

    bool result = true;
    
    switch(type)
    {

      
      case OP_BUYLIMIT   : result =  OrderDelete(OrderTicket());
                          break;
      
      case OP_SELLLIMIT  : result =  OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close,CloseAllPending. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
}
//=================================================================================//
//===================================== Lot Size ==================================//
//=================================================================================//


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