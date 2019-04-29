class TextLayer {
  String timestamp;
  int count, w, h;
  long ts;
  
  int fontSize = 24;
  
  PGraphics surface;
  PGraphics words;
  
  TextLayer(int w, int h) {
    this.w = w;
    this.h = h;
  }
  
  void create(long ts, int count) {

    
    surface = createGraphics(w, h, P2D);
    
    surface.beginDraw();
    surface.smooth(8);
    surface.stroke(0);
    surface.fill(0);
   
    PFont font;
    
    font = loadFont("TradeGothic-Bold-24.vlw");
    // font = createFont("TradeGothic-Bold", fontSize);
    int tl = fontSize + floor(fontSize * 0.2);
    int lp = floor(fontSize / 4.0);
    
    surface.textFont(font);
    
    // line spacing
    surface.textLeading(tl);
    // line height
    float lh = (surface.textAscent() + surface.textDescent());
    
    surface.text("04.14.2019  14:25:24", lp, lh);
    
    String lorem[] = { 
      "Lorem ipsum dolor sit amet, consectetur adip", 
      "iscing elit, sed do eiusmod tempor incididunt", 
      "ut labore et dolore magna aliqua. Consequat", 
      "interdum varius sit amet mattis vulputate enim.",
      "Faucibus turpis in eu mi. Id donec ultrices",
      "tincidunt arcu non. Pellentesque dignissim enim",
      "sit amet venenatis urna cursus eget nunc.",
      "Accumsan sit amet nulla facilisi morbi. Cras",
      "fermentum odio eu feugiat pretium nisl." 
    };

    float len = 0;
    for (int n=0; n < lorem.length; n++) {
      len = max(len, surface.textWidth(lorem[n]));
    }
    
    // try to calculate total height of text area
    float box = lh * lorem.length + (tl * (lorem.length-1));
    
    // surface.stroke(0);
    surface.noStroke();
    surface.fill(255);
    surface.rect(lp * 10 - 10, h/2 - box/2, len + 20, box);
    
    surface.fill(0);
    surface.text(join(lorem, "\n"), lp * 10, h/2 - box/2 + lh);
    surface.text(nf(count, 5) + "/75000", lp, h - lh/4);
    
    surface.endDraw();
  }
  
  void words() {
  }
}
