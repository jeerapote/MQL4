//+------------------------------------------------------------------+
//|                                            Ashi_EA.mq4    |
//|                                            Version 3      | 
//|                                            Date 11/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+



extern double  Lots                    = 0.01;

extern double  TakeProfit              = 10;    // In £GBP 

extern bool    EnableFridayClose       = true;

extern int     FridayCloseTime         = 18;







//=================================Initialization=======================================//
           
bool           newbuy                  = true;  // locks

bool           newsell                 = false; 

int            MagicNumber             = 2011;          


int            BarCount;

int            Current=0;

int            times = 2;
   

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

bool           exitFriday = false;


bool             morningHours   = (Hour() >  7 && Hour() < 10),
                 afternoonHours =  Hour() > 14 && Hour() < 18,
                 tradingHours   = morningHours || afternoonHours;

int init() {

   BarCount = Bars;
 
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


   

   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)
   {
     
      exitFriday=false;
      
   }
   
   if( exitFriday)return 0;

   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   //Lots = InitialLots * LotsFactor; 
   
   //Lots = Lot(Lots);
   
   int cnt, ticket, total;
   
   
   if(EnableFridayClose){

     if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> FridayCloseTime && AccountEquity() >= AccountBalance()){
  
        while(OrdersTotal()!=0){
      
         CloseAll();
         
        }
      
       exitFriday = true;
       return 0;
  
     }
    
   }
     


//====================================Begin Placing Orders================================//

  
  
   total=OrdersTotal(); 
   
         HAOpen3  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

         HAOpen4  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose4 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);
         
         

   if( lastTradeTime != Time[THIS_BAR] /*&& tradingHours*/) 
     {
  
        
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
         
         if(AccountEquity()< AccountBalance()){
            Lots  = Lots * times;
            times *= 2;
            if(Lots > 100)Lots=100;
            
         }
         
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"LoneWolf",MagicNumber+1,0,Blue);
         if(ticket>0 )
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderType()==OP_SELL) // go to short position
            {
            // should it be closed?
                  
                //   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position

            }
      
        }
      // check for short position (SELL) possibility
      if(( HAOpen3 > HAClose3 && (newsell)) )
        {
        
        newsell = false;
        newbuy = true;
        
        
         if(AccountEquity()< AccountBalance()){
            Lots  = Lots * times;
            times *= 2;
            if(Lots > 100)Lots=100;
            
         }
        
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"LoneWolf",MagicNumber+2,0,Red);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError()); 
         
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
           
              //   OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
           }
         

        }

     
    }

  
        
     
   
   if(AccountEquity()> AccountBalance()+TakeProfit)
   {  
      while(OrdersTotal()){
         CloseAll();
         Lots = InitialLots;
         times = 2;
      }
   }
   
   Comment("                                                                            Profit: ", AccountEquity()- AccountBalance());
   //MoveStopToBreakeven();
   
   
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

//===================================== CHECK PROFIT ==================================//


//===================================== Move to Breakeven ==================================//

bool MoveStopToBreakeven() {

   bool retVal = true;
   double sl;
   double tsl;
   
 

   // select the Order
   for(int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol() == Symbol()) {       
      
         
        
         if(  OrderType() == OP_BUY && OrderProfit() >= TakeProfit ){
         
              tsl = OrderStopLoss();   
              //sl = NormalizeDouble(OrderOpenPrice() + 10*Point,Digits);
              sl = NormalizeDouble(Low[2]-10*Point,Digits);
              if(tsl != sl)
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Blue) ;
              
         }
        
        if(OrderType() == OP_SELL && OrderProfit() >= TakeProfit ) {
       
              tsl = OrderStopLoss();
              //sl = NormalizeDouble(OrderOpenPrice() - 10*Point,Digits);
              sl = NormalizeDouble(High[2]+10*Point,Digits); 
              if(tsl != sl) 
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Red) ;
               
        }
        
        
        if(!retVal)
            Print("Error in OrderModify. Error code=",GetLastError());
       /* else
            Print("Order modified successfully.");*/
        
         
      }
   }
   
   
   return(retVal);
}


int CloseAll(){

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
      if(OrderSymbol()==Symbol() && OrderType()>1 ) OrderDelete(OrderTicket());
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),Bid,3);
      if(OrderSymbol()==Symbol() && OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3);
      
   }
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