
ClothTexture ct;
IntList moodValues;

void setup() {
  size(800, 500, P3D);
  background(51);
  frameRate(1);
  
  moodValues = new IntList();
  String[] moodData = split("3 2 1 0 3 5 5 7 6 4 6 1 5 0 4 3 7 6 7 6 7 6 7 6 5 4 3 2 1 6 7 6 7 6 7 6 7 6 7 6 5 7 4 3 2 1 0 1 2 3 4 5 6 0 4 3 4 5 6 7 2 1 0 3 3 4 0 7 4 1 0 5 2 7 5 2 0 2 6 3 1 6 4 0 2 6 1 3 0 1 6 5 6 7 2 3 3 0 1 2 2 3 4 5 6 7 5 4 4 4 3 3 2 2 1 4 5 0 3 5 3 4 7 6 2 0 2 4 3 5 2 3 3 3 7 4 4 3 5 3 3 3 2 0 3 4 3 4 4 4 3 2 2 4 4 6 7 6 7 6 7 6 4 3 7 6 7 3 1 3 2 7 0 5 4 0 6 3 1 4 3 2 1 3 3 4 5 1 2 4 5 6 7 0 3 2 7 2 3 5 3 4 3 4 3 4 3 4 3 4 3 4 3 5 5 3 4 3 4 5 4 5 4 4 4 4 4 4 3 4 3 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 4 5 4 4 4 4 4 4 4 4 4 4 5 6 0 7 1 2 3 4 5 7 3 3 0 4 5 6 7 3 2 1 7", " ");
  for (int i=0; i < moodData.length; i++) {
    moodValues.append(int(moodData[i]));
  }
  
  ct = new ClothTexture(width, height, moodValues);
}

void draw() {
  image(ct.surface,0,0);
  ct.createTexture();
}
