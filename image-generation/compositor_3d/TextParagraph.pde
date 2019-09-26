
class TextParagraph {
  int w, h;
  long ts;
  boolean drawn = false;

  int fontSize = 30; // demo
  // int fontSize = 96; // big
  PFont bfont;

  PGraphics surface;

  int border = int(width*0.02);

  TextParagraph(float w, float h) {
    this.bfont = createFont("Balto-Book.otf", fontSize);
    this.w = int(w);
    this.h = int(h); 
    this.surface = createGraphics(int(w), int(h), P3D);
  }


  void draw(long ts) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.fill(0);
    surface.textFont(bfont, fontSize);

    // line height
    String paragraph = 
"As the oldest continuously degree-granting college of art and design in the nation, MICA is acknowledged nationally as a leader among its peers—one that is deliberately cultivating a new generation of creatives and redefining the role of artists and designers in society." +"\n" +"\n" + "As a student here, you will be challenged to shape new and distinct career pathways. You will learn to integrate innovation, entrepreneurship, and creative citizenship with contemporary approaches to art, design, and media. You will leave the College empowered as a creative, solutions-oriented maker and thinker with the ability to drive cultural, social, and economic advancements that will impact our future. You will create work that breaks new ground while honoring tradition. You will make art and design that matters."      ;

    surface.text(paragraph, 20, 20, width*0.42, height*0.33);
    surface.endDraw();

    this.drawn = true;
  }
}
