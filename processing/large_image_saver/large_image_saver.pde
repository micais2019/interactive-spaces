/*
 * Example 5: High-resolution off-screen buffer
 * From: https://processing.org/tutorials/print/
 */

PGraphics big;  // Declare a PGraphics variable to hold the big image
  
// 4800 x 2550 is 16"w x 8.5"h @ 300dpi
int dpi = 360;
int w = 16 * dpi;
int h = floor(8.5 * dpi);

// MICA palette
color palette[] = {
  color(0, 71, 187), // blue
  color(16, 6, 159), // deep blue
  color(254, 219, 0), // yellow
  color(225, 0, 152), // pink
  color(45, 200, 77), // green
  color(254, 80, 0)  // orange
};

PImage logoImg;
int genDelay = 3000; // generate every 3000ms
long lastGen = 0;
int imgCount = 0;

void setup() {
  size(640, 480);
  frameRate(10);
  background(0);
  logoImg = loadImage("MICA_PrimarySig_RegularScale_Black.png");
}

void draw() {
  background(120);
  fill(0);
  rect(random(width), random(height), 40, 40);
  text(imgCount, 10, 10);

  long start = millis();
  if (start - lastGen > genDelay) {
    thread("generate");
    long finish = millis();
    lastGen = finish;
    imgCount += 1;
  }
}

void generate() {
  long ts = System.currentTimeMillis();
  
  
  big = createGraphics(w, h);
  big.beginDraw();

  big.background(palette[ int(random(palette.length)) ]);
  big.image(logoImg, w/2 + 100, 100);

  big.stroke(0);
  big.strokeWeight(30);
  big.line(w/2, 0, w/2, h);     // draw the spine

  big.endDraw();                // Stop drawing to the PGraphics object
  
  // save file
  String filename = String.format("%s_%d_%d.png", ts, int(w), int(h));
  println("saving file to ", filename);
  big.save(filename);
}
