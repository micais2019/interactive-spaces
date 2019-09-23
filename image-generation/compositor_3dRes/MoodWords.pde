

class MoodWords {
  JSONObject mood_words;
  PFont font;
  PGraphics2D surface;
  int w, h;
  IntList values;
  int fontSize = 50;

  MoodWords(float w, float h, IntList values) {
    mood_words = loadJSONObject("imagetoword.json"); // new text .json file, with nouns from Amazon's Rekognition + MICA photos

    this.w = floor(w);
    this.h = floor(h);
    this.values = values;

    // The font must be located in the sketch's 
    // "data" directory to load successfully
    font = createFont("Patron-Bold.otf", 50);

    surface = (PGraphics2D) createGraphics(this.w, this.h, P2D); 
    surface.smooth();
  }

  String pickWord(int value) {
    JSONArray words = mood_words.getJSONArray(str(value));
    int rand_idx = floor(random(words.size()));
    return words.getString(rand_idx);
  }

  PGraphics draw() {
    String text = "";
    for (int i=0; i < 4; i++) {
      if (i < 3) {
        text += pickWord(i) + ", ";

        //text += pickWord(floor(random(4))) + ", ";
      } else {
        //text += pickWord(floor(random(4)));
        text += pickWord(i);
      }
    }

    surface.beginDraw();
    surface.clear();
    surface.textFont(font, fontSize);

    for (int n=-1; n < 2; n++) {
      for (int x = -1; x < 2; x++) {
        surface.fill(0);
        surface.text(text, n+x, 50); // outline
        surface.text(text, n, 50+x); //outline
      }
      surface.fill(255);
      surface.text(text, n, 50);
    }

    surface.endDraw();

    return surface;
  }
}