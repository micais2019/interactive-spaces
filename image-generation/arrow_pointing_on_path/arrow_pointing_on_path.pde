int index=0;
int MAX_COUNTER = 800;
PShape arrow;

void setup() {
  size(500, 200);
  
  arrow = createShape();
  
  arrow.beginShape();
  arrow.fill(0);
  arrow.stroke(0);
  arrow.strokeWeight(2);
  arrow.vertex(0, 0);
  arrow.vertex(7, 7);
  arrow.vertex(0, 14);
  arrow.endShape(CLOSE);

}

void draw() {
  background(255);
  index += 1;
  
  stroke(0, 0, 128);
  pushMatrix();
  translate(width/2, height/2);
  for (int n=0; n < MAX_COUNTER; n++) {
    Point a = getEllipsePoint(n, 100, 1.045, 0.19);
    point(a.x, a.y);
  }
  popMatrix();
  
  
  Point arrow_center = getEllipsePoint((index+100) % MAX_COUNTER, 100, 1.045, 0.19);
  Point next_center = getEllipsePoint((index+101) % MAX_COUNTER, 100, 1.045, 0.19);
  
  float ang = atan2(next_center.y - arrow_center.y, next_center.x - arrow_center.x);
 
  fill(0);
  stroke(0);
  pushMatrix();
  translate(width/2 + arrow_center.x, height/2 + arrow_center.y);
  rotate(ang);
  shape(arrow, -6, -6);
  popMatrix();
}
  

  
  
Point getEllipsePoint(long counter, float radius, float wide, float flat) {
  float progress = map(counter, 0, MAX_COUNTER, 0, TWO_PI);
  //        > 1.0 means wider
  float x = wide * radius * cos(progress);
  //        < 1.0 means flatter
  float y = flat * radius * sin(progress);

  return new Point(x, y);
}
