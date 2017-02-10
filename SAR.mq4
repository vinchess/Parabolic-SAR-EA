//+------------------------------------------------------------------+
//|                                                          SAR.mq4 |
//|                                       Copyright 2017 Vincent Lim |
//|                                            vince.lim@outlook.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017 Vincent Lim"
#property link      "vince.lim@outlook.com"
#property version   "2.00"
#property strict

input int      magicNumber    =  120120; //Magic Identifier
input double   controlLot     =  0.1;  //control value
input int      trailStep      =  1;  //Trailing Step
input int      offsetSpread   =  5;   //Trailing Spread Offset
input int      trailingStop   =  30;  //Trailing Stop
input int      stopPoint      =  30; //SL Level
input int      profitPoint    =  60; //TP Level

int barCount=0;
int trailCount = 0;
double lot;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert fucking tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      //resetTrail();
      trail();
         
            if(checkCurrSAR() == "UPPER"){
               if(checkCurrSAR() != checkPrevSAR()){
                  //SELL NOW
                  if(Bars > barCount){
                     //closeOrder();
                     if(CheckCurrentPair()==0){
                        if(goodTime()){
                           makeOrder(OP_SELL);
                        }
                     }
                     barCount = Bars;
                  }
               }
            }else if(checkCurrSAR() == "LOWER"){
               if(checkCurrSAR() != checkPrevSAR()){
                  //BUY NOW
                  if(Bars > barCount){
                     //closeOrder();
                     if(CheckCurrentPair()==0){
                        if(goodTime()){
                           makeOrder(OP_BUY);
                        }
                     }
                     barCount = Bars;
                  }
               }
            }
         
  
      /*if(Bars > barCount){
      
         if(goodTime()){
            if(checkCurrSAR() == "UPPER"){
               if(checkCurrSAR() != checkPrevSAR()){
                  //SELL NOW
                  closeOrder();
                  makeOrder(OP_SELL);
               }
            }else if(checkCurrSAR() == "LOWER"){
               if(checkCurrSAR() != checkPrevSAR()){
                  //BUY NOW
                  closeOrder();
                  makeOrder(OP_BUY);
               }
            }
         }
         
         barCount = Bars;
            
      }*/
  }
//+------------------------------------------------------------------+

bool goodTime(){
   //if(TimeHour(TimeCurrent())>=10 && TimeHour(TimeCurrent())<=23)
      return true;
   //else
      //return false;
}

int CheckCurrentPair(){
   int cnt = OrdersTotal();
   int total = 0;
   for(int i=cnt-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
         if(OrderMagicNumber() == magicNumber){
            total++;
         }
      }
   }
   return total;
}

void resetTrail(){
   int cnt = OrdersTotal();
   for(int i=cnt-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
         if(OrderMagicNumber()==magicNumber){
            if(OrderType() == OP_BUY  || OrderType() == OP_SELL){
               return;
            }
         }
      }
   }
   trailCount = 0;
}

void makeOrder(int ORDER){
   lot = NormalizeDouble(((AccountBalance() * 0.01)*controlLot),2);
   
   if(lot>100){ lot=100; }
   
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   
   if(ORDER == OP_BUY){
      bool res = OrderSend(Symbol(),OP_BUY,lot,Ask,5,
                              getEnvLower(),
                              getEnvUpper(),
                              //getCurrSAR(),
                              //NormalizeDouble(Ask-(minstoplevel*stopPoint)*Point,Digits),
                              //NormalizeDouble(Ask+(minstoplevel*profitPoint)*Point,Digits),
                              //NormalizeDouble((Ask+(Ask-getCurrSAR())),Digits),
                              //NULL,
                              "Buy Order",magicNumber,0,Green);
      if(!res)
         Print("Error in OrderModify. Error code = ",GetLastError());
      else
         Print("Buy Opened");
   }else if(ORDER == OP_SELL){
      bool res = OrderSend(Symbol(),OP_SELL,lot,Bid,5,
                              getEnvUpper(),
                              getEnvLower(),
                              //getCurrSAR(),
                              //NormalizeDouble(Bid+(minstoplevel*stopPoint)*Point,Digits),
                              //NormalizeDouble(Bid-(minstoplevel*profitPoint)*Point,Digits),
                              //NormalizeDouble((Bid-(getCurrSAR()-Bid)),Digits),
                              //NULL,
                              "Sell Order",magicNumber,0,Green);
      if(!res)
         Print("Error in OrderModify. Error code = ",GetLastError());
      else
         Print("Sell Opened");
   }else{
      Print("Error Occured in order()");
   } 
}

string checkCurrSAR(){
   //double paraSAR = iSAR(NULL,PERIOD_CURRENT,0.02,0.2,0);
   double paraSAR = iSAR(NULL,PERIOD_CURRENT,0.01,0.2,0);

   if(paraSAR <= Open[0]){
      return "LOWER";
   }else if(paraSAR >= Open[0]){
      return "UPPER";
   }else{
      return "ERROR";
   }
}

double getCurrSAR(){
   //return NormalizeDouble(iSAR(NULL,PERIOD_CURRENT,0.02,0.2,0),Digits);
   return NormalizeDouble(iSAR(NULL,PERIOD_CURRENT,0.01,0.2,0),Digits);
}

string checkPrevSAR(){
   //double paraSAR = iSAR(NULL,PERIOD_CURRENT,0.02,0.2,1);
   double paraSAR = iSAR(NULL,PERIOD_CURRENT,0.01,0.2,1);

   if(paraSAR <= Close[1]){
      return "LOWER";
   }else if(paraSAR >= Close[1]){
      return "UPPER";
   }else{
      return "ERROR";
   }
}

void closeOrder(){
   int cnt = OrdersTotal();
   for(int i=cnt-1; i >= 0; i--){
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
         if(OrderMagicNumber() == magicNumber){
            int type = OrderType();
            if(type == OP_BUY){
                  bool res = OrderClose(OrderTicket(),OrderLots(),Bid,1,Red);
                  if(!res)
                     Print("Error in OrderModify. Error code = ",GetLastError());
                  else
                     Print("Order closed");
            }else if(type == OP_SELL){
                  bool res = OrderClose(OrderTicket(),OrderLots(),Ask,1,Red);
                  if(!res)
                     Print("Error in OrderModify. Error code = ",GetLastError());
                  else
                     Print("Order closed");
            }
         }
      }
   }
}

double getEnvUpper(){
   return NormalizeDouble(iEnvelopes(NULL,PERIOD_CURRENT,21,MODE_SMA,0,PRICE_CLOSE,0.5,MODE_UPPER,0),Digits);
}

double getEnvLower(){
   return NormalizeDouble(iEnvelopes(NULL,PERIOD_CURRENT,21,MODE_SMA,0,PRICE_CLOSE,0.5,MODE_LOWER,0),Digits);
}

double getEnvMain(){
   return NormalizeDouble(iEnvelopes(NULL,PERIOD_CURRENT,21,MODE_SMA,0,PRICE_CLOSE,0,MODE_MAIN,0),Digits);
}

void trail(){
   
   int cnt = OrdersTotal();
      for(int i=cnt-1;i>=0;i--){
         if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
           if(OrderMagicNumber()==magicNumber){
              int type = OrderType();
              
               if(type==0){
                  //if(Bid-OrderOpenPrice()>Point*(trailingStop+offsetSpread)){
                     //if(OrderStopLoss()<Bid-Point*(trailingStop+offsetSpread)){// || OrderStopLoss()==trailingStop){
                        Print("Modify Buy");
                        //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*trailingStop,Digits),
                                 //OrderTakeProfit(),0,Blue);
                           bool res=OrderModify(OrderTicket(),OrderOpenPrice(),getEnvLower(),getEnvUpper(),0,Blue);
                        if(!res)
                           Print("Error in OrderModify. Error code=",GetLastError());
                        else
                           Print("Order modified successfully.");
                     //}
                  //}
               }
               else if(type==1){
                  //if(OrderOpenPrice()-Ask>Point*(trailingStop+offsetSpread)){
                     //if(OrderStopLoss()>Ask+Point*(trailingStop+offsetSpread)){// || OrderStopLoss()==trailingStop){
                        Print("Modify Sell");
                        //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*trailingStop,Digits),
                                 //OrderTakeProfit(),0,Blue);
                        bool res=OrderModify(OrderTicket(),OrderOpenPrice(),getEnvUpper(),getEnvLower(),0,Blue);
                        if(!res)
                           Print("Error in OrderModify. Error code=",GetLastError());
                        else
                           Print("Order modified successfully.");
                     //}
                  //}
               }  
            }
         }
      }
   
}

/*void trail(){
   if(trailingStop>0){
   int cnt = OrdersTotal();
      for(int i=cnt-1;i>=0;i--){
         if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
           if(OrderMagicNumber()==magicNumber){
              int type = OrderType();
              
                  if(trailCount == 0){
                     if(type==0){
                        if(Bid-OrderOpenPrice()>Point*(trailingStop+offsetSpread)){
                           if(OrderStopLoss()<Bid-Point*(trailingStop+offsetSpread)){// || OrderStopLoss()==trailingStop){
                              Print("Modify Buy");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                                 bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+Point*(trailingStop+offsetSpread),Digits),
                                       NormalizeDouble(OrderTakeProfit()+Point*(trailingStop+offsetSpread),Digits),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                                 trailCount++;
                           }
                        }
                     }
                     else if(type==1){
                        if(OrderOpenPrice()-Ask>Point*(trailingStop+offsetSpread)){
                           if(OrderStopLoss()>Ask+Point*(trailingStop+offsetSpread)){// || OrderStopLoss()==trailingStop){
                              Print("Modify Sell");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()-Point*(trailingStop+offsetSpread),Digits),
                                       NormalizeDouble(OrderTakeProfit()-Point*(trailingStop+offsetSpread),Digits),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                                 trailCount++;
                           }
                        }
                     }
                  }else{
                     if(type==0){
                        if(Bid-OrderOpenPrice()>Point*trailStep){
                           if(OrderStopLoss()<Bid-Point*trailStep){// || OrderStopLoss()==trailingStop){
                              Print("Modify Buy");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                                 bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+Point*trailStep,Digits),
                                       NormalizeDouble(OrderTakeProfit()+Point*trailStep,Digits),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                           }
                        }
                     }
                     else if(type==1){
                        if(OrderOpenPrice()-Ask>Point*trailStep){
                           if(OrderStopLoss()>Ask+Point*trailStep){// || OrderStopLoss()==trailingStop){
                              Print("Modify Sell");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()-Point*trailStep,Digits),
                                       NormalizeDouble(OrderTakeProfit()-Point*trailStep,Digits),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                           }
                        }
                     }
                  }
            }
         }
      }
   }
}*/