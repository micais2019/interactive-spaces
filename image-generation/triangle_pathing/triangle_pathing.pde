Point origin, p1, p2;
PolygonPath triangle, zigs;

int STEPS = 75000; // higher steps means slower movement

void setup() {
  size(400, 400);
  origin = new Point(0, height);
  p1 = new Point(width/2, 0);
  p2 = new Point(width, height);
  triangle = new PolygonPath(new Point[]{ origin, p1, p2 }, 15000);
  
  // randomize zig zag points (don't do this in intentional sketches :P)
  Point[] zig_points = new Point[20];
  for (int i=0; i < zig_points.length; i++) {
    zig_points[i] = new Point(random(width), random(height));
  }
  zigs = new PolygonPath(zig_points, 10000);
}

void draw() {
  background(128);
  fill(255); 
  noStroke();
  
  long now = millis();
  text(now, 10, 10);
  
  Point tri_center = triangle.point(now);
  fill(255);
  ellipse(tri_center.x, tri_center.y, 10, 10);
  
  Point zig_center = zigs.point(now);
  fill(0, 255, 0);
  ellipse(zig_center.x, zig_center.y, 10, 10);
  
}
