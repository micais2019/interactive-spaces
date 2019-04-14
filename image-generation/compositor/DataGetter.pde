// install library "HTTP Requests for Processing"

import http.requests.*;

class DataGetter {
  DataGetter() {
  }

  String getCurrentTemperature(long atTime) {
    String url = "https://micavibe.com/weather?at=" + String.format("%d", atTime);
    GetRequest get = new GetRequest(url);
    get.addHeader("Accept", "application/json");
    get.addHeader("X-AIO-Key", "");
    get.send();

    String response = get.getContent();
    try {
      JSONObject jsvalue = parseJSONObject(response);
      return str(jsvalue.getJSONObject("current").getFloat("temperature"));
    } catch (RuntimeException ex) {
      
      println("ERROR failed to retrieve current.temperature from", url, ". error:", response);
      return "50.0";
    }
  }

  String getValue(String feed, long atTime) {
    String url = buildUrl(feed, atTime, 1);
    // get all data from public feeds
    GetRequest get = new GetRequest(url);
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
    String url = buildUrl(feed, atTime, valueCount);
    // get all data from public feeds
    GetRequest get = new GetRequest(url);
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

  String buildUrl(String feed, long atTime, int valueCount) {
    String url = "https://io.adafruit.com/api/v2/mica_ia/feeds/" + feed +
      "/data?limit=" + valueCount +
      "&end_time=" + String.format("%d", atTime);
    if (DEBUG) {
      println("URL", url);
    }
    return url;
  }
}
