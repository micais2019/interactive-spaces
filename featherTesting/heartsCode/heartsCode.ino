// Adafruit IO Multiple Feed Example
//
// Adafruit invests time and resources providing this open source code.
// Please support Adafruit and open source hardware by purchasing
// products from Adafruit!
//
// Written by Todd Treece for Adafruit Industries
// Copyright (c) 2016 Adafruit Industries
// Licensed under the MIT license.
//
// All text above must be included in any redistribution.

/************************** Configuration ***********************************/

// edit the config.h tab and enter your Adafruit IO credentials
// and any additional configuration needed for WiFi, cellular,
// or ethernet clients.
#include "config.h"

/*************************** DotStar Setup **********************************/

#include <Adafruit_DotStar.h>
// Because conditional #includes don't work w/Arduino sketches...
#include <SPI.h>         // COMMENT OUT THIS LINE FOR GEMMA OR TRINKET
//#include <avr/power.h> // ENABLE THIS LINE FOR GEMMA OR TRINKET

#define NUMPIXELS 8 // Number of LEDs in strip

// Here's how to control the LEDs from any two pins:
#define DATAPIN    4
#define CLOCKPIN   5
Adafruit_DotStar strip = Adafruit_DotStar(
  NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);
// The last parameter is optional -- this is the color data order of the
// DotStar strip, which has changed over time in different production runs.
// Your code just uses R,G,B colors, the library then reassigns as needed.
// Default is DOTSTAR_BRG, so change this if you have an earlier strip.

// Hardware SPI is a little faster, but must be wired to specific pins
// (Arduino Uno = pin 11 for data, 13 for clock, other boards are different).
//Adafruit_DotStar strip = Adafruit_DotStar(NUMPIXELS, DOTSTAR_BRG);

/************************ Example Starts Here *******************************/

// holds the current count value for our sketch
int count = 0;
// holds the boolean (true/false) state of the light
bool is_on = false;

// track time of last published messages and limit feed->save events to once
// every IO_LOOP_DELAY milliseconds
#define IO_LOOP_DELAY 15000
unsigned long lastUpdate;

// set up the 'hearts' feed
AdafruitIO_Feed *hearts = io.feed("hearts");

// set up the 'motion' feed
AdafruitIO_Feed *motion = io.feed("motion");

// set up the 'sound' feed
AdafruitIO_Feed *sound = io.feed("sound");

AdafruitIO_Feed *testHearts = io.feed("testhearts");

void setup() {

  // start the serial connection
  Serial.begin(115200);

  // wait for serial monitor to open
  while(! Serial);

  Serial.print("Connecting to Adafruit IO");

  // connect to io.adafruit.com
  io.connect();

  // attach message handler for the counter feed.
  //counter->onMessage(handleCount);

  // attach the same message handler for the second counter feed.
  motion->onMessage(handleMotion);

  // attach a new message handler for the light feed.
  sound->onMessage(handleSound);

  testHearts->onMessage(handleTestHearts);

  // wait for a connection
  while(io.status() < AIO_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  // we are connected
  Serial.println();
  Serial.println(io.statusText());

  // make sure all feeds get their current values right away
  // counter->get();
  motion->get();
  sound->get();
  testHearts->get();

  #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
    clock_prescale_set(clock_div_1); // Enable 16 MHz on Trinket
  #endif

    strip.begin(); // Initialize pins for output
    strip.show();  // Turn all LEDs off ASAP

}

// Simple strand test for Adafruit Dot Star RGB LED strip.
// This is a basic diagnostic tool, NOT a graphics demo...helps confirm
// correct wiring and tests each pixel's ability to display red, green
// and blue and to forward data down the line.  By limiting the number
// and color of LEDs, it's reasonably safe to power a couple meters off
// the Arduino's 5V pin.  DON'T try that with other code!

// Runs 10 LEDs at a time along strip, cycling through red, green and blue.
// This requires about 200 mA for all the 'on' pixels + 1 mA per 'off' pixel.

int      head  = 0, tail = -10; // Index of first 'on' and 'off' pixels
uint32_t color = 0xFF0000;      // 'On' color (starts red)

/* TEST DOTSTAR LOOP, ONLY KIND OF WORKS
void loop() {
  color = 0xFF0000;
  Serial.print("Reset to red?");
  strip.setPixelColor(head, color);
  strip.setPixelColor(tail, 0);
  strip.show();
  delay(20);
  color = 0x54CCE0;
  Serial.print("Changed to blue-ish?");
  strip.setPixelColor(head, color);
}
*/

void loop() {

  // process messages and keep connection alive
  io.run();

  //if (millis() > (lastUpdate + IO_LOOP_DELAY)) {
    //Serial.println();

    // save current count to 'counter'
    /*Serial.print("sending -> counter ");
    Serial.println(count);
    counter->save(count);

    // increment the count by 1 and save the value to 'counter-two'
    // Serial.print("sending -> counter-two ");
    // Serial.println(count + 1);
    // counter_two->save(count + 1);

    // print out the light value we are sending to Adafruit IO
    Serial.print("sending -> light ");
    if(is_on)
      Serial.println("is on.\n");
    else
      Serial.println("is off.\n");

    // save state of light to 'light' feed
    light->save(is_on);

    // increment count value
    count++;

    // for the purpose of this demo, toggle the
    // light state based on the count value
    if((count % 2) == 0)
      is_on = true;
    else
      is_on = false;

    // update timer
    lastUpdate = millis();
    */
  //}
  if (millis() > (lastUpdate + IO_LOOP_DELAY)) {
    strip.setPixelColor(head, color); // 'On' pixel at head
    strip.setPixelColor(tail, 0);     // 'Off' pixel at tail
    strip.show();                     // Refresh strip
    // delay(20);                        // Pause 20 milliseconds (~50 FPS) Disabled for now, may cause problems with Adafruit IO

    if(++head >= NUMPIXELS) {         // Increment head index.  Off end of strip?
      head = 0;                       //  Yes, reset head index to start
      if((color >>= 8) == 0)          //  Next color (R->G->B) ... past blue now?
        color = 0xFF0000;             //   Yes, reset to red
    }
    if(++tail >= NUMPIXELS) tail = 0; // Increment, reset tail index
  }

}

// you can set a separate message handler for a single feed,
// as we do in this example for the sound feed
void handleSound(AdafruitIO_Data *data) {

  // print out the received sound value
  Serial.print("received <- sound \n");
  //Serial.print();

  // use the isTrue helper to get the
  // boolean state of the sound station
  /*
  if(data->isTrue())
    Serial.println("is on.");
  else
    Serial.println("is off.");
  */
}

void handleMotion(AdafruitIO_Data *data) {

  // print out received motion value
  Serial.print("received <- motion \n");
  //Serial.print();

}

void handleTestHearts(AdafruitIO_Data *data) {

  int reading = data->toInt();
  Serial.print("received <- testHearts ");
  Serial.println(reading);


}

// you can also attach multiple feeds to the same
// meesage handler function. both counter and counter-two
// are attached to this callback function, and messages
// for both will be received by this function.
void handleCount(AdafruitIO_Data *data) {

  Serial.print("received <- \n");

  // since we are using the same function to handle
  // messages for two feeds, we can use feedName() in
  // order to find out which feed the message came from.
  Serial.print(data->feedName());
  Serial.print(" ");

  // print out the received count or counter-two value
  Serial.println(data->value());

}
