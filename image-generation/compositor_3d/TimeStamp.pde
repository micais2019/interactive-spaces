import java.util.Date;
import java.text.SimpleDateFormat;

class TimeStamp {
  String timestamp;
  int count, w, h;
  long ts;
  float scalar = 0.8;
  boolean drawn = false;
  int nFontSize = 40;
  // int fontSize = 96; // big
  PFont nfont;

  PGraphics surface;

  TimeStamp(int w, int h) {
    this.nfont = createFont("Pitch-Bold.otf", nFontSize);
    this.w = w;
    this.h = h; 
    this.surface = createGraphics(w, h, P3D);
  }

  // "04.14.2019  14:25:24";
  String timestamp(long ts) {
    Date time = getDateFromTimestamp(ts);
    SimpleDateFormat sdf = new SimpleDateFormat("MM.dd.yyyy HH:mm:ss");
    String stamp = sdf.format(time);
    //println(stamp);
    //String[] stamp = new String[11];
    //month day year hour minute second

    /*stamp[0] = "04";
     stamp[1] = ".";
     stamp[2] = "20";
     stamp[3] = ".";
     stamp[4] = "2019";
     stamp[5] = "  ";
     stamp[6] = "9";
     stamp[7] = ":";
     stamp[8] = "02";
     stamp[9] = ":";
     stamp[10] = "15";
     
     return join(stamp, "");*/
    return(stamp);
  }

  void draw(long ts) {
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.fill(0);
    surface.textFont(nfont, nFontSize);
    surface.text(timestamp(ts),0,25);
    surface.endDraw(); 

    this.drawn = true;
  }
}
