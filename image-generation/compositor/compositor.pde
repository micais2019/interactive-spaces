
////
// Book Cover Generator 0.1
////

/*
Flow:
- get data at timestamp
- call drawings, passing them data and timestamp
- composite drawings into cover image
- add time and text values


Final:
  File type: print-ready PDF
  Size (front, back, spine): +/- 8.5” height x +/- 16” width
  Images: 300 dpi
  Bleed: 3 mm, with crop marks
  Color: Standard, print-ready PDF settings
*/

boolean DEBUG = false;

float coverWidth = 16.5;
float coverHeight = 8.5;
int dpi = 300;

int coverFinalWidth = int(coverWidth * dpi);
int coverFinalHeight = int(coverHeight * dpi);

/* Data for sketches */
long now;
String motion, temperature;
ArrayList<String> sound, mood;

void setup() {
  size(100, 100, P3D);
  
  now = getTimestampFromArgs();
  println("-- running at", now, "--");

  DataGetter dg = new DataGetter();
  
  motion = dg.getValue("split-motion", now);
  sound = dg.getHistory("sound", now, 10);
  mood = dg.getHistory("mood", now, 100);
  temperature = dg.getCurrentTemperature(now);
  
  println("split-motion:", motion);
  println("sounds:", sound);
  println("mood:", mood);
  println("temperature:", temperature);
}

void draw() {
  println("DRAWING ", coverFinalWidth, "x", coverFinalHeight);
  PGraphics canvas = createGraphics(coverFinalWidth, coverFinalHeight);

  canvas.beginDraw();
  canvas.background(255);

  PGraphics letterform = drawWord("something", now, coverFinalWidth / 2, coverFinalHeight);
  canvas.image(letterform, coverFinalWidth / 2, 0);

  canvas.endDraw();
  String filename = String.format("%s_composite_%d_%d.png", now, coverFinalWidth, coverFinalHeight);
  println("save to", filename);
  canvas.save(filename);

  exit();
}
