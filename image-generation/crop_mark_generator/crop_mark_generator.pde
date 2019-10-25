
/* NOTE: copy this from compositor_3d */
float bleed = 3; // mm
float coverWidth  = 340 + (bleed * 2); // mm
float coverHeight = 235 + (bleed * 2); // mm
float dpmm = 11.811;
/* end copy */

float padIn = 32;   // px
float cropLen = 26; // px

int coverFinalWidth  = round(coverWidth * dpmm + (cropLen - 4));
int coverFinalHeight = round(coverHeight * dpmm + (cropLen - 4));

void settings() {
  size(coverFinalWidth, coverFinalHeight);
}

void setup() {
  noLoop();
  stroke(0);
  strokeWeight(1);
}

void draw() {
  background(255);
  
  // verticals
  //   top
  line(padIn, 0, padIn, cropLen); 
  line(width - padIn, 0, width - padIn, cropLen);
  //   bottom
  line(padIn, height, padIn, height - cropLen);
  line(width - padIn, height, width - padIn, height - cropLen);

  // horizontals
  //   left
  line(0, padIn, cropLen, padIn);
  line(0, height - padIn, cropLen, height - padIn);
  //   right
  line(width, padIn, width - cropLen, padIn);
  line(width, height - padIn, width - cropLen, height - padIn); // right
  
  // spine
  float slx = width/2 - ((10 * dpmm) / 2);
  float srx = width/2 + ((10 * dpmm) / 2);
  //   top
  line(slx, 0, slx, 9);
  line(srx, 0, srx, 9);
  //   bottom
  line(slx, height, slx, height - 9);
  line(srx, height, srx, height - 9);
  
  saveTransparentCanvas(#ffffff);
  exit();
}

void saveTransparentCanvas(color bg) {
  final PImage canvas = get();
  canvas.format = ARGB;
 
  color p[] = canvas.pixels, 
        bgt = bg & ~#000000;
        
  for (int i = 0; i != p.length; ++i) {
    if (p[i] == bg)  p[i] = bgt;
  }
 
  canvas.updatePixels();
  canvas.save(dataPath("crops.png"));
}
