/*TODO:
 • fix rectangle thin stroke? 
 • organize paths (can we draw them on the z-axis?) /dione
 • implement polygon paths /dione
 */
import peasy.*; 

final boolean CONTROL_POSITION = true;
final boolean DEBUG = false;
final boolean ONE_SHOT = false;

final boolean SKIP_DONUT = false;
final boolean SKIP_CLOTH = false;
final boolean SKIP_PLANETS = false;
final boolean SKIP_TEXT = false;
final boolean SKIP_WORDS = false;
final boolean SKIP_SPLASH = false;
final boolean SKIP_WEATHER = false;
final boolean SKIP_LOGO = false;
final boolean SKIP_PATHS = false;


final color BACKGROUND = color(255, 255, 255);

float coverWidth = 15;
float coverHeight = 10;
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

PShape MICA_logo;

// utility text
TextLayer textLayer;

// 4 words
MoodWords wordart;

long now;
int index;

String[] weatherData;
String[] soundData;
String[] moodData;

//triangular paths
Point origin, p1, p2, squareOrigin, ps1, ps2, ps3;
PolygonPath triangle, square;


int MAX_COUNTER = 1000;

void setup() {
  // size(4950, 2550, P3D); // FULL
  size(1200, 800, P3D);
  smooth(8);

  now = getTimestampFromArgs();
  index = getIndexFromArgs();

  soundScores = new FloatList();
  soundData = split("750 610 1853 636 923 381 485 220 532 351 308 533 310 319 1069 655 801 521 694 332 621 359 214 550 405 801 476 745 313 504 346 623 333 492 325 9404 2336 1098 1344 432 592 379 897 403 678 379 382 707 413 1219 715 1025 485 711 414 376 817 532 411 669 387 376 836 480 338 961 1335 513 1962 833 928 447 1060 678 630 1551 607 802 333 638 420 293 511 541 278 505 221 438 289 442 345 519 311 651 301 459 252 620 294 529 256 459 316 627 343 273 501 316 578 333 769 415 696 409 500 336 315 612 663 463 381 188 502 324 451 364 510 270 604 248 613 297 199 915 352 539 337 286 425 233 508 320 489 341 613 373 270 457 259 416", " ");
  for (int i=0; i < soundData.length; i++) {
    soundScores.append(soundToScore(int(soundData[i])));
  }

  moodValues = new IntList();
  moodData = split("3 2 1 0 3 5 5 7 6 4 6 1 5 0 4 3 7 6 7 6 7 6 7 6 5 4 3 2 1 6 7 6 7 6 7 6 7 6 7 6 5 7 4 3 2 1 0 1 2 3 4 5 6 0 4 3 4 5 6 7 2 1 0 3 3 4 0 7 4 1 0 5 2 7 5 2 0 2 6 3 1 6 4 0 2 6 1 3 0 1 6 5 6 7 2 3 3 0 1 2 2 3 4 5 6 7 5 4 4 4 3 3 2 2 1 4 5 0 3 5 3 4 7 6 2 0 2 4 3 5 2 3 3 3 7 4 4 3 5 3 3 3 2 0 3 4 3 4 4 4 3 2 2 4 4 6 7 6 7 6 7 6 4 3 7 6 7 3 1 3 2 7 0 5 4 0 6 3 1 4 3 2 1 3 3 4 5 1 2 4 5 6 7 0 3 2 7 2 3 5 3 4 3 4 3 4 3 4 3 4 3 4 3 5 5 3 4 3 4 5 4 5 4 4 4 4 4 4 3 4 3 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4 0 4 4 4 4 5 4 4 4 4 4 4 4 4 4 4 5 6 0 7 1 2 3 4 5 7 3 3 0 4 5 6 7 3 2 1 7", " ");
  for (int i=0; i < max(moodData.length, 100); i++) {
    moodValues.append(int(moodData[i]));
  }

  weatherScores = new FloatList();
  weatherData = split("61.48 57.94 88 101.96 61.48 100", " ");
  for (int i=0; i < weatherData.length; i++) {
    weatherScores.append(float(weatherData[i]));
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
    splash = explosion.create(24, this); //change to higher number for funky glitches
  }

  textLayer = new TextLayer(width, height);
  // textLayer.draw(now, index);
  // textLayer.create(now, index);

  if (!SKIP_LOGO) {
    MICA_logo = loadShape("mica_logo-01.svg");
  }
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
  lights();

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

  if (!SKIP_LOGO) {
    drawLogo(now);
  }

  if (!SKIP_PATHS) {
    drawPaths(now);

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
  //move it along a XZ axis, circularly
  translate(width*0.4, height*0.7, -50);

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
  scale(1);
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
  translate(width*0.1+(frameCount), height * 0.15+(frameCount), -600+(frameCount));
  rotateX(frameCount * 0.01);
  rotateZ(frameCount * 0.01);
  scale(1.7);
  shape(splash);
  popMatrix();
}


void drawWeatherGraph(long ts) {
  //relative adjustments for weathergraph
  float tolerance1 = (float(weatherData[0])-float(weatherData[1]))/2;
  float tolerance2 = (float(weatherData[1])-float(weatherData[2]))/2;
  float tolerance3 = (float(weatherData[2])-float(weatherData[3]))/2;
  float tolerance4 = (float(weatherData[3])-float(weatherData[4]))/2;

  Point oval_center = getEllipsePoint(frameCount % MAX_COUNTER, height*0.5, 1.3, 0.6);

  pushMatrix();
  translate(width/2 + oval_center.x, height/2 + oval_center.y);
  ellipse(0, 0, 2, 2);
  popMatrix();

  pushMatrix();

  // primary positioning
  translate(width/2 + oval_center.x, height/2 + oval_center.y);

  int rot = int(ts % (long)60);
  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);

  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.5f/width * TWO_PI);
    rotateX(mouseY * 1.25f/height * TWO_PI);
  } else { 
    rotateX(rx);
    rotateY(ry);
  }
  scale(1.2);

  // draw each shape
  shape(weatherObjects[0]);
  translate(20, tolerance1);
  shape(weatherObjects[1]);
  translate(20, tolerance2);
  shape(weatherObjects[2]);
  translate(20, tolerance3);
  shape(weatherObjects[3]);
  translate(20, tolerance4);
  shape(weatherObjects[4]);
  rotateZ(radians(90));
  translate(30, 50);
  shape(weatherObjects[5]);

  popMatrix();
}

void drawLogo(long ts) {
  pushMatrix();
  translate(width*0.5, height*0.4);
  rotate(radians(90));
  // MICA_logo.fill(255);
  shape(MICA_logo);
  MICA_logo.disableStyle();
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

//get points for elliptical paths
//draw paths
void drawPaths(long ts) {

  //TRIANGLE STUFF
  origin = new Point(width*0.1, height*0.97); //bottom left pt
  p1 = new Point(width*0.5, height*0.03);//top middle pt
  p2 = new Point(width*0.9, height*0.97);//bottom right pt
  triangle = new PolygonPath(new Point[]{ origin, p1, p2 }, MAX_COUNTER);
  //TRIANGLE STUFF

  //SQUARE STUFF
  squareOrigin = new Point(width*0.1, height*0.03); //top left pt
  ps1 = new Point(width*0.9, height*0.03);//top right pt
  ps2 = new Point(width*0.9, height*0.97);//bottom right pt
  ps3 = new Point(width*0.1, height*0.97);//bottom left pt
  square = new PolygonPath(new Point[]{ squareOrigin, ps1, ps2, ps3 }, MAX_COUNTER);
  //SQUARE STUFF

  for (int i=0; i<MAX_COUNTER; i+=3) {
    // 1. locate
    Point weather_center = getEllipsePoint(i, width*0.5, 0.85, 0.5);
    Point donut_center = getEllipsePoint(i, height*0.5, 1.0, 0.2);
    Point planets_center = getEllipsePoint(i, width*0.27, 0.4, 1.0);
    Point tri_center = triangle.point(i);
    Point square_center = square.point(i);


    //weather path
    fill(255, 0, 255);
    pushMatrix();
    translate(width*0.5 + weather_center.x, height*0.5 + weather_center.y);
    rect(0, 0, 3, 2);
    popMatrix();

    //donut path
    fill(100);
    pushMatrix();  
    translate(width*0.5 + donut_center.x, height*0.8 + donut_center.y);
   // rotateZ(radians(90));
    rect(0, 0, 3, 2);
    popMatrix();

    //planets path
    fill(251, 255, 10);
    pushMatrix();
    translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y);
    rect(0, 0, 3, 2);
    popMatrix();

    //triangle path, counter
    pushMatrix();
    fill(0, 13, 255);
    translate(tri_center.x, tri_center.y);
    rect(0, 0, 3, 2);
    popMatrix();

    //square path, timestamp
    pushMatrix();
    fill(255, 0, 0);
    translate(square_center.x, square_center.y);
    rect(0, 0, 3, 2);
    popMatrix();

    fill(255);
  }
}
float R = 100.0;

Point getEllipsePoint(long counter, float radius, float wide, float flat) {
  float progress = map(counter, 0, MAX_COUNTER, 0, TWO_PI); 

  //        > 1.0 means wider
  float x = wide * radius * cos(progress);
  //        < 1.0 means flatter
  float y = flat * radius * sin(progress);

  return new Point(x, y);
} 
