//+------------------------------------------------------------------+
//|                                            Ashi_EA.mq4    |
//|                                            Version 2      | 
//|                                            Date 09/2015   |
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+

extern int     MagicNumber             = 2011;

extern double  Lots                    = 0.25;

extern double  MultiLotsMultiple       = 2;

extern int     TakeProfit              = 10000;  // In pips
extern int     StopLoss                = 10000;
           
bool           EachTickMode            = True;

extern int     BreakEvenProfit         = 100;    // In £GBP 

extern int     MultiLotBreakEvenRatio  = 3;      // BreakEvenProfit/MultilotBreakEvenRatio = BreakEvenProfit  for Multilots;

extern int     MultiLotStopLoss        = 40;     // In pips



//=================================Initialization=======================================//
           
bool           newbuy                  = true;  // locks
bool           newsell                 = false;           


int            BarCount;

int            Current;
   

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

int init() {

   BarCount = Bars;

   if (EachTickMode) Current = 0; //else Current = -1;
   
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

   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   int cnt, ticket, total;
   
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);  
     }
     
   if(TakeProfit<4)
     {
      Print("TakeProfit less than 4");
      return(0); 
     }
     


//====================================Begin Placing Orders================================//

   newbar = 
  
   total=OrdersTotal(); 
   
         HAOpen3  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

         HAOpen4  = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
         HAClose4 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

   if(total<1 && lastTradeTime != Time[THIS_BAR]) 
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
         
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-(StopLoss*mPoint/10),Ask+TakeProfit*mPoint/10,"LoneWolf",MagicNumber+1,0,Blue);
         if(ticket>0)
           {
            lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderType()==OP_SELL) // go to short position
            {
            // should it be closed?
                  
                   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position

            }
      
        }
      // check for short position (SELL) possibility
      if(( HAOpen3 > HAClose3 && (newsell)) )
        {
        
        newsell = false;
        newbuy = true;
        
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+(StopLoss*mPoint/10),Bid-TakeProfit*mPoint/10,"LoneWolf",MagicNumber+2,0,Red);
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
           
                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
           }
         

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
   
   checkProfit();
   MoveStopToBreakeven();
   
   
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

int checkProfit()
{

   if(OrdersTotal() < 2 )
   {

       int pos = OrdersTotal()-1;
   
         if(OrderSelect(pos, SELECT_BY_POS)==true)
         {
      
            if(OrderProfit()>=BreakEvenProfit )
            {

              int order_type = OrderType();     
       
              if(order_type==OP_BUY)
               {
              
                  if(iVolume(NULL,0,0)==1);
                  
                  
                  Multilot = MultiLotsMultiple*Lots;
                  Multilot = Lot(Multilot);
                  ticket2 = OrderSend(Symbol(), OP_BUY, Multilot, Ask , 0, Ask-MultiLotStopLoss*Point, 0);
               }
               
              else 
               {
                  if(iVolume(NULL,0,0)==1);                        
                  Multilot = MultiLotsMultiple*Lots;
                  Multilot = Lot(Multilot);
                  ticket2 = OrderSend(Symbol(), OP_SELL, Multilot, Bid, 0, Bid+MultiLotStopLoss*Point, 0);
                  
               }
         
            }
            
        }
    } 
    
    return(0);
}  

//===================================== Move to Breakeven ==================================//

bool MoveStopToBreakeven() {

   bool retVal = true;
   double sl;
   double tsl;
   
 

   // select the Order
   for(int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol() == Symbol()) {       
      
      
         if( OrderType() == OP_BUY  && OrderLots() == Multilot && OrderProfit() >= BreakEvenProfit/MultiLotBreakEvenRatio ){
         
              tsl = OrderStopLoss();   
              sl = NormalizeDouble(OrderOpenPrice() + 10*Point,Digits);
              
              if(tsl != sl)
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Blue) ;
              
         }  
         
         if( OrderType() == OP_SELL && OrderLots() == Multilot && OrderProfit() >= BreakEvenProfit/MultiLotBreakEvenRatio ) {
       
              tsl = OrderStopLoss();
              sl = NormalizeDouble(OrderOpenPrice() - 10*Point,Digits);
               
              if(tsl != sl) 
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Red) ;
               
         }
         
        
         if(  OrderType() == OP_BUY && OrderProfit() >= BreakEvenProfit ){
         
              tsl = OrderStopLoss();   
              sl = NormalizeDouble(OrderOpenPrice() + 10*Point,Digits);
              
              if(tsl != sl)
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Blue) ;
              
         }
        
        if(OrderType() == OP_SELL && OrderProfit() >= BreakEvenProfit ) {
       
              tsl = OrderStopLoss();
              sl = NormalizeDouble(OrderOpenPrice() - 10*Point,Digits);
               
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