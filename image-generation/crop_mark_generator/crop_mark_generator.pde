
/* NOTE: copy this from compositor_3d */
float bleed = 3; // mm
float pageWidth = 165; // mm
float spineWidth = 13; // mm
float coverWidth  = (pageWidth * 2) + spineWidth + (bleed * 2); // mm
float coverHeight = 235 + (bleed * 2); // mm
float dpmm = 11.811;
/* end copy */

// all crop line values start in mm and get converted to px in setup()
float cropLine = 8;
float cropOverlap = 1.5;
float border = cropLine - cropOverlap;
float spineCropLine = border * 0.75; // shouldn't touch border
float padIn = border + bleed;

// copied from compositor with addition of border
int coverFinalWidth  = round(coverWidth * dpmm + (border * 2) * dpmm);
int coverFinalHeight = round(coverHeight * dpmm + (border * 2) * dpmm);

void settings() {
  size(coverFinalWidth, coverFinalHeight);
}

void setup() {
  noLoop();
  stroke(0);
  strokeWeight(1);
  
  println("cropLine", cropLine);
  println("border", border);
  println("spineCropLine", spineCropLine);
  println("padIn", padIn);
  println("spineWidth", spineWidth);  
  println("coverWidth", coverWidth);
  println("coverHeight", coverHeight);
  
  // convert
  cropLine      = round(cropLine * dpmm);
  border        = round(border * dpmm);
  spineCropLine = round(spineCropLine * dpmm);
  padIn         = round(padIn * dpmm);
  spineWidth    = round(spineWidth * dpmm);
  
  println("--------- CONVERTED ---------");
  println("cropLine", cropLine);
  println("border", border);
  println("spineCropLine", spineCropLine);
  println("cropOverlap", round(cropOverlap * dpmm));
  println("padIn", padIn);
  println("spineWidth", spineWidth);
  println("coverFinalWidth", coverFinalWidth);
  println("coverFinalHeight", coverFinalHeight);
}

void draw() {
  background(255, 0);
  
  println("width", width);
  println("height", height);
  
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
