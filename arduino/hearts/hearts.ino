#include <ESP8266WiFi.h>
#include "PubSubClient.h"

// Update these with values suitable for your network.
const char* ssid = "";
const char* password = "";
const char* mqtt_server = "";

const char* topics[] = {
  "mica_ia/feeds/split-motion",
  "mica_ia/feeds/mood",
  "mica_ia/feeds/sound",
  "mica_ia/feeds/sound-2",
  NULL
};

#define IO_USERNAME  "" // no sensitive information here!
#define IO_KEY       "" // no sir!

WiFiClient espClient;
PubSubClient client(espClient);

/*************************** DotStar Setup **********************************/

#include <Adafruit_DotStar.h>
// Because conditional #includes don't work w/Arduino sketches...
#include <SPI.h>         // COMMENT OUT THIS LINE FOR GEMMA OR TRINKET
//#include <avr/power.h> // ENABLE THIS LINE FOR GEMMA OR TRINKET

#define NUMPIXELS 16 // Number of LEDs in strip
int sound1Start = 0;
int sound1End = NUMPIXELS / 4;
int motionStart = sound1End;
int motionEnd = sound1End + (NUMPIXELS / 4);
int moodStart = motionEnd;
int moodEnd = motionEnd + (NUMPIXELS / 4);
int sound2Start = moodEnd;
int sound2End = moodEnd + (NUMPIXELS / 4);

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

/***************************************************************************/

#define VALUES_MAX 64

int mood_values[VALUES_MAX];

#define SOUND_1_BASE 0xFF1899
#define MOTION_BASE  0x0033FF
#define SOUND_2_BASE 0x44FF30

uint32_t green = strip.Color(255, 0, 0);
uint32_t yellow = strip.Color(153, 255, 0);
uint32_t orange = strip.Color(21, 234, 0); // Suggested: RGB 234, 21, 0
uint32_t magenta = strip.Color(0, 216, 39); // 66, 244, 167
uint32_t red = strip.Color(0, 255, 0);
uint32_t purple = strip.Color(5, 196 , 255);
uint32_t aqua = strip.Color(255, 0, 255);
uint32_t aizome = strip.Color(0, 0, 153);

uint32_t soundC = SOUND_1_BASE;
uint32_t sound2C = SOUND_2_BASE;
uint32_t motionC = MOTION_BASE;
uint32_t moodC = 0x0;

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Setting value arrays
  for (int n = 0; n < VALUES_MAX; n++) {
    // -1 is a safe "this value is not set" value, since none of our data streams will produce -1
    //sound_values[n] = -1;
    //motion_values[n] = -1;
    mood_values[n] = -1;
  }

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

uint32_t dim(uint32_t color, float perc) {
  float mult = 1.0 - constrain(perc, 0.0, 1.0);

  uint32_t r = (float)(color & 0xFF0000) * mult;
  uint32_t g = (float)(color & 0x00FF00) * mult;
  uint32_t b = (float)(color & 0x0000FF) * mult;

  return (r & 0xFF0000) | (g & 0x00FF00) | (b & 0x0000FF);
}

// fill dots in a region with a color
void fill(uint32_t c, int start_i, int end_i) {
  for(uint16_t i=start_i; i<end_i; i++) {
    strip.setPixelColor(i, c);
  }
  strip.show();
}

// dimming variables
long lastTime = 0;
const int interval = 40;

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  long now = millis();
  if (now > lastTime + interval) {
    fill(soundC, sound1Start, sound1End);
    fill(motionC, motionStart, motionEnd);
    //fill(moodC, moodStart, moodEnd);
    fill(sound2C, sound2Start, sound2End);

    for (int i=0; 0 < VALUES_MAX; i++) {
      if (mood_values[i] != -1) {
        if (mood_values[i] == 0) {
          moodC = green;
        } else if (mood_values[i] == 1) {
          moodC = yellow;
        } else if (mood_values[i] == 2) {
          moodC = orange;
        } else if (mood_values[i] == 3) {
          moodC = magenta;
        } else if (mood_values[i] == 4) {
          moodC = red;
        } else if (mood_values[i] == 5) {
          moodC = purple;
        } else if (mood_values[i] == 6) {
          moodC = aqua;
        } else if (mood_values[i] == 7) {
          moodC = aizome;
        } else {
          moodC = red;
        }
        fill(moodC, moodStart, moodEnd);
      }
        break; //unset or too big!
    }

    soundC = dim(soundC, 0.05);
    sound2C = dim(sound2C, 0.05);
    motionC = dim(motionC, 0.05);

    lastTime = now;
  }
}


/* do something when data arrives on any feed
 *  `topic` - the full MQTT feed topic. "mica_ia/feeds/sound", etc.
 *  `payload` - data
 *  `length` - length of the payload
 */
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("got ");
  Serial.print(length);
  Serial.print(" bytes of ");
  Serial.println(topic);

  if (String(topic).endsWith("split-motion")) {
    motionC = MOTION_BASE;
  } else if (String(topic).endsWith("sound")) {
    soundC = SOUND_1_BASE;
  } else if (String(topic).endsWith("sound-2")) {
    sound2C = SOUND_2_BASE;
  } else if (String(topic).endsWith("mood")) {
    Serial.print("got ");
    Serial.print(topic);
    Serial.print(" value is: ");
    String moodReading = String((char *)payload);
    Serial.println(moodReading);
    split(moodReading, mood_values);
  }
}


// Function written for splitting long strings!
void split(String input, int vals[]) {
  // reset
  for (int n = 0; n < VALUES_MAX; n++) {
    vals[n] = -1;
  }

  int j = 0, i = 0, n = 0;
  while (i < input.length() && n < VALUES_MAX) {
    j = input.indexOf(" ", i);
    if (j > 0) {
      vals[n] = input.substring(i, j).toInt();
      i = j + 1;
    } else {
      // end of the string or string with no spaces, capture what's left
      vals[n] = input.substring(i, input.length()).toInt();
      i = input.length();
    }
    n++;
  }
}

////////////////////////
// Connection helpers //
////////////////////////

void setup_wifi() {
  delay(10);

  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());
}

/*
 *  Basic MQTT connection function. This is
 */
void reconnect() {
  // loop until reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    // Create a random client ID
    String clientId = "mica-ia-";
    clientId += String(random(0xffff), HEX);

    // Attempt to connect
    if (client.connect(clientId.c_str(), IO_USERNAME, IO_KEY)) {
      Serial.println("connected");

      // subscribe after connection to all feeds in `topics` list.
      int idx = 0;
      const char *topic = topics[idx];
      delay(100);
      while (topic != NULL) {
        Serial.println(topic);
        client.subscribe(topic);
        topic = topics[++idx];
        delay(100);
      }

    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");

      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
