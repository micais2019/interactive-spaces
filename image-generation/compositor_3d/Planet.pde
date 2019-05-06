import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;



class Planet {
  HE_Mesh mesh;
  PApplet app;
  float radius;
  
  FloatList offsets, rotations, scales;
  
  Planet(float value, long ts, PApplet app) {
    this.radius = value;
    this.app = app;
    
    offsets = new FloatList();
    rotations = new FloatList();
    scales = new FloatList();
    
    int count = floor(random(3, 8));
    offsets.clear();
    rotations.clear();
    scales.clear();
    for (int i=0; i < count; i++) {
      offsets.append((40 * i));
      rotations.append(random(TWO_PI));
      scales.append(random(0.6, 2.0));
    }
  }

  /* 
    params: 
     shape of fingerprints
     size of spheres
     placement of spheres
   */
  
  PShape create() {
    PGraphics skin = target(); 
    HEC_Sphere creator=new HEC_Sphere();
    creator.setRadius(radius); 
    creator.setUFacets(36);
    creator.setVFacets(36);
    mesh=new HE_Mesh(creator); 
    // HET_Diagnosis.validate(mesh);
    
    textureMode(NORMAL);
    textureWrap(REPEAT);
    PShape fabric = WB_PShapeFactory.createSmoothPShape(mesh, skin, app);
    fabric.disableStyle();
    return fabric;
  }
  
  PGraphics target() { // float freq, int cx, int cy) {
    PGraphics graphic = createGraphics(600, 600);
    graphic.beginDraw();
    graphic.smooth(8);
    graphic.ellipseMode(CENTER);
    graphic.stroke(0);
    graphic.fill(255);
    graphic.strokeWeight(20);
    
    for (int n=0; n < 80; n++) {
      finger(graphic, (int)random(width), (int)random(height));
    }
    
    graphic.endDraw();
    
    return graphic;
  }
  
  void finger(PGraphics graphic, int x, int y) {
    int rings = floor(random(3, 7));
    float step = random(1, 3.5); 
    float weight = step * 8;
    
    graphic.pushMatrix();
    graphic.translate(x, y);
    for (float i = rings * step; i > 0.1; i -= step) {
      graphic.strokeWeight(weight);
      graphic.ellipse(0, 0, i * 25, i * 25);
    }
    graphic.popMatrix();
  }

}
