boolean MASK = true;
boolean DRAW_MASK = false;

background(255, 255, 0);

size(500, 500);

// drawing layer
PGraphics drawing = createGraphics(width, height);
drawing.beginDraw();
drawing.fill(0, 0, 128);
drawing.rect(0, 0, width, height);
drawing.endDraw();

PGraphics mask = createGraphics(width, height);
mask.beginDraw();
mask.noStroke();
mask.fill(255, 128);
mask.ellipse(width/2, height/2, 100, 100);
mask.endDraw();

if (MASK) {
  // I call the mask function on my drawing layer
  // with the mask layer as an argument.
  drawing.mask(mask);
  image(drawing, 0, 0);
} else if (DRAW_MASK) {
  image(mask, 0, 0);
} 
