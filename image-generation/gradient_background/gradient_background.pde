color[] colors  = {  
  #0061ff, 
  #ffff00, 
  #ff0000, 
  #009104, 
  #ff0f97, 
  #0073a8, 
  #00FF9F, 
  #00FDFF, 
};

PGraphics gSurface;
int ystep = 40;
int xstep = 10;

void setup() {
  size(500, 500);
  background(51);
  frameRate(1);
  ystep = height / 10;
  gSurface = createGraphics(500, 500);
}

void draw() {
  color newColor = colors[int(random(0, 6))];
  color prevColor = colors[int(random(0, 6))];

  // color start1 = colors[int(random(0,6))];
  // color end1 = colors[int(random(0,6))];
  gSurface.beginDraw();
  for (int i = 0; i <height; i+=ystep) {
    for (int j = 0; j<width; j+=xstep) {
      color tweenColor = lerpColor(newColor, prevColor, float(j)/float(width));
      gSurface.fill(tweenColor);
      gSurface.noStroke();
      gSurface.rect(j, i, xstep, ystep);
      //int xPostion = lerp(0,width,20.0);
    }
    /* 
     newColor = colors[int(random(0, 6))];
     prevColor = colors[int(random(0, 6))];
     */
    newColor = prevColor;
    prevColor = colors[int(random(0, 6))];


    /*
    fill(newColor);
     rect(0, 20, 20, 20);
     fill(prevColor);
     rect(480, 20, 20, 20); */
  }
  gSurface.endDraw();
  
  image(gSurface,0,0);
}
