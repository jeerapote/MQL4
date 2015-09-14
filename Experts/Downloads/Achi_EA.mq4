//+------------------------------------------------------------------+
//|                                            Ashi_EA.mq4    |
//|                                          
//|                                            By Murat Aka   |
//+------------------------------------------------------------------+

extern int    MagicNumber = 2011;

extern double TakeProfit              = 100000;
extern double Lots                    = 0.25;
           
extern bool   EachTickMode            = True;

extern int StopLoss = 10000;

extern int ProfitMargin = 100;

extern int LossMargin = 200;






//=================================Initialization=======================================//
           
bool newbuy=true;
bool newsell=false;           

int digit=0;

int BarCount;

int Current;
bool TickCheck = False;

double   mPoint                     = 0.0001;

int ticket2;

int init() {
   BarCount = Bars;

   if (EachTickMode) Current = -1; //else Current = -1;
   
   mPoint = Point*10;

   return(0);
}

int deinit() {
   return(0);
}

//===================================Broker Recognition=================================//


//=====================================Trade Session=====================================//



//======================================Time Control=====================================//


//====================================EA Start Function==================================//

datetime newbar;

int start()
  {

   int cnt, ticket, total;
   
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);  
     }
     
   if(TakeProfit<4)
     {
      Print("TakeProfit less than 4");
      return(0); 
     }
     
//========================================Variables=======================================//

double HAOpen3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 2, Current + 1);
double HAClose3 = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", 2, 4, 2, 1, 3, Current + 1);

//====================================Begin Placing Orders================================//


  
   total=OrdersTotal(); 

   if(total<1) 
     {
  
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }
      // check for long position (BUY) possibility
      if(( HAOpen3 < HAClose3 )&& (newbuy) )
        {
        
         newbuy=false;
         newsell=true;
        
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-(StopLoss*mPoint/10),Ask+TakeProfit*mPoint/10,"LoneWolf",MagicNumber+1,0,Blue);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderType()==OP_SELL) // go to short position
            {
            // should it be closed?
                  
                   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position

            }
      
        }
      // check for short position (SELL) possibility
      if(( HAOpen3 > HAClose3 && (newsell)) )
        {
        
        newsell = false;
        newbuy = true;
        
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+(StopLoss*mPoint/10),Bid-TakeProfit*mPoint/10,"LoneWolf",MagicNumber+2,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError()); 
         
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
           
                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
           }
         

        }

     
    }

  
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
 
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            if (HAOpen3 > HAClose3)
                {

                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
                 //return(0); // exit
                 
                }
			   }
       
         if(OrderType()==OP_SELL) // go to short position
           {
            // should it be closed?
              if (HAOpen3 < HAClose3)//
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
             
              }
            }
   }
   return(0);
  }
  
//========================================Broker Digit Conversion=============================//


  
  
double GetPoint(string symbol = "") //5 digit broker conversion ---  Copyright "Coders Guru" 
{
   if(symbol=="" || symbol == Symbol())
   {
      if(Point==0.00001) return(0.0001);
      else if(Point==0.001) return(0.01);
      else return(Point);
   }
   else
   {
      RefreshRates();
      double tPoint = MarketInfo(symbol,MODE_POINT);
      if(tPoint==0.00001) return(0.0001);
      else if(tPoint==0.001) return(0.01);
      else return(tPoint);
   }
}

//===================================== CHECK PROFIT ==================================//

int checkProfit()
{

   if(OrdersTotal() < 2 )
   {

       int pos = OrdersTotal()-1;
   
         if(OrderSelect(pos, SELECT_BY_POS)==true)
         {
   
            // MoveStopToBreakeven();
   
            if(OrderProfit()>=ProfitMargin )
            {

              int order_type=OrderType();     
       
              if(order_type==OP_BUY)
               {
              
                  if(iVolume(NULL,0,0)==1);
                  
                  ticket2 = OrderSend(Symbol(), OP_BUY, 2*Lots, Ask , 0, Ask-LossMargin*Point, 0);
               }
               
              else 
               {
                  if(iVolume(NULL,0,0)==1);                        
    
                  ticket2 = OrderSend(Symbol(), OP_SELL, 2*Lots, Bid, 0, Bid+LossMargin*Point, 0);
                  
               }
         
            }
            
        }
    } 
    
    return(0);
}  