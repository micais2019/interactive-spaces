
class TextParagraph {
  int w, h;
  long ts;
  boolean drawn = false;

  int fontSize = 14; // demo
  // int fontSize = 96; // big
  PFont bfont;

  PGraphics surface;

  int border = 20;

  TextParagraph(int w, int h) {
    this.bfont = loadFont("Avara-Bold-48.vlw");
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }


  void draw(long ts) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.fill(0);
    surface.textFont(bfont, fontSize);

    // line height
    String paragraph = 
      "Acknowledged nationally as a premier leader in art and design education, MICA is deliberately cultivating a new generation of artist—one that is capable of seamlessly integrating innovation entrepreneurship and creative citizenship with contemporary approaches to art, design and media. MICA is redefining the role of the artists and designers as creative, solutions-oriented makers and thinkers who will drive social cultural, and economic advancement for our future. As the oldest continuously degree-granting college of art and design in the nation, MICA is located in Baltimore, deeply connected to the community. It is a leading contributor to the creative economy regionally and a top producer of nationally and internationally recognized professional artists and designers."
      ;

    surface.text(paragraph, 20, 20, 480, 270);
    surface.endDraw();

    this.drawn = true;
  }
}
