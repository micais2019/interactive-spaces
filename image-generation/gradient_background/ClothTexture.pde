class ClothTexture {
  
  PGraphics2D surface;
  
  int w, h;
  IntList values;
  
  ClothTexture(int w, int h, IntList values) {
    this.w = w;
    this.h = h;
    this.values = values;
    
    // now create the real texture
    surface = (PGraphics2D) createGraphics(w, h, P2D);
    
    createTexture();
  }

  public void createTexture() {
    int tex_w = w;
    int tex_h = h;
    int ystep = 8;
    int xstep = 12;
  
    values.shuffle();
    
    color[] colors  = {  
      #0061ff, 
      #ffff00, 
      #ff0000, 
      #009104, 
      #ff0f97, 
      #0073a8, 
      #00FF9F, 
      #00FDFF, 
    };
      
    int idx = 1;
    color prevColor = colors[values.get(idx-1)];
    color nextColor = colors[values.get(idx)];
    surface.beginDraw();
    
    int steps = floor(random(2, 6));
    int step = 0;
    for (int j = 0; j < tex_w; j += xstep) {
      int stepCount = floor((tex_h/ystep) / steps);
      println("col", j, "steps", steps, "stepCount", stepCount);
      for (int i = 0; i < tex_h; i += ystep) {
        if (step >= stepCount) {
          idx = (idx + 1) % values.size();
          prevColor = nextColor;
          nextColor = colors[values.get(idx)];
          step = 0;
        }
        color tweenColor = lerpColor(prevColor, nextColor, float(step) / float(stepCount));
        surface.fill(tweenColor);
        surface.noStroke();
        surface.rect(j, i, xstep, ystep);
        step++;
      }
      
      // rotate
      idx = (idx + 1) % values.size();
      prevColor = nextColor;
      nextColor = colors[values.get(idx)];
      steps = floor(random(2, 6));
    }
    
    surface.filter(BLUR, 2);
  
    surface.endDraw();
  }
}
