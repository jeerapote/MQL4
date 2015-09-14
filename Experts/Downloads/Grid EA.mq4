
#property copyright "Copyright © 2008, Patrick Doucette"
#property link      "http://www.stochmonster.com"
#property show_inputs

extern int uniqueGridMagic = 550000;
extern double Lots = 0.01;
extern double GridSize = 6.0;
extern double GridSteps = 10.0;
extern double TakeProfit = 10.0;
extern double StopLoss = 0.0;
extern int trailStop = 0;
extern double UpdateInterval = 1.0;
extern bool wantLongs = TRUE;
extern bool wantShorts = TRUE;
extern bool wantBreakout = TRUE;
extern bool wantCounter = TRUE;
extern bool limitEMA = TRUE;
extern int EMAperiod = 30;
extern double GridMaxOpen = 50.0;
extern bool UseMACD = TRUE;
extern bool UseOsMA = FALSE;
extern bool CloseOpenPositions = FALSE;
extern bool doHouseKeeping = TRUE;
extern double keepOpenTimeLimit = 0.0;
extern int emaFast = 12;
extern int emaSlow = 26;
extern int signalPeriod = 9;
extern int timeFrame = 0;
extern int minFromPrice = 0;
extern int tradeForMinutes = 0;
extern int gridOffset = 0;
extern double longGridCenter = 0.0;
extern double shortGridCenter = 0.0;
extern double longGridLow = 0.0;
extern double longGridHigh = 0.0;
extern double shortGridLow = 0.0;
extern double shortGridHigh = 0.0;
extern double profitTarget = 15000.0;
extern bool suspendGrid = FALSE;
extern bool shutdownGrid = FALSE;
string gs_grid_280 = "Grid";
double g_datetime_288 = 0.0;
double gd_unused_296 = 0.0;
double gd_304 = 0.0;
double gd_312 = 0.0;
double gd_320 = 0.0;
bool gi_328 = FALSE;
int g_count_332 = 0;
int g_count_336 = 0;
bool gi_340 = TRUE;
bool gi_344 = FALSE;

int init() {
   string ls_0 = "2010.10.12";
   int l_str2time_8 = StrToTime(ls_0);
   if (TimeCurrent() >= l_str2time_8) {
      Alert("The trial version has been expired!");
      return (0);
   }
   gs_grid_280 = StringConcatenate("Grid-", Symbol(), "-", uniqueGridMagic);
   return (0);
}

int IsPosition(double ad_0, double ad_8, int ai_16) {
   int l_cmd_20;
   int l_ord_total_24 = OrdersTotal();
   for (int l_pos_28 = 0; l_pos_28 < l_ord_total_24; l_pos_28++) {
      OrderSelect(l_pos_28, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
         l_cmd_20 = OrderType();
         if (MathAbs(OrderOpenPrice() - ad_0) < 0.9 * ad_8)
            if ((ai_16 && l_cmd_20 == OP_BUY || l_cmd_20 == OP_BUYLIMIT || l_cmd_20 == OP_BUYSTOP) || (!ai_16 && l_cmd_20 == OP_SELL || l_cmd_20 == OP_SELLLIMIT || l_cmd_20 == OP_SELLSTOP)) return (1);
      }
   }
   return (0);
}

void DeleteAfter(double ad_0) {
   int li_unused_8;
   int l_ord_total_12 = OrdersTotal();
   for (int l_pos_16 = l_ord_total_12 - 1; l_pos_16 >= 0; l_pos_16--) OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
      if (MathAbs(iTime(Symbol(), PERIOD_M5, 0) - OrderOpenTime()) >= 60.0 * (60.0 * ad_0) && iTime(Symbol(), PERIOD_M5, 0) > 0) {
         li_unused_8 = 0;
         if (OrderType() == OP_BUY) li_unused_8 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL) li_unused_8 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         if (OrderType() > OP_SELL) li_unused_8 = OrderDelete(OrderTicket());
      }
   }
}

void CloseAllPendingOrders() {
   int li_unused_0;
   int l_ord_total_4 = OrdersTotal();
   for (int l_pos_8 = l_ord_total_4 - 1; l_pos_8 >= 0; l_pos_8--) {
      OrderSelect(l_pos_8, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280)
         if (OrderType() > OP_SELL) li_unused_0 = OrderDelete(OrderTicket());
   }
}

void ClosePendingOrdersAndPositions() {
   int li_unused_0;
   int l_ord_total_4 = OrdersTotal();
   for (int l_pos_8 = l_ord_total_4 - 1; l_pos_8 >= 0; l_pos_8--) {
      OrderSelect(l_pos_8, SELECT_BY_POS);
      li_unused_0 = 0;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
         if (OrderType() == OP_BUY) li_unused_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL) li_unused_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         if (OrderType() > OP_SELL) li_unused_0 = OrderDelete(OrderTicket());
      }
   }
}

void CloseOrdersfromEMA(double ad_0) {
   int l_cmd_8;
   int li_unused_12;
   int l_ord_total_16 = OrdersTotal();
   for (int l_pos_20 = l_ord_total_16 - 1; l_pos_20 >= 0; l_pos_20--) {
      OrderSelect(l_pos_20, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
         l_cmd_8 = OrderType();
         li_unused_12 = 0;
         if (l_cmd_8 == OP_BUYLIMIT && OrderOpenPrice() <= ad_0) li_unused_12 = OrderDelete(OrderTicket());
         if (l_cmd_8 == OP_BUYSTOP && OrderOpenPrice() <= ad_0) li_unused_12 = OrderDelete(OrderTicket());
         if (l_cmd_8 == OP_SELLLIMIT && OrderOpenPrice() >= ad_0) li_unused_12 = OrderDelete(OrderTicket());
         if (l_cmd_8 == OP_SELLSTOP && OrderOpenPrice() >= ad_0) li_unused_12 = OrderDelete(OrderTicket());
      }
   }
}

int openPositions() {
   int l_cmd_0;
   int l_count_4 = 0;
   int l_ord_total_8 = OrdersTotal();
   for (int l_pos_12 = l_ord_total_8 - 1; l_pos_12 >= 0; l_pos_12--) {
      OrderSelect(l_pos_12, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
         l_cmd_0 = OrderType();
         if (l_cmd_0 == OP_BUY) l_count_4++;
         if (l_cmd_0 == OP_SELL) l_count_4++;
      }
   }
   return (l_count_4);
}

void TestForProfit(int a_magic_0, double ad_4, int ai_12, int ai_16) {
   int li_20;
   int l_cmd_24;
   if (ad_4 > 0.0) {
      gd_304 = 0;
      if (ai_16 == 1) {
         li_20 = OrdersHistoryTotal();
         for (int l_pos_28 = 0; l_pos_28 < li_20; l_pos_28++) {
            OrderSelect(l_pos_28, SELECT_BY_POS, MODE_HISTORY);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == a_magic_0) gd_304 += OrderProfit();
         }
      } else gd_320 = 0;
      gd_312 = 0;
      if (ai_12 == 1) {
         li_20 = OrdersTotal();
         g_count_332 = 0;
         g_count_336 = 0;
         for (l_pos_28 = 0; l_pos_28 < li_20; l_pos_28++) {
            OrderSelect(l_pos_28, SELECT_BY_POS);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == a_magic_0) {
               gd_312 += OrderProfit();
               l_cmd_24 = OrderType();
               if (l_cmd_24 == OP_BUY) g_count_332++;
               if (l_cmd_24 == OP_SELL) g_count_336++;
            }
         }
      }
      if (gd_304 + gd_312 >= ad_4 + gd_320) {
         Print("Closing grid due to profit target");
         ClosePendingOrdersAndPositions();
         gd_320 = gd_320 + gd_304 + gd_312;
         gi_328 = TRUE;
         if (gi_344 == TRUE) gi_340 = FALSE;
      }
   }
}

void TrailIt(int ai_0) {
   if (ai_0 >= 5) {
      for (int l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
         OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == uniqueGridMagic || OrderComment() == gs_grid_280) {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > ai_0 * MarketInfo(OrderSymbol(), MODE_POINT))
                  if (OrderStopLoss() < Bid - ai_0 * MarketInfo(OrderSymbol(), MODE_POINT)) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - ai_0 * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), 255);
            } else {
               if (OrderType() == OP_SELL) {
                  if (OrderOpenPrice() - Ask > ai_0 * MarketInfo(OrderSymbol(), MODE_POINT))
                     if (OrderStopLoss() > Ask + ai_0 * MarketInfo(OrderSymbol(), MODE_POINT) || OrderStopLoss() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + ai_0 * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), 255);
               }
            }
         }
      }
   }
}

int start() {
   int li_0;
   int li_unused_4;
   int l_cmd_8;
   bool li_12;
   double l_point_16;
   double ld_24;
   double l_price_32;
   double ld_40;
   double l_ima_48;
   int li_56;
   double ld_60;
   double ld_68;
   double ld_76;
   int li_84;
   double l_price_88;
   if (TakeProfit <= 0.0) TakeProfit = GridSize;
   bool l_bool_96 = wantLongs;
   bool l_bool_100 = wantShorts;
   if (suspendGrid == TRUE) CloseAllPendingOrders();
   if (shutdownGrid == TRUE) {
      ClosePendingOrdersAndPositions();
      return (0);
   }
   if (gi_328 == TRUE) {
      ClosePendingOrdersAndPositions();
      if (gi_344 == TRUE) gi_340 = FALSE;
   }
   if (gi_340 == FALSE) return (0);
   if (MathAbs(TimeCurrent() - g_datetime_288) > 60.0 * UpdateInterval) {
      if (profitTarget > 0.0) TestForProfit(uniqueGridMagic, profitTarget, 1, 0);
      g_datetime_288 = TimeCurrent();
      l_point_16 = MarketInfo(Symbol(), MODE_POINT);
      ld_24 = (Ask + l_point_16 * GridSize / 2.0) / l_point_16 / GridSize;
      li_0 = ld_24;
      li_0 = li_0 * GridSize;
      ld_24 = li_0 * l_point_16 - GridSize * GridSteps / 2.0 * l_point_16;
      l_ima_48 = iMA(NULL, 0, EMAperiod, 0, MODE_EMA, PRICE_CLOSE, 0);
      li_56 = 0;
      if (GridMaxOpen > 0.0) {
         li_56 = openPositions();
         if (li_56 >= GridMaxOpen) CloseAllPendingOrders();
      }
      if (limitEMA)
         if (doHouseKeeping) CloseOrdersfromEMA(l_ima_48);
      if (keepOpenTimeLimit > 0.0) DeleteAfter(keepOpenTimeLimit);
      if (trailStop > 0) TrailIt(trailStop);
      if (UseMACD || UseOsMA) {
         if (UseMACD) {
            ld_60 = iMACD(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, MODE_MAIN, 0);
            ld_68 = iMACD(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, MODE_MAIN, 1);
            ld_76 = iMACD(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, MODE_MAIN, 2);
         }
         if (UseOsMA) {
            ld_60 = iOsMA(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, 0);
            ld_68 = iOsMA(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, 1);
            ld_76 = iOsMA(NULL, timeFrame, emaFast, emaSlow, signalPeriod, PRICE_CLOSE, 2);
         }
         if (ld_60 > 0.0 && ld_68 > 0.0 && ld_76 < 0.0) {
            CloseAllPendingOrders();
            if (CloseOpenPositions == TRUE) ClosePendingOrdersAndPositions();
         }
         if (ld_60 < 0.0 && ld_68 < 0.0 && ld_76 > 0.0) {
            CloseAllPendingOrders();
            if (CloseOpenPositions == TRUE) ClosePendingOrdersAndPositions();
         }
         l_bool_96 = FALSE;
         l_bool_100 = FALSE;
         if (ld_60 > 0.0 && ld_68 > 0.0 && ld_76 > 0.0 && wantLongs == TRUE) l_bool_96 = TRUE;
         if (ld_60 < 0.0 && ld_68 < 0.0 && ld_76 < 0.0 && wantShorts == TRUE) l_bool_100 = TRUE;
      }
      li_84 = GridSteps;
      if (GridMaxOpen > 0.0 && li_56 >= GridMaxOpen) li_84 = 0;
      if (suspendGrid == TRUE) return (0);
      Print("Trigs ", ld_60, "  ", ld_68, "  ", ld_76, "  ", l_bool_96, "  ", l_bool_100, "  ", li_84, " ema ", l_ima_48, " price ", Bid);
      for (int l_count_104 = 0; l_count_104 < li_84; l_count_104++) {
         ld_24 = (Ask + l_point_16 * GridSize / 2.0) / l_point_16 / GridSize;
         li_0 = ld_24;
         li_0 = li_0 * GridSize;
         ld_24 = li_0 * l_point_16 - GridSize * GridSteps / 2.0 * l_point_16;
         l_price_32 = ld_24 + l_count_104 * l_point_16 * GridSize + gridOffset * l_point_16;
         if (l_bool_96 && !limitEMA || l_price_32 > l_ima_48) {
            if (longGridCenter > l_point_16) {
               ld_40 = GridSteps / 2.0;
               li_0 = ld_40;
               ld_24 = longGridCenter - li_0 * GridSize * l_point_16;
            } else {
               ld_24 = (Ask + l_point_16 * GridSize / 2.0) / l_point_16 / GridSize;
               li_0 = ld_24;
               li_0 = li_0 * GridSize;
               ld_24 = li_0 * l_point_16 - GridSize * GridSteps / 2.0 * l_point_16;
            }
            l_price_32 = ld_24 + l_count_104 * l_point_16 * GridSize + gridOffset * l_point_16;
            li_12 = TRUE;
            if (l_price_32 < longGridLow) li_12 = FALSE;
            if (l_price_32 > longGridHigh && longGridHigh > l_point_16) li_12 = FALSE;
            if (IsPosition(l_price_32, l_point_16 * GridSize, 1) == 0 && li_12 == TRUE) {
               l_price_88 = 0;
               if (StopLoss > 0.0) l_price_88 = l_price_32 - l_point_16 * StopLoss;
               if (l_price_32 > Ask) l_cmd_8 = 4;
               else l_cmd_8 = 2;
               if ((l_price_32 > Ask + minFromPrice * Point && wantBreakout) || (l_price_32 <= Ask - minFromPrice * Point && wantCounter)) li_unused_4 = OrderSend(Symbol(), l_cmd_8, Lots, l_price_32, 0, l_price_88, l_price_32 + l_point_16 * TakeProfit, gs_grid_280, uniqueGridMagic, 0, Green);
            }
         }
         if (l_bool_100 && !limitEMA || l_price_32 < l_ima_48) {
            if (shortGridCenter > l_point_16) {
               ld_40 = GridSteps / 2.0;
               li_0 = ld_40;
               ld_24 = shortGridCenter - li_0 * GridSize * l_point_16;
            } else {
               ld_24 = (Ask + l_point_16 * GridSize / 2.0) / l_point_16 / GridSize;
               li_0 = ld_24;
               li_0 = li_0 * GridSize;
               ld_24 = li_0 * l_point_16 - GridSize * GridSteps / 2.0 * l_point_16;
            }
            l_price_32 = ld_24 + l_count_104 * l_point_16 * GridSize + gridOffset * l_point_16;
            li_12 = TRUE;
            if (l_price_32 < shortGridLow) li_12 = FALSE;
            if (l_price_32 > shortGridHigh && shortGridHigh > l_point_16) li_12 = FALSE;
            if (IsPosition(l_price_32, l_point_16 * GridSize, 0) == 0 && li_12 == TRUE) {
               l_price_88 = 0;
               if (StopLoss > 0.0) l_price_88 = l_price_32 + l_point_16 * StopLoss;
               if (l_price_32 > Bid) l_cmd_8 = 3;
               else l_cmd_8 = 5;
               if ((l_price_32 < Bid - minFromPrice * Point && wantBreakout) || (l_price_32 >= Bid + minFromPrice * Point && wantCounter)) li_unused_4 = OrderSend(Symbol(), l_cmd_8, Lots, l_price_32, 0, l_price_88, l_price_32 - l_point_16 * TakeProfit, gs_grid_280, uniqueGridMagic, 0, Red);
            }
         }
      }
   }
   return (0);
}