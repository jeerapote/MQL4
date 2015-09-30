//+------------------------------------------------------------------+
//|                                                  mGRID EA_V3.mq4 |
//|                                                        version 3 |
//|                                                     by Murat aka.|
//|                                                   date 2015/09   |
//|                                                                  |
//+------------------------------------------------------------------+

//---- input parameters ---------------------------------------------+

extern int              INCREMENT=10;
extern int              RETRACEMENT=5;
extern ENUM_TIMEFRAMES  TIMEFRAME=PERIOD_M5;
extern double           DIFFERENCE = 150;
extern double           LOTS=0.01;
extern int              LEVELS=100; 
extern int              CloseAtProfit=4;
extern bool             EnableFridayClose=false;
extern double           MAX_LOTS=99;
extern int              MAGIC=1803;
extern bool             CONTINUE=true;



bool key =true;


//+------------------------------------------------------------------+

bool      UseProfitTarget=false;
bool      UsePartialProfitTarget=false;
int       Target_Increment = 50;
int       First_Target = 20;
bool      UseEntryTime=false;
int       EntryTime=0;
int       EquityOnMonday;
int       EquityOnFriday;



int Tally, LOrds, SOrds, PendBuy, PendSell;

double high,low,difference;

//+------------------------------------------------------------------+

bool Enter=true;
int nextTP;

int init()
  {
//+------------------------------------------------------------------+ 
   nextTP = First_Target;
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
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
  
  high = iHigh("EURUSD",TIMEFRAME,1);
  low  = iLow("EURUSD",TIMEFRAME,1);
  difference = MathAbs(high-low)/Point;
  
  
 
   if(DayOfWeek()==MONDAY && TimeHour(TimeGMT())==1)EquityOnMonday = AccountEquity();
   if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())==16)EquityOnFriday = AccountEquity();
  
   if(EnableFridayClose){
   
    if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> 16 && EquityOnMonday/EquityOnFriday<0.95){
   
     EndSession();
     return(0);
  
    }
  
    // do not work on holidays.
    if(DayOfWeek()==FRIDAY && TimeHour(TimeGMT())> 10 && AccountEquity() >= AccountBalance()){
  
     EndSession();
     return(0);
  
    }
    
   }
  
  
  
  
   int ticket, cpt, profit, total=0, BuyGoalProfit, SellGoalProfit, PipsLot;
   double ProfitTarget=INCREMENT*2, BuyGoal=0, SellGoal=0, spread=(Ask-Bid)/Point, InitialPrice=0;
//----
  
   if(INCREMENT<MarketInfo(Symbol(),MODE_STOPLEVEL)+spread) INCREMENT=1+MarketInfo(Symbol(),MODE_STOPLEVEL)+spread;
//   if(MONEY_MANAGEMENT) MAX_LOTS=OrdersTotal();
  /* if(OrdersTotal()>128)
   {
      Comment("Not Enough Free Margin to begin");
      return(0);
   }
   */
   
   for(cpt=1;cpt<LEVELS;cpt++) PipsLot+=cpt*INCREMENT;
   for(cpt=0;cpt<OrdersTotal();cpt++)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
      {
         total++;
         if(!InitialPrice) InitialPrice=StrToDouble(OrderComment());
         if(UsePartialProfitTarget && UseProfitTarget && OrderType()<2)
         {
            double val=getPipValue(OrderOpenPrice(),OrderType());
            takeProfit(val,OrderTicket()); 
         }
      }
   }
     
  
   if(total<1 &&  difference > DIFFERENCE && Enter && (!UseEntryTime || (UseEntryTime && Hour()==EntryTime)))
   {
    /*  if(OrdersTotal()>128)
      {
         Print("Not enough free margin to begin");
         return(0);
      }
      */
      // - Open Check - Start Cycle
      InitialPrice=Ask;
      SellGoal=InitialPrice-(LEVELS+1)*INCREMENT*Point;
      BuyGoal=InitialPrice+(LEVELS+1)*INCREMENT*Point;
      for(cpt=1;cpt<=LEVELS;cpt++)
      {
         //OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,SellGoal-spread*Point,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,BuyGoal+spread*Point,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
     
      }
    } // initial setup done - all channels are set up
    else // We have open Orders
    {
      BuyGoal=InitialPrice+INCREMENT*(LEVELS+1)*Point;
      SellGoal=InitialPrice-INCREMENT*(LEVELS+1)*Point;
      total=OrdersHistoryTotal();
//      total=128;
      for(cpt=0;cpt<total;cpt++)
      {
         OrderSelect(cpt,SELECT_BY_POS,MODE_HISTORY);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC &&  StrToDouble(OrderComment())==InitialPrice){EndSession();return(0);}
      }
      if(UseProfitTarget && CheckProfits(LOTS,OP_SELL,true,InitialPrice)>ProfitTarget) {/*EndSession();return(0);*/}
      BuyGoalProfit=CheckProfits(LOTS,OP_BUY,false,InitialPrice);
      SellGoalProfit=CheckProfits(LOTS,OP_SELL,false,InitialPrice);
      if(BuyGoalProfit<ProfitTarget)
      // - Incriment Lots Buy
      {
         for(cpt=LEVELS;cpt>=1 && BuyGoalProfit<ProfitTarget;cpt--)
         {
            if(Ask<=(InitialPrice+(cpt*INCREMENT-MarketInfo(Symbol(),MODE_STOPLEVEL))*Point))
            {
              // ticket=OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,SellGoal-spread*Point,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
            
             // ticket=OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,0,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
            }
            if(ticket>0) BuyGoalProfit+=LOTS*(BuyGoal+spread-InitialPrice-cpt*INCREMENT*Point)/Point;
         }
      }
      if(SellGoalProfit<ProfitTarget)
      // - Increment Lots Sell
      {
         for(cpt=LEVELS;cpt>=1 && SellGoalProfit<ProfitTarget;cpt--)
         {
            if(Bid>=(InitialPrice-(cpt*INCREMENT-MarketInfo(Symbol(),MODE_STOPLEVEL))*Point))
            {
               //ticket=OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,BuyGoal+spread*Point,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
                 //ticket=OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,0,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
            
            
            }
            if(ticket>0) SellGoalProfit+=LOTS*(InitialPrice-cpt*INCREMENT*Point-SellGoal-spread*Point)/Point;
         }
      }
     }
       
   
   int pos = OrdersTotal()-1;
   
   
   
   if(OrderSelect(pos, SELECT_BY_POS)==true){
      
    // if(Ask < OrderOpenPrice()-(5*INCREMENT*Point) ){
    if(Ask > OrderOpenPrice()+ (RETRACEMENT*INCREMENT*Point) ){
   
      Print("buy_stop");
      Print(OrderType());
      double Initial = Ask;
         for(cpt=1;cpt<=5;cpt++){
         //OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,SellGoal-spread*Point,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,BuyGoal+spread*Point,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
       //  Print(Initial+cpt*INCREMENT*Point);
         OrderSend(Symbol(),OP_BUYSTOP,LOTS,Initial+cpt*INCREMENT*Point,2,0,0,"comment",MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
        // OrderSend(Symbol(), OP_BUYSTOP, LOTS, NormalizeDouble(Initial+(cpt*(INCREMENT+1)*Point),Digits) , 1, 0, 0, "comment", MAGIC, 0, CLR_NONE);
     
         }
        
    }
      
     if(Ask < OrderOpenPrice()-(RETRACEMENT*INCREMENT*Point)){
      Initial = Ask;
     
      Print("sell_stop");
        Print(OrderType());
         for(cpt=1;cpt<=5;cpt++){
       //  Print(Initial-cpt*INCREMENT*Point);
         //OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,SellGoal-spread*Point,BuyGoal+spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,InitialPrice-cpt*INCREMENT*Point,2,BuyGoal+spread*Point,SellGoal-spread*Point,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_BUYSTOP,LOTS,InitialPrice+cpt*INCREMENT*Point,2,0,0,DoubleToStr(InitialPrice,MarketInfo(Symbol(),MODE_DIGITS)),MAGIC,0);
         //OrderSend(Symbol(),OP_SELLSTOP,LOTS,Initial-cpt*INCREMENT*Point,2,0,0,0,MAGIC,0);
         OrderSend(Symbol(), OP_SELLSTOP, LOTS, Initial-cpt*INCREMENT*Point, 2, 0, 0, "comment", MAGIC, 0);
     
         }
   
     }
      
   }
   
   PrintStats();
   
   if(AccountEquity()>AccountBalance()+CloseAtProfit){
      
      EndSession();
      return 0;
   }
//+------------------------------------------------------------------+   

    Comment("mGRID EXPERT ADVISOR ver 2.0\n",
            "FX Acc Server:",AccountServer(),"\n",
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),"\n",
            "Minimum Lot Sizing: ",MarketInfo(Symbol(),MODE_MINLOT),"\n",
            "Account Balance:  $",AccountBalance(),"\n",
            "FreeMargin: $",AccountFreeMargin(),"\n",
            "Total Orders Open: ",OrdersTotal(),"\n",
            "Total Orders History: ",OrdersHistoryTotal(),"\n",            
            "Symbol: ", Symbol(),"\n",
            "Price:  ",NormalizeDouble(Bid,4),"\n",
            "Pip Spread:  ",MarketInfo("EURUSD",MODE_SPREAD),"\n",
            "Increment=" + INCREMENT,"\n",
            "Lots:  ",LOTS,"\n",
            "Levels: " + LEVELS,"\n",
            "Float: ",Tally," Longs: ",LOrds," Shorts: ",SOrds, " BuyStops: ",PendSell," SellStops: ",PendBuy);
            
            
            
   return(0);
   
   
  
}

//+------------------------------------------------------------------+















int CheckProfits(double LOTS, int Goal, bool Current, double InitialPrice)
{
   int profit=0, cpt;
   if(Current)//return current profit
   {
      for(cpt=0;cpt<=OrdersTotal();cpt++)
      {
         OrderSelect(cpt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && StrToDouble(OrderComment())==InitialPrice)
         {
            if(OrderType()==OP_BUY) profit+=(Bid-OrderOpenPrice())/Point*OrderLots()/LOTS;
            if(OrderType()==OP_SELL) profit+=(OrderOpenPrice()-Ask)/Point*OrderLots()/LOTS;
         }
      }
      return(profit);
   }
   else
   {
      if(Goal==OP_BUY)
      {
         for(cpt=0;cpt<=OrdersTotal();cpt++)
         {
            OrderSelect(cpt, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol()==Symbol() && StrToDouble(OrderComment())==InitialPrice)
            {
               if(OrderType()==OP_BUY) profit+=(OrderTakeProfit()-OrderOpenPrice())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELL) profit-=(OrderStopLoss()-OrderOpenPrice())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_BUYSTOP) profit+=(OrderTakeProfit()-OrderOpenPrice())/Point*OrderLots()/LOTS;
            }
        }
         return(profit);
      }
      else
      {
         for(cpt=0;cpt<=OrdersTotal();cpt++)
         {
            OrderSelect(cpt, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol()==Symbol() && StrToDouble(OrderComment())==InitialPrice)
            {
               if(OrderType()==OP_BUY) profit-=(OrderOpenPrice()-OrderStopLoss())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELL) profit+=(OrderOpenPrice()-OrderTakeProfit())/Point*OrderLots()/LOTS;
               if(OrderType()==OP_SELLSTOP) profit+=(OrderOpenPrice()-OrderTakeProfit())/Point*OrderLots()/LOTS;              
            }
         }
         return(profit);
      }
   }
}

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
      if(!CONTINUE)  Enter=false;

      return(true);
}


double getPipValue(double ord,int dir)
{
   double val;
   RefreshRates();
   if(dir == 1) val=(NormalizeDouble(ord,Digits) - NormalizeDouble(Ask,Digits));
   else val=(NormalizeDouble(Bid,Digits) - NormalizeDouble(ord,Digits));
   val = val/Point;
   return(val);   
}

//========== FUNCTION takeProfit

void takeProfit(int current_pips, int ticket)
{
   if(OrderSelect(ticket, SELECT_BY_TICKET))
   {

      if(current_pips >= nextTP && current_pips < (nextTP + Target_Increment))
      {
         if(OrderType()==1)
         {
            if(OrderClose(ticket, MAX_LOTS, Ask, 3))
            nextTP+=Target_Increment;
            else
            Print("Error closing order : ",GetLastError()); 
         } 
         else
         {
            if(OrderClose(ticket, MAX_LOTS, Bid, 3))
            nextTP+=Target_Increment;
            else
            Print("Error closing order : ",GetLastError()); 
         }        
      }
   }
}



//========== FUNCTION PrintStats

void PrintStats(){
  int y, total;  
    
    Tally      =0;
    LOrds      =0;
    SOrds      =0;
    PendBuy    =0;
    PendSell   =0;
    
    total = OrdersTotal();  

      for(y=0;y<total;y++) {
         OrderSelect(y,SELECT_BY_POS);
            if(OrderSymbol() == Symbol()){ 
                            
                               
                               if(OrderType()==OP_BUY){
                               LOrds++;
                               Tally=Tally+OrderProfit();
                               
                               }
                               if(OrderType()==OP_SELL){
                               SOrds++;
                               Tally=Tally+OrderProfit();
                               
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