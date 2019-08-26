import java.util.Date;

class TimeStamp {
  String timestamp;
  int count, w, h;
  long ts;
  float scalar = 0.8;
  boolean drawn = false;
  int nFontSize = 22;
  // int fontSize = 96; // big
  PFont nfont;

  PGraphics surface;

  TimeStamp(int w, int h) {
    this.nfont = loadFont("TerminalGrotesque-Open-48.vlw");
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }

  // "04.14.2019  14:25:24";
  String timestamp(long ts) {
    Date time = getDateFromTimestamp(ts);
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

  void draw(long ts) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.fill(0);
    surface.textFont(nfont, nFontSize);
    surface.text(timestamp(ts), 100, nFontSize);
    surface.endDraw(); 

    this.drawn = true;
  }
}
