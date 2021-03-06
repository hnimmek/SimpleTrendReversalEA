//+----------------------------+
//|   Analyze Currency Symbol  |
//+============================+
//|
//|   Rev Date: 2010.06.07
//|
//|   Contains the following Functions:
//|
//|   GetSymbolType()
//|   GetBasePairForCross()
//|   GetCounterPairForCross()
//|   GetSymbolLeverage()
//|   AnalyzeSymbol()
//|
//+----------------------------+

#property copyright "1005phillip"
#include <stderror.mqh>
#include <stdlib.mqh>

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetSymbolType()                                                                                                                        |
//|=======================================================================================================================================|
//|   int GetSymbolType(string symbol, bool verbose=false)                                                                                                  |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the SymbolType for use with Profit/Loss and lotsize calcs.                                           |
//|   The function returns an integer value which is the SymbolType.                                                                      |
//|   An integer value of 6 for SymbolType is returned in the event of an error                                                           |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 1:  symbol  = USDJPY                                                                                                 |
//|                     Base    = USD                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 2:  symbol  = EURUSD                                                                                                 |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = USD                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 3:  symbol  = CHFJPY                                                                                                 |
//|                     Base    = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  symbol) = AUDCAD                                                                                                 |
//|                     Base    = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                      |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  symbol  = EURGBP                                                                                                  |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|      SymbolType 6:  Error occurred, SymbolType could not be identified                                                                |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int GetSymbolType(string symbol, bool verbose=true)
{ 
   int     calculatedSymbolType=6;
   string  currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="",calculatedCounterPairForCross="";  
   currentSymbol = symbol;
   
   //if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",currentSymbol);

   symbolBase    = StringSubstr(currentSymbol, 0, 3);
   symbolCounter = StringSubstr(currentSymbol, 3, 3);
   postfix       = StringSubstr(currentSymbol, 6);
   if(symbolBase    == AccountCurrency()) calculatedSymbolType = 1;
   if(symbolCounter == AccountCurrency()) calculatedSymbolType = 2;
   if((calculatedSymbolType == 1 || calculatedSymbolType == 2) && verbose == true) 
   {
      Print("Base currency is ",symbolBase," and the Counter currency is ", symbolCounter," (this pair is a major)");
   }
   
   if (calculatedSymbolType != 1 && calculatedSymbolType != 2)
   {
      //if(verbose==true) Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
      if (MarketInfo(StringConcatenate(AccountCurrency(), symbolCounter, postfix), MODE_LOTSIZE) > 0)
      {
         calculatedSymbolType          = 4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
         calculatedCounterPairForCross = StringConcatenate(AccountCurrency(), symbolCounter, postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS)));
      }
      else if (MarketInfo(StringConcatenate(symbolCounter, AccountCurrency(), postfix), MODE_LOTSIZE) > 0)
      {
         calculatedSymbolType          = 5;
         calculatedCounterPairForCross = StringConcatenate(symbolCounter, AccountCurrency(), postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS)));
      }

      // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      if (MarketInfo(StringConcatenate(AccountCurrency(), symbolBase, postfix), MODE_LOTSIZE) > 0)
      {
         calculatedSymbolType       = 3;
         calculatedBasePairForCross = StringConcatenate(AccountCurrency(), symbolBase, postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS)));
      }
      else if(MarketInfo(StringConcatenate(symbolBase, AccountCurrency(), postfix), MODE_LOTSIZE) > 0)
      {
         calculatedBasePairForCross = StringConcatenate(symbolBase, AccountCurrency(), postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS)));
      }
   }
   //if(verbose==true) Print("GetSymbolType() = ",calculatedSymbolType);
   //if(calculatedSymbolType==6) Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = ",calculatedSymbolType);
   return calculatedSymbolType;
}  // SymbolType body end


//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetBasePairForCross()                                                                                                                  |
//|=======================================================================================================================================|
//|   string GetBasePairForCross(string symbol, bool verbose=false)                                                                                         |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency in Symbol()  |
//|   in the event that Symbol() is a cross-currency financial instrument.                                                                |
//|   Returns a text string with the name of the financial instrument which is the base currency pair to Symbol() if possible,            |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      string   CrossBasePair=GetBasePairForCross();   // USD is base to the base currency pair - USDCHF                                   |
//|      Print("The base pair for the cross-currency instrument ",Symbol()," is ",CrossBasePair);                                         |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                     Base     = CHF                                                                                                        |
//|                     Counter  = JPY                                                                                                     |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                     Base    = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                      |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string GetBasePairForCross(string symbol, bool verbose=false)
{  
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="";
   currentSymbol = symbol;
   //if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",currentSymbol);

   symbolBase    = StringSubstr(currentSymbol, 0, 3);
   symbolCounter = StringSubstr(currentSymbol, 3, 3);
   postfix       = StringSubstr(currentSymbol, 6);
   switch( GetSymbolType(currentSymbol) ) // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
   {
      case 1:  
      break;
      
      case 2:  
      break;
      
      case 3:  
         calculatedBasePairForCross = StringConcatenate(AccountCurrency(), symbolBase, postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))); 
      break;
      
      case 4:  
         calculatedBasePairForCross = StringConcatenate(symbolBase, AccountCurrency(), postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))); 
      break;
      
      case 5:  
         calculatedBasePairForCross = StringConcatenate(symbolBase, AccountCurrency(), postfix);
          //if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))); 
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for identifying BasePairForCross on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;   
   }
   return calculatedBasePairForCross;
}  // BasePairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetCounterPairForCross()                                                                                                               |
//|=======================================================================================================================================|
//|   string GetCounterPairForCross(bool verbose=false)                                                                                      |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency in        |
//|   Symbol() in the event that Symbol() is a cross-currency financial instrument.                                                       |
//|   Returns a text string with the name of the financial instrument which is the counter currency pair to Symbol() if possible,         |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      string   CrossCounterPair=GetCounterPairForCross();   // USD is base to the counter currency pair - USDJPY                          |
//|      Print("The counter pair for the cross-currency instrument ",Symbol()," is ",CrossCounterPair);                                   |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string GetCounterPairForCross(string symbol, bool verbose=false)
{  
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedCounterPairForCross="";
   currentSymbol = symbol;
  // if(verbose==true) Print("Account currency is ", AccountCurrency()," and Current Symbol = ",currentSymbol);
   symbolBase    = StringSubstr(currentSymbol,0, 3);
   symbolCounter = StringSubstr(currentSymbol,3, 3);
   postfix       = StringSubstr(currentSymbol,6);

   switch( GetSymbolType(currentSymbol) ) // Determine if AccountCurrency() is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
   {
      case 1:  
      break;
      
      case 2:  
      break;
      
      case 3:  
         calculatedCounterPairForCross = StringConcatenate(AccountCurrency(), symbolCounter, postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))); 
      break;
      
      case 4:  
         calculatedCounterPairForCross = StringConcatenate(AccountCurrency(), symbolCounter, postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))); 
      break;
      
      case 5:  
         calculatedCounterPairForCross = StringConcatenate(symbolCounter, AccountCurrency(), postfix);
         //if(verbose==true) Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))); 
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for identifying CounterPairForCross on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;   
   }
   
   return calculatedCounterPairForCross;
}  // CounterPairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetSymbolLeverage()                                                                                                                    |
//|=======================================================================================================================================|
//|   int GetSymbolLeverage(bool verbose=false)                                                                                              |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the broker's required leverage for the financial instrument.                                         |
//|   Returns an integer value representing leverage ratio if possible, otherwise, it returns a zero value.                               |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // AccountCurrency()=USD                                                                                                         |
//|      int   calculatedLeverage=GetSymbolLeverage();   // Leverage for USDJPY is set to 100:1                                           |
//|      Print("Leverage for ",Symbol()," is set at ",calculatedLeverage,":1");                                                           |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int GetSymbolLeverage(string symbol, bool verbose=false)
{  // SymbolLeverage body start
   double      calculatedLeverage=0;
   string      currentSymbol="",calculatedBasePairForCross="";

   currentSymbol = symbol;
   switch(GetSymbolType(currentSymbol)) // Determine the leverage for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
         calculatedLeverage = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)/MarketInfo(currentSymbol,MODE_MARGINREQUIRED),2); 
      break;
      
      case 2:  
         calculatedLeverage = NormalizeDouble(MarketInfo(currentSymbol,MODE_ASK)*MarketInfo(currentSymbol,MODE_LOTSIZE)/MarketInfo(currentSymbol,MODE_MARGINREQUIRED),2); 
      break;
      
      case 3:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(2*MarketInfo(currentSymbol,MODE_LOTSIZE)/((MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))*MarketInfo(currentSymbol,MODE_MARGINREQUIRED)),2); 
      break;
      
      case 4:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)*(MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))/(2*MarketInfo(currentSymbol,MODE_MARGINREQUIRED)),2); 
      break;
      
      case 5:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)*(MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))/(2*MarketInfo(currentSymbol,MODE_MARGINREQUIRED)),2); 
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for calculating Leverage on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }
   if(verbose==true) Print("Leverage for ",currentSymbol," is set at ",calculatedLeverage,":1");
   return (int)(calculatedLeverage);
}  // SymbolLeverage body end

//+------------------------------------------------------------------------------------------------+
//| AnalyzeSymbol()                                                                                |
//|================================================================================================|
//| Analysis routines for characterizing the resultant trade metrics                               |
//+------------------------------------------------------------------------------------------------+
void AnalyzeSymbol(string symbol)
{  
   double   calculatedLeverage=0,calculatedMarginRequiredLong=0,calculatedMarginRequiredShort=0;
   int      calculatedSymbolType=0,ticket=0,lotSizeDigits=0,CurrentOrderType=0;
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="",calculatedCounterPairForCross="";

   currentSymbol=symbol;
  // Print("Account currency is ", AccountCurrency()," and max allowed account leverage is ",AccountLeverage(),":1");
  // Print("Current Symbol = ",currentSymbol,", Bid = ",DoubleToStr(MarketInfo(currentSymbol,MODE_BID),MarketInfo(currentSymbol,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(currentSymbol,MODE_ASK),MarketInfo(currentSymbol,MODE_DIGITS)));
   symbolBase    = StringSubstr(currentSymbol,0,3);
   symbolCounter = StringSubstr(currentSymbol,3,3);
   postfix       = StringSubstr(currentSymbol,6);
   calculatedSymbolType = GetSymbolType(currentSymbol);
   if(calculatedSymbolType == 6)
   {
     // Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = ",calculatedSymbolType);
      return;
   }

  // Print("calculatedGetSymbolType() = ",calculatedSymbolType);
   calculatedLeverage = GetSymbolLeverage(currentSymbol);
   switch(calculatedSymbolType) // Determine the Base and Counter pairs for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  //Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter); 
      break;
      
      case 2:  
         //Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter); 
      break;
      
      case 3:  
         //Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
         //Print(AccountCurrency()," is the Base currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS)));
         //Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))); 
      break;
      
      case 4:  
         Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
         //Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS)));
         //Print(AccountCurrency()," is the Base currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))); 
      break;
      
      case 5:  
         Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
         //Print(AccountCurrency()," is the Counter currency to the Base currency for this cross, the BasePair is ",calculatedBasePairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_BID),MarketInfo(calculatedBasePairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedBasePairForCross,MODE_ASK),MarketInfo(calculatedBasePairForCross,MODE_DIGITS)));
         //Print(AccountCurrency()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",calculatedCounterPairForCross,", Bid = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_ASK),MarketInfo(calculatedCounterPairForCross,MODE_DIGITS)));
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for reporting on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }

   //Print("MODE_POINT = ",DoubleToStr(MarketInfo(currentSymbol,MODE_POINT),MarketInfo(currentSymbol,MODE_DIGITS))," (Point size in the quote currency)");
   //Print("MODE_TICKSIZE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_TICKSIZE),MarketInfo(currentSymbol,MODE_DIGITS))," (Tick size in the quote currency)");
   //Print("MODE_TICKVALUE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_TICKVALUE),6)," (Tick value in the deposit currency)");
   switch(calculatedSymbolType) // Determine the tickvalue for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
         //Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_POINT)*MarketInfo(currentSymbol,MODE_LOTSIZE)/MarketInfo(currentSymbol,MODE_BID),6)," (Tick value in the deposit currency - base)"); 
      break;
      
      case 2:  
         //Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_POINT)*MarketInfo(currentSymbol,MODE_LOTSIZE),6)," (Tick value in the deposit currency - counter)"); 
      break;
      
      case 3:  
         //Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_POINT)*MarketInfo(currentSymbol,MODE_LOTSIZE)/MarketInfo(calculatedCounterPairForCross,MODE_BID),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Base to Counter)"); 
      break;
      
      case 4:  
         //Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(currentSymbol,MODE_POINT)*MarketInfo(currentSymbol,MODE_LOTSIZE)/MarketInfo(calculatedCounterPairForCross,MODE_BID),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Base to Counter)"); 
      break;
      
      case 5:  
         //Print("Calculated TICKVALUE = ",DoubleToStr(MarketInfo(calculatedCounterPairForCross,MODE_BID)*MarketInfo(currentSymbol,MODE_POINT)*MarketInfo(currentSymbol,MODE_LOTSIZE),6)," (Tick value in the deposit currency - ",AccountCurrency()," is Counter to Counter)"); 
      break;
      
      default:  
         //Print("Error encountered in the SWITCH routine for calculating tickvalue of financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }
   //Print("MODE_DIGITS = ",MarketInfo(currentSymbol,MODE_DIGITS)," (Count of digits after decimal point in the symbol prices)");
   //Print("MODE_SPREAD = ",MarketInfo(currentSymbol,MODE_SPREAD)," (Spread value in points)");
   //Print("MODE_STOPLEVEL = ",MarketInfo(currentSymbol,MODE_STOPLEVEL)," (Stop level in points)");
   //Print("MODE_LOTSIZE = ",MarketInfo(currentSymbol,MODE_LOTSIZE)," (Lot size in the Base currency)");
   //Print("MODE_MINLOT = ",MarketInfo(currentSymbol,MODE_MINLOT)," (Minimum permitted amount of a lot)");
   //Print("MODE_LOTSTEP = ",MarketInfo(currentSymbol,MODE_LOTSTEP)," (Step for changing lots)");
   //Print("MODE_MARGINREQUIRED = ",MarketInfo(currentSymbol,MODE_MARGINREQUIRED)," (Free margin required to open 1 lot for buying)");

   switch(calculatedSymbolType) // Determine the margin required to open 1 lot position for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
         calculatedMarginRequiredLong = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)/calculatedLeverage,2);
         //Print("Calculated MARGINREQUIRED = ",calculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
         //Print("Calculated Leverage = ",calculatedLeverage,":1 for this specific financial instrument (",currentSymbol,")"); 
      break;
      
      case 2:  
         calculatedMarginRequiredLong  = NormalizeDouble(MarketInfo(currentSymbol,MODE_ASK)*MarketInfo(currentSymbol,MODE_LOTSIZE)/calculatedLeverage,2);
         calculatedMarginRequiredShort = NormalizeDouble(MarketInfo(currentSymbol,MODE_BID)*MarketInfo(currentSymbol,MODE_LOTSIZE)/calculatedLeverage,2);
         //Print("Calculated MARGINREQUIRED = ",calculatedMarginRequiredLong," for Buy (free margin required to open 1 lot position as long), and Calculated MARGINREQUIRED = ",calculatedMarginRequiredShort," for Sell (free margin required to open 1 lot position as short)");
         //Print("Calculated Leverage = ",calculatedLeverage,":1 for this specific financial instrument (",currentSymbol,")"); 
      break;
      
      case 3:  
         calculatedMarginRequiredLong = NormalizeDouble(2*MarketInfo(currentSymbol,MODE_LOTSIZE)/((MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))*calculatedLeverage),2);
         //Print("Calculated MARGINREQUIRED = ",calculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
         //Print("Calculated Leverage = ",calculatedLeverage,":1 for this specific financial instrument (",currentSymbol,")"); 
      break;
      
      case 4:  
         calculatedMarginRequiredLong = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)*(MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))/(2*calculatedLeverage),2);
         //Print("Calculated MARGINREQUIRED = ",calculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
         //Print("Calculated Leverage = ",calculatedLeverage,":1 for this specific financial instrument (",currentSymbol,")"); 
      break;
      
      case 5:  
         calculatedMarginRequiredLong = NormalizeDouble(MarketInfo(currentSymbol,MODE_LOTSIZE)*(MarketInfo(calculatedBasePairForCross,MODE_BID)+MarketInfo(calculatedBasePairForCross,MODE_ASK))/(2*calculatedLeverage),2);
         //Print("Calculated MARGINREQUIRED = ",calculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
         //Print("Calculated Leverage = ",calculatedLeverage,":1 for this specific financial instrument (",currentSymbol,")"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for calculating required margin for financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }
   lotSizeDigits =(int) -MathRound(MathLog(MarketInfo(currentSymbol,MODE_LOTSTEP))/MathLog(10.)); // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
   //Print("Digits for lotsize = ",lotSizeDigits);
}  // AnalyzeSymbol body end
