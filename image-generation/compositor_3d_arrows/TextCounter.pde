import java.util.Date;

class TextCounter {
  int count, w, h;
  boolean drawn = false;

  int nFontSize = 22;
  PFont nfont;

  PGraphics surface;

  TextCounter(int w, int h) {
    this.nfont = loadFont("TerminalGrotesque-Open-48.vlw");
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }


  void draw( int count) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.fill(0);
    surface.textFont(nfont, nFontSize);
    surface.text(nf(count, 5) + "/75000",100,20);

    surface.endDraw();

    this.drawn = true;
  }
}
