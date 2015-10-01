//+------------------------------------------------------------------+
//|                                    OBV, TVI, Price_Div_EA_V3.mq4 |
//|                                                        version 3 |
//|                                                     by Murat aka.|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+



extern double  Lots                    = 0.5;
extern double  TakeProfit              = 100;
extern double  StopLoss                = 300;
extern bool    RiskManagamentOn        = true;



int OnInit()
  {
//---
   InitialBalance = AccountBalance();
   
   InitialLots = Lots;
   
   if(RiskManagamentOn)InitialLots = InitialBalance/100000;
//---
   return(INIT_SUCCEEDED);
  }
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
    

//-------------------------------------------------------------------- 2 --



   int xaZZBuy_indicator=1;
   int xaZZSell_indicator=0;
   
   double   OBV, TVI, dHigh, dHighLeft, dHighMiddle, dHighRight, 
            dMax1=0, dTVImax1=0, dOBVmax1=0,
            dStopLoss, dTakeProfit, dLots=0.01;
            
            
   int         iTicket;
   
   int         order;
   int         shift;
   int         iMax1_Bar, iMax2_Bar;
   
   
   bool closed;
   int count = 0;
   int count2 = 1;
   bool zero = false;
   
double         InitialBalance;    

double         Balance;      

double         InitialLots, LotsFactor;
   
   double  TVI_Last, TVI_Now;
   double  OBV_Last, OBV_Now;
   double  TVI_Max1, TVI_Max2=0;
   double  OBV_Max1, OBV_Max2=0;
   double  Price_Max1, Price_Max2=0;
   double  dStop, dProfit;
   double  Spread;
   
   
   datetime       lastTradeTime;
   datetime       Max1_Time, Max2_Time;

   #define        THIS_BAR 0

//--------------------------------------------------------------- 4 --
      double xazz_Sell_signal_Last = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 1); //
      double xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 1); //
      double xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, 0); //
      double xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, 0); //
//--------------------------------------------------------------- 5 --
   int ExtDepth=12;
   int ExtDeviation=5;
   int ExtBackstep=3;

//--------------------------------------------------------------- 3 --
int start()                      
  {

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

   dStop = p3;
   dProfit =p2;
   
   Spread = MarketInfo(Symbol(),MODE_SPREAD);
   
   Balance = AccountBalance();
   
   LotsFactor = Balance/InitialBalance;
   
   Lots = InitialLots * LotsFactor; 
   
   Lots = Lot(Lots);

   TVI_Last = iCustom(NULL,0,"TVI_v2",5,5,5, 4, bar); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
   TVI_Now = iCustom(NULL,0,"TVI_v2",5,5,5, 4, 1); //1 = upNEG, 0 = upPOS, 2 = downPOS  3= downNEG
     
   xazz_Buy_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar); //
   xazz_Sell_signal_Last  = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar); //
   
   OBV_Last = iCustom(NULL,0,"Gadi_OBV_v2.2 for EA", 0, bar);
   OBV_Now = iCustom(NULL,0,"Gadi_OBV_v2.2 for EA", 0, 0);
   
   xazz_Sell_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZSell_indicator, bar4); //
   xazz_Buy_signal_Now = iCustom(NULL,0,"Strategy2/xaZZ", xaZZBuy_indicator, bar4); //
  
 

//----------------------------------------------------------------------------
//---------------------------------------------------------------------------

  
   if(TVI_Now != 2147483647 && TVI_Now > 0 && TVI_Now > TVI_Max2 ){
     
      
      TVI_Max2 = TVI_Now;
      Max2_Time = iTime("EURUSD",PERIOD_M1,1);

      OBV_Max2 = OBV_Now;
      zero = true;
     
    
   }
   
   
   if(TVI_Now < -0.1 && zero == true ){
   
    if(count == 1){
    
     Print(count," ",Hour()," ",Minute());
     Max1_Time = Max2_Time;
     TVI_Max1 = TVI_Max2;     
      
    }
         
    if(count == 2){
    
     Print(count," ",Hour()," ",Minute()); 
     iMax1_Bar = iBarShift("EURUSD",PERIOD_M1,Max1_Time);
    
     iMax2_Bar = iBarShift("EURUSD",PERIOD_M1,Max2_Time);  
     
     Price_Max1 = High[iMax1_Bar];
     Price_Max2 = High[iMax2_Bar];
      
     dStopLoss = Bid-30*Point;
     dTakeProfit = Bid+30*Point;
     
     Trader();
     //DrawLine(IntegerToString(count2),iMax1_Bar,iMax2_Bar);
     count = 0;    
     count2++;
    }
    
     
    
     TVI_Max2 = 0;
     OBV_Max2 = 0;
     Price_Max2 = 0;
    
     count = count + 1;
    
     zero = false;  
     
    
   }
   
   
//----------------------------------------------------------------------------- 5 --
    
        Comment("GRID BarPriceAction ver 3.0\n",
            "FX Acc Server:",AccountServer(),"\n",
            "Date: ",Month(),"-",Day(),"-",Year()," Server Time: ",Hour(),":",Minute(),":",Seconds(),"\n",
            "Minimum Lot Sizing: ",MarketInfo(Symbol(),MODE_MINLOT),"\n",
            "Account Balance:  $",AccountBalance(),"\n",
            "FreeMargin: $",AccountFreeMargin(),"\n",
            "Total Orders Open: ",OrdersTotal(),"\n",
            "Total Orders History: ",OrdersHistoryTotal(),"\n",            
            "Symbol: ", Symbol(),"\n",
            "Price:  ",NormalizeDouble(Bid,4),"\n",
            "Pip Spread:  ",MarketInfo(Symbol(),MODE_SPREAD),"\n",
            "Lots:  ",Lots,"\n",
            "Leverage: ",AccountLeverage(),"\n",
            "Effective Leverage: ",AccountMargin()*AccountLeverage()/AccountEquity(),"\n",
            "Point: ", Digits,"\n",
            "Freezelevel: ",MarketInfo(Symbol(),MODE_FREEZELEVEL),"\n");
   
//====================================================================
//--------------------------------------------------------------- 6 --
   return(0);                          
  }
  
 
//--------------------------------------------------------------- 7 -------------------------------------------+

void Trader(){


   bool HigherHigh = TVI_Max2 < TVI_Max1 && Price_Max1 < Price_Max2 /*&& OBV_Max2 < OBV_Max1*/ ;

   if(HigherHigh && lastTradeTime != Time[THIS_BAR] /*&& OrdersTotal() < 1*/){
  
    lastTradeTime = Time[THIS_BAR];
    Sell();
    
   }


}
//=================================================================================//
//===================================== Draw  ==================================//
//=================================================================================//

void DrawLine(string name, int bar, int bar4){

   ObjectCreate("ObjName: "+name, OBJ_TREND, 0, Time[bar], High[bar], Time[bar4], High[bar4] ); 
   ObjectSet("ObjName: "+name, OBJPROP_WIDTH, 2);
   ObjectSet("ObjName: "+name,OBJPROP_RAY,false);
   ObjectSet("ObjName: "+name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("ObjName: "+name,OBJPROP_COLOR,Red);
   
}


//=================================================================================//
//===================================== void buy ==================================//
//=================================================================================//


void Buy(){

   dStopLoss = NormalizeDouble(xazz_Buy_signal_Last-30*Point,Digits);
   dTakeProfit = NormalizeDouble(xazz_Sell_signal_Last+30*Point,Digits);
   
     dStopLoss = NormalizeDouble(Bid-30*Point,Digits);
     dTakeProfit = NormalizeDouble(Bid+30*Point,Digits);
     
   RefreshRates();
         
   iTicket=OrderSend(Symbol(),OP_BUY,dLots,Ask,3,(dStopLoss),(dTakeProfit),"OBV,TVI",0,Red);
   
   if(iTicket>0){
        
      if(OrderSelect(iTicket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
   }
   else Print("Error opening BUY order : ",GetLastError());
   
}


//==================================================================================//
//===================================== Void Sell ==================================//
//==================================================================================//

void Sell(){


   dStopLoss = NormalizeDouble(dStop+Spread*Point,Digits);
   dTakeProfit = NormalizeDouble(dProfit-Spread*Point,Digits);
   
   if(dStopLoss < Ask)dStopLoss = NormalizeDouble(Ask+50*Point,Digits);
   if(dTakeProfit > Ask)dTakeProfit = NormalizeDouble(Ask-75*Point,Digits);
      
   

   iTicket=OrderSend(Symbol(),OP_SELL,dLots,Bid,3,(dStopLoss),dTakeProfit,"OBV,TVI",0,Red);
   if(iTicket>0){
      DrawLine(IntegerToString(iTicket),iMax1_Bar,iMax2_Bar);
      if(OrderSelect(iTicket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
   }
   else Print("Error opening SELL order : ",GetLastError());
   
}


//=================================================================================//
//===================================== Lot Size ==================================//
//=================================================================================//


double Lot(double dLots)                                     // User-defined function
  {
  
 
   double Lots_New;
   string Symb   =Symbol();                    // Symbol
   double One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);//!-lot cost
   double Min_Lot=MarketInfo(Symb,MODE_MINLOT);// Min. amount of lots
   double Step   =MarketInfo(Symb,MODE_LOTSTEP);//Step in volume changing
   double Free   =AccountFreeMargin()*0.9;         // Free margin
//----------------------------------------------------------------------------- 3 --
   if (dLots>0)                                 // Volume is explicitly set..
     {                                         // ..check it
      double Money=dLots*One_Lot;               // Order cost
      if(Money<=AccountFreeMargin()*0.9)           // Free margin covers it..
         Lots_New=dLots;                        // ..accept the set one
      else                                     // If free margin is not enough..
         Lots_New=MathFloor(Free/One_Lot/Step)*Step;// Calculate lots
     }
//----------------------------------------------------------------------------- 4 --

    
//----------------------------------------------------------------------------- 5 --
   if (Lots_New < Min_Lot)                     // If it is less than allowed..
      Lots_New=Min_Lot;                        // .. then minimum
   
   return Lots_New;                               // Exit user-defined function
  }

