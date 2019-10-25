//import controlP5.*;
import java.io.PrintWriter;

/*
 Calling this sketch from the command line:
 
 */
/*TODO:
 */
//import peasy.*;

final boolean CONTROL_POSITION = false;
final boolean DEBUG = false;
boolean ONE_SHOT = false;
final boolean MULTI_SHOT = true;

final boolean SKIP_DONUT = false;
final boolean SKIP_CLOTH = false;
final boolean SKIP_PLANETS = false;
final boolean SKIP_TEXT = false;
final boolean SKIP_WORDS =  false;
final boolean SKIP_SPLASH = false;
final boolean SKIP_WEATHER = false;
final boolean SKIP_LOGO = false;
final boolean SKIP_PATHS = false;
final boolean SKIP_TIME = false;
final boolean SKIP_COUNTER = false;

final color BACKGROUND = color(255, 255, 255);

float bleed = 3; // mm
float coverWidth  = 340 + (bleed * 2); // mm
float coverHeight = 235 + (bleed * 2); // mm
float dpmm = 11.811;

int coverFinalWidth  = round(coverWidth * dpmm);
int coverFinalHeight = round(coverHeight * dpmm);

DataLoader dload;
FloatList sound1Scores;
FloatList sound2Scores;
FloatList weatherScores;
FloatList motionScores;

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
TextParagraph textPara;

//timestamp class
TimeStamp timestamp;

TextCounter counter;

// 4 words
MoodWords wordart;

long now;
int index;
int starting_index;
int IMAGE_GENERATION_COUNT = 10;

//triangular paths
Point origin, p1, p2, squareOrigin, ps1, ps2, ps3;
PolygonPath triangle, square, zigzag;

String[] weatherData;
String[] sound1Data;
String[] sound2Data;
String[] moodData;
String[] motionData;

int MAX_COUNTER = 68000;

PShape arrow;

PImage typeset;

//zigzag points
Point [] zig_points = new Point [11];

void settings() {
  // 13.25" x 9.25" @ 300dpi
  size(coverFinalWidth, coverFinalHeight, P3D); //renders
  // size(4200, 2847, P3D); // FULL3
  smooth(8);
}

void setup() {
  getOneShotFromArgs();

  // loading data
  dload = new DataLoader(this);
  starting_index = 12530; //getIndexFromArgs();
  index = starting_index;
  resetDataAndObjects();
  generatePaths(); // create paths but don't draw them
}

void resetDataAndObjects() {
  now = getTimestampFromIndex(index);

  println("IMAGE", index, "AT", now);

  // debugDataLoader(dload);

  sound1Scores  = dload.getSound1Scores(now);
  sound2Scores  = dload.getSound2Scores(now);
  moodValues    = dload.getMoodValues(now);
  motionScores  = dload.getMotionScores(now);
  weatherScores = dload.getWeatherScores(now);

  float sound1avg = average(sound1Scores)*10000;
  float sound2avg = average(sound2Scores)*10000;
  float motionavg = average(motionScores);

  //println("sound1avg:" + sound1avg);
  //println("sound2avg:" + sound2avg);
  //println("motionMax:" + motionMax);
  //println("motionAvg:" + motionavg); //gives more dynamic change to cloth width

  if (!SKIP_CLOTH) {
    // w h amp detail
    // more amp -> bigger hills
    // more detail -> tighter hills
    int clothWidth = int(map(motionavg, 0, 30, width*0.55, height*5)); //map avg motion val to cloth thickness
    cloth = new ClothShape(floor(width * 0.5), floor(height * 3), clothWidth, 200);
    fabric = cloth.create(moodValues, this);
  }

  if (!SKIP_DONUT) {
    float size = map(sound1avg, 200, 10000, width*0.1, width*0.672); //map avg sound1 val to torus radius
    toroid = new SparkleDonut(size); //size
    donut = toroid.create(sound1Scores, this);
  }

  if (!SKIP_PLANETS) {
    float spacing = map(sound2avg, 200, 1000, 5, 60);
    planet = new Planet(height * 0.03, spacing, now, this);
  }

  if (!SKIP_WORDS) {
    wordart = new MoodWords(width * 0.6, height * 0.1, moodValues);
  }

  if (!SKIP_WEATHER) {
    WeatherGraph weather = new WeatherGraph();
    weatherObjects = weather.create(weatherScores, 2, this);
  }

  if (!SKIP_SPLASH) {
    explosion = new SplashMotion(500);
    int splashWidth = int(map(motionavg, 0, 30, width*0.1, width*0.4)); //map avg motion val to splash radius
    int spokes = int(map(motionavg, 0, 30, 30, 70));
    splash = explosion.create(spokes, 20, splashWidth, this); //change to higher number for funky glitches
  }

  if (!SKIP_TEXT) {
    textPara = new TextParagraph(width*0.43, height*0.5);
    typeset = loadImage("typeset4.png");
  }

  if (!SKIP_LOGO) {
    MICA_logo = loadShape("mica_logo-01.svg");
    MICA_logo.disableStyle();
    MICA_logo.setFill(255);
  }

  if (!SKIP_TIME) {
    timestamp = new TimeStamp(int(width*0.18), int(height*0.016));
  }

  if (!SKIP_COUNTER) {
    counter = new TextCounter(int(width*0.16), int(height*0.0166));
  }
}

void generatePaths() {
  arrow = createShape();
  arrow.scale(3);
  arrow.beginShape();
  arrow.noStroke();
  arrow.vertex(0, 0);
  arrow.vertex(7, 7);
  arrow.vertex(0, 14);
  arrow.endShape();
  arrow.disableStyle();

  // ZIGZAG
  for (int lp = 0; lp <9; lp+=2) {
    float spacing = height*0.1;
    float offset = height*0.1;
    zig_points[lp] = new Point(width*0.1, offset +lp*spacing);
  }
  for (int rp = 1; rp <9; rp+=2) {
    float spacing = height*0.1;
    float offset = height*0.1;
    zig_points[rp] = new Point(width*0.8, offset + rp*spacing);
  }

  zig_points[9] = new Point(width*0.9, height*0.9);
  zig_points[10] = new Point(width*0.9, height*0.1);
  zigzag = new PolygonPath(zig_points, MAX_COUNTER);

  //TRIANGLE STUFF
  origin = new Point(width*0.12, height*0.97); //bottom left pt
  p1 = new Point(width*0.5, height*0.03);//top middle pt
  p2 = new Point(width*0.88, height*0.97);//bottom right pt
  triangle = new PolygonPath(new Point[]{ origin, p1, p2 }, MAX_COUNTER);
  //TRIANGLE STUFF

  //SQUARE STUFF
  squareOrigin = new Point(width*0.12, height*0.03); //top left pt
  ps1 = new Point(width*0.88, height*0.03);//top right pt
  ps2 = new Point(width*0.88, height*0.97);//bottom right pt
  ps3 = new Point(width*0.12, height*0.97);//bottom left pt
  square = new PolygonPath(new Point[]{ squareOrigin, ps1, ps2, ps3 }, MAX_COUNTER);
  // SQUARE STUFF
}

void draw() {
  background(BACKGROUND);
  directionalLight(200, 200, 200, 0, 0, -1);
  directionalLight(180, 180, 180, 1, 0, -1);
  directionalLight(18, 18, 18, -1, 0, 0);
  lights();

  if (!SKIP_PATHS) {
    drawPathsandArrows();
  }

  if (!SKIP_CLOTH) {
    drawCloth();
  }

  if (!SKIP_DONUT) {
    drawDonut(now);
  }

  if (!SKIP_PLANETS) {
    drawPlanets(now);
  }

  if (!SKIP_SPLASH) {
    drawSplash();
  }

  if (!SKIP_WEATHER) {
    drawWeatherGraph();
  }

  noLights();

  if (!SKIP_TEXT) {
    drawText();
  }

  hint(DISABLE_DEPTH_TEST); // draw on top of all the other stuff

  if (!SKIP_WORDS) {
    drawWords();
  }

  if (!SKIP_TIME) {
    drawTimestamp(now);
  }

  if (!SKIP_COUNTER) {
    drawCounter();
  }

  if (!SKIP_LOGO) {
    drawLogo(now);
  }

  hint(ENABLE_DEPTH_TEST); // stop drawing on top of all the other stuff (close loop)

  // save image of the current frame
  String filename = String.format("output/%s_%d_%d_%d.png", now, index, width, height);
  println("@" + filename);
  saveFrame(filename);

  if (ONE_SHOT) {
    println("done");
    exit();
  }

  index++;
  if (index < starting_index + IMAGE_GENERATION_COUNT && index <= MAX_COUNTER) {
    resetDataAndObjects();
  } else {
    println("done");
    exit();
  }
}

void drawDonut(long ts) {
  Point donut_center = getEllipsePoint(index % MAX_COUNTER, height*0.5, 1.0, 0.5);

  pushMatrix();
  translate(width*0.5+donut_center.x, height*0.8, donut_center.y);
  rotateX(index * 0.2);
  rotateZ(index * 0.3);
  noStroke();
  textureMode(NORMAL);
  scale(1);
  shape(donut);

  popMatrix();
}

void drawPlanets(long ts) {
  Point planets_center = getEllipsePoint(index % MAX_COUNTER, width*0.27, 0.4, 1.0);

  pushMatrix();
  noStroke();
  translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y, 40);

  orb = planet.create();
  for (int n=0; n < planet.offsets.size(); n++) {
    pushMatrix();
    rotateX(PI);
    rotateZ(planet.rotations.get(n) + (index * 0.01));
    translate(planet.offsets.get(n), 0, 0);
    scale(planet.scales.get(n));
    shape(orb);
    popMatrix();
  }

  popMatrix();
}

void drawCloth() {
  pushMatrix();
  translate(width * 0.49, height*0.125, -width*0.42);
  rotateY(-1.649); //rotate it sideways
  rotateX(2.989);
  noStroke();
  textureMode(NORMAL);
  shape(fabric);
  popMatrix();
}

void drawText() {
  Point text_center = getEllipsePoint(index % MAX_COUNTER, width*0.27, 0.1, 0.45); //create points
  pushMatrix();
  translate(width*0.12, height*0.25); //width*0.1 z
  scale(1);
  imageMode(CORNER);
  image(typeset, text_center.x, text_center.y); // from image
  popMatrix();
  noStroke();
}

void drawWords() {
  Point zig_center = zigzag.point(index % MAX_COUNTER);  //create zigzag points
  pushMatrix();
  imageMode(CORNER);
  scale(1);
  image(wordart.draw(), zig_center.x - width*0.05, zig_center.y + height*0.01);
  popMatrix();
  noStroke();
}

void drawTimestamp(long ts) {
  Point tri_center = triangle.point(index % MAX_COUNTER);
  timestamp.draw(ts);
  pushMatrix();
  //translate(width*0.17,height*0.17, width*0.2);
  imageMode(CENTER);
  scale(1);
  image(timestamp.surface, tri_center.x, tri_center.y);
  popMatrix();
}

void drawCounter() {
  Point square_center = square.point(index % MAX_COUNTER);
  counter.draw(index);
  pushMatrix();
  //translate(width*0.17,height*0.19, width*0.2);
  imageMode(CENTER);
  scale(1);
  image(counter.surface, square_center.x, square_center.y);
  popMatrix();
}


void drawSplash() {
  Point splash_center = getMoebiusPoint(index % MAX_COUNTER, width*0.25);

  pushMatrix();
  translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z);
  rotateY(index * 0.4);
  rotateZ(index * 0.6);
  rotateX(index * 0.8);
  scale(0.8);
  //specular(255, 255, 255);
  directionalLight(255, 255, 255, 0, -1, -1);
  shape(splash);

  //specular(30,30,30);
  popMatrix();
  fill(255);
}


void drawWeatherGraph() {
  noStroke();

  //relative adjustments for weathergraph
  float tolerance1 = (weatherScores.get(0)-weatherScores.get(1))/2;
  float tolerance2 = (weatherScores.get(1)-weatherScores.get(2))/2;
  float tolerance3 = (weatherScores.get(2)-weatherScores.get(3))/2;
  float tolerance4 = (weatherScores.get(3)-weatherScores.get(4))/2;
  float tolerance5 = ((weatherScores.get(4))/2);

  Point weather_center = getEllipsePoint(index % MAX_COUNTER, width*0.35, 1, 0.65);

  pushMatrix();
  // primary positioning
  translate(width/2+ weather_center.x, height/2 + weather_center.y, width*0.05);
  scale(2.5);
  rotateX(index * 0.2);
  rotateZ(index * 0.1);

  pushMatrix();
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
  translate(tolerance5, 40);
  shape(weatherObjects[5]);
  popMatrix();

  popMatrix();
}

void drawLogo(long ts) {
  pushMatrix();
  translate(width*0.5, height*0.5, width*0.4);
  scale(width*0.0005);
  rotate(radians(90));
  shapeMode(CENTER);
  shape(MICA_logo);
  popMatrix();
  shapeMode(CORNER);
}


void mouseClicked() {
  long t = (new Date()).getTime() / 1000;
  String filename = String.format("snap_%d.png", t);
  saveFrame(filename);
}


void drawPathsandArrows() {

  PFont font;
  font = createFont("Pitch-Bold.otf", 10);
  noStroke();
  shapeMode(CENTER); //for arrows

 pushMatrix();
  translate(-width*0.1, -height*0.1, -width*0.1);
  scale(1.2);

  //ZIGZAG
  zigzag = new PolygonPath(zig_points, MAX_COUNTER);
  textFont(font, 20);

  for (int i=1; i<MAX_COUNTER; i+=1) {
    Point zig_center = zigzag.point(i);
    pushMatrix();
    fill(#0000FF);
    translate(zig_center.x, zig_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    if (i == 61820) {
      pushMatrix();
      rotate(radians(90));
      text("IMAGE DESCRIPTORS", 0, -10);
      popMatrix();
    }
    popMatrix();
  }

  for (int i=1; i< MAX_COUNTER; i+=1) {

    Point weather_center = getEllipsePoint(i, width*0.5, 0.85, 0.5);
    Point donut_center = getEllipsePoint(i, height*0.5, 1.0, 0.5);
    Point planets_center = getEllipsePoint(i, width*0.27, 0.4, 1.0);
    Point splash_center = getMoebiusPoint(i, width*0.25);

    noStroke();
    //weather path
    fill(#2dc84d);
    pushMatrix();
    translate(width*0.5 + weather_center.x, height*0.5 + weather_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    if (i == 61000) {
      pushMatrix();
      rotate(radians(39));
      text("WEATHER", 0, -10);
      popMatrix();
    }
    popMatrix();

    //donut path
    fill(#fe5000);
    pushMatrix();
    translate(width*0.5 + donut_center.x, height*0.8, donut_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    if (i == 13000) {
      pushMatrix();
      rotate(-radians(8));
      scale(0.8);
      text("SOUND: LOCATION #1", 0, 25);
      popMatrix();
    }
    popMatrix();

    //planets path
    fill(#fedb00);
    pushMatrix();
    translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    if (i == 67300) {
      pushMatrix();
      rotate(radians(90));
      text("SOUND: LOCATION #2", 0, -10);
      popMatrix();
    }
    popMatrix();

    //moebius path, splash
    pushMatrix();
    fill(#e10098);
    translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z );
    rect(0, 0, width*0.0007, width*0.0007);
    if (i == 14700) {
      pushMatrix();
      rotate(radians(28));
      scale(0.6);
      text("MOTION", 0, -10);
      popMatrix();
    }
    popMatrix();

    fill(255);
  }
  textMode(SHAPE);
  fill(#10069f);
  Point Zarrow_center = zigzag.point((index+1) % MAX_COUNTER);
  Point Znext_center = zigzag.point((index+2) % MAX_COUNTER);
  float angZ = atan2(Znext_center.y - Zarrow_center.y, Znext_center.x - Zarrow_center.x);
  pushMatrix();
  translate(Zarrow_center.x, Zarrow_center.y);
  rotate(angZ);
  shape(arrow, 0, 0);
  popMatrix();

  fill(#2dc84d);
  Point Warrow_center = getEllipsePoint((index+300) % MAX_COUNTER, width*0.5, 0.85, 0.5);
  Point Wnext_center = getEllipsePoint((index+301) % MAX_COUNTER, width*0.5, 0.85, 0.5);
  float angW = atan2(Wnext_center.y - Warrow_center.y, Wnext_center.x - Warrow_center.x);
  pushMatrix();
  translate(width*0.5 +  Warrow_center.x, height*0.5 + Warrow_center.y);
  rotate(angW);
  shape(arrow, 0, 0);
  popMatrix();

  fill(#fe5000);
  Point Darrow_center = getEllipsePoint((index+100) % MAX_COUNTER, height*0.5, 1.045, 0.197);
  Point Dnext_center = getEllipsePoint((index+101) % MAX_COUNTER, height*0.5, 1.045, 0.197);
  //debug 
  /*for (int i=1; i<MAX_COUNTER; i+=1) {
    fill(150);
    pushMatrix();
    Point D = getEllipsePoint(i, height*0.5, 1.045, 0.197 );
    rect(width/2 + D.x, height*0.83 +D.y, 2, 2);
    popMatrix();}*/
  //debug 
  float angD = atan2(Dnext_center.y - Darrow_center.y, Dnext_center.x - Darrow_center.x);
  pushMatrix();
  translate(width/2 + Darrow_center.x, height*0.83 + Darrow_center.y);
  rotate(angD);
  fill(#fe5000);
  shape(arrow, 0, 0);
  popMatrix();

  fill(#fedb00);
  Point Parrow_center = getEllipsePoint((index+100) % MAX_COUNTER, width*0.27, 0.4, 1.0);
  Point Pnext_center = getEllipsePoint((index+101) % MAX_COUNTER, width*0.27, 0.4, 1.0);
  float angP = atan2(Pnext_center.y - Parrow_center.y, Pnext_center.x - Parrow_center.x);
  pushMatrix();
  translate(width*0.7 + Parrow_center.x, height*0.5 + Parrow_center.y);
  rotate(angP);
  shape(arrow, 0, 0);
  popMatrix();

  fill(#e10098);
  Point Marrow_center = getMoebiusPoint((index+100) % MAX_COUNTER, width*0.25);
  Point Mnext_center =getMoebiusPoint((index+101) % MAX_COUNTER, width*0.25);
  float angM = atan2(Mnext_center.y - Marrow_center.y, Mnext_center.x - Marrow_center.x);
  pushMatrix();
  translate(width*0.5+ Marrow_center.x, height*0.5 + Marrow_center.y, Marrow_center.z);
  rotate(angM);
  scale(0.95);
  shape(arrow, 0, 0);
  popMatrix();

  fill(255);//reset
  shapeMode(CORNER);//reset

  popMatrix();
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

Point getMoebiusPoint(float counter, float radius) {
  float progress = map(counter, 0, MAX_COUNTER, 0, radians(720));
  float y = cos(progress) + radius*(cos(progress/2));
  float x = sin(progress) + radius*(sin(progress/1));
  float z = radius*sin(0.5*progress);
  return new Point(x, y, z);
}
