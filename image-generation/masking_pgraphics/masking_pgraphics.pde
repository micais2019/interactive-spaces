boolean MASK = true;
boolean DRAW_MASK = false;

PGraphics drawing;
PGraphics mask;

int w = 300, h = 300;

void setup() {
  background(255, 255, 0);
  
  size(800, 800);
  
  // drawing layer
  drawing = createGraphics(w, h);
  drawing.beginDraw();
  drawing.fill(0, 0, 128);
  drawing.rect(0, 0, w, h);
  drawing.endDraw();
  
  // mask layer
  mask = createGraphics(w, h);
  mask.beginDraw();
  mask.stroke(255);
  mask.noFill();
  mask.strokeWeight(30);
  mask.ellipse(w/2, h/2, 100, 100);
  mask.endDraw();
}

void draw() { 
  background(255, 255, 0);
  imageMode(CENTER);
  if (MASK) {
    // I call the mask function on my drawing layer
    // with the mask layer as an argument.
    drawing.mask(mask);
    image(drawing, width/2, height/2, random(width) + 50, random(height) + 50);
  } else if (DRAW_MASK) {
    image(mask, 0, 0);
  } 
}
