/*
 *  A Processing sketch that connects to Adafruit IO and listens for new
 *  messages on a feed.
 */

import mqtt.*;
MQTTClient client;
// Install MQTT via the Processing library manager
// Go to the "Sketch" menu,
//   then "Import Libray >",
//   then "Add Library..." and search for 'mqtt'

// get these from your Adafruit IO account
String io_username = "..."; // plug this in yourself
String io_key = "...";      // plug this in yourself
String url = "mqtts://" + io_username + ":" + io_key + "@io.adafruit.com";
// Adafruit IO's API requires MQTT connections to use "topics" in the form:
//
//   {username}/feeds/{feed key}
//
// For us, that looks like this:
String feed = io_username + "/feeds/motion";
float currentValue = 0;


void setup() {
  size(640, 640);
  pixelDensity(displayDensity()); // handle high-dpi screens
  // println("using displayDensity", displayDensity());
  // println(width, height);
  // println(pixelWidth, pixelHeight);

  ellipseMode(CENTER);
  rectMode(CENTER);
  fill(0, 200, 0);

  // connect to Adafruit IO, get the most recent value from the shape feed
  client = new MQTTClient(this);
  client.connect(url);
  client.subscribe(feed);
}


void draw() {
  background(0);

  if (currentValue > 0) {
    rect(0, 0, pixelWidth, map(currentValue, 0, 100, 0, pixelHeight));
    currentValue -= 0.1;
  }

  if (currentValue < 0) currentValue = 0;
}


void messageReceived(String topic, byte[] payload) {
  try {
    float value = Float.parseFloat(new String(payload));
    println("new message: " + topic + " - ", value);

    currentValue = value;
  } catch (NumberFormatException ex) {
    currentValue = 100.0;
  }
}
