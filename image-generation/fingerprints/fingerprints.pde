float frequency; 

void setup() {
  size(500, 500);
  background(255);
  frameRate(1);
}

void draw() {
  background(255);
  for (int n=0; n < 50; n++) {
    frequency = random(10, 35);
    target(frequency, int(random(width)), int(random(height)));  
  }
}
  
void target(float freq, int cx, int cy) {
  //for (float j = random(0,500); j<500; j+= random(0,50)){
  for (float i = (freq*10); i > 0; i-= freq*3) {
    strokeWeight(freq);
    //rotate(PI/3);
    fill(255);
    ellipseMode(CENTER);
    ellipse(cx, cy, i, i);
  }
}
