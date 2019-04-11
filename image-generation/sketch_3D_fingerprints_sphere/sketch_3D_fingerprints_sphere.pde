// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/FGAwi7wpU8c

import peasy.*;
Planet sun;

float frequency; 

PeasyCam cam;

PGraphics prints;

int amtOfspheres = 4;

//PImage[] textures = new PImage[3];

void setup() {
  size(700, 700, P3D);
  prints = createGraphics(500, 500);
  cam = new PeasyCam(this, 500);
  frameRate(1);
}

void draw() {
  background(50, 52, 200);
  for (int n=0; n < 50; n++) {
    frequency = random(5, 35);
    target(frequency, int(random(width)), int(random(height)));
  }
  //ambientLight(255,255,255);
  pointLight(255, 255, 255, 500, -500, 500);
  sun = new Planet(50, 0, 0, prints);
  sun.spawnMoons(amtOfspheres, 1);
  sun.show();

  //PShape bg = createShape(BOX, 200, 200, 10);
  pushMatrix();
  rotateY(PI/3);
  rotateX(PI/3);

  //shape(bg, 0, 0);
  popMatrix();
  //sun.orbit();

  //saveFrame("spherefingerprintsdramatic-##.png");
}

void target(float freq, int cx, int cy) {

  prints.beginDraw();
  
  int numberofRings = 100;
  float spacebetweenRings = 3; //alter

  for (float i = (freq*numberofRings); i > 0; i-= freq*spacebetweenRings) {
    prints.strokeWeight(freq);
    //rotate(PI/3);
    prints.fill(255);
    prints.ellipseMode(CENTER);
    prints.ellipse(cx, cy, i, i);
  }

  prints.endDraw();
}
