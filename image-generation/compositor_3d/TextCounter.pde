import java.util.Date;

class TextCounter {
  int count, w, h;
  boolean drawn = false;

  int nFontSize = 45;
  PFont nfont;

  PGraphics surface;

  TextCounter(int w, int h) {
    this.nfont = createFont("Pitch-Bold.otf", nFontSize);
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }

  void draw(int count) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.background(0,0);
    surface.textFont(nfont, nFontSize);
    for (int x = -1; x < 2; x++) {
        surface.fill(0);
        surface.text("#"+ nf(count, 5) + " of 75000", 0, 37+x); // outline
        surface.text("#"+ nf(count, 5)+ " of 75000", x, 37); //outline
    }
    surface.fill(255);
    surface.text("#"+ nf(count, 5)+ " of 75000", 0, 37);

    surface.endDraw();

    this.drawn = true;
  }
}
