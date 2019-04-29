class ClothTexture {
  
  PGraphics2D surface;
  
  int w, h;
  
  ClothTexture(int w, int h) {
    this.w = w;
    this.h = h;
    createTexture();
  }

  public void createTexture() {
    int tex_w = w;
    int tex_h = h;
    int ystep = 20;
    int xstep = 10;
  
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
      
    // now create the real texture
    surface = (PGraphics2D) createGraphics(tex_w, tex_h, P2D);
    
    color newColor = colors[int(random(0, 6))];
    color prevColor = colors[int(random(0, 6))];
    surface.beginDraw();
    for (int i = 0; i < tex_w; i+=ystep) {
      for (int j = 0; j < tex_h; j+=xstep) {
        color tweenColor = lerpColor(newColor, prevColor, float(j)/float(tex_w));
        surface.fill(tweenColor);
        surface.noStroke();
        surface.rect(j, i, xstep, ystep);
        //int xPostion = lerp(0,width,20.0);
      }
      newColor = prevColor;
      prevColor = colors[int(random(0, 6))];
    }
    
    surface.filter(BLUR, 4);
  
    surface.endDraw();
  
  }
}
