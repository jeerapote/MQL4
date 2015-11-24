//+------------------------------------------------------------------+
//|                                         Heiken Ashi Smoothed.mq4 |
//|                                                                  |
//|                                                      mod by Raff |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//----

//---- parameters
extern int MaMetod =2;
extern int MaPeriod=6;
extern int MaMetod2 =3;
extern int MaPeriod2=2;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators


//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   
   double maOpen, maClose, maLow, maHigh;
   double haOpen, haHigh, haLow, haClose;
   if(Bars<=10) return(0);
   
   ExtCountedBars=IndicatorCounted();
   Print(ExtCountedBars);
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
   Print("hello");
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   int pos=Bars-ExtCountedBars-1;
   Print(pos);
   while(pos>=0)
     {
       
       
       Print("h");
      maOpen=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_OPEN,pos);
      maClose=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_CLOSE,pos);
      maLow=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_LOW,pos);
      maHigh=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_HIGH,pos);
//----

      haOpen=(ExtMapBuffer5[pos+1]+ExtMapBuffer6[pos+1])/2;
      haClose=(maOpen+maHigh+maLow+maClose)/4;
      haHigh=MathMax(maHigh, MathMax(haOpen, haClose));
      haLow=MathMin(maLow, MathMin(haOpen, haClose));
      
      if (haOpen<haClose)
        {
         ExtMapBuffer7[pos]=haLow;
         ExtMapBuffer8[pos]=haHigh;
                   
          int ticket = OrderSend(Symbol(),OP_BUY,1,Ask,2,0,0,0,2000,0);

          if(ticket>0){
           //lastTradeTime = Time[THIS_BAR];
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Buy order opened : ",OrderOpenPrice());
          }
          else Print("Error opening Buy order : ",GetLastError()); 
           
          
        }
      else
        {
         ExtMapBuffer7[pos]=haHigh;
         ExtMapBuffer8[pos]=haLow;
        }
      ExtMapBuffer5[pos]=haOpen;
      ExtMapBuffer6[pos]=haClose;
      pos--;
     }
   int i;
   for(i=0; i<Bars; i++) ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer7,Bars,MaPeriod2,0,MaMetod2,i);
   for(i=0; i<Bars; i++) ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer8,Bars,MaPeriod2,0,MaMetod2,i);
   for(i=0; i<Bars; i++) ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer5,Bars,MaPeriod2,0,MaMetod2,i);
   for(i=0; i<Bars; i++) ExtMapBuffer4[i]=iMAOnArray(ExtMapBuffer6,Bars,MaPeriod2,0,MaMetod2,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+