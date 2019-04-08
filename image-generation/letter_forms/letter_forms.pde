
import java.util.Date;
Date d;

void setup() {
  size(600, 600);
  frameRate(2);
}

long a = 0;
void draw() {
  background(0);
  Date d = new Date();
  println(d.getTime()/ 1000);
  LetterForm lf = getLetter("a", a, 2, color(128, 128, 0));
  lf.draw();

  image(lf.surface, 0, 0);

  a += 0.005;
}
