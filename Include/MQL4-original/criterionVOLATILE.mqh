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
datetime lastTradeTime;

#define LAST_BAR 1
#define THIS_BAR 0

extern   int      RSI_Period                          =  14;
extern   double   RSI_BuyBarrier                      =  31;
extern   double   RSI_SellBarrier                     =  70;

//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
     
   double  rsi_Now, rsi_Then,  volatility, TVI;

   bool bullish, bearish;
//--------------------------------------------------------------- 4 --

   rsi_Now    =  iRSI(Symbol(),Period(),RSI_Period,PRICE_CLOSE,THIS_BAR);   
   rsi_Then   =  iRSI(Symbol(),Period(),RSI_Period,PRICE_CLOSE,LAST_BAR);   
   
   TVI = iCustom(NULL,0,"TVI_v2",5,5,5, 4, LAST_BAR); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
   
   volatility = iCustom(NULL,0,"Volatility4",28, 0, 0);
 
//--------------------------------------------------------------- 5 --
  
  if(  rsi_Then < RSI_BuyBarrier && TVI <-5 && volatility < 3)bullish=true;
  else bullish=false;
  if( rsi_Then > RSI_SellBarrier && TVI > 5 && volatility < 3)bearish=true;
  else bearish = false;
  
   
  
       if( lastTradeTime != Time[THIS_BAR] ) {
         if( bullish   && OrdersTotal() <=1)
         {
                
         lastTradeTime = Time[THIS_BAR];
            return(10);                      // Открытие Buy 
               
         }   
         
            
         if( bearish && OrdersTotal() <=1){
         
               lastTradeTime = Time[THIS_BAR];  
                return(20);                      // Открытие Sell    
                }         
      }
      
      if (OrdersTotal() >= 1 && volatility > 6)CloseAll();
             
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


