/**
 * Double Random 
 * by Ira Greenberg.  
 * 
 * Using two random() calls and the point() function 
 * to create an irregular sawtooth line.
 */

class Toroid {
  int pts = 80; 
  float angle = 0;
  float radius; // tube radius

  // lathe segments
  int segments = 60;
  float latheAngle = 0;
  float latheRadius; // whole donut

  //vertices
  PVector vertices[], vertices2[];
  PGraphics surface;
  
  PGraphics pix;
  int textureStepX, textureStepY, texHW, texHH;

  Toroid(int h, int w) {
    surface = createGraphics(h, w, P3D);
    latheRadius = h / 3.4;
    radius = h / 8.0;
    
    // w = circumference of donut, h = circumference of tube
    // println(latheRadius, radius);
    pix = createGraphics(1400, 800);
    textureStepX = pix.width / segments;
    textureStepY = pix.height / pts;
      
    texHW = pix.width / 2;
    texHH = pix.height / 2;
  }
  
  void drawTexture(float score) {
    score += 0.5;
    
    pix.beginDraw();
    pix.clear();
    pix.noStroke();
    pix.translate(texHW, texHH);

    float pixelsize = 10; 
  
    // from the center of the image outwards
    for (int x = -texHW; x < texHW; x += pixelsize) {
      for (int y= -texHH; y < texHH; y += pixelsize) {
        if (abs(x) < random(0, texHW * score) && abs(y) < random(0, texHH * score)) {
          pix.fill(255);
        } else {
          pix.fill(0);
        }
        pix.rect(x, y, pixelsize, pixelsize);
      }
    }
    
    pix.endDraw();
  }

  void draw(float score) {
    drawTexture(score);

    surface.beginDraw();
    surface.smooth();
    surface.clear();

    surface.fill(0, 0, 128);
    surface.noStroke();
    
    //center and spin toroid
    surface.translate(surface.width/2, surface.height/2, -100);

    surface.rotateX(31 * PI/150);
    surface.rotateY(8 * PI/170);
    surface.rotateZ(frameCount * PI/50); 
    
    surface.textureWrap(CLAMP);

    // initialize point arrays
    vertices = new PVector[pts+1];
    vertices2 = new PVector[pts+1];

    for (int i=0; i<=pts; i++) {
      vertices[i] = new PVector();
      vertices2[i] = new PVector();
      vertices[i].x = latheRadius + sin(radians(angle)) * radius;
      vertices[i].z = cos(radians(angle)) * radius;
      angle += 360.0/pts;
    }
    
    // draw toroid
    latheAngle = 0;
    for (int i=0; i <= segments; i++) { // around the donut
      surface.beginShape(QUAD_STRIP);  
      surface.texture(pix);
      for (int j=0; j<=pts; j++) { // around each segment of the donut
        if (i>0) {
          // on every subsequent segment after the first, draw point on left edge of segment
          surface.vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z, i * textureStepX * 0.9, j * textureStepY);
        }
        
        vertices2[j].x = cos(radians(latheAngle)) * vertices[j].x;
        vertices2[j].y = sin(radians(latheAngle)) * vertices[j].x;
        vertices2[j].z = vertices[j].z;

        surface.vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z, (i + 1) * textureStepX * 0.9, j * textureStepY);
      }
      latheAngle += (360.0 / segments); // latheAngle moves the draw head around the torus clockwise 
      surface.endShape();
    }
    surface.endDraw();
  }
}

class SparkleDonut {
  PGraphics surface;
  Toroid toroid;
  
  SparkleDonut(int h, int w) {
    toroid = new Toroid(h, w);
  }
  
  void draw(float score) {
    toroid.draw(score);
    surface = toroid.surface;
  }
}
