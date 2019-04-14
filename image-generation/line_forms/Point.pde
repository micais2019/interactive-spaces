class Point {
  int x, y;
  int depth;
  
  ArrayList<Point> edges;
  
  Point(int _x, int _y, int _depth) {
    x = _x;
    y = _y;
    depth = _depth;
    edges = new ArrayList<Point>();
  }
  
  void add(Point other) {
    edges.add(other);
  }
  
//  Point offset(Point p) {
//    return new Point(x + p.x, y + p.y, depth + 1); 
//  }
}
