import java.util.Date;
import java.text.SimpleDateFormat;

class TimeStamp {
  String timestamp;
  int count, w, h;
  long ts;
  float scalar = 0.8;
  boolean drawn = false;
  int nFontSize = 45;
  // int fontSize = 96; // big
  PFont nfont;

  PGraphics surface;

  TimeStamp(int w, int h) {
    this.nfont = createFont("Pitch-Bold.otf", nFontSize);
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }

  // "04/14/2019 02:25:24 PM";
  String timestamp(long ts) {
    Date time = getDateFromTimestamp(ts);
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a");
    String stamp = sdf.format(time);
    return(stamp);
  }

  void draw(long ts) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.background(0, 0);
    surface.textFont(nfont, nFontSize);
    surface.fill(0);
    for (int x = -1; x < 2; x++) {
      surface.text(timestamp(ts), 0, 37+x); // outline
      surface.text(timestamp(ts), x, 37);   // outline
    }
    surface.fill(255);
    surface.text(timestamp(ts), 0, 37);
    surface.endDraw(); 

    this.drawn = true;
  }
}
