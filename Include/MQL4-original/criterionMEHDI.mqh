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
extern double Tolerance=0.0001;
extern double Tolerance2=0.0002;
extern double ProfitMargin=1.5;

//extern double TakeProfitFactor;
//extern double StopLossPips;

   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   int order;
   
   bool closed;

//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
  
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
      
   double
   TVI, TVI_Last, TVI_Last_Later, TVI_Last_Previous;

//--------------------------------------------------------------- 4 --
 
      double xazz_Sell_signal_Last = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 1); //
      double xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 1); //
      double xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 0); //
      double xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 0); //
//--------------------------------------------------------------- 5 --
   int ExtDepth=12;
   int ExtDeviation=5;
   int ExtBackstep=3;
 
 
   int n, i, bar, bar4; 
   double p0, p1, p2, p3, p4, p5;
  
   i=0;
   
      while(n<5)
      {
      if(p0>0) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,0,i);
      if(n==2){bar = i;}
      if(n==0){bar4=i;}
      if(p0>0) {n+=1; }
      i++;
      }
      
   TVI_Last = iCustom(NULL,0,"TVI_v2",5,5,5, 4, bar); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
   
   TVI_Last_Previous = iCustom(NULL,0,"TVI_v2",5,5,5, 4, bar-2);
   TVI_Last_Later= iCustom(NULL,0,"TVI_v2",5,5,5, 4, bar+2);
   
   int TVI_Peak_Last;
   
   TVI_Peak_Last= TVI_Last;
   
   
   
   if(tradeExited(order)==true && !closed)
   {
      CloseAll();
      closed=true;
      
   }   
   int pos = OrdersTotal()-1;
   
   if(OrderSelect(pos, SELECT_BY_POS)==true)
   {
   
   // MoveStopToBreakeven();
   
   if(OrderProfit()>=1.5 && OrderProfit() <=3 && OrdersTotal() == 1)
    {
        // Print(pos);
        // Print("Profit for the order 10 ",OrderProfit());
        int order_type=OrderType();
        
       // Print(order_type);
        MaxOrders = 3;
        
       
        if(order_type==0)
         {
        
            if(iVolume(NULL,0,0)==1);
            order=OrderTicket();
            closed=false;
            
            return(10);
         }
        else 
         {
            if(iVolume(NULL,0,0)==1);
            order=OrderTicket();
            closed=false;
            return(20);   
         }
         
        
         
     }
      
   }
   MaxOrders=0;
  // else
  // Print("OrderSelect returned the error of ",GetLastError());
   

   ///------------Condition 1, buy----------------
   
   xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar); //
   xazz_Sell_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar); //
   
   xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar4); //
   xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar4); //
  
  //if((p4 <= p2+Tolerance && p4>= p2-Tolerance) && p3>p2 && xazz_Buy_signal_Now == p4 && xazz_Buy_signal_Now <= xazz_Buy_signal_Last+Tolerance && xazz_Buy_signal_Now >= xazz_Buy_signal_Last-Tolerance)
   if(p3>p2 && p4== xazz_Buy_signal_Now && (xazz_Buy_signal_Now <= xazz_Buy_signal_Last+Tolerance && xazz_Buy_signal_Now >= xazz_Buy_signal_Last-Tolerance)&&(Bid <= xazz_Buy_signal_Last+Tolerance && Bid >= xazz_Buy_signal_Last-Tolerance)  )
    {
      
      
      TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 3, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      if(TVI_Last_Previous < TVI_Last)TVI_Peak_Last= TVI_Last_Previous;
      if(TVI_Last_Later < TVI_Last)TVI_Peak_Last = TVI_Last_Later;
      if(TVI_Last_Previous < TVI_Last_Later) TVI_Peak_Last = TVI_Last_Previous;
      
      
      if( TVI!=2147483647 && TVI!=0 && TVI_Last < 0 && TVI < TVI_Peak_Last)
      {  
     // StopLoss = MathAbs((Bid-xazz_Buy_signal_Last)*10*10000)+StopLossPips;
     // TakeProfit = TakeProfitFactor *(StopLoss);
      return(10);
      }

   }

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------



//---------------- condition 1, sell --------------------------------
 // if((p4 <= p2+Tolerance && p4>= p2-Tolerance) && p2>p3 && xazz_Sell_signal_Now == p4 && xazz_Sell_signal_Now <= xazz_Sell_signal_Last+Tolerance && xazz_Sell_signal_Now >= xazz_Sell_signal_Last-Tolerance)
   if( p2>p3  && p4== xazz_Sell_signal_Now && (xazz_Sell_signal_Now <= xazz_Sell_signal_Last+Tolerance && xazz_Sell_signal_Now >= xazz_Sell_signal_Last-Tolerance)&&(Bid <= xazz_Sell_signal_Last+Tolerance && Bid >= xazz_Sell_signal_Last-Tolerance))
     {
   
    TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 0, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
    if(TVI_Last_Previous > TVI_Last)TVI_Peak_Last= TVI_Last_Previous;
    if(TVI_Last_Later > TVI_Last)TVI_Peak_Last = TVI_Last_Later;
    if(TVI_Last_Previous > TVI_Last_Later) TVI_Peak_Last = TVI_Last_Previous;
   
    if( TVI!=2147483647 && TVI!=0 && TVI_Last > 0 && TVI > TVI_Peak_Last  ){
      // StopLoss=MathAbs((xazz_Sell_signal_Last-Ask)*10*10000)+StopLossPips;
      
      // TakeProfit = TakeProfitFactor *(StopLoss);
       
     //  Alert("Takeprofit=",TakeProfit);
       return(20);
    }

   }
   
//====================================================================
//--------------------------------------


/*
   if((p4 < p2) && p3>p2)
   {
   if(TVI!=2147483647 && TVI > TVI_Last && (p4 > Bid-Tolerance2 && p4 < Bid+Tolerance2)){
       
        if(iVolume(NULL,0,0)==1) return(10);                  // Открытие Buy 
      
      }
    }
          */ 
//--------------------------------------------------------------- 6 --
   return(0);                          // Выход из пользов. функции
  }
  
  
  
  
  
//--------------------------------------------------------------- 7 -------------------------------------------+

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


bool MoveStopToBreakeven() {

   bool retVal = true;
   double sl;
   double breakeven;

   // select the Order
   for(int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol() == Symbol()) {         
         
         if(  OrderType() == OP_BUY && Bid >=  OrderOpenPrice() && OrderProfit() >= ProfitMargin ){
         
              breakeven = ( Bid - OrderOpenPrice() ) ;
                
              sl = OrderOpenPrice() + breakeven/3;
              
              if( sl > OrderStopLoss() ) {
               retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Blue) ;
              }
         }
        
       if(OrderType() == OP_SELL && Ask <= OrderOpenPrice() && OrderProfit() >= ProfitMargin) {
       
               breakeven = ( OrderOpenPrice() - Ask ) ;
               sl = OrderOpenPrice() - breakeven/3;
               
               if( sl < OrderStopLoss() ) {
                  retVal = OrderModify(OrderTicket(),OrderOpenPrice(), sl,OrderTakeProfit(),0,Red) ;
               }
         }
      }
   }
   
   if( !retVal ) {
      Print( ErrorDescription( GetLastError() ) + ". SL: " + DoubleToStr( sl, Digits) );
   }
   
   return(retVal);
}


bool tradeExited(int OrderTicketNumber)
{


for(int trade=OrdersHistoryTotal()-1;trade>=0;trade--)
{
 OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
 
 if(OrderTicket()==OrderTicketNumber)
 {
  return(true);
  break;
 }
}
}