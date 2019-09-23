
import peasy.*; 

final boolean CONTROL_POSITION = false;
final boolean DEBUG = false;
boolean ONE_SHOT = false;

final boolean SKIP_DONUT = false;
final boolean SKIP_CLOTH = false;
final boolean SKIP_PLANETS = false;
final boolean SKIP_TEXT = false;
final boolean SKIP_WORDS =false;
final boolean SKIP_SPLASH = false;
final boolean SKIP_WEATHER = false;
final boolean SKIP_LOGO = false;
final boolean SKIP_PATHS = false;
final boolean SKIP_TIME = false;
final boolean SKIP_COUNTER = false;
final boolean SKIP_ARROWS = false;


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

String[] weatherData;
String[] soundData;
String[] moodData;

//triangular paths
Point origin, p1, p2, squareOrigin, ps1, ps2, ps3;
PolygonPath triangle, square, zigzag;

PShape arrow;

int MAX_COUNTER = 75000;

//zigzag points
Point [] zig_points = new Point [11];

void setup() {
  size(4200, 2847, P3D); // FULL
  //size(3600, 2400, P3D);
  smooth(8);

  ONE_SHOT = getOneShotFromArgs();
  now = 1555750935;
  //now = getTimestampFromArgs();
  //index = getIndexFromArgs();
  index = 10;

  // loading data
  DataLoader dload = new DataLoader(this);

  soundScores = dload.getSound1Scores(now);
  moodValues = dload.getMoodValues(now);
  weatherScores = dload.getWeatherScores(now);

  if (!SKIP_CLOTH) {
    // w h amp detail
    // more amp -> bigger hills
    // more detail -> tighter hills
    //int amp = map (motion data, 0, 5344, 1000, 8000);
    cloth = new ClothShape(floor(width * 0.44), floor(height * 3), 8000, 400);
    fabric = cloth.create(moodValues, this);
  }

  if (!SKIP_DONUT) {
    // just give size
    //int size = map(soundScore, 898, 839413, width * 0.08, width * 0.7);
    toroid = new SparkleDonut(width *0.08);
    donut = toroid.create(soundScores, this);
  }

  if (!SKIP_PLANETS) {
    // TODO: add sound2 scores
    planet = new Planet(height * 0.04, now, this);
  }

  if (!SKIP_WORDS) {
    wordart = new MoodWords(width * 0.6, 70, moodValues);
  }

  if (!SKIP_WEATHER) {
    WeatherGraph weather = new WeatherGraph();
    //int radius = map(weatherScores, 0, 100, 1, 5); 
    weatherObjects = weather.create(weatherScores, this);
  }

  if (!SKIP_SPLASH) {
    // TO ADD: Motion Scores?
    //mapping motion scores to points and thickness
    //int points = map(motion scores, 0, 5344, 5, 25);    //25 = max, 3 = min
    //int thickness = map(motion scores, 0, 5344, 5, 100); //50 = max, 5 = min
    //int size = map(motion scores, 0, 5344, 50, 500);
    explosion = new SplashMotion(width * 0.1);
    splash = explosion.create(24, 20, 500, this); //change to higher number for funky glitches
  }

  if (!SKIP_TEXT) { 

    textPara = new TextParagraph(1700, 700);
  }

  if (!SKIP_LOGO) {
    MICA_logo = loadShape("mica_logo-01.svg");
    MICA_logo.disableStyle();
    MICA_logo.setFill(255);
  }

  if (!SKIP_TIME) { 
    timestamp = new TimeStamp(1200, 100);
  }

  if (!SKIP_COUNTER) {
    counter = new TextCounter(800, 100);
  }

  generatePaths(); // create paths but don't draw them
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

  Point text_center = getEllipsePoint(index % MAX_COUNTER, width*0.27, 0.1, 0.85); //create points

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

  if (!SKIP_TEXT) {
    drawText(now);
  }

  if (!SKIP_WORDS) {
    drawWords(now);
  }

  if (!SKIP_TIME) {
    drawTimestamp(now);
  }

  if (!SKIP_COUNTER) {
    drawCounter(index);
  }

  if (!SKIP_ARROWS) {
    drawArrows(now);
  }

  if (ONE_SHOT) {
    String filename = String.format("%s_%d_%d.png", now, 
      coverFinalWidth, coverFinalHeight, index);
    saveFrame(filename);
    exit();
  }
}

void drawDonut(long ts) {

  Point donut_center = getEllipsePoint(index % MAX_COUNTER, height*0.5, 1.0, 0.5);

  pushMatrix();
  //move it along a XZ axis, circularly
  translate(width*0.5+donut_center.x, height*0.8, donut_center.y +50);

  int rot = int(ts % (long)60);

  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(index * 0.1);
    rotateZ(index * 0.1);
  }
  noStroke();
  textureMode(NORMAL);
  scale(0.9);
  shape(donut);

  popMatrix();
}

void drawPlanets(long ts) {

  Point planets_center = getEllipsePoint(index % MAX_COUNTER, width*0.27, 0.4, 1.0);

  pushMatrix();
  noStroke();
  translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y, 40);
  // rotateY(0.2);`

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

void drawWords(long ts) {

  boolean movingRight = true;
  boolean movingUp = false;

  Point zig_center = zigzag.point(index % MAX_COUNTER);  //create zigzag points

  pushMatrix();
  scale(0.8);
  //translate(width *0.2, height * 0.1);
  translate(zig_center.x+200, zig_center.y + 250, 700);
  imageMode(CORNER);
  image(wordart.draw(), 0, 0);
  popMatrix();
}


void drawCloth(long ts) {
  pushMatrix();

  translate(width * 0.4, 100, -900);
  /* if (CONTROL_POSITION) {
   rotateY(mouseX * 1.0f/width * TWO_PI);
   rotateX(mouseY * 1.0f/height * TWO_PI);
   } else { */
  rotateY(-1.649);
  rotateX(2.889);
  //}

  noStroke();
  textureMode(NORMAL);
  shape(fabric);
  popMatrix();
}

void drawText(long ts) {
  float border = 50;

  Point text_center = getEllipsePoint(index % MAX_COUNTER, width*0.27, 0.1, 0.85);
  textPara.draw(ts); 
  pushMatrix();
  translate(width*0.08, height*0.35, 200);
  scale(0.9);
  imageMode(CORNER);
  //draw white rectangle
  fill(255);
  rectMode(CORNER);
  rect(text_center.x*0.8-(border/2), text_center.y*0.8-(border/2), width*0.4 + border, height*0.25 + border);
  noFill();
  //draw text
  image(textPara.surface, text_center.x*0.8, text_center.y*0.8);
  popMatrix();
}

void drawTimestamp(long ts) {
  Point tri_center = triangle.point(index % MAX_COUNTER);
  timestamp.draw(ts);
  pushMatrix();
  scale(0.75);
  translate(tri_center.x + 150, tri_center.y + 400, 800);

  imageMode(CORNER);
  image(timestamp.surface, 0, 0);
  popMatrix();
}

void drawCounter(long ts) {
  Point square_center = square.point(index % MAX_COUNTER);
  counter.draw(index); 
  pushMatrix();
  scale(0.75);
  translate(square_center.x + 200, square_center.y + 400, 800);
  imageMode(CORNER);
  image(counter.surface, 0, 0);
  popMatrix();
}


void drawSplash(long ts) {
  Point splash_center = getMoebiusPoint(index % MAX_COUNTER, width*0.25);

  pushMatrix();
  translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z);
  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.0f/width * TWO_PI);
    rotateX(mouseY * 1.0f/height * TWO_PI);
  } else { 
    rotateX(index * 0.2);
    rotateZ(index * 0.2);
  }
  scale(2.5);
  shape(splash);
  popMatrix();
}


void drawWeatherGraph(long ts) {
  //relative adjustments for weathergraph
  float tolerance1 = (weatherScores.get(0)-weatherScores.get(1))/2;
  float tolerance2 = (weatherScores.get(1)-weatherScores.get(2))/2;
  float tolerance3 = (weatherScores.get(2)-weatherScores.get(3))/2;
  float tolerance4 = (weatherScores.get(3)-weatherScores.get(4))/2;
  float tolerance5 = ((weatherScores.get(0))/2);


  Point weather_center = getEllipsePoint(index % MAX_COUNTER, width*0.4, 0.85, 0.5);

  pushMatrix();

  // primary positioning

  translate(width/2 + weather_center.x, height/2 + weather_center.y, 400);

  int rot = int(ts % (long)60);
  float ry = map(rot, 0, 60, -1.48, 0.48);
  float rx = map(rot, 0, 60, -0.78, 1.2);

  if (CONTROL_POSITION) {  
    rotateY(mouseX * 1.5f/width * TWO_PI);
    rotateX(mouseY * 1.25f/height * TWO_PI);
  } else { 
    rotateX(index * 0.1);
    rotateZ(index * 0.1);
  }
  scale(3); // just adjust this when scaling resolution
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
}

void drawLogo(long ts) {
  pushMatrix();
  translate(width*0.5, height*0.5, 2000);
  scale(0.8);
  rotate(radians(90));
  //fill(255);
  shapeMode(CENTER);
  shape(MICA_logo);
  popMatrix();
  shapeMode(CORNER);
}


void mouseClicked() {
  long t = (new Date()).getTime() / 1000;
  String filename = String.format("%s_%d_%d.png", now, 
    coverFinalWidth, coverFinalHeight);
  saveFrame(filename);
}

//get points for paths
//draw paths
void drawPaths(long ts) {

  //ZIGZAG
  zigzag = new PolygonPath(zig_points, 4500);

  //draw zigzag and weather
  for (int i=0; i<MAX_COUNTER; i+=1) {
    Point zig_center = zigzag.point(i);

    //zigzag path, moodwords
    pushMatrix();
    //fill(#B8FF01);
    fill(#0000FF);
    translate(zig_center.x, zig_center.y);
    rect(0, 0, 3, 3);
    popMatrix();
  }

  //draw the rest of the paths
  for (int i=0; i< MAX_COUNTER; i+=1) {

    // 1. locate
    Point weather_center = getEllipsePoint(i, width*0.5, 0.85, 0.5);
    Point donut_center = getEllipsePoint(i, height*0.5, 1.0, 0.5);
    Point planets_center = getEllipsePoint(i, width*0.27, 0.4, 1.0);
    Point text_center = getEllipsePoint(i, width*0.27, 0.1, 0.85);
    Point splash_center = getMoebiusPoint(i, width*0.25);

    noStroke();
    //weather path
    fill(#00ED18);
    pushMatrix();
    translate(width*0.5 + weather_center.x, height*0.5 + weather_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    popMatrix();

    //donut path
    fill(50);
    pushMatrix();  
    translate(width*0.5 + donut_center.x, height*0.8, donut_center.y);
    rect(0, 0, width*0.0008, width*0.0008);
    popMatrix();

    //planets path
    fill(#FFF700);
    pushMatrix();
    translate(width*0.7 + planets_center.x, height*0.5 + planets_center.y);
    rect(0, 0, width*0.0007, width*0.0007);
    popMatrix();

    //moebius path, splash
    pushMatrix();
    fill(#FF0DAA);
    translate(width*0.5+splash_center.x, height*0.5+splash_center.y, splash_center.z );
    rect(0, 0, width*0.0007, width*0.0007);
    popMatrix();

    fill(255);
  }
}


void drawArrows(long ts) {

  //donut arrow
  arrow.disableStyle();
  fill(50);
  Point arrow_centerD = getEllipsePoint((index+250) % MAX_COUNTER, height*0.5, 1.045, 0.182);
  float progressD = map((index+250), 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width/2 + arrow_centerD.x, height*0.828+arrow_centerD.y);
  rotate(progressD+radians(90));
  shapeMode(CENTER);
  scale(4);
  shape(arrow, 0, 0);
  popMatrix();
  shapeMode(CORNER);
  //donut arrow
  fill(255);

  //planets arrow
  arrow.disableStyle();
  fill(#FFF700);
  Point arrow_centerP = getEllipsePoint((index+150) % MAX_COUNTER, width*0.27, 0.4, 1.0);
  float progressP = map(index +150, 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width*0.7 + arrow_centerP.x, height*0.5 + arrow_centerP.y, 0);
  rotate(progressP+radians(90));
  shapeMode(CENTER);
  scale(4);
  shape(arrow, 0, 0);
  popMatrix();
  //planets arrow
  fill(255);
  shapeMode(CORNER);

  //zigzag arrow
  boolean movingRight = true;
  boolean movingUp = false;
  Point arrow_center = zigzag.point((index+30)  % MAX_COUNTER);

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
  scale(4);
  shape(arrow, 0, -6);
  popMatrix();
  //zigzag arrow

  //weather arrow
  arrow.disableStyle();
  fill(#00ED18);
  Point arrow_centerW = getEllipsePoint((index +50) % MAX_COUNTER, width*0.51, 0.845, 0.505);
  float progressW = map(index +50, 0, MAX_COUNTER, 0, TWO_PI); 
  pushMatrix();
  translate(width/2 + arrow_centerW.x, height/2 + arrow_centerW.y, 0);
  rotate(progressW+radians(90));
  scale(4);

  shape(arrow, 0, 0);
  popMatrix();
  //weather arrow
  fill(255);

  //splash arrow
  //Point splash_center = getMoebiusPoint(i, width*0.25);

  //arrow
  arrow.disableStyle();
  fill(#FF0DAA);
  Point arrow_centerS = getMoebiusPoint((25000+frameCount*100+50) % MAX_COUNTER, width*0.25);
  float progress = map((frameCount*100+50), 0, 3400, 0, PI/2);
  pushMatrix();
  translate(width*0.5+arrow_centerS.x, height*0.5+arrow_centerS.y, arrow_centerS.z);
  if (arrow_centerS.y > 520 && arrow_centerS.y < 900 && arrow_centerS.x < 1100 && arrow_centerS.x > 600) {
    rotate(-progress+radians(180));
  }
  if (arrow_centerS.z > 910 && arrow_centerS.z < 1100 && arrow_centerS.y < 520) {
    rotate(-radians(160));
  }

  if (arrow_centerS.y < -450 && arrow_centerS.y > -850) {
    rotate(progress+radians(230));
  }

  if (arrow_centerS.x > 250 && arrow_centerS.y > -850) {
    rotate(progress+radians(230));
  }
  println(arrow_centerS.x);
  scale(4);
  shapeMode(CENTER);
  shape(arrow, 0, 0);
  popMatrix();
  //arrow3
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