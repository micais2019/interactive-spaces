class MoodWords {
  JSONObject mood_words;
  PFont font;
  PGraphics surface;
  int w, h;
  IntList values;
  int fontSize = 50;

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

    surface = createGraphics(this.w, this.h); 
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
    int level = 30;

    surface.beginDraw();
    surface.clear();
    surface.textFont(font, fontSize);
    surface.textAlign(LEFT);
    surface.noStroke();
    surface.noFill();

    for (int n=-1; n < 2; n++) {
      for (int x = -1; x < 1; x++) {
        surface.fill(0);
        //surface.textSize(61);
        //surface.text(text, n-x, 50+x); // outline
        //surface.text(text, n+x, 50-x); //outline
      }
      surface.fill(255);
      //surface.textSize(60);
      surface.text(text, n, 50);
    }
      // level += this.rowHeight;
    
    surface.endDraw();

    return surface;
  }
}
