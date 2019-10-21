class MoodWords {
  JSONObject mood_words;
  PFont font;
  PGraphics surface;
  int w, h;
  IntList values;
  int fontSize = 70;

  MoodWords(float w, float h, IntList values) {
    mood_words = loadJSONObject("imagetoword.json"); // new text .json file, with nouns from Amazon's Rekognition + MICA photos

    this.w = floor(w);
    this.h = floor(h);
    this.values = values;

    // The font must be located in the sketch's 
    // "data" directory to load successfully
    font = createFont("PatronTRIAL-BoldItalic.otf", fontSize);

    surface = createGraphics(this.w, this.h); 
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
      } else {
        text += pickWord(i);
      }
    }
    surface.smooth(4);
    surface.beginDraw();
    surface.clear();
    surface.background(0,0);
    surface.textFont(font, fontSize);
    //surface.textAlign(CORNER);
    for(int x = -1; x < 2; x++){
    //for(int y = -2; y < 2; y++){
      surface.fill(0);
      surface.text(text, 1, 60+x); // outline
      surface.text(text, 1+x, 60); //outline
    //}
    }
    surface.fill(255);
    surface.text(text, 1, 60);    
    surface.endDraw();

    return surface;
  }
}
