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
  float radius = 100.0; // tube radius

  // lathe segments
  int segments = 60;
  float latheAngle = 0;
  float latheRadius = 800.0; // whole donut

  //vertices
  PVector vertices[], vertices2[];

  PGraphics surface;

  Toroid(int h, int w) {
    surface = createGraphics(h, w, P3D);
    latheRadius = h / 3.0;
    radius = h / 5.0;
  }

  void draw(float score) {
    surface.beginDraw();
    surface.smooth();
    surface.clear();

    surface.fill(0);
    surface.noStroke();

    //center and spin toroid
    surface.translate(surface.width/2, surface.height/2, -100);

    surface.rotateX(frameCount*PI/150);
    surface.rotateY(frameCount*PI/170);
    surface.rotateZ(frameCount*PI/90);

    // initialize point arrays
    vertices = new PVector[pts+1];
    vertices2 = new PVector[pts+1];

    for (int i=0; i<=pts; i++) {
      vertices[i] = new PVector();
      vertices2[i] = new PVector();
      vertices[i].x = latheRadius + sin(radians(angle)) * radius;
      vertices[i].z = cos(radians(angle)) * radius;
      angle+=360.0/pts;
    }

    // draw toroid
    latheAngle = 0;
    for (int i=0; i<=segments; i++) {
      surface.beginShape(QUAD_STRIP); 

      for (int j=0; j<=pts; j++) {
        if (i>0) {
          surface.vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z);
        }
        vertices2[j].x = cos(radians(latheAngle)) * vertices[j].x;
        vertices2[j].y = sin(radians(latheAngle)) * vertices[j].x;
        vertices2[j].z = vertices[j].z;

        if (random(1.0) < score) surface.fill(255);
        else surface.fill(0);
        surface.vertex(vertices2[j].x, vertices2[j].y, vertices2[j].z);
      }
      
      // create extra rotation for helix
      latheAngle += 360.0/segments;
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
