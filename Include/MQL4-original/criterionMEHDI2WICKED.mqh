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


extern double wickedPercentage=99;
extern double StopLossPips=3;
extern double TviTolerance=3;
extern double Tolerance2=0.0002;



   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   int wicked_indicator=1;
 //  int wickedSell_indicator=0;
   
   int ExtDepth=12;
   int ExtDeviation=5;
   int ExtBackstep=3;
   
   int bar_Now=1;
   int bar_Last=2;

   double SymSpread;
//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
  
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
      
 
   if(Digits==3){SymSpread=(Ask-Bid)*100;}
   if(Digits==5){SymSpread=(Ask-Bid)*10000;}
   
   

//--------------------------------------------------------------- 4 --
 
      double xazz_Sell_signal_Last = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar_Last); //
      double xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar_Last); //
      
      double xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar_Now); //
      double xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar_Now); //
      
      
    //  double wicked_Sell_signal_Last=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wickedSell_indicator, 3); //!=0
      double wicked_signal_Last=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wicked_indicator, bar_Last); //!=0
      
    //  double wicked_Sell_signal_Now=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wickedSell_indicator, 2); //!=0
      double wicked_signal_Now=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wicked_indicator, bar_Last); //!=0
      
      
      double p4=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,0,bar_Last);
      
      double TVI_downPos = iCustom(NULL,0,"TVI_v2",5,5,5, 2, bar_Last); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      double TVI_upNeg = iCustom(NULL,0,"TVI_v2",5,5,5, 1, bar_Last); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
      
      
      double close_Last = iClose(Symbol(),0,bar_Last);
      double open_Last  = iOpen(Symbol(),0,bar_Last);
      
      double close_Now = iClose(Symbol(),0,bar_Now);
      double open_Now  = iOpen(Symbol(),0,bar_Now);
//--------------------------------------------------------------- 5 --
  
 
 
     int n, i, bar; 
  // double p0, p1, p2, p3, p4, p5;
/*  
   i=0;
   
      while(n<5)
      {
      if(p0>0) {p5=p4; p4=p3; p3=p2; p2=p1; p1=p0; }
      p0=iCustom(Symbol(),0,"zigzag",ExtDepth,ExtDeviation,ExtBackstep,0,i);
      if(n==2){bar = i;}
      if(p0>0) {n+=1; }
      i++;
      }
 */
 
 bool bearish;
 bool bullish;
 
 if(wicked_signal_Last !=0 && wicked_signal_Now !=0 && close_Last>open_Last && close_Now < open_Now )bearish=true;
 else bearish=false; 
 
 if(wicked_signal_Last !=0 && wicked_signal_Now !=0 && close_Last<open_Last && close_Now > open_Now )bullish=true;
 else bullish=false; 
   

   ///------------Condition 1, buy----------------
  
//  if( bullish==true && TVI_downPos <= -TviTolerance && TVI_downPos!=2147483647 && p4 == xazz_Buy_signal_Last && p4  != 0  && xazz_Buy_signal_Last != 2147483647 )
  if( bullish==true  && p4 == xazz_Buy_signal_Last && p4  != 0  && xazz_Buy_signal_Last != 2147483647 )
   {
   
   
      xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 0); //
      //if(xazz_Buy_signal_Now != 2147483647)StopLoss=((Bid-xazz_Buy_signal_Now)*10*10000);
      //StopLoss = ((Bid-xazz_Buy_signal_Last)*10*10000)+StopLossPips+SymSpread;;;
      StopLoss = 20+SymSpread;
      if(iVolume(NULL,0,0)==1) return(10); //Buy
   
   }

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------



//---------------- condition 1, sell --------------------------------
 // if(bearish == true && TVI_upNeg >= TviTolerance && TVI_upNeg !=2147483647 && p4 == xazz_Sell_signal_Last && p4  != 0 && xazz_Sell_signal_Last != 2147483647 && wicked_signal_Last !=0 && wicked_signal_Now !=0)
  if(bearish == true  && p4 == xazz_Sell_signal_Last && p4  != 0 && xazz_Sell_signal_Last != 2147483647 && wicked_signal_Last !=0 && wicked_signal_Now !=0)
   {
      xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 0); //
     // if(xazz_Sell_signal_Now != 2147483647)StopLoss=((xazz_Sell_signal_Now-Ask)*10*10000);
     // StopLoss=((xazz_Sell_signal_Last-Ask)*10*10000)+StopLossPips+ SymSpread;;
      StopLoss = 20+SymSpread;
      if(iVolume(NULL,0,0)==1) return(20); //Sell
   
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


