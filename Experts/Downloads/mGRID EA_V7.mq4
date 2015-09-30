//+------------------------------------------------------------------+
//|                                    SugarGRID EA_V1.mq4    |
//|                                              Version 1    | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+



extern double     UpperLimit              =0.15;  // In pips
extern double     LowerLimit              =0.06;

 
int               LEVELS;
int               INCREMENT;
int               ticket;
int               Spread;
int               StopLevel;
double            Lots=0.02;


int               MagicNumber = 2011;

datetime          lastTradeTime=0;

#define           THIS_BAR 0




int init() {
   

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


    LEVELS         = AccountBalance();
    INCREMENT      = (UpperLimit-LowerLimit)/Point/LEVELS;
    
    StopLevel      = MarketInfo(Symbol(), MODE_STOPLEVEL);
    Spread         = MarketInfo(Symbol(),MODE_SPREAD);
    
    if (INCREMENT < StopLevel+Spread) INCREMENT = StopLevel+Spread;
    
    
    if(lastTradeTime != Time[THIS_BAR])
    {
    
        CheckBuyGrid();

    }
     
     
      Comment("GRID BarPriceAction ver 3.0\n",
            "FX Acc Server:",AccountServer(),"\n",
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),"\n",
            "Minimum Lot Sizing: ",MarketInfo(Symbol(),MODE_MINLOT),"\n",
            "FreeMargin: $",AccountFreeMargin(),"\n",
            "Total Orders Open: ",OrdersTotal(),"\n",
            "Total Orders History: ",OrdersHistoryTotal(),"\n",            
            "Symbol: ", Symbol(),"\n",
            "Price:  ",NormalizeDouble(Bid,4),"\n",
            "Pip Spread:  ",MarketInfo(Symbol(),MODE_SPREAD),"\n",
            "Lots:  ",Lots,"\n",
            "StopLevel: ",StopLevel,"\n",
            "LEVELS:  ",LEVELS,"\n",
            "INCREMENT: ",INCREMENT,"\n",
            "Leverage: ",AccountLeverage(),"\n",
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),"\n",
            "Point: ", Digits,"\n",
            "MaxLots: ",Lot(10000),"\n");
    
    
  }

//===================================== CloseAllPending ==================================//
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
  
  
//===================================== CloseAllPending ==================================//

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
  
}

//===================================== CloseAllPending ==================================//

int BuyGrid(){


       for(int cpt=1;cpt<=LEVELS;cpt++)
       {
       
         CloseAllPending();
         if(NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits)> Ask+(INCREMENT+StopLevel)*Point){
         
           ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(LowerLimit+cpt*INCREMENT*Point+INCREMENT*Point,Digits),DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);  
           if(ticket>0)
             {
               lastTradeTime = Time[THIS_BAR];
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
             }
           else Print("Error opening BUYSTOP order : ",GetLastError());
         }
         
        }
}


//===================================== CloseAllPending ==================================//

int CheckBuyGrid(){

       int total = OrdersTotal();

       for(int cpt=1;cpt<=LEVELS;cpt++)
       {
         bool found = false;
         for(int i=total-1;i>=0;i--){
          
          if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ){
          
            if(OrderOpenPrice() == NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits)){
          
               found = true;
         
            }
        
          }
         }
         
         if(!found && NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits)> Ask+(INCREMENT+StopLevel)*Point){
         
              ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(LowerLimit+cpt*INCREMENT*Point,Digits),2,0,NormalizeDouble(LowerLimit+cpt*INCREMENT*Point+INCREMENT*Point,Digits),DoubleToStr(Ask,MarketInfo(Symbol(),MODE_DIGITS)),MagicNumber+2,0);  
              if(ticket>0){
               lastTradeTime = Time[THIS_BAR];
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUYSTOP order opened : ",OrderOpenPrice());
              }
              else Print("Error opening BUYSTOP order : ",GetLastError());
         }
        }

  return 0;
}
        
        