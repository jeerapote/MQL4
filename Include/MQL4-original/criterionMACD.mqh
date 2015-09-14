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



//--------------------------------------------------------------- 3 --
int Criterion()                      
  {
   string Sym="EURUSD";
   if (Sym!=Symbol())                 
     {
      Inform(16);                      
      return(-1);                     
     }
     




//--------------------------------------------------------------- 4 --

 
 
//--------------------------------------------------------------- 5 --



             
//--------------------------------------------------------------- 6 --
   return(0);                         
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


