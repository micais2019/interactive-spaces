
import processing.opengl.*;


ClothShape cloth;
ClothTexture tex;

PShape fabric;

void setup() {
  size(1000,1000,P3D);
  smooth(8);
   
  tex = new ClothTexture(1000, 1000);
  cloth = new ClothShape(300, 100);
  fabric = cloth.createShape(tex, this);
}

void draw() {
  background(255);
 
  // lights();
  directionalLight(255, 255, 255, 0, 0, -1);
  directionalLight(127, 127, 127, 0, 1, 0);
  pushMatrix();
  translate(width/2 - 50, 100, -400);
  rotateY(3.524867);
  rotateX(2.475575);
  noStroke();
  shape(fabric);
  popMatrix();
  
  /* cloth.update();
  fabric = cloth.createShape(tex, this); */
}

void mouseClicked() {
  // tex.createTexture();
  println(map(mouseX, 0, width, -1000, 1000), 
  mouseX * 1.0f/width * TWO_PI, 
  mouseY * 1.0f/height * TWO_PI);
}
