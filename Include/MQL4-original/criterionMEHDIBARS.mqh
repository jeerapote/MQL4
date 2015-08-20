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
//int condition=3;
//extern double Tolerance=0.0001;
//extern double Tolerance2=0.0002;

int bar=1;
int ticket;
double myPoint = 0.00001;

int count = 0;

//extern double StopLossFactor=8;
//extern double TakeProfitFactor=4;
extern double pipsAbove=0.0002;
extern double pipsBelow=0.0002;
extern int difference=30;
extern double Lot=0.1;



//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
  
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
      
 
   
   

//--------------------------------------------------------------- 4 --
 
      double close = iClose(Symbol(),0,bar);
      double open  = iOpen(Symbol(),0,bar);
      double high  = iHigh(Symbol(),0,bar);
      double low   = iLow(Symbol(),0,bar);
      
      double bodysize = (open-close)/myPoint;
      
      Comment(bodysize);
//--------------------------------------------------------------- 5 --
  
 
 

 
 bool bearish;
 bool bullish;
 
 if(bodysize < (-1*difference))bearish=true;
 else bearish=false; 
 
 if(bodysize > difference )bullish=true;
 else bullish=false; 
   

   ///------------Condition 1, buy----------------
  
  if(bullish==true)
   {
   
   /*   TakeProfit=MathAbs(bodysize)/ TakeProfitFactor;
      StopLoss=TakeProfit/ StopLossFactor;
      */
      
      CloseAll_Sell();
      if(iVolume(NULL,0,0)==1)
     // ticket = OrderSend(Sym, OP_BUYSTOP, Lot, high, 0, StopLoss, TakeProfit);
       ticket = OrderSend(Sym, OP_BUYSTOP, Lot, high, 0, low, high+pipsAbove);
       
      
      //return(10);//buy
   
   }

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------



//---------------- condition 1, sell --------------------------------
  if(bearish==true )
  {
      //TakeProfit=MathAbs(bodysize)/TakeProfitFactor;
      //StopLoss=TakeProfit/StopLossFactor;
      CloseAll_Buy();
      if(iVolume(NULL,0,0)==1)
      ticket = OrderSend(Sym, OP_SELLSTOP, Lot, low, 0, high , low-pipsBelow);
      //return(20);//buy
   
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

int CloseAll_Sell(){

int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
     // case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          //break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;
                 
      case OP_SELLSTOP  : result = OrderDelete(OrderTicket()); 
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}



int CloseAll_Buy(){

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
     // case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          break;
      
      case OP_BUYSTOP   : result = OrderDelete(OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}

