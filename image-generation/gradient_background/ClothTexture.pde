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
    int ystep = 20;
    int xstep = 8;
  
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
    
    int steps = floor(random(4, 12));
    int step = 0;
    for (int i = 0; i < tex_h; i+=ystep) {
      int stepSize = floor((tex_w/xstep) / steps);
      for (int j = 0; j < tex_w; j += xstep) {
        if (step == stepSize) {
          idx = (idx + 1) % values.size();
          prevColor = nextColor;
          nextColor = colors[values.get(idx)];
          step = 0;
        }
        color tweenColor = lerpColor(prevColor, nextColor, float(step) / float(stepSize));
        surface.fill(tweenColor);
        surface.noStroke();
        surface.rect(j, i, xstep, ystep);
        step++;
      }
      
      // rotate
      idx = (idx + 1) % values.size();
      prevColor = nextColor;
      nextColor = colors[values.get(idx)];
      steps = floor(random(2, 8));
    }
    
    surface.filter(BLUR, 4);
  
    surface.endDraw();
  }
}
