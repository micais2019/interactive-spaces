class LetterForm {
  PGraphics surface;
  float timestamp;
  int weight;
  color colr;

  LetterForm(float ts, int w, color c) {
    timestamp = ts;
    weight = w;
    colr = c;
    this.setup();
  }

  void setup() { }

  void draw() { }
  
  void update(float ts) {
    timestamp = ts;
  }
}
