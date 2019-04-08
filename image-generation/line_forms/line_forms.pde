// line-forms

LineForms lineForms; 
int seed = 128;

void setup() {
  size(2400, 1600);
  background(0); 
  frameRate(16);
  
  lineForms = new LineForms(800, 1600, 4, 8, seed);
}

void draw() {
  lineForms.draw();
  image(lineForms.surface, 1100, 0);
  noLoop();
}

void keyPressed() {
  lineForms.seed++;
  loop();
}
