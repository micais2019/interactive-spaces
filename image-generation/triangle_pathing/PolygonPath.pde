class PolygonPath {
  Point[] points;
  int max_counter;
  
  PolygonPath(Point[] points, int max_counter) {
    this.points = points;
    this.max_counter = max_counter;
  }
  
  Point point(int timer) {
    int counter = timer % max_counter;
    float progress = map(counter, 0, max_counter, 0.0, 1.0);
    float x = 0, y = 0;
    
    // map timer value into progress around the shape, 
    // regardless of how many segments it has
    Point from = new Point(),
          to = new Point();
    float segment_progress = 0;
    for (int n=0; n < points.length; n++) {
      float startrange = map(n, 0, points.length, 0, 1.0);
      float endrange   = map(n + 1, 0, points.length, 0, 1.0);
      
      if (startrange < progress && progress < endrange) {
        // get current % along segment
        segment_progress = map(progress - startrange, 
          0, (endrange - startrange),
          0, 1.0
        );
        from = points[n];
        to = points[(n + 1) % points.length];
      }
    }
    
    x = lerp(from.x, to.x, segment_progress);
    y = lerp(from.y, to.y, segment_progress);
    
    return new Point(x, y);
  }

  // handle other timer data types
  Point point(float timer) {
    return this.point(int(timer));
  }

  Point point(long timer) {
    return this.point(int(timer));
  }

}
