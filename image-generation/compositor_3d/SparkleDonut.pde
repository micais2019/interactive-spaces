import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

class SparkleDonut {
  HE_Mesh mesh;
  HEC_Torus creator;
  WB_Render render;
  
  int tubeFacets = 36;
  int torusFacets = 80;
  int twist = 0;//36;
  float size;
  
  PGraphics pix; // texture

  SparkleDonut(float rad) {
    this.size = rad;
    pix = createGraphics(800, 800);
  }

  void drawTexture(FloatList scores) {
    pix.beginDraw();
    pix.noStroke();
    pix.background(0);
    pix.fill(255);

    int hh = pix.height / 2;
    float pixelsize = hh / 50;//128.0;
    float barwidth = float(pix.width) / scores.size();
    float score;

    for (int idx=0; idx < scores.size(); idx++) {
      pix.pushMatrix();
      pix.translate(idx * barwidth, hh);
      score = scores.get(idx);
      for (int y = -(hh - 1); y < hh; y += pixelsize) {
        float adj = abs(y);
        float lim = (score * hh) - pixelsize;
        if (random(adj) < random(lim)) {
          pix.rect(0, y, barwidth, pixelsize);
        }
      }
      pix.popMatrix();
    }
    pix.endDraw();
  }

  PShape create(FloatList scores, PApplet app) {
    drawTexture(scores);
    
    HEC_Torus creator=new HEC_Torus();
    creator.setRadius(size/3, size); 
    creator.setTubeFacets(tubeFacets);
    creator.setTorusFacets(torusFacets);
    creator.setTwist(twist);//twist the torus a given number of facets
    
    mesh=new HE_Mesh(creator); 
    
    HET_Diagnosis.validate(mesh);
    textureMode(NORMAL);
    textureWrap(REPEAT);
    PShape ring = WB_PShapeFactory.createSmoothPShape(mesh, pix, app);
    ring.disableStyle();
    return ring;
  }
}
