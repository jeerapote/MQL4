//+------------------------------------------------------------------+
//|                                            LoneWolfSimple.mq4    |
//|                                            Modified from MACD    |   
//|                                            By Otis16Keith        |
//+------------------------------------------------------------------+

extern int    MagicNumber = 2011;

extern double TakeProfit              = 1000;
extern double Lots                    = 0.25;
extern int    BreakEvenAt             = 200;           
extern int    BreakEvenSlide          = 10; 

extern bool   EachTickMode            = True;
extern int    SlipPage                = 3;

extern string s4 = "== Time Filters == ";

extern string UseTradingHours = "Time Control ( 1 = True, 0 = False )";

extern int    TimeControl = 0;
extern string TimeZone = "Adjust ServerTimeZone if Required";
extern int    ServerTimeZone = 0;
extern string TradingTimes = "HourStopGMT > HourStartGMT";
extern int    HourStartGMT = 1;
extern int    HourStopGMT = 12;
extern string DontTradeFriday = "Dont Trade After FridayFinalHourGMT";
extern bool   UseFridayFinalTradeTime = False;
extern int    FridayFinalHourGMT = 11;


//=================================Initialization=======================================//
           

int digit=0;

int BarCount;

int Current;
bool TickCheck = False;

double   mPoint                     = 0.0001;

int init() {
   BarCount = Bars;

   if (EachTickMode) Current = 0; else Current = 1;
   
   mPoint = GetPoint();


   return(0);
}

int deinit() {
   return(0);
}

//===================================Broker Recognition=================================//

int checkorder=1;
double Points;


// 4 or 5 Digit Broker Account Recognition
double GetPoint()
 {
    // Automatically Adjusts to Full-Pip and Sub-Pip Accounts
    if (Digits == 4 || Digits == 2) 
     {
       SlipPage = SlipPage;
       Points = Point;
     }
  
   if (Digits == 5 || Digits == 3) 
     {     
       SlipPage = SlipPage*10;
       Points = Point*10;
     } 
     
     return Points;
 }


//=====================================Trade Session=====================================//

bool TradeSession() {
   int Hour_Start_Trade;
   int Hour_Stop_Trade;

   Hour_Start_Trade = HourStartGMT + ServerTimeZone;
   Hour_Stop_Trade = HourStopGMT + ServerTimeZone;
   if (Hour_Start_Trade < 0)Hour_Start_Trade = Hour_Start_Trade + 24;
   if (Hour_Start_Trade >= 24)Hour_Start_Trade = Hour_Start_Trade - 24;
   if (Hour_Stop_Trade > 24)Hour_Stop_Trade = Hour_Stop_Trade - 24;
   if (Hour_Stop_Trade <= 0)Hour_Stop_Trade = Hour_Stop_Trade + 24;
   if ((UseFridayFinalTradeTime && (Hour()>=FridayFinalHourGMT + ServerTimeZone) && DayOfWeek()==5)||DayOfWeek()==0)return (FALSE); // Friday Control
   if((TimeControl(Hour_Start_Trade,Hour_Stop_Trade)!=1 && TimeControl==1 && Hour_Start_Trade<Hour_Stop_Trade)
        || (TimeControl(Hour_Stop_Trade,Hour_Start_Trade)!=0 && TimeControl==1 && Hour_Start_Trade>Hour_Stop_Trade)
          ||TimeControl==0)return (TRUE); // "Trading Time";
    return (FALSE); // "Non-Trading Time";
}

//======================================Time Control=====================================//

int TimeControl(int StartHour, int EndHour)
{
   if (Hour()>=StartHour &&  Hour()< EndHour)
      { 
      return(0);
      }
return(1);
}



//====================================EA Start Function==================================//

datetime newbar;

int start()
  {

   int cnt, ticket, total;
   
      
   if(newbar==Time[0])return(0);

   else newbar=Time[0];

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
     
//========================================Variables=======================================//

double HAOpen3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 3, 10, 3, 1, 2, Current + 1);
double HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 3, 10, 3, 1, 3, Current + 1);

double HAOpen2 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 3, 10, 3, 1, 2, Current + 2); 
double HAClose2 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 3, 10, 3, 1, 3, Current + 2);

//====================================Begin Placing Orders================================//


  
   total=OrdersTotal(); 

   if(total<2) 
     {
     if(TradeSession()==True)
       {
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }
      // check for long position (BUY) possibility
      if(HAOpen2 > HAClose2 && HAOpen3<HAClose3)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*mPoint,"LoneWolf",MagicNumber,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         //return(0); 
        }
      // check for short position (SELL) possibility
      if(HAOpen2 < HAClose2 && HAOpen3>HAClose3)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*mPoint,"LoneWolf",MagicNumber,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError()); 
         //return(0); 
        }
      //return(0);
     }
    }

  
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            if (HAOpen2 < HAClose2 && HAOpen3>HAClose3)// && ArrowUp<ArrowDown && ArrowUp1>ArrowDown1)// && HAOpen1<HAClose1)
                {

                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
                 return(0); // exit
                 
                }
			   }
       
         else // go to short position
           {
            // should it be closed?
            if (HAOpen2 > HAClose2 && HAOpen3<HAClose3)// && ArrowUp>ArrowDown && ArrowUp1<ArrowDown1) //&& HAOpen1>HAClose1)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
               return(0); // exit
              }
            }
          }

   {
  
   
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if (BreakEvenAt>0)
      {
         if (OrderType()==OP_BUY)
         {
            if (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>=mPoint*BreakEvenAt)
            {
               if (OrderStopLoss()<OrderOpenPrice() + BreakEvenSlide*mPoint)
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + BreakEvenSlide*mPoint,OrderTakeProfit(),0,Green); 
            }
         }
         else if (OrderType()==OP_SELL)
         {
            if (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>=mPoint*BreakEvenAt)
            {
               if (OrderStopLoss()>OrderOpenPrice() - BreakEvenSlide*mPoint)
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - BreakEvenSlide*mPoint,OrderTakeProfit(),0,Red); 
            }
         }
      }
    }
  }
   return(0);
  }
  
//========================================Broker Digit Conversion=============================//


  
  


//==============================================================================================//

