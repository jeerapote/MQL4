//+------------------------------------------------------------------+
//|                                            Ashi_EA.mq4    |
//|                                            Version 3      | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+

extern int     MagicNumber             = 2011;

extern double  Lots                    = 0.25;

extern int     BreakEvenAt             = 100 ; //in points.

extern int     TakeProfit              = 120; // in points, 100 points = 10 pips;

extern int     StopLoss                = 100; // in points;

extern int     TrailingStop            = 70;   // in points;

//extern int     LossMargin              = 30;
           
//bool           EachTickMode            = True;

extern double  MultiLotsMultiple       = 2;

extern double  MultiLotStart           = 100;    // In £GBP 







//=================================Initialization=======================================//
           
bool           newbuy                  = true;  // locks
bool           newsell                 = false;           


int            BarCount;

int            Current=0;
   

double         mPoint                  = 0.0001;

int            ticket2;


double         InitialBalance;    
double         Balance;      
double         LotsFactor;
double         InitialLots;
double         Multilot;

datetime       lastTradeTime;

#define        THIS_BAR 0


double         HAOpen3;
double         HAClose3;

double         HAOpen4;
double         HAClose4;

int            Spread,StopLevel;


bool             morningHours   = (Hour() >  7 && Hour() < 10),
                 afternoonHours =  Hour() > 14 && Hour() < 18,
                 tradingHours   = morningHours || afternoonHours;

int init() {

   BarCount = Bars;

 //  if (EachTickMode) Current = 0; //else Current = -1;
   
   mPoint = Point*10;
   
   InitialBalance = AccountBalance();
   
   InitialLots = Lots;
   

   return(0);
}

int deinit() {
   return(0);
}

//===================================Broker Recognition=================================//


//=====================================Trade Session=====================================//


//======================================Time Control=====================================//


//====================================EA Start Function==================================//

datetime newbar;

int start()
  {


           morningHours   = TimeHour(TimeGMT()) >  1 && TimeHour(TimeGMT()) < 12;
                 afternoonHours =  TimeHour(TimeGMT()) > 14 && TimeHour(TimeGMT()) < 20;
                 tradingHours   = morningHours || afternoonHours;

   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   StopLevel =MarketInfo(Symbol(), MODE_STOPLEVEL);



   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   Lots = Lot(Lots);
   
   int cnt, ticket, total;
     

     


//====================================Begin Placing Orders================================//

  
  
   total=OrdersTotal(); 
   
         HAOpen3  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

         HAOpen4  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose4 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);
         
         

   if(total<1 && lastTradeTime != Time[THIS_BAR] /*&& tradingHours*/) 
     {
  
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }
        
        //========================================Variables=======================================//

         HAOpen3  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

         HAOpen4  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose4 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);
         
      // check for long position (BUY) possibility
      if(( HAOpen3 < HAClose3 )&& (newbuy)  )
        {
        
         newbuy=false;
         newsell=true;
         
         //ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-(StopLoss*mPoint/10),Ask+TakeProfit*mPoint/10,"LoneWolf",MagicNumber+1,0,Blue);
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"achi",MagicNumber+1,0,Blue);
         if(ticket>0 )
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         
         /*
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderType()==OP_SELL) // go to short position
            {
            // should it be closed?
                  
                   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position

            }
            */
      
        }
      // check for short position (SELL) possibility
      if(( HAOpen3 > HAClose3 && (newsell)) )
        {
        
         newsell = false;
         newbuy = true;
        
        // ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+(StopLoss*mPoint/10),Bid-TakeProfit*mPoint/10,"LoneWolf",MagicNumber+2,0,Red);
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"achi",MagicNumber+2,0,Red);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError()); 
         
         /*
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
           
                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
           }
         */

        }

     
    }

  
   for(cnt=0;cnt<total;cnt++)
     {
     
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
 
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            if (HAOpen4 > HAClose4)
                {

                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
                 //return(0); // exit
                 
                }
			  }
       
         if(OrderType()==OP_SELL) // go to short position
           {
            // should it be closed?
              if (HAOpen4 < HAClose4)//
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
             
              }
           }
            
     }
   
  
   BreakEven();
   CheckProfit();
   Multilot();
   TrailingTakeProfit();
   
   
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
            "StopLevel: ",MarketInfo(Symbol(), MODE_STOPLEVEL),"\n",
            "Leverage: ",AccountLeverage(),"\n",
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),"\n",
            "Point: ", Digits,"\n",
            "Freezelevel: ",MarketInfo(Symbol(),MODE_FREEZELEVEL),"\n");
   
   
   return(0);
  }
  
//========================================Broker Digit Conversion=============================//

  
double GetPoint(string symbol = "") //5 digit broker conversion ---  Copyright "Coders Guru" 
{
   if(symbol=="" || symbol == Symbol())
   {
      if(Point==0.00001) return(0.0001);
      else if(Point==0.001) return(0.01);
      else return(Point);
   }
   else
   {
      RefreshRates();
      double tPoint = MarketInfo(symbol,MODE_POINT);
      if(tPoint==0.00001) return(0.0001);
      else if(tPoint==0.001) return(0.01);
      else return(tPoint);
   }
}

//===================================== Trailing Take Profit ==================================//
int TrailingTakeProfit(){

  int total = OrdersTotal();
 
  double tsl;

  double sl;

  bool fine=true;

  for(int i=total-1;i>=0;i--){
  
   if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
    
       if( OrderType()==OP_BUY && OrderOpenPrice()+ (TakeProfit+TrailingStop+Spread+StopLevel)*Point < Bid ) {
         
         
         tsl = OrderStopLoss()+TrailingStop*Point;
         sl  = NormalizeDouble(Bid-Point*(Spread+StopLevel+TakeProfit),Digits); 
        
         if(tsl < sl)
         fine  = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
         
       }
       else if( OrderType()==OP_SELL && OrderOpenPrice()-(TakeProfit+TrailingStop+Spread+StopLevel)*Point > Ask) {
    
         tsl = OrderStopLoss()-TrailingStop*Point; 
         sl  = NormalizeDouble(Ask+Point*(Spread+StopLevel+TakeProfit),Digits); 
       
         if(tsl > sl)
         fine = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
       }
    
       if(!fine)
       Print("Error in TrailingTakeProfit(). Error code=",GetLastError()); 
   }   
  }
  
  
  return(0);
}



//===================================== CHECK PROFIT ==================================//
int CheckProfit(){

for(int i = 0; i < OrdersTotal(); i++) {
  
   if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
      
      int type   = OrderType();

      bool result = true;
    
      switch(type)
      {
         //Close opened long positions
         
         case OP_BUY       : if(Bid<OrderOpenPrice()-(Spread+StopLevel+StopLoss)*Point){
                             result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                             }
                             break;
      
         //Close opened short positions
         case OP_SELL      : if(Ask>OrderOpenPrice()+(Spread+StopLevel+StopLoss)*Point){
                             result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                             }
                          
      }
    
      if(result == false)
      {
       Alert("Order " , OrderTicket() , "CheckProfit(), failed to close. Error:" , GetLastError() );
       Sleep(3000);
      }  
       
   }
  }
  
  return(0);
}




//===================================== Move to Breakeven ==================================//


int BreakEven(){

double tsl;

double sl;

bool fine=true;

for(int i = 0; i < OrdersTotal(); i++) {
if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
    if( OrderType()==OP_BUY && OrderOpenPrice()+ (Spread+BreakEvenAt+StopLevel)*Point < Bid && OrderStopLoss() < OrderOpenPrice()+(TakeProfit+Spread+StopLevel)*Point) {
         
        tsl = OrderStopLoss();
        sl  = NormalizeDouble(OrderOpenPrice()+Point*(Spread+StopLevel),Digits); 
        
        if(tsl < sl)
        fine  = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
    }
    else if( OrderType()==OP_SELL && OrderOpenPrice()-(Spread+BreakEvenAt+StopLevel)*Point > Ask && OrderStopLoss() > OrderOpenPrice()-(TakeProfit+Spread+StopLevel)*Point) {
    
        tsl = OrderStopLoss(); 
        sl  = NormalizeDouble(OrderOpenPrice()-Point*(Spread+StopLevel),Digits); 
        
        if(tsl > sl)
        fine = OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0);
    }
    
    if(!fine)
    Print("Error in BreakEven(). Error code=",GetLastError());
}

}
}


//========================================MultiLot=============================//
int Multilot()
{

   if(OrdersTotal() < 2 /*&& tradingHours*/)
   {

       int pos = OrdersTotal()-1;
   
         if(OrderSelect(pos, SELECT_BY_POS)==true)
         {
      
            if(OrderProfit()< StopLoss*-1 )CloseAll();
            if(OrderProfit()>=MultiLotStart )
            {

              int order_type = OrderType();     
       
              if(order_type==OP_BUY)
               {
              
                  if(iVolume(NULL,0,0)==1);
                  
                  
                  Multilot = MultiLotsMultiple*Lots;
                  Multilot = Lot(Multilot);
                 
                  
                 // ticket2 = OrderSend(Symbol(), OP_BUY, Multilot, Ask , 0, Ask-MultiLotStopLoss*Point, 0);
                  ticket2 = OrderSend(Symbol(), OP_BUY, Multilot, Ask , 0, 0, 0);
                  if(ticket2>0)
                   {
                      lastTradeTime = Time[THIS_BAR];
                      if(OrderSelect(ticket2,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
                   }
                  else Print("Multilot(), Error opening BUY order : ",GetLastError());
               }
               
              else 
               {
                  if(iVolume(NULL,0,0)==1);                        
                  Multilot = MultiLotsMultiple*Lots;
                  Multilot = Lot(Multilot);
                  
                 // ticket2 = OrderSend(Symbol(), OP_SELL, Multilot, Bid, 0, Bid+MultiLotStopLoss*Point, 0);
                  ticket2 = OrderSend(Symbol(), OP_SELL, Multilot, Bid , 0, 0, 0);
                  if(ticket2>0)
                  {
                     lastTradeTime = Time[THIS_BAR];
                     if(OrderSelect(ticket2,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
                  }
                  else Print("MultiLot(), Error opening SELL order : ",GetLastError());
                  
               }
         
            }
            
        }
   } 
    
    return(0);
}  

//========================================Close All=============================//
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
      Alert("Order " , OrderTicket() , "CloseAll(), failed to close. Error:" , GetLastError() );
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