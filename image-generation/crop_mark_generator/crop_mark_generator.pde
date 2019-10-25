
/* NOTE: copy this from compositor_3d */
float bleed = 3; // mm
float coverWidth  = 340 + (bleed * 2); // mm
float coverHeight = 235 + (bleed * 2); // mm
float dpmm = 11.811;
/* end copy */

// all crop line values start in mm and get converted to px in setup()
float cropLine  = 20;
float cropOverlap = 1.5;
float border = cropLine - cropOverlap;
float spineCropLine = border * 0.75; // shouldn't touch border
float padIn = border + bleed;
float spineWidth = 10; 

// copied from compositor with addition of border
int coverFinalWidth  = round(coverWidth * dpmm + border * dpmm);
int coverFinalHeight = round(coverHeight * dpmm + border * dpmm);

void settings() {
  size(coverFinalWidth, coverFinalHeight);
}

void setup() {
  noLoop();
  stroke(0);
  strokeWeight(1);
  
  // convert
  cropLine      = round(cropLine * dpmm);
  cropOverlap   = round(cropOverlap * dpmm);
  border        = round(border * dpmm);
  spineCropLine = round(spineCropLine * dpmm);
  padIn         = round(padIn * dpmm);
  spineWidth    = round(spineWidth * dpmm);
}

void draw() {
  background(255);
  
  // verticals
  //   top
  line(padIn, 0, padIn, cropLine); 
  line(width - padIn, 0, width - padIn, cropLine);
  //   bottom
  line(padIn, height, padIn, height - cropLine);
  line(width - padIn, height, width - padIn, height - cropLine);

  // horizontals
  //   left
  line(0, padIn, cropLine, padIn);
  line(0, height - padIn, cropLine, height - padIn);
  //   right
  line(width, padIn, width - cropLine, padIn);
  line(width, height - padIn, width - cropLine, height - padIn); // right
  
  // spine
  float slx = width/2 - (spineWidth / 2);
  float srx = width/2 + (spineWidth / 2);
  //   top
  line(slx, 0, slx, spineCropLine);
  line(srx, 0, srx, spineCropLine);
  //   bottom
  line(slx, height, slx, height - spineCropLine);
  line(srx, height, srx, height - spineCropLine);
  
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
