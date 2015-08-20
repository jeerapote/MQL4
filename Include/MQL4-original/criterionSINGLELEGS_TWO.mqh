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
   
#define THIS_BAR 0

   extern double  Tolerance = 0.0010;
  
   datetime lastTradeTime;
  
    double   Percent1 = 0.236;
    double   Percent2 = 0.5;
    double   Percent3 = 0.51;
    double   Percent4 = -2;
    double   Percent5 = -1;
    
    
    double fib0;
    double fib100;
    double fib236;
    double fib50;
    double fib51;
    double fib200;
      
    double Lot = 0.1;
    double Price ;
    double SL ;
    double TP ;
      
      
   bool setup_complete= false;
   bool order_complete= false;

  
   
   int ticket;
   

   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   
   


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

   
   
   xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar); //
   xazz_Sell_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar); //
   
   xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar4); //
   xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar4); //
   
  // Comment( "p2: ",p2, " ", xazz_Buy_signal_Last, " ", xazz_Buy_signal_Now," ", xazz_Sell_signal_Last," ",xazz_Sell_signal_Now);

   ///------------Condition 1, buy----------------
      
  
   double zigzag_length = NormalizeDouble(p3-xazz_Buy_signal_Now,Digits);
   double tolerance = zigzag_length/5;
   bool first_condition = (p3>p2 && (Bid-Tolerance) >  xazz_Buy_signal_Now );
 //  bool first_condition = (p3>p2 && (Bid-Tolerance) >  xazz_Buy_signal_Now );
  //if(first_condition == true) Print(first_condition);
  
   if(first_condition && !setup_complete && !order_complete)  
    {
                
     /* 
       fib0 = p3;
       fib100 = xazz_Buy_signal_Now;
       fib236 = NormalizeDouble(xazz_Buy_signal_Now+(p3-xazz_Buy_signal_Now)*Percent1,Digits);
       fib50 = NormalizeDouble(xazz_Buy_signal_Now+(p3-xazz_Buy_signal_Now)*Percent2,Digits);
       fib51 = NormalizeDouble(xazz_Buy_signal_Now+(p3-xazz_Buy_signal_Now)*Percent3,Digits);
       fib200 = NormalizeDouble(xazz_Buy_signal_Now+(p3-xazz_Buy_signal_Now)*Percent4,Digits);
      */
      
       fib0 = Bid;
       fib100 = xazz_Buy_signal_Now;
       fib236 = NormalizeDouble(Bid-(Bid-xazz_Buy_signal_Now)*Percent1,Digits);
       fib50 = NormalizeDouble(Bid-(Bid-xazz_Buy_signal_Now)*Percent2,Digits);
       fib51 = NormalizeDouble(Bid-(Bid-xazz_Buy_signal_Now)*Percent3,Digits);
       fib200 = NormalizeDouble(Bid-(Bid-xazz_Buy_signal_Now)*Percent4,Digits);
      
       
       Lot = 0.1;
       Price = fib0;
       SL = fib51;
       TP = p3;
       
      setup_complete=true;
    
                
    }
    
   if(Bid < fib236 && !order_complete && setup_complete && OrdersTotal()< 1 && lastTradeTime != Time[THIS_BAR])
    { 
      // Print(first_condition);
      ticket = OrderSend(Sym, OP_BUYSTOP, Lot, Price, 0, SL, TP);
      order_complete= true;
      setup_complete=false;
      lastTradeTime = Time[THIS_BAR]; 
      
         
    }
     
   if(Bid < fib50 && OrdersTotal()>=1)
    {
    
      bool Ans=OrderDelete(ticket);
      order_complete=false;
      setup_complete=false;
    
      
    }
   
 /*  if(OrdersTotal() < 1 && lastTradeTime != Time[THIS_BAR])
    {
      order_complete=false;
    //  setup_complete=false;
      lastTradeTime = Time[THIS_BAR];
    } 
    */
    
    if(OrdersTotal() < 1 )
    {
      order_complete=false;
     // setup_complete=false;  
     
    } 

//--------------------------------------------------------------- 6 --
   return(0);                          // Выход из пользов. функции
   
   
  }
  
  
  
  
