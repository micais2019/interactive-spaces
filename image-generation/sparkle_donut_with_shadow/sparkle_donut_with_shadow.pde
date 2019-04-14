boolean MASK = true;
boolean DRAW_MASK = false;

PGraphics pix;
PGraphics donut;
PGraphics shadow;

float frequency; 

int w = 600, h = 600;

//donut
float resolution = 100; // how many points in the circle
float rad = 250;
float x = 1;
float y = 1;
float t = 0; // time passed
float tChange = 0.001; // how quick time flies
float nVal; // noise value
float nInt = 1; // noise intensity
float nAmp = 1; // noise amplitude

void setup() {
  size(600, 600);
  frameRate(0.5);
  noiseDetail(1);
  smooth();
  donut = createGraphics(w, h);
  shadow = createGraphics(w, h);

  pix = createGraphics(w, h);
}

void draw() {

  //background(51);
  //drawing layer
  pix.beginDraw();
  pix.background(255);
  pix.noStroke();
  for (int x = 0; x<width; x+=5) {
    for (int y=0; y < height; y+=5) {  
      pix.rect(x, y, 5, 5);
      if (x< random(100, 500) && y>random(100, 500)) {
        pix.fill(255);
      } else {
        pix.fill(0);
      }
    }
  }

  //mask layer
  donut.beginDraw();
  shadow.beginDraw();
  donut.beginShape();
  shadow.beginShape();

  donut.smooth();
  //donut.background(255);
  donut.translate(width/2, height/2);
  donut.noFill();
  donut.stroke(255);
  donut.strokeWeight(80);
  shadow.translate(width/2, height/2);
  shadow.noFill();
  shadow.stroke(100);
  shadow.strokeWeight(80);
  nInt =0.6; //0.1 to 30
  nAmp = 0.2; // 0 to 1.0

  for (float a=0; a<=TWO_PI; a+=TWO_PI/resolution) {

    nVal = map(noise( cos(a)*nInt+1, sin(a)*nInt+1, t ), 0.0, 1.0, nAmp, 1.0); // map noise value to match the amplitude

    x = cos(a)*rad *nVal;
    y = sin(a)*rad *nVal;

    donut.vertex(x, y);
    shadow.vertex(x +10, y +10);
  }

  donut.endShape(CLOSE);
  shadow.endShape(CLOSE);
    donut.endDraw();
  shadow.filter(BLUR,6);
  shadow.endDraw();
  //t+=tChange;

  //boolean
  if (MASK) {
    // I call the mask function on my drawing layer
    // with the mask layer as an argument.
    pix.mask(donut);
    image(shadow,0,0);
    image(pix, 0, 0);
  } else if (DRAW_MASK) {
    image(donut, 0, 0);
  }

}
