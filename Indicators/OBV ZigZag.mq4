//+------------------------------------------------------------------+
//|                                                   OBV ZigZag.mq4 |
//|                 Copyright © 2005-2007, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Gold
#property indicator_width1 2
#property indicator_width2 2

extern int OBVPrice=0; 
extern int ExtDepth=12;
extern double ExtDeviation=1;
extern int ExtBackstep=3;
//---- indicator buffers
double ZigzagBuffer[];
double obv[];
double HighMapBuffer[];
double LowMapBuffer[];
int level=3; // recounting's depth 
bool downloadhistory=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
//---- drawing settings
   SetIndexStyle(1,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,obv);
   SetIndexBuffer(1,ZigzagBuffer);
   SetIndexBuffer(2,HighMapBuffer);
   SetIndexBuffer(3,LowMapBuffer);
   SetIndexEmptyValue(1,0.0);

//---- indicator short name
   IndicatorShortName("OBV ZigZag ("+ExtDepth+","+DoubleToStr(ExtDeviation,1)+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   int limit,counterZ,whatlookfor;
   int shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   if (counted_bars==0 && downloadhistory) // history was downloaded
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
     }
   if (counted_bars==0) 
     {
      limit=Bars-ExtDepth;
      downloadhistory=true;
     }
   if (counted_bars>0) 
     {
      while (counterZ<level && i<100)
        {
         res=ZigzagBuffer[i];
         if (res!=0) counterZ++;
         i++;
        }
      i--;
      limit=i;
      if (LowMapBuffer[i]!=0) 
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      for (i=limit-1;i>=0;i--)  
        {
         ZigzagBuffer[i]=0.0;  
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
      
   for(shift=limit; shift>=0; shift--)
     {
      obv[shift] = iOBV(Symbol(),0,OBVPrice,shift);
      val=obv[ArrayMinimum(obv,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((obv[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[shift+back];
               if((res!=0)&&(res>val)) LowMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      if (obv[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=obv[ArrayMaximum(obv,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-obv[shift])>(ExtDeviation*Point)) val=0.0;
         
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[shift+back];
               if((res!=0)&&(res<val)) HighMapBuffer[shift+back]=0.0; 
              } 
           }
        }
      if (obv[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

   // final cutting 
   if (whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for (shift=limit;shift>=0;shift--)
     {
      res=0.0;
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if (lastlow==0 && lasthigh==0)
              {
               if (HighMapBuffer[shift]!=0)
                 {
                  lasthigh=obv[shift];
                  lasthighpos=shift;
                  whatlookfor=-1;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                 }
               if (LowMapBuffer[shift]!=0)
                 {
                  lastlow=obv[shift];
                  lastlowpos=shift;
                  whatlookfor=1;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                 }
              }
             break;  
         case 1: // look for peak
            if (LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if (HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=-1;
               res=1;
              }   
            break;               
         case -1: // look for lawn
            if (HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if (LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=1;
              }   
            break;               
         default: return; 
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+