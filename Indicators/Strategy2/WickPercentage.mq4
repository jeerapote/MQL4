//+------------------------------------------------------------------+
//|                                               WickPercentage.mq4 |
//|                                                              cja |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 RoyalBlue
#property indicator_width1 2
#property indicator_width2 2

extern double percentage = 10;

double buffer1[];
double buffer2[];


double myPoint;
   double SetPoint() 
   { double mPoint; 
   if (Digits < 4) 
   mPoint = 0.01; 
   else
   mPoint = 0.0001; 
   return(mPoint); 
   } 

int init() {
   myPoint = SetPoint();
   IndicatorBuffers(2);
   
   SetIndexBuffer(0, buffer1);     
   SetIndexStyle(0, DRAW_HISTOGRAM);
   
   SetIndexBuffer(1, buffer2);     
   SetIndexStyle(1, DRAW_HISTOGRAM);
   
   IndicatorShortName("WickPercentage");
   
         
   return(0);
}
  
int deinit() { return(0);}
     
int start() {
    
   int counted_bars=IndicatorCounted();
  
   if(counted_bars < 0) 
       return(-1);
   if(counted_bars > 0) 
       counted_bars--;
       
   int limit = Bars - counted_bars;     
      
   for(int i = limit; i >= 0; i--) {

      int shift = iBarShift(Symbol(), 0, Time[i], true);     
          
      buffer2[i] = 0;
      buffer1[i] = 0;      
          
      double close = iClose(Symbol(),0,shift);
      double open  = iOpen(Symbol(),0,shift);
      double high  = iHigh(Symbol(),0,shift);
      double low   = iLow(Symbol(),0,shift);
 
      double bodysize = MathAbs(open-close)/myPoint; 
      double percent = (bodysize/100)*percentage;
            
      if(open>close && ((high-open)/myPoint < percent) && ((close-low)/myPoint < percent) ){  
         buffer2[i] = close;      
         buffer1[i] = open;  
      }
      if(open<close && ((high-close)/myPoint < percent) && ((open-low)/myPoint < percent) ){  
        
         buffer2[i] = close;
         buffer1[i] = open;      
           
      }
    } 
   return(0);
 }

