class MoodWords {
  JSONObject mood_words;
  PFont font;
  PGraphics2D surface;
  int w, h;
  IntList values;

  int rowHeight = 200;
  int fontSize = 22;

  color[] colors = {  
    #0061ff, 
    #ffff00, 
    #ff0000, 
    #009104, 
    #ff0f97, 
    #0073a8, 
    #00FF9F, 
    #00FDFF, 
  };

  MoodWords(float w, float h, IntList values) {
    mood_words = loadJSONObject("word-test.json"); // new text .json file, with nouns from Amazon's Rekognition + MICA photos

    this.w = floor(w);
    this.h = floor(h);
    this.values = values;

    // The font must be located in the sketch's 
    // "data" directory to load successfully
    font = loadFont("Syne-Bold-54.vlw");

    surface = (PGraphics2D) createGraphics(this.w, this.h, P2D); 
    surface.smooth(4);
  }

  String pickWord(int value) {
    JSONArray words = mood_words.getJSONArray(str(value));
    int rand_idx = floor(random(words.size()));
    return words.getString(rand_idx);
  }

  PGraphics draw() {
    String text = "";
    for (int i=0; i < 4; i++) {
      text += " (" + pickWord(floor(random(8))) + ") ";
    }
    int level = 30;

    surface.beginDraw();
    surface.clear();
    surface.textFont(font, fontSize);
    surface.textAlign(LEFT);
    surface.noStroke();

    for (int i=0; i < 4; i++) {
      int mood = floor(random(8));
      String word = "(" + this.pickWord(mood) + ")";

      surface.noFill();

      //surface.text(word,0,30);
      for (int n=1; n < 4; n+= 3) {
        //surface.text(word, n, level); 
        surface.text(text, n, 30 );
        //surface.text(word, n, height*0.1);
      }
      surface.fill(255);

      // level += this.rowHeight;
    }
    surface.endDraw();

    return surface;
  }
}
