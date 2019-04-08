// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/FGAwi7wpU8c

import peasy.*;
Planet sun;

float frequency; 

PeasyCam cam;

PGraphics prints;

//PImage[] textures = new PImage[3];

void setup() {
  size(700, 700, P3D);
  prints = createGraphics(500,500);
  cam = new PeasyCam(this, 500);
  sun = new Planet(50, 0, 0, prints);
  sun.spawnMoons(4, 1);
}

void draw() {
  background(255);
  
    for (int n=0; n < 50; n++) {
    frequency = random(5, 35);
    target(frequency, int(random(width)), int(random(height)));
  }
  //ambientLight(255,255,255);
  pointLight(255, 255, 255, 500, -500, 500);
  sun.show();
  //sun.orbit();
}

void target(float freq, int cx, int cy) {
  //for (float j = random(0,500); j<500; j+= random(0,50)){

  prints.beginDraw();

  for (float i = (freq*10); i > 0; i-= freq*3) {
    prints.strokeWeight(freq);
    //rotate(PI/3);
    prints.fill(255);
    prints.ellipseMode(CENTER);
    prints.ellipse(cx, cy, i, i);
  }
}
