//+------------------------------------------------------------------+
//|                                              WebRequestExample.mq4|
//|                        Your Name/Your Company                    |
//+------------------------------------------------------------------+
#property strict

input string DataEndpoint = "http://your.api.endpoint/receive_data"; // Replace with your actual API endpoint
input int TransmissionInterval = 10; // Interval in seconds to transmit data

datetime lastTransmissionTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   lastTransmissionTime = TimeCurrent();
   ObjectsDeleteAll();  // Clear any existing objects on the chart
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();  // Clean up chart objects on deinitialization
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double bid = MarketInfo(Symbol(), MODE_BID);
   double ask = MarketInfo(Symbol(), MODE_ASK);
   datetime currentTime = TimeCurrent();

   string jsonData = StringFormat("{\"symbol\":\"%s\",\"bid\":%f,\"ask\":%f,\"time\":%d}",
                                  Symbol(), bid, ask, currentTime);

   // Move text display back to the top left side of the chart
   DrawTextOnChart("BidPrice", "Bid: " + DoubleToString(bid, Digits), 10, 20, CORNER_LEFT_UPPER);
   DrawTextOnChart("AskPrice", "Ask: " + DoubleToString(ask, Digits), 10, 40, CORNER_LEFT_UPPER);
   DrawTextOnChart("SendStatus", "Sending Data...", 10, 60, CORNER_LEFT_UPPER);

   if (currentTime >= lastTransmissionTime + TransmissionInterval)
     {
      int responseCode = sendDataToAPI(DataEndpoint, jsonData);
      
      if(responseCode == 200)
         DrawTextOnChart("SendStatus", "Data transmitted successfully!", 10, 60, CORNER_LEFT_UPPER);
      else
         DrawTextOnChart("SendStatus", "Error transmitting data, response code: " + IntegerToString(responseCode), 10, 60, CORNER_LEFT_UPPER);

      lastTransmissionTime = currentTime;
     }
  }
//+------------------------------------------------------------------+
//| Function to send data to the API                                  |
//+------------------------------------------------------------------+
int sendDataToAPI(string url, string jsonData)
  {
   int timeout = 5000;
   char post[];
   StringToCharArray(jsonData, post);
   char result[1024];
   string headers = "Content-Type: application/json\r\n";
   string resultHeaders;

   int responseCode = WebRequest("POST", url, headers, "", timeout, post, ArraySize(post) - 1, result, resultHeaders);

   if (responseCode == -1)
   {
      Print("WebRequest failed, error code: ", GetLastError());
   }

   return responseCode;
  }
//+------------------------------------------------------------------+
//| Function to draw text on the chart                                |
//+------------------------------------------------------------------+
void DrawTextOnChart(string name, string text, int x, int y, int corner)
  {
   if(ObjectFind(0, name) != 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);  // Set the corner position
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }
