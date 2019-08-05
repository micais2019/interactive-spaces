import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

class SplashMotion {
  WB_ProgressReporter pr;
  HE_Mesh mesh;
  WB_Render3D render;
  float size;

  float thickness = random(10, 20);

  SplashMotion(float rad) {
    this.size = rad;
  }

  PShape create(int points, PApplet app) {

    //number of points in the splash
    WB_Point[] basepoints =new WB_Point[points];

    for (int i=0; i<points; i++) {
      basepoints[i]=new WB_Point(0, random(200), 0);
      //note: in Math.PI/x....etc, x must be no. of points/2
      if (i>0) basepoints[i].rotateAboutAxisSelf(Math.PI/12.0*i, 0, 0, 0, 0, 0, 1);
    }

    WB_Polygon polygon=new WB_Polygon(basepoints); //create polygon from base points, HEC_Polygon assumes the polygon is planar
    HEC_Polygon creator=new HEC_Polygon();
    creator.setPolygon(polygon);//alternatively polygon can be a WB_Polygon2D
    creator.setThickness(thickness);// thickness 0 creates a surface
    mesh=new HE_Mesh(creator);
    HET_Diagnosis.validate(mesh);
    HE_VertexIterator vitr=mesh.vItr();
    while (vitr.hasNext()) {
      vitr.next().setColor(color(random(255), random(50), random(255)));
      noStroke();//color, random
    }
    PShape splashmesh = WB_PShapeFactory.createFacetedPShapeWithVertexColor(mesh, app);
    noStroke();
    //splashmesh.disableStyle();
    return splashmesh;
  }
}
