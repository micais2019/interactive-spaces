import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

class ClothShape {
  
  HE_Mesh mesh;
  
  // modifier
  WB_Plane P;
  WB_Line L;
  HEM_Bend modifier;
  HEC_Grid creator;
  
  float ystep = 0;
  int detail; 
  int strength;
  float noiseDetail;
  
  ClothShape(int strength, int detail) {
    this.strength = strength;
    
    this.detail = detail;
    noiseDetail = map(detail, 100, 1000, 0.1, 0.01);
    
    creator=new HEC_Grid();
    
    creator.setU(detail);// number of cells in U direction
    creator.setV(detail * 2);// number of cells in V direction
    creator.setUSize(1000);// size of grid in U direction
    creator.setVSize(2000);// size of grid in V direction
  }

  PShape createShape(ClothTexture tex, PApplet app) {
    update();
    mesh = new HE_Mesh(creator); 
    textureMode(NORMAL);
    textureWrap(REPEAT);   
    PShape fabric = WB_PShapeFactory.createSmoothPShape(mesh, tex.surface, app);
    fabric.disableStyle();
    return fabric;
  }
  
  void update() {
    int d1 = detail + 1;
    float[][] values=new float[d1][d1 * 2];
    for (int y = 0; y < d1 * 2; y++) {
      for (int x = 0; x < d1; x++) {
        values[x][y] = (strength * map(y, 0, d1 * 2, 3.0, 0)) * noise(noiseDetail*x, (noiseDetail * 0.1) *(y + ystep));
      }
    }
  
    creator.setWValues(values); // displacement of grid points (W value)
    
    ystep += 0.1;
  }
}
