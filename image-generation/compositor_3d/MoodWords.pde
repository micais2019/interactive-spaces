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
    mood_words = loadJSONObject("imagetoword.json"); // new text .json file, with nouns from Amazon's Rekognition + MICA photos

    this.w = floor(w);
    this.h = floor(h);
    this.values = values;

    // The font must be located in the sketch's 
    // "data" directory to load successfully
    font = createFont("Patron-Bold.otf", fontSize);

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
      if (i < 3) {
        text += pickWord(i) + ", ";

        //text += pickWord(floor(random(4))) + ", ";
      } else {
        //text += pickWord(floor(random(4)));
        text += pickWord(i);
      }
    }
    int level = 30;

    surface.beginDraw();
    surface.clear();
    surface.textFont(font, fontSize);
    surface.textAlign(LEFT);
    surface.noStroke();
      surface.noFill();

    for (int i=0; i < 4; i++) {
      int mood = floor(random(4));

      String word = "(" + this.pickWord(mood) + ")";

      //surface.text(word,0,30);
      for (int n=1; n < 4; n+= 3) {
        //surface.text(word, n, level); 
        surface.text(text, n, 30 );
        //surface.text(word, n, height*0.1);
      }

      // level += this.rowHeight;
    }
    surface.endDraw();

    return surface;
  }
}
