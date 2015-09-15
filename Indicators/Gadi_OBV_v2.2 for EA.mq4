#property copyright "Copyright © 2012, Gadi."
#property link      "Gadi @ CompIT"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Lavender

int TF = 0;
int gi_108 = 0;
double g_ibuf_112[];
double gd_116;
double gd_132;
double gd_140;
int gi_152;
int gi_156 = 0;
int gi_160 = 0;
string gs_164;
string gs_dummy_172;
string gs_dummy_180;
string gs_dummy_188;
string gs_dummy_196;
string gs_204;

int init() 
{
   SetIndexBuffer(0, g_ibuf_112);
   SetIndexStyle(0, DRAW_LINE);
   IndicatorDigits(0);
   IndicatorShortName(gs_164);
   SetIndexLabel(0, gs_164);
   return (0);
}

int start() {
   double ld_12;
   double ld_20;
   int li_8 = IndicatorCounted();
   if (li_8 > 0) li_8--;
   int li_4 = Bars - li_8 - 1;
   for (int li_0 = li_4; li_0 >= 0; li_0--) {
      if (li_0 == Bars - 1) g_ibuf_112[li_0] = iVolume(NULL, TF, li_0);
      else {
         ld_12 = f0_0(gi_108, li_0);
         ld_20 = f0_0(gi_108, li_0 + 1);
         if (ld_12 == ld_20) g_ibuf_112[li_0] = g_ibuf_112[li_0 + 1];
         else {
            if (ld_12 < ld_20) {
               if (iHigh(NULL, TF, li_0) - iLow(NULL, TF, li_0) > 0.0) {
                  gd_116 = (iOpen(NULL, TF, li_0) - iClose(NULL, TF, li_0)) / (iHigh(NULL, TF, li_0) - iLow(NULL, TF, li_0));
                  g_ibuf_112[li_0] = g_ibuf_112[li_0 + 1] - iVolume(NULL, TF, li_0) * gd_116;
                  continue;
               }
               g_ibuf_112[li_0] = g_ibuf_112[li_0 + 1];
            } else {
               if (iHigh(NULL, TF, li_0) - iLow(NULL, TF, li_0) > 0.0) {
                  gd_116 = (iClose(NULL, TF, li_0) - iOpen(NULL, TF, li_0)) / (iHigh(NULL, TF, li_0) - iLow(NULL, TF, li_0));
                  g_ibuf_112[li_0] = g_ibuf_112[li_0 + 1] + iVolume(NULL, TF, li_0) * gd_116;
               } else g_ibuf_112[li_0] = g_ibuf_112[li_0 + 1];
            }
         }
      }
   }

   return (0);
}

double f0_0(int ai_0, int ai_4) 
{
   double ld_ret_8;
   switch (ai_0) {
   case 0:
      ld_ret_8 = iClose(NULL, TF, ai_4);
      break;
   case 1:
      ld_ret_8 = iOpen(NULL, TF, ai_4);
      break;
   case 2:
      ld_ret_8 = iHigh(NULL, TF, ai_4);
      break;
   case 3:
      ld_ret_8 = iLow(NULL, TF, ai_4);
      break;
   case 4:
      ld_ret_8 = (iHigh(NULL, TF, ai_4) + iLow(NULL, TF, ai_4)) / 2.0;
      break;
   case 5:
      ld_ret_8 = (iHigh(NULL, TF, ai_4) + iLow(NULL, TF, ai_4) + iClose(NULL, TF, ai_4)) / 3.0;
      break;
   case 6:
      ld_ret_8 = (iHigh(NULL, TF, ai_4) + iLow(NULL, TF, ai_4) + 2.0 * iClose(NULL, TF, ai_4)) / 4.0;
      break;
   default:
      ld_ret_8 = 0.0;
   }
   return (ld_ret_8);
}


