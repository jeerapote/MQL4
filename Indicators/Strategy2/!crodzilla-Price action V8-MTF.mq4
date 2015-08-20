//------------------------------------------------------------------
#property copyright "mladen+Tomcat98+crodzilla"
#property link      "www.forexfactory.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  MediumVioletRed
#property indicator_color2  Orange
#property indicator_width1  2
#property indicator_width2  2

extern int    TimeFrame       = 0;
extern int    Use_Previous_Bars = 0;
extern int    Inhibit_Comments = 0;
extern int    linestyle       = 0;
extern int    linewidth       = 1;
extern bool   showhistory     = true;
extern color  colorhigh       = Red ;            
extern color  colorhighold    = Maroon ;        
extern color  colorlow        = LimeGreen;       
extern color  colorlowold     = DarkGreen ;    

double dotUp[];
double dotDn[];
double trend[];
int aboveprice, belowprice, lowcleared, highcleared;
int longesttoclear, avgtoclear;
int barstoclear;
int highestnumtoclear;
double deviation, maxdeviation;
double Hdeviation, Hmaxdeviation;
double CurrentMaxLDeviation, CurrentMaxHDeviation;
double DnCumulativepips,UpCumulativepips;
int chartbars;
bool same = true;

double point;
string DRAW;
//--------------------------------------------------------
//
//--------------------------------------------------------
int init()
{
   IndicatorBuffers(3);
   SetIndexBuffer(0,dotUp); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159);
   SetIndexBuffer(1,dotDn); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,trend);
   
   DRAW = "Delicate_Secret_Levels_V2-";
   aboveprice = 0;
   belowprice = 0;
   lowcleared = 0;
   highcleared = 0;
   barstoclear = 0;
   highestnumtoclear = 0;
   CurrentMaxLDeviation = 0;
   DnCumulativepips = 0;
   UpCumulativepips = 0;
   
   if(TimeFrame == 0) TimeFrame = Period();
   
   same = True;
   if(TimeFrame!=Period()) same = False;
   
   point=Point;
   if(Digits==3||Digits==5) point*=10;
   chartbars = iBars(NULL,TimeFrame);
   return(0);
}
//--------------------------------------------------------
void deinit()
{
   ObDeleteObjectsByPrefix(DRAW);
   Comment("");
   
}
//--------------------------------------------------------
//
//
//
//
//

int start()
{
 
   color k;
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
      int limit=MathMin(iBars(NULL,TimeFrame)-counted_bars,iBars(NULL,TimeFrame)-1);
      if (Use_Previous_Bars!=0 && Use_Previous_Bars < limit) {
         limit = Use_Previous_Bars;
         chartbars = limit;
         }
      
   //
   //
   //
   //
   //
   
   for (int i=limit; i>=0; i--)
   {
      dotUp[i] = EMPTY_VALUE;
      dotDn[i] = EMPTY_VALUE;
      trend[i] = trend[i+1];
         double atr    = iATR(NULL,0,20,i);
         double range0 = iHigh(NULL,TimeFrame,i)-iLow(NULL,TimeFrame,i);
         double range7 = iHigh(NULL,TimeFrame,i+7)-iLow(NULL,TimeFrame,i+7);
            if (iClose(NULL,TimeFrame,i)<iOpen(NULL,TimeFrame,i) && iOpen(NULL,TimeFrame,i)>iLow(NULL,TimeFrame,i+2) && iClose(NULL,TimeFrame,i+1) > iClose(NULL,TimeFrame,i+7) && iClose(NULL,TimeFrame,i+1) > iHigh(NULL,TimeFrame,i+4) && range0>range7 && trend[i]!= 1) {
               if(same==True) dotUp[i] = iLow(NULL,TimeFrame,i) - atr/2.0;  
               trend[i] =  1; // GREEN DOT - RETURN TO HIGH of I
               
               k = colorlow;
               for(int j=i-1;j>=1;j--) {
                  if(iHigh(NULL,TimeFrame,j)>iHigh(NULL,TimeFrame,i)) {
                     k = colorlowold;
                     if(showhistory) DrawLine(iTime(NULL,TimeFrame,i),iTime(NULL,TimeFrame,j),i,iHigh(NULL,TimeFrame,i),k);
                     break;
                     }  
                  }
                  
                  if(k==colorlow) { 
                     DrawLine(iTime(NULL,TimeFrame,i),D'01.01.2025',i,iHigh(NULL,TimeFrame,i),k);
                     aboveprice = aboveprice + 1;
                     for(j=i;j>=0;j--){
                        double CurrentHdeviation = iHigh(NULL,TimeFrame,i)-iLow(NULL,TimeFrame,j);
                        if (CurrentMaxHDeviation<CurrentHdeviation) CurrentMaxHDeviation = CurrentHdeviation;
                        }
                     }
                     
                  if (k==colorlowold) { 
                     highcleared = highcleared + 1;
                     barstoclear = barstoclear + (i-j);
                     if (highestnumtoclear < (i-j)) highestnumtoclear = (i-j);
                     double maxcum = 0;
                     for(int m=i-1; m>=j; m--) {
                        if(maxcum<(iHigh(NULL,TimeFrame,i)-iLow(NULL,TimeFrame,m))) maxcum = (iHigh(NULL,TimeFrame,i)-iLow(NULL,TimeFrame,m));
                        }
                     UpCumulativepips = UpCumulativepips + maxcum;
                     if(Hmaxdeviation<maxcum) Hmaxdeviation = maxcum;
                     }
                }
                
            if (iClose(NULL,TimeFrame,i)>iOpen(NULL,TimeFrame,i) && iOpen(NULL,TimeFrame,i)<iHigh(NULL,TimeFrame,i+2) && iClose(NULL,TimeFrame,i+1) < iClose(NULL,TimeFrame,i+7) && iClose(NULL,TimeFrame,i+1) < iLow(NULL,TimeFrame,i+4)  && range0>range7 && trend[i]!=-1) { 
               if(same==True) dotDn[i] = iHigh(NULL,TimeFrame,i) + atr/2.0; 
               trend[i] = -1; // ORANGE DOT - RETURN TO LOW
               
               k = colorhigh;
               for(j=i-1;j>=1;j--) {
                  if(iLow(NULL,TimeFrame,j)<iLow(NULL,TimeFrame,i)) {
                     k = colorhighold;
                     if(showhistory) DrawLine(iTime(NULL,TimeFrame,i),iTime(NULL,TimeFrame,j),i,iLow(NULL,TimeFrame,i),k);
                     //deviation = High[j]-Low[i];
                     //if (maxdeviation<deviation) maxdeviation = deviation;
                     break;
                     } 
                  }
                  
                  if(k==colorhigh) { 
                     DrawLine(iTime(NULL,TimeFrame,i),D'01.01.2025',i,iLow(NULL,TimeFrame,i),k);
                     belowprice = belowprice + 1;
                     for(j=i; j>=0;j--) {
                        double CurrentLdeviation = iHigh(NULL,TimeFrame,j)-iLow(NULL,TimeFrame,i);
                        if (CurrentMaxLDeviation < CurrentLdeviation) CurrentMaxLDeviation = CurrentLdeviation;
                        }
                     }
                  
                  if(k==colorhighold) {
                     lowcleared = lowcleared + 1;
                     barstoclear = barstoclear + (i-j);
                     if (highestnumtoclear < (i-j)) highestnumtoclear = (i-j);
                     maxcum = 0;
                     for(m=i-1; m>=j; m--) {
                        if(maxcum<(iHigh(NULL,TimeFrame,m)-iLow(NULL,TimeFrame,i))) maxcum = (iHigh(NULL,TimeFrame,m)-iLow(NULL,TimeFrame,i));
                        }
                     DnCumulativepips = DnCumulativepips + maxcum;
                     if(maxdeviation<maxcum) maxdeviation = maxcum;
                     }
               }
   }
   double divisor;
   if (barstoclear>0) divisor = (barstoclear/(highcleared+lowcleared));
   
   string temp10 = StringConcatenate("\n","Cumulative BEARISH signal pips: ",DoubleToString(DnCumulativepips/point,1)," pips.");
   string temp11 = StringConcatenate("\n","Cumulative BULLISH signal pips: ",DoubleToString(UpCumulativepips/point,1)," pips.");
   
   string temp = StringConcatenate("\n","\n","Levels not cleared ABOVE: ",aboveprice);
   string tempa = StringConcatenate("\n","Levels not cleared BELOW: ",belowprice);
   string temp1 = StringConcatenate("\n","\n","High levels cleared: ",highcleared,"   (Avg. ",DoubleToString((UpCumulativepips/point)/highcleared,1)," pips per level potential)");
   string temp2 = StringConcatenate("\n","\n","Low levels cleared: ",lowcleared,"   (Avg. ",DoubleToString((DnCumulativepips/point)/lowcleared,1)," pips per level potential)");
   string temp2a = temp + tempa;
   if (showhistory) temp2a = temp + tempa + temp1 + temp11 + temp2 + temp10;
   
   string temp3 = StringConcatenate("\n","\n","Avg bars to clear: ",DoubleToString(divisor,1));
   string temp4 = StringConcatenate("\n","Highest # bars to clear: ",highestnumtoclear);
   string temp5 = StringConcatenate("\n","\n","Largest cleared BULLISH deviation in price: ",DoubleToStr(maxdeviation/point,1)," pips.");
   string temp6 = StringConcatenate("\n","Largest cleared BEARISH deviation in price: ",DoubleToStr(Hmaxdeviation/point,1)," pips.");
   string temp7 = StringConcatenate("\n","This chart # of bars: ",chartbars);
   string temp8 = StringConcatenate("\n","Largest Open BEARISH deviation: ",DoubleToString(CurrentMaxHDeviation/point,1)," pips.");
   string temp9 = StringConcatenate("\n","\n","Largest Open BULLISH deviation: ",DoubleToString(CurrentMaxLDeviation/point,1)," pips.");
   
   if(Inhibit_Comments==0) Comment(temp7+temp2a+temp3+temp4+temp5+temp6+temp9+temp8);
   
   return(0);
}  
//+------------------------------------------------------------------+
void ObDeleteObjectsByPrefix(string Prefix)
{ 
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
   {
      string ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix)
      { 
         i++; 
         continue;
      }
      ObjectDelete(ObjName);
   } 
 }
//+------------------------------------------------------------------+
void DrawLine(datetime t1, datetime t2,int i, double p, color k)
{
   string s =StringConcatenate(DRAW,TimeFrame,"-",TimeToString(t1,TIME_DATE|TIME_MINUTES));
   ObjectCreate(s,OBJ_TREND,0,0,0,0);
   ObjectSet(s,OBJPROP_COLOR,k);
   ObjectSet(s,OBJPROP_TIME1,t1);
   ObjectSet(s,OBJPROP_TIME2,t2);
   ObjectSet(s,OBJPROP_PRICE1,p);
   ObjectSet(s,OBJPROP_PRICE2,p);
   ObjectSet(s,OBJPROP_RAY,false);
   ObjectSet(s,OBJPROP_STYLE,linestyle);
   ObjectSet(s,OBJPROP_WIDTH,linewidth);
}

//+--------------------------END----------------------------------------+
