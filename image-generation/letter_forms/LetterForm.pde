LetterForm getLetter(String l, float ts, int w, color c) {
  switch(l){
    case "a": return new LetterA(ts, w, c);
    case "b": return new LetterB(ts, w, c);
    case "c": return new LetterC(ts, w, c);
    case "d": return new LetterD(ts, w, c);
    case "e": return new LetterE(ts, w, c);
    case "f": return new LetterF(ts, w, c);
    case "g": return new LetterG(ts, w, c);
    case "h": return new LetterH(ts, w, c);
    case "i": return new LetterI(ts, w, c);
    case "j": return new LetterJ(ts, w, c);
    case "k": return new LetterK(ts, w, c);
    case "l": return new LetterL(ts, w, c);
    case "m": return new LetterM(ts, w, c);
    case "n": return new LetterN(ts, w, c);
    case "o": return new LetterO(ts, w, c);
    case "p": return new LetterP(ts, w, c);
    case "q": return new LetterQ(ts, w, c);
    case "r": return new LetterR(ts, w, c);
    case "s": return new LetterS(ts, w, c);
    case "t": return new LetterT(ts, w, c);
    case "u": return new LetterU(ts, w, c);
    case "v": return new LetterV(ts, w, c);
    case "w": return new LetterW(ts, w, c);
    case "x": return new LetterX(ts, w, c);
    case "y": return new LetterY(ts, w, c);
    case "z": return new LetterZ(ts, w, c);
  }
  return null;
}


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
