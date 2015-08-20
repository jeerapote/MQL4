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
extern   double   RSI_BuyBarrier                      =  27;
extern   double   RSI_SellBarrier                     =  73;

//--------------------------------------------------------------- 3 --
int Criterion()                        // Пользовательская функция
  {
   string Sym="EURUSD";
   if (Sym!=Symbol())                  // Если не наш фин. инструмент
     {
      Inform(16);                      // Сообщение..
      return(-1);                      // .. и выход
     }
     
  int    orders=HistoryTotal();     // history orders total
  int    losses=0;                  // number of losses orders without a break
  
  
  
    
    double  volatility = iCustom(NULL,0,"Volatility4",2, 0, 0);
 
    
  
   
     
      if (volatility<5)                  // Если не наш фин. инструмент
   //   if (rsi_Now<30 || rsi_Now>70)                  // Если не наш фин. инструмент
     {
     
    // CloseAll();
      return(0);
    
     }
     
   double
buy,sell,buy2,sell2;

//--------------------------------------------------------------- 4 --

/*
 
 buy = iCustom(NULL,0,"Downloads/ReversalFractals",false, 0,2 );
 buy2 = iCustom(NULL,0,"Downloads/ReversalFractals",false, 0,3 );
 sell = iCustom(NULL,0,"Downloads/ReversalFractals",false, 1,2 );
 sell2 = iCustom(NULL,0,"Downloads/ReversalFractals",false, 1,3 );
 
 */
 
   double rsi_Now    =  iRSI(Symbol(),Period(),RSI_Period,PRICE_CLOSE,THIS_BAR);   
   double rsi_Then   =  iRSI(Symbol(),Period(),RSI_Period,PRICE_CLOSE,LAST_BAR);   
   
   bool bullish = rsi_Then <= RSI_BuyBarrier && rsi_Now > RSI_BuyBarrier;
   bool bearish = rsi_Then >= RSI_SellBarrier && rsi_Now < RSI_SellBarrier ;
 
//--------------------------------------------------------------- 5 --
/*
int bought= 0;
int sold = 1;


   // Вычисление торговых критериев
   if(buy!=2147483647 || buy2!=2147483647 ){
   
    //     if (condition==bought) return(0);
         
         condition=bought;
       
         return(10);                      // Открытие Buy 
      
      }
   if(sell!=2147483647 || sell2!=2147483647)
   {
   
      
      //   if (condition==sold) return(0);
         
         condition=sold;
        return(20);                      // Открытие Sell
         
  }
  
  */
  
  
  
       if( lastTradeTime != Time[THIS_BAR] ) {
         if( bullish )
         //   if( OpenTrade(LONG, Lots, atr, 0, ORDER_COMMENT) )
         
         lastTradeTime = Time[THIS_BAR];
            return(10);                      // Открытие Buy 
               
               
         if( bearish )
          //  if( OpenTrade(SHORT, Lots, atr, 0, ORDER_COMMENT) )
               lastTradeTime = Time[THIS_BAR];  
                return(20);                      // Открытие Sell             
      }
             
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


