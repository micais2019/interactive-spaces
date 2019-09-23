import java.util.Date;

class TextCounter {
  int count, w, h;
  boolean drawn = false;

  int nFontSize = 80;
  PFont nfont;

  PGraphics surface;

  TextCounter(int w, int h) {
    this.nfont = createFont("Pitch-Bold.otf", 80);
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
    surface.text(nf(count, 5) + "/75000",100,nFontSize);

    surface.endDraw();

    this.drawn = true;
  }
}