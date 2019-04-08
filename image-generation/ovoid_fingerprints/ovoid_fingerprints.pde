boolean MASK = true;
boolean DRAW_MASK = false;
float frequency; 

PGraphics prints;
PGraphics ovoid;

void setup() {
  size(800, 800);
  frameRate(1);

  prints = createGraphics(800, 800);
  ovoid = createGraphics(800, 800);
}

void draw() {
  background(255);
  for (int n=0; n < 50; n++) {
    frequency = random(5, 35);
    target(frequency, int(random(width)), int(random(height)));
  }
  //mask layer

  ovoid.beginDraw();
  ovoid.clear();
  ovoid.noStroke();
  ovoid.fill(255);

  for (int i = 1; i < 6; i ++){
  ovoid.pushMatrix();
  ovoid.translate(random(width), random(height/2));
  ovoid.scale(random(0.5, 3));
  ovoid.rotate(random(-0.5,0.5));
  ovoid.beginShape();
  ovoid.vertex(0, -100);
  ovoid.bezierVertex(25, -100, 40, -65, 40, -40);
  ovoid.bezierVertex(40, -15, 25, 0, 0, 0);
  ovoid.bezierVertex(-25, 0, -40, -15, -40, -40);
  ovoid.bezierVertex(-40, -65, -25, -100, 0, -100);
  ovoid.endShape();
  ovoid.popMatrix();
   }
  ovoid.endDraw();

  //boolean
  if (MASK) {
    // I call the mask function on my drawing layer
    // with the mask layer as an argument.
    prints.mask(ovoid);
    image(prints, 0, 0);
  } else if (DRAW_MASK) {
    image(ovoid, 0, 0);
  }
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
