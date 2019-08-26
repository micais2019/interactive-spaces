
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

String[] weatherData;
String[] soundData;
String[] moodData;

int MAX_COUNTER = 1000;

PShape arrow;
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
    //int amp = map (motion data, 0, 5344, 1000, 4000);
    cloth = new ClothShape(floor(width * 0.5), floor(height * 3), 4000, 200);
    fabric = cloth.create(moodValues, this);
  }

  if (!SKIP_DONUT) {
    // just give size
    //int size = map(soundScore, 898, 839413, 100,400);
    toroid = new SparkleDonut(100); //size
    donut = toroid.create(soundScores, this);
  }

  if (!SKIP_PLANETS) {
    // TODO: add sound2 scores
    planet = new Planet(height * 0.04, now, this);
  }

  if (!SKIP_WORDS) {
    wordart = new MoodWords(width * 0.6, height * 0.3, moodValues);
  }

  if (!SKIP_WEATHER) {
    WeatherGraph weather = new WeatherGraph();
    //int radius = map(weatherScores, 0, 100, 1, 5); 
    weatherObjects = weather.create(weatherScores, 2, this);
  }

  if (!SKIP_SPLASH) {
    // TO ADD: Motion Scores?
    //mapping motion scores to points and thickness
    //int points = map(motion scores, 0, 5344, 5, 25);    //25 = max, 3 = min
    //int thickness = map(motion scores, 0, 5344, 5, 100); //50 = max, 5 = min
    //int size = map(motion scores, 0, 5344, 50, 500);
    explosion = new SplashMotion(500);
    splash = explosion.create(45, 20, 500, this); //change to higher number for funky glitches
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

  arrow = createShape();
  arrow.beginShape();
  arrow.noStroke();
  //arrow.stroke(0);
  //arrow.strokeWeight(2);
  arrow.vertex(0, 0);
  arrow.vertex(7, 7);
  arrow.vertex(0, 14);
  arrow.endShape();

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

  //arrow
  arrow.disableStyle();
  fill(50);
  Point arrow_center = getEllipsePoint((frameCount*10+100) % MAX_COUNTER, height*0.5, 1.045, 0.19);
  float progress = map((frameCount*10+100), 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width/2 + arrow_center.x, height*0.828+arrow_center.y);
  rotate(progress+radians(90));
  shape(arrow, -6, -6);  
  popMatrix();
  fill(255);
  //arrow

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

  //arrow
  arrow.disableStyle();
  fill(#FFF700);
  Point arrow_center = getEllipsePoint((frameCount * 5+100) % MAX_COUNTER, width*0.27, 0.4, 1.0);
  float progress = map(frameCount * 5 +100, 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width*0.7 + arrow_center.x, height*0.5 + arrow_center.y, 0);
  rotate(progress+radians(90));
  shape(arrow, -6, -6);
  popMatrix();
  //arrow
  fill(255);

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

  boolean movingRight = true;
  boolean movingUp = false;

  //ZIGZAG
  zigzag = new PolygonPath(zig_points, 4000);
  Point zig_center = zigzag.point(frameCount*3 % 4000);

  //arrow
  Point arrow_center = zigzag.point((frameCount*3+50) % 4000);

  if (arrow_center.y > height*0.1 && arrow_center.y < height*0.2 && arrow_center.x < width*0.85|| 
    arrow_center.y > height*0.3 && arrow_center.y < height*0.4 && arrow_center.x < width*0.85||
    arrow_center.y > height*0.5 && arrow_center.y < height*0.6 && arrow_center.x < width*0.85||
    arrow_center.y > height*0.7 && arrow_center.y < height*0.8 && arrow_center.x < width*0.85||
    arrow_center.y == height*0.9 && arrow_center.x < width*0.9
    ) {
    movingRight = !movingRight;
  } else if (arrow_center.x == width*0.9) {
    movingUp = true;
  }
  pushMatrix();
  translate(arrow_center.x, arrow_center.y);
  if (!movingRight) {
  } else {
    scale(-1, 1);
  }
  if (movingUp) {
    translate(-2, 0);
    rotate(-radians(90));
  }
  arrow.disableStyle();
  fill(#0000FF);

  shape(arrow, -6, -6);
  popMatrix();
  //arrow
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

  translate(width * 0.55, 100, -500);
  /* if (CONTROL_POSITION) {
   rotateY(mouseX * 1.0f/width * TWO_PI);
   rotateX(mouseY * 1.0f/height * TWO_PI);
   } else { */
  rotateY(-1.649);
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
  //arrow
  Point arrow_center = getEllipsePoint((frameCount * 6 +200) % MAX_COUNTER, width*0.27, 0.1, 0.85);
  float progress = map(frameCount * 6 +200, 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(-width*0.199, 0, 0);
  translate(width/2 + arrow_center.x, height/2 + arrow_center.y, 0);
  rotate(progress+radians(90));
  shape(arrow, -6, -6);
  popMatrix();
  //arrow

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
  Point tri_center = triangle.point(frameCount*5 % MAX_COUNTER);
  timestamp.draw(ts);
  pushMatrix();
  translate(width*0.42+tri_center.x*0.64, height*0.52+tri_center.y*0.64, 250);
  scale(0.7); 
  imageMode(CENTER);
  image(timestamp.surface, 0, 0);
  popMatrix();
}

void drawCounter(int count) {
  Point square_center = square.point(frameCount*5 % 3000);
  counter.draw(2000); 
  pushMatrix();
  translate(width*0.42+square_center.x*0.64, height*0.52+square_center.y*0.64, 250);
  scale(0.7);
  imageMode(CENTER);
  image(counter.surface, 0, 0);
  popMatrix();
}


void drawSplash(long ts) {
 Point splash_center = getMoebiusPoint(frameCount % MAX_COUNTER, 300);

  //arrow
  arrow.disableStyle();
  fill(#FF0DAA);
  Point arrow_center = getMoebiusPoint((frameCount+50) % MAX_COUNTER, 300);
  //println(arrow_center.y);
  float progress = map((frameCount+50), 0, 300, 0, TWO_PI); 
  pushMatrix();
  translate(width*0.5+arrow_center.x, height*0.5+arrow_center.y, arrow_center.z);
  rotate(progress+radians(180));
  shape(arrow, -6, -6);
  popMatrix();
  //arrow

  pushMatrix();
  translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateY(frameCount * 0.2);
    rotateX(frameCount *0.1);
    rotateZ(frameCount * 0.2);
  }
  scale(1.5);
  shape(splash);
  popMatrix();
  fill(255);
}


void drawWeatherGraph(long ts) {
  //relative adjustments for weathergraph
  float tolerance1 = (float(weatherData[0])-float(weatherData[1]))/2;
  float tolerance2 = (float(weatherData[1])-float(weatherData[2]))/2;
  float tolerance3 = (float(weatherData[2])-float(weatherData[3]))/2;
  float tolerance4 = (float(weatherData[3])-float(weatherData[4]))/2;
  float tolerance5 = (float(weatherData[0])/2);
  Point weather_center = getEllipsePoint((frameCount * 10) % MAX_COUNTER, width*0.35, 0.85, 0.5);

  //arrow
  arrow.disableStyle();
  fill(#00ED18);
  Point arrow_center = getEllipsePoint((frameCount * 10 +50) % MAX_COUNTER, width*0.5, 0.851, 0.5);
  float progress = map(frameCount * 10 +50, 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width/2 + arrow_center.x, height/2 + arrow_center.y, 0);
  rotate(progress+radians(90));
  shape(arrow, -6, -6);
  popMatrix();
  //arrow
  fill(255);

  pushMatrix();
  // primary positioning
  translate(width/2 + weather_center.x, height/2 + weather_center.y, 200);

  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.5f/width * TWO_PI);
    rotateX(mouseY * 1.25f/height * TWO_PI);
  } else { 
    rotateX(frameCount * 0.1);
    rotateZ(frameCount * 0.1);
  }
  scale(0.8);

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
  translate(tolerance5, 50);
  shape(weatherObjects[5]);
  popMatrix();

  popMatrix();
}

void drawLogo(long ts) {
  pushMatrix();
  translate(width*0.5, height*0.5, 500);
  rotate(radians(90));
  // MICA_logo.fill(255);
  scale(0.35);
  shapeMode(CENTER);
  shape(MICA_logo);
  MICA_logo.disableStyle();
  popMatrix();
  shapeMode(CORNER);
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

  //ZIGZAG
  zigzag = new PolygonPath(zig_points, 6000);

  //draw zigzag and square
  for (int i=0; i<6000; i+=1) {
    Point zig_center = zigzag.point(i);
    //Point square_center = square.point(i);

    //zigzag path, moodwords
    pushMatrix();
    fill(#0000FF);
    translate(zig_center.x, zig_center.y);
    rect(0, 0, 1.2, 1.2);
    popMatrix();

    //square path, timestamp
    /*pushMatrix();
     fill(58);
     translate(square_center.x, square_center.y);
     rect(0, 0, 1, 1);
     popMatrix();*/
  }

  //draw the rest of the paths
  for (int i=0; i< MAX_COUNTER; i+=2) {
    Point weather_center = getEllipsePoint(i, width*0.5, 0.85, 0.5);

    //ellipse(width*0.5, height*0.5, width*0.842, height*0.737);
    noStroke();
    //weather path
    fill(#00ED18);
    pushMatrix();
    translate(width*0.5 + weather_center.x, height*0.5 + weather_center.y);
    //rotate(0.1);
    rect(0, 0, 1.5, 1.5);
    //rotate(-cos(weather_center.x)*(-sin(weather_center.y))+radians(90));
    popMatrix();
  }  

  for (int i=0; i< MAX_COUNTER; i+=2) {
    Point donut_center = getEllipsePoint(i, height*0.5, 1.0, 0.5);
    float progress = map(i, 0, MAX_COUNTER, 0, TWO_PI); 

    //donut path
    fill(0);
    pushMatrix();  
    //ellipse(width*0.5, height*0.5, width*0.84, height*0.735);
    translate(width*0.5 + donut_center.x, height*0.8, donut_center.y);
    rotate(progress+radians(90));
    rotateZ(progress);
    ellipse(0, 0, 1.2, 1.2);
    popMatrix();
  }

  for (int i=0; i< MAX_COUNTER; i+=2) {
    Point planets_center = getEllipsePoint(i, width*0.27, 0.4, 1.0);
    Point text_center = getEllipsePoint(i, width*0.27, 0.1, 0.85);
    Point tri_center = triangle.point(i);

    //planets path
    fill(#FFF700);
    pushMatrix();
    translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y);
    rect(0, 0, 1.5, 1.5);
    popMatrix();

    //text path
    fill(0);
    pushMatrix();
    translate(width*0.3 + text_center.x, height*0.5 + text_center.y);
    rect(0, 0, 1.2, 1.2);
    popMatrix();

    /*//triangle path, counter
     pushMatrix();
     fill(0, 13, 255);
     translate(tri_center.x, tri_center.y);
     rect(0, 0, 1, 1);
     popMatrix();*/
  }
  for (float i=0; i< MAX_COUNTER; i+=0.5) {
    Point splash_center = getMoebiusPoint(i, 300);

    //moebius path, splash
    pushMatrix();
    fill(#FF0DAA);

    float progress = map(i, 0, MAX_COUNTER, 0, 1.5*TWO_PI); 
    translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z );
    //rotate(progress + radians(90));
    rotate(0.1);
    rect(0, 0, 1.2, 1.2);
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


Point getMoebiusPoint(float counter, float radius) {
  float progress = map(counter, 0, MAX_COUNTER, 0, radians(720)); 
  float y = cos(progress) + radius*(cos(progress/2));
  float x = sin(progress) + radius*(sin(progress/1));
  float z = radius*sin(0.5*progress);
  return new Point(x, y, z);
}
