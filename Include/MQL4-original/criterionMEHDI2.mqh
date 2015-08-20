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

extern bool turn_on_crodzilla = true;
extern bool turn_on_engulfing = true;
extern bool turn_on_trend = true;
extern bool turn_on_wicked = true;
extern double wickedPercentage;


extern double TakeProfitFactor;
extern double StopLossPips;

  bool key1=false;
  bool key2=false;
  bool key3=false;
  bool key4=false;
  bool key5=false;
  
  
 bool eng_tre_wic_on= false;
 bool cro_eng_wic_on= false;
 bool cro_eng_tre_on= false;
 bool cro_tre_wic_on= false;
 bool all_on=false;

//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
  
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
     // return(-1);                      // .. и выход
     }
      
      
  
   int crodzillaSell_indicator=0;
   int crodzillaBuy_indicator=1; 
  
   int EngulfingBuyIndicator=0;
   int EngulfingSellIndicator=1;
   
   int trendSell_indicator=1;
   int trendBuy_indicator=0;
   
   int wickedBuy_indicator=1;
   int wickedSell_indicator=0;
   
   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;

   bool bullish;
   bool bearish;
   
   bool bullish2;
   bool bearish2;
//--------------------------------------------------------------- 4 --
 
  
      double xazz_Sell_signal = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 1); //
      double xazz_Buy_signal  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 1); //
 
//--------------------------------------------------------------- 5 --
  
      double crodzilla_Sell_signal = iCustom(NULL,0,"Strategy2/!crodzilla-Price action V8-MTF", crodzillaSell_indicator, 1); // !=2147483647
      double crodzilla_Buy_signal = iCustom(NULL,0,"Strategy2/!crodzilla-Price action V8-MTF", crodzillaBuy_indicator, 1); // !=2147483647

//--------------------------------------------------------------- 5 --
      
      double engulfing_Sell_signal = iCustom(NULL,0,"Strategy2/Engulfing Bar Alert v1.2_FGB", EngulfingSellIndicator, 1); //!=2147483647
      double engulfing_Buy_signal = iCustom(NULL,0,"Strategy2/Engulfing Bar Alert v1.2_FGB", EngulfingBuyIndicator, 1); //!=2147483647
 //--------------------------------------------------------------- 5 --
  
      double trend_Sell_signal = iCustom(NULL,0,"Strategy2/ForexTrend Indicator", trendSell_indicator, 1); //!=2147483647
      double trend_Buy_signal = iCustom(NULL,0,"Strategy2/ForexTrend Indicator", trendBuy_indicator, 1); //!=2147483647
 //--------------------------------------------------------------- 5 --
 
      double wicked_Sell_signal=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wickedSell_indicator, 1); //!=0
      double wicked_Buy_signal=iCustom(NULL,0,"Strategy2/WickPercentage",wickedPercentage, wickedBuy_indicator, 1); //!=0
 //--------------------------------------------------------------- 5 --  
 
if(turn_on_crodzilla != true || turn_on_engulfing != true || turn_on_trend != true || turn_on_wicked != true)
{
  if(turn_on_engulfing == true && turn_on_trend == true && turn_on_wicked == true)eng_tre_wic_on=true; else eng_tre_wic_on=false;
  if(turn_on_crodzilla == true && turn_on_engulfing == true  && turn_on_wicked == true)cro_eng_wic_on= true; else cro_eng_wic_on= false;
  if(turn_on_crodzilla == true && turn_on_engulfing == true && turn_on_trend == true)cro_eng_tre_on= true; else cro_eng_tre_on= false;
  if(turn_on_crodzilla == true && turn_on_trend == true && turn_on_wicked == true)cro_tre_wic_on= true; else cro_tre_wic_on= false;
}
else
{

  key1=false;
  key2=false;
  key3=false;
  key4=false;
  
  eng_tre_wic_on= false;
  cro_eng_wic_on= false;
  cro_eng_tre_on= false;
  cro_tre_wic_on= false;

}
 
  key1=eng_tre_wic_on;
  key2=cro_eng_wic_on;
  key3=cro_eng_tre_on;
  key4=cro_tre_wic_on;
 


 
  
  
  //--------------------------------------------------------------- 5 -- 




  ///------------Condition 1----------------
   
   
if(key1==true)
{
  if( engulfing_Sell_signal !=2147483647 && trend_Sell_signal !=2147483647 && crodzilla_Sell_signal !=2147483647 && xazz_Sell_signal != 2147483647)
 {
      bearish=true; // && wicked_signal !=0
      StopLoss=((xazz_Sell_signal-Ask)*10*10000)+ StopLossPips;
      TakeProfit = TakeProfitFactor*(StopLoss);
      
      Alert("StopLoss=",StopLoss, " TakeProfit=",TakeProfit);
  }
  else bullish=false;

  if( engulfing_Buy_signal !=2147483647 && trend_Buy_signal !=2147483647 && crodzilla_Buy_signal !=2147483647 && xazz_Buy_signal != 2147483647)
  {
      bullish = true; // && wicked_signal !=0
      
      StopLoss = ((Bid-xazz_Buy_signal)*10*10000)-StopLossPips;
      TakeProfit = TakeProfitFactor *(StopLoss);
  }
  else bullish=false;
}


if(key2==true)
{
  if( engulfing_Sell_signal !=2147483647 && wicked_Sell_signal !=0 && crodzilla_Sell_signal !=2147483647 && xazz_Sell_signal != 2147483647)
  {
      bearish=true; // && wicked_signal !=0
      StopLoss=((xazz_Sell_signal-Ask)*10*10000)+ StopLossPips;
      TakeProfit = TakeProfitFactor*(StopLoss);
      
      Alert("StopLoss=",StopLoss, " TakeProfit=",TakeProfit);
  }
  else bearish=false;

  if( engulfing_Buy_signal !=2147483647 && wicked_Buy_signal !=0 && crodzilla_Buy_signal !=2147483647 && xazz_Buy_signal != 2147483647)
  {
      bullish = true; // && wicked_signal !=0
      StopLoss = ((Bid-xazz_Buy_signal)*10*10000)-StopLossPips;
      TakeProfit = TakeProfitFactor *(StopLoss);
  }  
  else bullish=false;
}


if(key3==true)
{
  if( engulfing_Sell_signal !=2147483647 && trend_Sell_signal !=2147483647 && crodzilla_Sell_signal !=2147483647 && xazz_Sell_signal != 2147483647 )
  {
      bearish=true; // && wicked_signal !=0
      StopLoss=((xazz_Sell_signal-Ask)*10*10000)+ StopLossPips;
      TakeProfit = TakeProfitFactor*(StopLoss);
      
      Alert("StopLoss=",StopLoss, " TakeProfit=",TakeProfit);
  }
  else bearish=false;

  if( engulfing_Buy_signal !=2147483647 && trend_Buy_signal !=2147483647 && crodzilla_Buy_signal !=2147483647 && xazz_Buy_signal != 2147483647)
  {
      bullish = true; // && wicked_signal !=0
      StopLoss = ((Bid-xazz_Buy_signal)*10*10000)-StopLossPips;
      TakeProfit = TakeProfitFactor *(StopLoss);
  }
  else bullish=false;
}


if(key4==true)
{
  if( trend_Sell_signal !=2147483647 && wicked_Sell_signal !=0 && crodzilla_Sell_signal !=2147483647 && xazz_Sell_signal != 2147483647)
  {
      bearish=true; // && wicked_signal !=0
      StopLoss=((xazz_Sell_signal-Ask)*10*10000)+ StopLossPips;
      TakeProfit = TakeProfitFactor*(StopLoss);
      
      Alert("StopLoss=",StopLoss, " TakeProfit=",TakeProfit);
  }
  else bearish=false;

  if( trend_Buy_signal !=2147483647 && wicked_Buy_signal !=0 && crodzilla_Buy_signal !=2147483647 && xazz_Buy_signal != 2147483647)
  {
      bullish = true; // && wicked_signal !=0
      StopLoss = ((Bid-xazz_Buy_signal)*10*10000)-StopLossPips;
      TakeProfit = TakeProfitFactor *(StopLoss);
  }
  else bullish=false;
}



  if( engulfing_Sell_signal !=2147483647 && trend_Sell_signal !=2147483647 && wicked_Sell_signal !=0 && crodzilla_Sell_signal !=2147483647 && xazz_Sell_signal != 2147483647)
{
   bearish2=true; // && wicked_signal !=0
   StopLoss=((xazz_Sell_signal-Ask)*10*10000)+ StopLossPips;
   TakeProfit = TakeProfitFactor*(StopLoss);
   Alert("StopLoss=",StopLoss, " TakeProfit=",TakeProfit);
}
  else bearish2=false;

  if( engulfing_Buy_signal !=2147483647 && trend_Buy_signal !=2147483647 && wicked_Buy_signal !=0 && crodzilla_Buy_signal !=2147483647 && xazz_Buy_signal != 2147483647)
{

   bullish2 = true; // && wicked_signal !=0
   StopLoss = ((Bid-xazz_Buy_signal)*10*10000)-StopLossPips;
   TakeProfit = TakeProfitFactor *(StopLoss);

}  
  
  else bullish2=false;



//----------------------------------------------------------------------------


  if(bullish==true || bullish2 ==true)
   {
                        return(10);           // Открытие Buy   
   }
   
   
  if(bearish==true || bearish2 == true)
   {
                        return(20);           // Открытие sell   
   }
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


