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

//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
  
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
      
  
  int crodzillaSell_indicator=1;
  int crodzillaBuy_indicator=0; 
  
   int EngulfingBuyIndicator=0;
   int EngulfingSellIndicator=1;
   
   int trendSell_indicator=1;
   int trendBuy_indicator=0;
  
  int n, i, bar;
  
  double p0, p1, p2, p3, p4, p5;

//--------------------------------------------------------------- 4 --
 

 
//--------------------------------------------------------------- 5 --
  
      i=0;
   
      while(n<5)
      {
      if(p0!=2147483647) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(NULL,0,"Strategy2/!crodzilla-Price action V8-MTF", crodzillaBuy_indicator, i); //
      if(n==2){bar = i;}
      if(p0!=2147483647) {n+=1; }
      i++;
      }
    
      double crodzilla_signal = p4;  
      
  
//--------------------------------------------------------------- 5 --
      
      i=0;
   
      while(n<5)
      {
      if(p0!=2147483647) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(NULL,0,"Strategy2/Engulfing Bar Alert v1.2_FGB", EngulfingBuyIndicator, i); //
      if(n==2){bar = i;}
      if(p0!=2147483647) {n+=1; }
      i++;
      }
         
      double engulfing_signal = p4; 
  
  
 //--------------------------------------------------------------- 5 --
  
      i=0;
   
      while(n<5)
      {
      if(p0!=2147483647) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(NULL,0,"Strategy2/ForexTrend Indicator", trendBuy_indicator, i); //
      if(n==2){bar = i;}
      if(p0!=2147483647) {n+=1; }
      i++;
      }
  
      double trend_signal = p4;
      
 //--------------------------------------------------------------- 5 --
 
   double wicked_signal=iCustom(NULL,0,"Strategy2/WickPercentage", wickedBuy_indicator, 1); //
   
 //--------------------------------------------------------------- 5 --  
 
 

   ///------------Condition 1, buy----------------
  
  if((p4 <= p2+Tolerance && p4>= p2-Tolerance) && p3>p2)
   {
   TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 2, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      if(TVI_Last_Previous < TVI_Last)TVI_Peak_Last= TVI_Last_Previous;
   if(TVI_Last_Later < TVI_Last)TVI_Peak_Last = TVI_Last_Later;
   if(TVI_Last_Previous < TVI_Last_Later) TVI_Peak_Last = TVI_Last_Previous;
   
   if( TVI!=2147483647 && TVI!=0 && TVI_Last < 0 && TVI < TVI_Peak_Last && (p4 > Bid-Tolerance2 && p4 < Bid+Tolerance2)){  
   
     if(iVolume(NULL,0,0)==1){
         TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 2, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      
            if(TVI!=2147483647 && TVI !=0){
            
            TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 2, 0); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
               if(TVI != 2147483647 && TVI !=0){
                  return(10);           // Открытие Buy
                  }
               
      }
      
      
    }
   }
   }

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------



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


