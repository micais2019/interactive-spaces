
import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

class WeatherGraph {

  WB_Render render;
  HE_Mesh [] mesh = new HE_Mesh[5];

  float radius = 5;
  PGraphics [] texture = new PGraphics[5]; // texture
  color [] colors = {color(#EB5118), color(#59CEEB), color(#FF55AD), color(#FFEE00), color(#1E00F0)};

  PShape[] create(FloatList wscores, PApplet app) {

    PShape[] objects = new PShape[5];

    for (int i = 0; i < 5; i ++) {
      float cylinderHeight = wscores.get(i);

      texture[i] = createGraphics(800, 800);
      texture[i].beginDraw();
      texture[i].noStroke();
      texture[i].background(colors[i]);
      texture[i].endDraw();

      HEC_Cylinder creator =new HEC_Cylinder();
      creator.setRadius(radius, radius); // upper and lower radius. If one is 0, HEC_Cone is called. 
      creator.setHeight(cylinderHeight);
      creator.setFacets(20).setSteps(1);
      creator.setCap(true, true);// cap top, cap bottom?
      //Default axis of the cylinder is (0,1,0). To change this use the HEC_Creator method setZAxis(..).
      creator.setZAxis(0, 1, 0);

      mesh[i] = new HE_Mesh(creator);

      HET_Diagnosis.validate(mesh[i]);

      objects[i] = WB_PShapeFactory.createSmoothPShape(mesh[i], texture[i], app);
    }
    
    /* objects[1] = WB_PShapeFactory.createSmoothPShape(dewpoint_mesh, app);
     objects[2] = WB_PShapeFactory.createSmoothPShape(humidity_mesh, app);
     objects[3] = WB_PShapeFactory.createSmoothPShape(pressure_mesh, app);
     objects[4] = WB_PShapeFactory.createSmoothPShape(uv_mesh, app); */
noStroke();
    return objects;
  }
}
