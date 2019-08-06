int[] origin, p1, p2;
int STEPS = 75000; // higher steps means slower movement

void setup() {
  size(400, 400);
  origin = new int[]{ 0, height };
  p1 = new int[]{ width/2, 0 };
  p2 = new int[]{ width, height };
}

void draw() {
  background(128);
  fill(255); 
  stroke(0);
  
  // overall progress around the shape
  int point = millis() % STEPS;
  float prog = map(point, 0, STEPS, 0.0, 1.0);
  text(prog, 10, 10);
  
  // Movement along each line segment. This could be 
  // expanded to as many segments as you want, as long
  // as each segment has its own start and end point.  
  float segment_progress;
  int[] from, to;
  if (prog < 0.33) {
    // line 1 from origin to p1 
    segment_progress = map(prog, 0, 0.33, 0, 1.0);
    from = origin;
    to = p1;
  } else if (prog < 0.66) {
    // line 2 from p1 to p2
    segment_progress = map(prog, 0.33, 0.66, 0, 1.0);
    from = p1;
    to = p2;
  } else {
    // line 3 from p2 to origin
    segment_progress = map(prog, 0.66, 1.0, 0, 1.0);
    from = p2;
    to = origin;
  }
  
  float x = lerp(from[0], to[0], segment_progress);
  float y = lerp(from[1], to[1], segment_progress);
  
  ellipse(x, y, 10, 10);
}
