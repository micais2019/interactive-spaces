import java.util.*; 

class LineForm {
  PGraphics surface;
  
  int w, h, weight;
  color c;
  int diam;
  
  LineForm(int _w, int _h, color _c, int _weight) {
    w = _w;
    h = _h;
    c = _c;
    weight = _weight;
    diam = h / 3;
    setup();
  }
   
  void setup() {
    surface = createGraphics(w, h);
  }
  
  void draw() {
    // DO DRAWINGS HERE
    
    surface.beginDraw();
    surface.smooth();
    surface.noFill();
    surface.stroke(c);
    surface.strokeWeight(weight);
    surface.ellipseMode(CENTER);
    surface.ellipse(w/2, h/2, diam, diam);
    surface.endDraw();
  }
}
