//----------------------------------------------------------------------------------------
// usualexpert.mq4
// The code should be used for educational purpose only.
//----------------------------------------------------------------------------------- 1 --
#property copyright "Copyright © Murat Aka"
#property link      "Murat Aka"
//----------------------------------------------------------------------------------- 2 --
#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>
//----------------------------------------------------------------------------------- 3 --
#include <MQL4-original/Variables.mqh>   // Description of variables 
#include <MQL4-original/Check.mqh>       // Checking legality of programs used
#include <MQL4-original/Terminal.mqh>    // Order accounting
#include <MQL4-original/Events.mqh>      // Event tracking function
#include <MQL4-original/Inform.mqh>      // Data function
#include <MQL4-original/Trade.mqh>       // Trade function
#include <MQL4-original/Open_Ord.mqh>    // Opening one order of the preset type
#include <MQL4-original/Close_All.mqh>   // Closing all orders of the preset type
#include <MQL4-original/Tral_Stop.mqh>   // StopLoss modification for all orders of the preset type
#include <MQL4-original/Lot.mqh>         // Calculation of the amount of lots
#include <MQL4-original/CriterionCOG.mqh>   // Trading criteria
#include <MQL4-original/Errors.mqh>      // Error processing function
//----------------------------------------------------------------------------------- 4 --
int init()                             // Special function 'init'
  {
   Level_old=MarketInfo(Symbol(),MODE_STOPLEVEL );//Min. distance
   Terminal();                         // Order accounting function 
   return;                             // Exit init() 
  }
//----------------------------------------------------------------------------------- 5 --
int start()                            // Special function 'start'
  {
   if(Check()==false)                  // If the usage conditions..
      return;                          // ..are not met, then exit
 //  PlaySound("tick.wav");              // At every tick
   Terminal();                         // Order accounting function 
   Events();                           // Information about events
   Trade(Criterion());                 // Trade function
   Inform(0);                          // To change the color of objects
   return;                             // Exit start()
  }
//----------------------------------------------------------------------------------- 6 --
int deinit()                           // Special function deinit()
  {
   Inform(-1);                         // To delete objects
   return;                             // Exit deinit()
  }
//----------------------------------------------------------------------------------- 7 -