//--------------------------------------------------------------------
// Criterion.mqh
// Предназначен для использования в качестве примера в учебнике MQL4.
//-------------------------------------------------------------------- 1 --
// Function calculating trading criteria.
// Returned values:
// 10 - opening Buy  
// 20 - opening Sell 
// 11 - closing Buy
// 21 - closing Sell
// 0  - no important criteria available
// -1 - another symbol is used
//-------------------------------------------------------------------- 2 --
int condition=3;
static int TimeSent;


#define LAST_BAR 1
#define THIS_BAR 0

int WaitTime = 10;  // 10 Min.

 extern int BarsBack = 500;
extern double TakeProfitFactor;
extern double StopLossFactor;
extern double Tolerance;

//extern   int      RSI_Period                          =  14;
//extern   double   RSI_BuyBarrier                      =  31;
//extern   double   RSI_SellBarrier                     =  70;

extern int Start_Time = 1;          // Time to allow trading to start ( hours of 24 hr clock ) 0 for both disables
extern int Finish_Time = 23;        // Time to stop trading ( hours of 24 hr clock ) 0 for both disables


extern   double MaxSpreadPips           = 4.5; 

double SymSpread;

bool trailing = false;
int StopLoss   =200; // StopLoss for new orders (in points) 
int TakeProfit =500;  // TakeProfit for new orders (in points)
int TralingStop=500; // TralingStop for market orders (in points)


int buy=0;
int sell = 1;
int lastTrade;

 double COG_upper_green;
   double COG_blue ;
   double COG_lower_green ;
     double COG_lower_brown; 
      double COG_upper_brown ;
  


//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
    //  return(-1);                      // .. и выход
     }
     
     
       if(Digits==3){SymSpread=(Ask-Bid)*100;}
   if(Digits==5){SymSpread=(Ask-Bid)*10000;}
   
   
   double  rsi_Now, rsi_Then,  volatility, TVI,TVI_Down_Neg,TVI_Up_Neg,TVI_Down_Pos,TVI_Up_Pos;

   bool bullish, bearish;
   
   
   double
buy2,sell2;
   
   bool morningHours   = (Hour() >  1 && Hour() < 2),
     afternoonHours =  Hour() > 14 && Hour() < 24,
     tradingHours   = morningHours || afternoonHours;

//--------------------------------------------------------------- 4 --


/*
 buy = iCustom(NULL,0,"Downloads/ReversalFractals",false, 0,2 );
 buy2 = iCustom(NULL,0,"Downloads/ReversalFractals",false, 0,3 );
 sell = iCustom(NULL,0,"Downloads/ReversalFractals",false, 1,2 );
 sell2 = iCustom(NULL,0,"Downloads/ReversalFractals",false, 1,3 );*/

    COG_upper_green = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 1, 0); 
   COG_blue = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 0, 0);
   COG_lower_green = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 2, 0);
   
    COG_lower_brown = iCustom(NULL,0,"Market/Center of Gravity",BarsBack,4, 0);
    COG_upper_brown = iCustom(NULL,0,"Market/Center of Gravity",BarsBack, 3, 0);
    
     TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 4, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      TVI_Down_Neg = iCustom(NULL,0,"TVI_v2",5,5,5, 3, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      TVI_Up_Neg = iCustom(NULL,0,"TVI_v2",5,5,5, 1, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      
         TVI_Down_Pos = iCustom(NULL,0,"TVI_v2",5,5,5, 2, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      TVI_Up_Pos = iCustom(NULL,0,"TVI_v2",5,5,5, 0, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      
      
      if(COG_upper_green-COG_lower_green != 0)
      StopLoss=StopLossFactor*10*10000*(COG_upper_green-COG_lower_green);
      
      Print(COG_upper_green);
     
    // StopLoss = 100;
    // TakeProfit = 75;
      
      
      
      //if(StopLoss<50 && StopLoss != 0) StopLoss = 50;
     // if(StopLoss>800)return(0);
      
     // TakeProfit = TakeProfitFactor*10*10000*(COG_upper_green-COG_blue);
     
     TakeProfit = TakeProfitFactor * StopLoss;
 
//--------------------------------------------------------------- 5 --
  
 // if(  Bid-0.0001 < COG_lower_green && TVI < -3 && (TVI_Up_Pos !=2147483647 || TVI_Down_Pos !=2147483647)&& tradingHours == true )bullish=true;
 //  if(  Bid-0.00031 < COG_lower_green && TVI < -3 && tradingHours == true )bullish=true;
 //if(  Bid < COG_blue && TVI <-3 && tradingHours == true && (buy!=2147483647 || buy2!=2147483647))bullish=true;
  if(  Bid-Tolerance< COG_lower_green  && SymSpread<MaxSpreadPips)bullish=true;
  else bullish=false;
 // if( Bid+0.0001 > COG_upper_green && TVI > 3 && (TVI_Up_Neg !=2147483647 || TVI_Down_Neg !=2147483647) && tradingHours== true )bearish=true;
 // if( Bid+0.00031 > COG_upper_green && TVI > 3 && tradingHours== true )bearish=true;
// if( Bid>COG_blue && TVI > 3 && tradingHours== true && (sell!=2147483647 || sell2!=2147483647))bearish=true;
if( Bid+Tolerance> COG_upper_green && SymSpread<MaxSpreadPips)bearish=true;
  else bearish = false;
  
 
   bool bProfitableTrade = false;
int  iPos = LastClosedOrderPos();
if (iPos >= 0) {
   if (OrderSelect(iPos, SELECT_BY_POS, MODE_HISTORY))
      bProfitableTrade = ((OrderProfit()+OrderCommission()+OrderSwap()) > 0);
   else
      Print("OrderSelect error ",GetLastError());
   if (bProfitableTrade) {
      // do whatever after a good trade
      WaitTime=0;
   }
   else {
      // do whatever after a bad trade
      WaitTime=0;//10/40; //12 hours
   }   
}
  
       if(  TimeCurrent() >= TimeSent  + (WaitTime*60) ) {
         if( bullish   && OrdersTotal() <=1 && lastTrade == sell )
         {
                lastTrade = buy;
         TimeSent = TimeCurrent();
            return(10);                      // Открытие Buy 
               
         }   
         
            
         if( bearish && OrdersTotal() <=1  && lastTrade == buy){
         
         lastTrade = sell;
         
               TimeSent = TimeCurrent();  
                return(20);                      // Открытие Sell    
         }         
      }
      
    // if (OrdersTotal() >= 1 && Bid == COG_blue)CloseAll();
             
//--------------------------------------------------------------- 6 --
   return(0);                          // Выход из пользов. функции
  }
//--------------------------------------------------------------- 7 -------------------------------------------+


int LastClosedOrderPos(int iOrderType=-1, int iOrderMagicNumber=-1, string sSymbol="") {
  datetime tOrderCloseTime;
  int      i, iOrderPosition=-1, iOrdersTotal=OrdersHistoryTotal();
 
  for (i=0; i<iOrdersTotal; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
      if (sSymbol=="" || OrderSymbol()==sSymbol) {
        if (iOrderType<0 || OrderType()==iOrderType) {
          if (iOrderMagicNumber<0 || OrderMagicNumber()==iOrderMagicNumber) {
            if (tOrderCloseTime<OrderCloseTime()) {
              tOrderCloseTime=OrderCloseTime();
              iOrderPosition=i;
            }
          }
        }
      }
    }
  }
  return(iOrderPosition);
} 



bool AllowTradesByTime()
   {
   int Current_Time = TimeHour(TimeCurrent());
   if (Start_Time == 0) Start_Time = 24; if (Finish_Time == 0) Finish_Time = 24; if (Current_Time == 0) Current_Time = 24;
      
   if ( Start_Time < Finish_Time )
      if ( (Current_Time < Start_Time) || (Current_Time >= Finish_Time) ) return(false);
      
   if ( Start_Time > Finish_Time )
      if ( (Current_Time < Start_Time) && (Current_Time >= Finish_Time) ) return(false);
      
   return(true);
   }


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
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}


