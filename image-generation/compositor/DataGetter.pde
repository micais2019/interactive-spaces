// install library "HTTP Requests for Processing"

import http.requests.*;

class DataGetter {
  DataGetter() {
  }

  String getValue(String feed, long atTime) {
    GetRequest get = new GetRequest("https://io.adafruit.com/api/v2/mica_ia/feeds/" + feed + "/data?limit=1");
    get.addHeader("Accept", "application/json");
    get.send();
    
    String response = get.getContent();
    JSONArray jsvalues;
    JSONObject jsvalue;
    try {
      jsvalues = parseJSONArray(response);
      jsvalue = jsvalues.getJSONObject(0);
      return jsvalue.getString("value");
    } catch (RuntimeException ex) {
      println("ERROR failed to retrieve value for", feed, "error:", response);
      return "0.0";
    }
  }

  ArrayList<String> getHistory(String feed, long atTime, int valueCount) {
    GetRequest get = new GetRequest("https://io.adafruit.com/api/v2/mica_ia/feeds/" + feed + "/data?limit=" + valueCount);
    get.addHeader("Accept", "application/json");
    get.send();
    
    String response = get.getContent();
    JSONArray jsvalues;
    ArrayList<String> values = new ArrayList<String>();
    try {
      jsvalues = parseJSONArray(response);
      for (int n=0; n < jsvalues.size(); n++) {
        JSONObject datum = jsvalues.getJSONObject(n);
        values.add(datum.getString("value"));
      }
    } catch (RuntimeException ex) {
      println("ERROR failed to retrieve value for", feed, "error:", response);
    }
    return values;
  }
}
