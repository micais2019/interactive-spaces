
/* 
  Calling this sketch from the command line:
  
  
 */


/*TODO:
 • fix rectangle thin stroke? 
 • organize paths (can we draw them on the z-axis?) /dione
 • implement polygon paths /dione
 * why do text paths put images at 0,0 for point(0)?
 * convert all draw point calculations from frameCount to index (current image index in 0 - 75000 sequence)
 */
import peasy.*; 

final boolean CONTROL_POSITION = false;
final boolean DEBUG = false;
boolean ONE_SHOT = false;


final boolean SKIP_DONUT = false;
final boolean SKIP_CLOTH = false;
final boolean SKIP_PLANETS = false;
final boolean SKIP_TEXT = false;
final boolean SKIP_WORDS = false;
final boolean SKIP_SPLASH = false;
final boolean SKIP_WEATHER = false;
final boolean SKIP_LOGO = false;
final boolean SKIP_PATHS = true;
final boolean SKIP_TIME = false;
final boolean SKIP_COUNTER = false;


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
TextParagraph textPara;

//timestamp class
TimeStamp timestamp;

TextCounter counter;

// 4 words
MoodWords wordart;


long now;
int index;



//triangular paths
Point origin, p1, p2, squareOrigin, ps1, ps2, ps3;
PolygonPath triangle, square, zigzag;


int MAX_COUNTER = 1000;

//zigzag points
Point [] zig_points = new Point [11];

void setup() {
  // size(4950, 2550, P3D); // FULL
  size(1200, 800, P3D);
  smooth(8);
  
  ONE_SHOT = getOneShotFromArgs();
  now = getTimestampFromArgs();
  index = getIndexFromArgs();
  DataLoader dload = new DataLoader(this); 
  
  soundScores = dload.getSound1Scores(now); 
  moodValues = dload.getMoodValues(now);
  weatherScores = dload.getWeatherScores(now);

  if (!SKIP_CLOTH) {
    // w h amp detail
    // more amp -> bigger hills
    // more detail -> tighter hills
    cloth = new ClothShape(floor(width * 0.5), floor(height * 2), 2500, 200);
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

  textPara = new TextParagraph(600, 400);

  if (!SKIP_LOGO) {
    MICA_logo = loadShape("mica_logo-01.svg");
  }

  if (!SKIP_TIME) {
    timestamp = new TimeStamp(width, height);
  }

  if (!SKIP_COUNTER) {
    counter = new TextCounter(width, height);
  }

  generatePaths();
}

void generatePaths() {
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
  square = new PolygonPath(new Point[]{ squareOrigin, ps1, ps2, ps3 }, 3000);
  //SQUARE STUFF

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
  zigzag = new PolygonPath(zig_points, 4000);
  // ZIGZAG STUFF
}

void draw() {
  background(BACKGROUND);

  directionalLight(200, 200, 200, 0, 0, -1);
  directionalLight(127, 127, 127, 0, 1, 0);
  directionalLight(18, 18, 18, -1, 0, 0);
  lights();

  if (!SKIP_PATHS) {
    drawPaths(now);
  }

  if (!SKIP_CLOTH) {
    drawCloth(now);
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

  noLights();

  drawText(now);

  if (!SKIP_WORDS) {
    drawWords(now);
  }

  if (!SKIP_TIME) {
    drawTimestamp(now);
  }

  if (!SKIP_COUNTER) {
    drawCounter(index);
  }

  if (ONE_SHOT) {
    String filename = String.format("%s_%d_%d.png", now, 
      coverFinalWidth, coverFinalHeight);
    saveFrame(filename);
    exit();
  }
}

void drawDonut(long ts) {
  /// TODO
  Point donut_center = getEllipsePoint(frameCount*10 % MAX_COUNTER, height*0.5, 1.0, 0.5);

  pushMatrix();
  //move it along a XZ axis, circularly
  translate(width*0.5+donut_center.x, height*0.8, donut_center.y);

  int rot = int(ts % (long)60);

  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(frameCount * 0.2);
    rotateZ(frameCount * 0.3);
  }
  noStroke();
  textureMode(NORMAL);
  scale(1);
  shape(donut);

  popMatrix();
}

void drawPlanets(long ts) {
  Point planets_center = getEllipsePoint((frameCount*5) % MAX_COUNTER, width*0.27, 0.4, 1.0);

  pushMatrix();
  noStroke();
  translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y, 40);
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
  Point zig_center = zigzag.point(frameCount*3 % 4000);

  pushMatrix();
  // translate(width * 0.7, height * 0.2);
  translate(250+zig_center.x*0.75, 150+zig_center.y*0.73, 200);
  scale(0.55);
  imageMode(CENTER);
  image(wordart.draw(), 0, 0);
  popMatrix();
}

/*
void mouseMoved() {
  println(mouseX * 1.0f/width * TWO_PI, mouseY * 1.0f/height * TWO_PI);
}
*/

void drawCloth(long ts) {
  pushMatrix();

  translate(width * 0.58, 100, -400);
  /* if (CONTROL_POSITION) {
   rotateY(mouseX * 1.0f/width * TWO_PI);
   rotateX(mouseY * 1.0f/height * TWO_PI);
   } else { */
  rotateY(-2.649);
  rotateX(2.989);
  //}

  noStroke();
  textureMode(NORMAL);
  shape(fabric);
  popMatrix();
}

void drawText(long ts) {
  float border = 20;

  Point text_center = getEllipsePoint(frameCount*6 % MAX_COUNTER, width*0.27, 0.1, 0.85);
  textPara.draw(ts); 
  pushMatrix();
  translate(width*0.15, height*0.35, 200);
  scale(0.7);
  imageMode(CORNER);
  //draw white rectangle
  fill(255);
  rectMode(CORNER);
  rect(text_center.x*0.8, text_center.y*0.8, 500 + border, 270 + border);
  noFill();
  //draw text
  image(textPara.surface, text_center.x*0.8, text_center.y*0.8);
  popMatrix();
}

void drawTimestamp(long ts) {
  Point tri_center = triangle.point(0);
  timestamp.draw(ts);
  pushMatrix();
  println(width*0.42+tri_center.x*0.64, height*0.52+tri_center.y*0.64, 250);
  translate(width*0.42+tri_center.x*0.64, height*0.52+tri_center.y*0.64, 250);
  scale(0.7); 
  imageMode(CENTER);
  image(timestamp.surface, 0, 0);
  popMatrix();
}

void drawCounter(int count) {
  Point square_center = square.point(frameCount*5 % 3000);
  counter.draw(count); 
  pushMatrix();
  translate(width*0.42+square_center.x*0.64, height*0.52+square_center.y*0.64, 250);
  scale(0.7);
  imageMode(CENTER);
  image(counter.surface, 0, 0);
  popMatrix();
}


void drawSplash(long ts) {
  Point splash_center = getMoebiusPoint(frameCount% MAX_COUNTER, 300);

  pushMatrix();
  translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(frameCount * 0.2);
    rotateZ(frameCount * 0.2);
  }
  scale(0.8);
  shape(splash);
  popMatrix();
}


void drawWeatherGraph(long ts) {
  //relative adjustments for weathergraph
  float tolerance1 = (weatherScores.get(0)-weatherScores.get(1))/2;
  float tolerance2 = (weatherScores.get(1)-weatherScores.get(2))/2;
  float tolerance3 = (weatherScores.get(2)-weatherScores.get(3))/2;
  float tolerance4 = (weatherScores.get(3)-weatherScores.get(4))/2;

  Point weather_center = getEllipsePoint((frameCount * 10) % MAX_COUNTER, width*0.35, 0.85, 0.5);

  pushMatrix();

  // primary positioning
  translate(width/2 + weather_center.x, height/2 + weather_center.y, 200);

  int rot = int(ts % (long)60);
  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);

  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.5f/width * TWO_PI);
    rotateX(mouseY * 1.25f/height * TWO_PI);
  } else { 
    rotateX(frameCount * 0.1);
    rotateZ(frameCount * 0.1);
  }
  scale(0.8);

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
  translate(width*0.5125, height*0.4, 100);
  rotate(radians(90));
  // MICA_logo.fill(255);
  shape(MICA_logo);
  scale(1);
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

//get points for paths
//draw paths
void drawPaths(long ts) {

  //draw zigzag and square
  for (int i=0; i<4000; i+=1) {
    Point zig_center = zigzag.point(i);
    Point square_center = square.point(i);

    //zigzag path, moodwords
    pushMatrix();
    fill(0, 255, 255);
    translate(zig_center.x, zig_center.y);
    rect(0, 0, 1, 1);
    popMatrix();

    //square path, timestamp
    pushMatrix();
     fill(58);
     translate(square_center.x, square_center.y);
     rect(0, 0, 1, 1);
     popMatrix();
  }
  
  noStroke();

  //draw the rest of the paths
  for (int i=0; i< MAX_COUNTER; i+=1) {

    // 1. locate
    Point weather_center = getEllipsePoint(i, width*0.5, 0.85, 0.5);
    Point donut_center = getEllipsePoint(i, height*0.5, 1.0, 0.5);
    Point planets_center = getEllipsePoint(i, width*0.27, 0.4, 1.0);
    Point text_center = getEllipsePoint(i, width*0.27, 0.1, 0.85);
    Point tri_center = triangle.point(i);
    Point splash_center = getMoebiusPoint(i, 300);

    //weather path
     fill(255, 0, 0);
     pushMatrix();
     translate(width*0.5 + weather_center.x, height*0.5 + weather_center.y);
     rect(0, 0, 1, 1);
     popMatrix();

    //donut path
    fill(100);
    pushMatrix();  
    translate(width*0.5 + donut_center.x, height*0.8, donut_center.y);
    rect(0, 0, 1, 1);
    popMatrix();

    //planets path
     fill(251, 255, 10);
     pushMatrix();
     translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y);
     rect(0, 0, 1, 1);
     popMatrix();

    //text path
     fill(0, 255, 0);
     pushMatrix();
     translate(width*0.3 + text_center.x, height*0.5 + text_center.y);
     rect(0, 0, 1, 1);
     popMatrix();

    //triangle path, counter
     pushMatrix();
     fill(0, 13, 255);
     translate(tri_center.x, tri_center.y);
     rect(0, 0, 1, 1);
     popMatrix();

    //moebius path, splash
    pushMatrix();
    fill(252, 186, 3);
    translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z );
    rect(0, 0, 1, 1);
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


Point getMoebiusPoint(long counter, float radius) {
  float progress = map(counter, 0, MAX_COUNTER, 0, radians(720)); 
  float y = cos(progress) + radius*(cos(progress/2));
  float x = sin(progress) + radius*(sin(progress/1));
  float z = radius*sin(0.5*progress);
  return new Point(x, y, z);
}


void dashedLine(float x1, float y1, float x2, float y2, float dashL, float space) {
  float pc = dist(x1, y1, x2, y2) / 100;
  float pcCount = 0.5;
  float gPercent = 0;
  float lPercent = 0;
  float currentPos = 0;
  float xx1 = 0, 
    yy1 = 0, 
    xx2 = 0, 
    yy2 = 0;

  while (int(pcCount * pc) < dashL) {
    pcCount++;
  }
  lPercent = pcCount;
  pcCount = 0.1;
  while (int(pcCount * pc) < space) {
    pcCount++;
  }
  gPercent = pcCount;

  lPercent = lPercent / 100;
  gPercent = gPercent / 100;
  while (currentPos < 1) {
    xx1 = lerp(x1, x2, currentPos);
    yy1 = lerp(y1, y2, currentPos);
    xx2 = lerp(x1, x2, currentPos + lPercent);
    yy2 = lerp(y1, y2, currentPos + lPercent);
    if (x1 > x2) {
      if (xx2 < x2) {
        xx2 = x2;
      }
    }
    if (x1 < x2) {
      if (xx2 > x2) {
        xx2 = x2;
      }
    }
    if (y1 > y2) {
      if (yy2 < y2) {
        yy2 = y2;
      }
    }
    if (y1 < y2) {
      if (yy2 > y2) {
        yy2 = y2;
      }
    }

    line(xx1, yy1, xx2, yy2);
    currentPos = currentPos + lPercent + gPercent;
  }
}
