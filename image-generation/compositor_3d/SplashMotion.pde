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

  SplashMotion(float rad) {
    this.size = rad;
  }

  PShape create(int points, float thickness, int reach, PApplet app) {

    //number of points in the splash
    WB_Point[] basepoints =new WB_Point[points];

    for (int i=0; i<points; i++) {
      basepoints[i]=new WB_Point(10, random(reach), random(-20, 20));
      //note: in Math.PI/x....etc, x must be no. of points/2
      if (i>0) basepoints[i].rotateAboutAxisSelf(Math.PI/(points*0.5)*i, 0, 0, 0, 0, 0, 1);
    }

    WB_Polygon polygon=new WB_Polygon(basepoints); //create polygon from base points, HEC_Polygon assumes the polygon is planar
    HEC_Polygon creator=new HEC_Polygon();
    creator.setPolygon(polygon);//alternatively polygon can be a WB_Polygon2D
    creator.setThickness(thickness);// thickness 0 creates a surface
    stroke(0);

    mesh=new HE_Mesh(creator);
    // HET_Diagnosis.validate(mesh);

    HET_MeshOp.splitFacesCenter(mesh);
    // HET_MeshOp.splitFacesCenter(mesh);

    //HET_MeshOp.splitFacesCenter(mesh);
    //mesh.getSelection("center").modify(new HEM_Extrude().setDistance(-40).setChamfer(0.2));
    HET_MeshOp.splitFacesTri(mesh);

    HE_VertexIterator vitr=mesh.vItr();
    while (vitr.hasNext()) {
      colorMode(RGB);
      stroke(0);
      strokeWeight(2);
      vitr.next().setColor(color(255, 255, 0, 255));
      //vitr.next().setColor(int(random(100))); //night b&w

      //vitr.next().setColor(color(random(0,100), random(10), random(50,100))); //night
      //vitr.next().setColor(color(random(255), random(50), random(100, 255)));//default
      //vitr.next().setColor(color(random(180,230), random(100,150), random(200, 255)));//day
      //noStroke();//color, random
    }
    PShape splashmesh = WB_PShapeFactory.createFacetedPShapeWithVertexColor(mesh, app);
    noStroke();
    //splashmesh.disableStyle();
    return splashmesh;
  }
}
