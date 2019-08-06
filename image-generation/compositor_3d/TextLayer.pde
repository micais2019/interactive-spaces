import java.util.Date;

class TextLayer {
  String timestamp;
  int count, w, h;
  long ts;
  float scalar = 0.8;
  float tl_fudge = 0.4;
  boolean drawn = false;
  
  int fontSize = 14; // demo
  int nFontSize = 22;
  // int fontSize = 96; // big
  PFont nfont, bfont;
  
  boolean DEBUG_BORDER = false;
  
  PGraphics surface;
  
  TextLayer(int w, int h) {
    this.nfont = loadFont("TerminalGrotesque-Open-48.vlw");
    this.bfont = loadFont("Avara-Bold-48.vlw");
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }
  
  // "04.14.2019  14:25:24";
  String timestamp(long ts) {
    Date time = new Date(ts * 1000);
    String[] stamp = new String[11];
    
    stamp[0] = "04";
    stamp[1] = ".";
    stamp[2] = "29";
    stamp[3] = ".";
    stamp[4] = "2019";
    stamp[5] = "  ";
    stamp[6] = "11";
    stamp[7] = ":";
    stamp[8] = "22";
    stamp[9] = ":";
    stamp[10] = "37";
    
    return join(stamp, "");
  }
  
  void draw(long ts, int count) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    int lp = floor(fontSize / 4.0);
    
    surface.fill(0);
    surface.textFont(nfont, nFontSize);
    surface.text(timestamp(ts), lp, nFontSize);
    surface.textFont(nfont, nFontSize);
    surface.text(nf(count, 5) + "/75000", lp, h - nFontSize/4);
 
    surface.textFont(bfont, fontSize);
    
    // line spacing
    int tl = fontSize + floor(fontSize * 0.2);
    surface.textLeading(tl);
    
    // line height
    float lh = (surface.textAscent() * scalar + surface.textDescent() * scalar);

    String lorem[] = { 
      
      "Acknowledged nationally as a premier leader in art and", 
      "design education, MICA is deliberately cultivating a new", 
      "generation of artist—one that is capable of seamlessly ", 
      "integrating innovation entrepreneurship and creative citizenship",
      "with contemporary approaches to art, design and media. MICA is ",
      "redefining the role of the artists and designers as creative,",
      "solutions-oriented makers and thinkers who will drive social,",
      "cultural, and economic advancement for our future. As the oldest",
      "continuously degree-granting college of art and design in the",
      "nation, MICA is located in Baltimore, deeply connected to the",
      "community. It is a leading contributor to the creative economy",
      "regionally and a top producer of nationally and internationally",
      "recognized professional artists and designers."
    };
    
    float len = 0;
    for (int n=0; n < lorem.length; n++) {
      len = max(len, surface.textWidth(lorem[n]));
    }
    
    // try to calculate total height of text area
    float box = lh * lorem.length + (tl * tl_fudge * (lorem.length-1));
    
    if (DEBUG_BORDER) {
      surface.stroke(0);
      surface.strokeWeight(2);
    } else {
      surface.noStroke();
    }
    
    surface.fill(255);
    surface.rect(
      lp * 10 - 20, 
      h/2 - box/2 - lh, 
      len + 40, 
      box
    );
    
    surface.fill(0);
        

    String message = join(lorem, "\n"); 
    surface.text(message, lp * 10, h/2 - box/2 + lh);
    surface.endDraw();
    
    this.drawn = true;
  }
}
