import peasy.*; 

final boolean CONTROL_POSITION = true;
final boolean DEBUG = false;
final boolean ONE_SHOT = false;

final boolean SKIP_DONUT = false;
final boolean SKIP_CLOTH = false;
final boolean SKIP_PLANETS = false;
final boolean SKIP_TEXT = false;
final boolean SKIP_WORDS = false;
final boolean SKIP_WEATHER = false;
final boolean SKIP_SPLASH = false;

final color BACKGROUND = color(255, 255, 255);

float coverWidth = 16.5;
float coverHeight = 8.5;
int dpi = 300;

int coverFinalWidth = int(coverWidth * dpi);
int coverFinalHeight = int(coverHeight * dpi);

FloatList soundScores;
FloatList weatherScores;

IntList moodValues;

// ring
SparkleDonut toroid;
PShape donut;

// planet
Planet planet;
PShape orb;

// background 
ClothShape cloth;
ClothTexture tex;
PShape fabric;

//splash-- using motion scores
SplashMotion explosion;
PShape splash;

//weather
WeatherGraph weather;
PShape [] weatherObjects;

// utility text
TextLayer textLayer;

// 4 words
MoodWords wordart;

long now;
int index;

void setup() {
  // size(4950, 2550, P3D); // FULL
  size(1600, 800, P3D);
  smooth(8);

  now = getTimestampFromArgs();
  index = getIndexFromArgs();

  soundScores = new FloatList();
  String[] soundData = split("750 610 1853 636 923 381 485 220 532 351 308 533 310 319 1069 655 801 521 694 332 621 359 214 550 405 801 476 745 313 504 346 623 333 492 325 9404 2336 1098 1344 432 592 379 897 403 678 379 382 707 413 1219 715 1025 485 711 414 376 817 532 411 669 387 376 836 480 338 961 1335 513 1962 833 928 447 1060 678 630 1551 607 802 333 638 420 293 511 541 278 505 221 438 289 442 345 519 311 651 301 459 252 620 294 529 256 459 316 627 343 273 501 316 578 333 769 415 696 409 500 336 315 612 663 463 381 188 502 324 451 364 510 270 604 248 613 297 199 915 352 539 337 286 425 233 508 320 489 341 613 373 270 457 259 416", " ");
  for (int i=0; i < soundData.length; i++) {
    soundScores.append(soundToScore(int(soundData[i])));
  }

  moodValues = new IntList();
  String[] moodData = split("3 2 1 0 3 5 5 7 6 4 6 1 5 0 4 3 7 6 7 6 7 6 7 6 5 4 3 2 1 6 7 6 7 6 7 6 7 6 7 6 5 7 4 3 2 1 0 1 2 3 4 5 6 0 4 3 4 5 6 7 2 1 0 3 3 4 0 7 4 1 0 5 2 7 5 2 0 2 6 3 1 6 4 0 2 6 1 3 0 1 6 5 6 7 2 3 3 0 1 2 2 3 4 5 6 7 5 4 4 4 3 3 2 2 1 4 5 0 3 5 3 4 7 6 2 0 2 4 3 5 2 3 3 3 7 4 4 3 5 3 3 3 2 0 3 4 3 4 4 4 3 2 2 4 4 6 7 6 7 6 7 6 4 3 7 6 7 3 1 3 2 7 0 5 4 0 6 3 1 4 3 2 1 3 3 4 5 1 2 4 5 6 7 0 3 2 7 2 3 5 3 4 3 4 3 4 3 4 3 4 3 4 3 5 5 3 4 3 4 5 4 5 4 4 4 4 4 4 3 4 3 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 4 5 4 4 4 4 4 4 4 4 4 4 5 6 0 7 1 2 3 4 5 7 3 3 0 4 5 6 7 3 2 1 7", " ");
  for (int i=0; i < max(moodData.length, 100); i++) {
    moodValues.append(int(moodData[i]));
  }

  weatherScores = new FloatList();
  String[] weatherData = split("61.48 57.94 88 101.96 61.48 ", " ");
  for (int i=0; i < weatherData.length; i++) {
    weatherScores.append(int(weatherData[i]));
  }

  if (!SKIP_CLOTH) {
    // w h amp detail
    // more amp -> bigger hills
    // more detail -> tighter hills
    cloth = new ClothShape(floor(width * 0.6), floor(height * 3), 1200, 200);
    fabric = cloth.create(moodValues, this);
  }

  if (!SKIP_DONUT) {
    // just give size
    toroid = new SparkleDonut(width * 0.08);
    donut = toroid.create(soundScores, this);
  }

  if (!SKIP_PLANETS) {
    // TODO: add sound2 scores
    planet = new Planet(height * 0.04, now, this);
  }

  if (!SKIP_WORDS) {
    wordart = new MoodWords(width * 0.4, height * 0.3, moodValues);
  }

  if (!SKIP_WEATHER) {
    WeatherGraph weather = new WeatherGraph();
    weatherObjects = weather.create(weatherScores, this);
  }

  if (!SKIP_SPLASH) {
    // TO ADD: Motion Scores?
    explosion = new SplashMotion(width * 0.05);
    splash = explosion.create(24, this);
  }

  textLayer = new TextLayer(width, height);
  // textLayer.draw(now, index);
  // textLayer.create(now, index);
}

float soundToScore(int level) {
  level = constrain(level, 200, 10000);
  return float(level) / 10000.0;
}

void draw() {
  background(BACKGROUND);

  directionalLight(200, 200, 200, 0, 0, -1);
  directionalLight(127, 127, 127, 0, 1, 0);
  directionalLight(18, 18, 18, -1, 0, 0);

  if (!SKIP_CLOTH) {
    drawCloth(now);
  }

  if (!SKIP_WORDS) {
    drawWords(now);
  }

  if (!SKIP_DONUT) {
    drawDonut(now);
  }

  if (!SKIP_PLANETS) {
    drawPlanets(now);
  }

  if (!SKIP_SPLASH) {
    drawSplash(now);
  }

  if (!SKIP_WEATHER) {
    drawWeatherGraph(now);
  }
  noLights();
  drawText(now);

  if (ONE_SHOT) {
    String filename = String.format("%s_%d_%d.png", now, 
      coverFinalWidth, coverFinalHeight);
    saveFrame(filename);
    exit();
  }
}

void drawDonut(long ts) {
  pushMatrix();

  translate(width * 0.79, height * 0.7);

  int rot = int(ts % (long)60);

  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(rx);
    rotateY(ry);
  }
  noStroke();
  textureMode(NORMAL);
  scale(1.2);
  shape(donut);

  popMatrix();
}

void drawPlanets(long ts) {
  pushMatrix();
  noStroke();
  translate(width * 0.70, height * 0.2, 0);
  // rotateY(0.2);`

  orb = planet.create();
  for (int n=0; n < planet.offsets.size(); n++) {
    pushMatrix();
    rotateX(PI);
    rotateZ(planet.rotations.get(n) + (frameCount * 0.01));
    translate(planet.offsets.get(n), 0, 0);
    scale(planet.scales.get(n));
    shape(orb);
    popMatrix();
  }

  popMatrix();
}

void drawWords(long ts) {
  pushMatrix();
  // translate(width * 0.7, height * 0.2);
  translate(mouseX, mouseY);
  image(wordart.draw(), 0, 0);
  popMatrix();
}

void mouseMoved() {
  println(mouseX * 1.0f/width * TWO_PI, mouseY * 1.0f/height * TWO_PI);
}

void drawCloth(long ts) {
  pushMatrix();

  translate(width * 0.78, 100, -400);
  /* if (CONTROL_POSITION) {
   rotateY(mouseX * 1.0f/width * TWO_PI);
   rotateX(mouseY * 1.0f/height * TWO_PI);
   } else { */
  rotateY(2.649);
  rotateX(2.649);
  //}

  noStroke();
  textureMode(NORMAL);
  shape(fabric);
  popMatrix();
}

void drawText(long ts) {
  textLayer.draw(ts, index); 
  image(textLayer.surface, 0, 0);
}

void drawSplash(long ts) {
  pushMatrix();
  translate(width/3, height/3);
  rotateY(mouseX*1.0f/width*TWO_PI);
  rotateX(mouseY*1.0f/height*TWO_PI);
  noStroke();
  shape(splash);
  popMatrix();
}


void drawWeatherGraph(long ts) {

  pushMatrix();

  // primary positioning
  translate(width*0.3, height* 0.8);
  int rot = int(ts % (long)60);
  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(rx);
    rotateY(ry);
  }
  scale(2);
  // relative positioning
  pushMatrix(); 
  // draw each shape
  shape(weatherObjects[0]);
  translate(40, 0);
  shape(weatherObjects[1]);
  translate(40, 0);
  shape(weatherObjects[2]);
  translate(40, 0);
  shape(weatherObjects[3]);
  translate(40, 0);
  shape(weatherObjects[4]);
  popMatrix();

  popMatrix();
}

void mouseClicked() {
  /* println( 
   mouseX * 1.0f/width * TWO_PI, 
   mouseY * 1.0f/height * TWO_PI); */
  long t = (new Date()).getTime() / 1000;
  String filename = String.format("snap_%d.png", t);
  saveFrame(filename);
}
