/**
 * Double Random 
 * by Ira Greenberg.  
 * 
 * Using two random() calls and the point() function 
 * to create an irregular sawtooth line.
 */
import peasy.PeasyCam;
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;


Toroid toroid;

PShape torus;

PGraphics pix;
float frequency; 

void setup() {  
  size(1280, 800, P3D);
  stroke(255);
  frameRate(1);
  pix = createGraphics(640, 360);
} 


void draw() {

  background(50, 52, 200);
  pointLight(255, 255, 255, 200, 0, -500);

  float pixelsize = 10;//random(5, 100); //alter

  pix.beginDraw();
  pix.background(255);
  pix.noStroke();
  for (int x = 0; x<width; x+=pixelsize) {
    for (int y=0; y < height; y+=pixelsize) {  
      pix.rect(x, y, pixelsize, pixelsize);
      if (x> random(0, 600) && y>random(0, 600)) {
        pix.fill(255);
      } else {
        pix.fill(0);
      }
    }
  }
  toroid = new Toroid(this, 100, 100);
  toroid.setRadius(random(20, 50), random(20, 50), 80);
  toroid.rotateToX(radians(-30));
  toroid.rotateToZ(random(1, 5));
  toroid.rotateToY(random(1, 3));
  toroid.scale(0.5);
  toroid.moveTo(new PVector(300, 200, 0));
  toroid.stroke(color(0, 0, 60));
  toroid.fill(255);
  toroid.strokeWeight(0.8f);
  toroid.setTexture(pix);
  toroid.drawMode(S3D.TEXTURE);
  toroid.draw();

  //saveFrame("high###.png");
}
