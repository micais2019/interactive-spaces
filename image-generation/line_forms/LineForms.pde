class LineForms {

  boolean cells[][];
  int xstep, ystep;
  int xsteps, ysteps;
  Point root; 
  
  int width, height;
  
  PGraphics surface;
    
  int MAX_DEPTH = 2;
  int seed = 128;
  
  LineForms(int w, int h, int _xsteps, int _ysteps, int seed) {
    width = w;
    height = h;
    xsteps = _xsteps;
    ysteps = _ysteps;
    xstep = width / xsteps;
    ystep = height / ysteps;
    
    surface = createGraphics(width, height);
  }
  
  void generate() {
    // grow a tree
    int xorigin = int(random(xsteps - 2)) + 1;
    int yorigin = int(random(ysteps - 2)) + 1;
  
    // regenerate cell tracking table
    cells = new boolean[xsteps][ysteps];
    cells[xorigin][yorigin] = true;
  
    // create root
    root = new Point(xorigin, yorigin, 0);
    grow(root);
  }
  
  void grow(Point p) {
    ArrayList<int[]> nabes = neighbors(p.x, p.y, p.depth);
     
    if (nabes.size() == 0) return;
   
    for (int i = 0; i < (MAX_DEPTH); i++) {
      int idx = int(random(nabes.size()));
      
      int[] part = nabes.get(idx);
      nabes.remove(idx);
  
      // flag a cell as occupied
      cells[part[0]][part[1]] = true;
      Point nextp = new Point(part[0], part[1], p.depth + 1);
      p.add(nextp);
  
      // pick fewer at each depth
      if (p.edges.size() > (MAX_DEPTH - p.depth) || nabes.size() == 0) {
        break;
      }
      
    }
  
    // grow out a level
    if (p.depth + 1 < MAX_DEPTH && p.edges.size() > 0) {
      for (int e=0; e < p.edges.size(); e++) {
        grow((Point)p.edges.get(e));
      }
    }
  }
  
  // allow diagonals
  int offsets[][] = {
    {-1, -1}, {0, -1}, {1, -1}, 
    {-1, 0}, {1, 0}, 
    {-1, 1}, {0, 1}, {1, 1}
  };
  
  ArrayList<int[]> neighbors(int x, int y, int d) {
    ArrayList<int[]> out = new ArrayList<int[]>();
  
    for (int crd=0; crd < offsets.length; crd++) {
      int nx = x + offsets[crd][0];
      int ny = y + offsets[crd][1];
  
      // ignore spaces that are out of bounds or already taken
      if (nx < 0 || nx >= xsteps || ny < 0 || ny >= ysteps || cells[nx][ny]) {
        continue;
      }
      
      int coords[] = {nx, ny};
      out.add(coords);
    }
  
    // ** TOTAL RANDOMIZATION **
    // Collections.shuffle(out);
    
    return out;
  }
  
  void draw() {
    randomSeed(seed);
    generate();
  
    surface.beginDraw();
    surface.clear();
    surface.background(0);
    surface.ellipse(tx(root.x), ty(root.y), 10, 10);
    showTree(root);
    surface.endDraw();
    
    // noLoop();
  }
  
  // translate to the center of the step
  int tx(int x) { 
    return x * xstep + (xstep / 2);
  }
  int ty(int y) { 
    return y * ystep + (ystep / 2);
  }
  
  void showTree(Point p) {
    // draw leaf
    LineForm lf = new LineForm(xstep, ystep, color(255), 4 * (MAX_DEPTH - p.depth) + 1);
    lf.draw();
    surface.image(lf.surface, xstep * p.x, ystep * p.y);
  
    // loop through branches
    for (int e=0; e < p.edges.size(); e++) {
      Point other = p.edges.get(e);
      connect(p, other, 4 * (MAX_DEPTH - p.depth) + 1);
      showTree(other);
    }
  }
  
  void connect(Point a, Point b, int weight) {
    float gap = 48;
    
    // connect leaves
    int tpx = tx(a.x);
    int tpy = ty(a.y);
    int opx = tx(b.x);
    int opy = ty(b.y);
  
    float dx = opx - tpx;
    float dy = opy - tpy;
    float theta = atan2(dy, dx);
  
    float ax = tpx + (gap * cos(theta));
    float ay = tpy + (gap * sin(theta));
  
    float len = dist(tpx, tpy, opx, opy);
    float bx = tpx + ((len - gap) * cos(theta));
    float by = tpy + ((len - gap) * sin(theta));
  
    surface.stroke(255);
    surface.strokeWeight(weight);
    surface.line(ax, ay, bx, by);
  }
}
