boolean MASK = true;
boolean DRAW_MASK = false; 

PGraphics lines;
PGraphics splash;
float frequency= random(1, 30); 

void setup() {
  size(700, 700);

  noStroke();
  noLoop();  // Run once and stop
  splash = createGraphics(700, 700);
  lines = createGraphics(700, 700);
}

void draw() {
  background(255);

  //lines texture
  lines.beginDraw();
  lines.background(255);
  for (int i = 0; i < 500; i+= frequency*2) {  
    lines.pushMatrix();
    lines.strokeWeight(frequency);
    // rotate(1);
    lines.line(i, 0, i, width*3); 
    lines.popMatrix();
  }

  lines.endDraw();

  //splash mask
  splash.beginDraw();
  splash.noStroke();
  splash.pushMatrix();
  for (int i = 0; i <10; i++) {
    //triangle(width/2, height/2, width/3, height/2, random(width), random(height));
    splash.triangle(width/2, height/2, width/3, height/2, random(0, width/4*3), random(height));
  }
  splash.popMatrix();
  splash.endDraw();  


  imageMode(CENTER);

  if (MASK) {
    // I call the mask function on my drawing layer
    // with the mask layer as an argument.
    lines.mask(splash);
    image(lines, width/2, height/2);
  } else if (DRAW_MASK) {
    image(splash, 0, 0);
  }
}
