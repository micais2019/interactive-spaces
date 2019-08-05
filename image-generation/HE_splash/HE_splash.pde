import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;
WB_ProgressReporter pr;
HE_Mesh mesh;
WB_Render3D render;

PImage img;

void setup() {
  size(1000, 1000, P3D);
  smooth(8);
  textureMode(NORMAL);
  //number of points in the splash
  WB_Point[] basepoints =new WB_Point[24];
  for (int i=0; i<24; i++) {
    basepoints[i]=new WB_Point(0, random(200), 0);
    //note: in Math.PI/x....etc, x must be no. of points/2
    if (i>0) basepoints[i].rotateAboutAxisSelf(Math.PI/12.0*i, 0, 0, 0, 0, 0, 1);
  }

  //create polygon from base points, HEC_Polygon assumes the polygon is planar
  WB_Polygon polygon=new WB_Polygon(basepoints);

  HEC_Polygon creator=new HEC_Polygon();
  creator.setPolygon(polygon);//alternatively polygon can be a WB_Polygon2D
  creator.setThickness(15);// thickness 0 creates a surface
  
  mesh=new HE_Mesh(creator);
  HET_Diagnosis.validate(mesh);

  img = loadImage("stripes.png");

  render=new WB_Render3D(this);
  //color, random
    HE_VertexIterator vitr=mesh.vItr();
  while(vitr.hasNext()){
   vitr.next().setColor(color(random(255), random(80),random(80,180)));

  }
}



void draw() {
  background(255);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  translate(width/3, height/3);
  rotateY(mouseX*1.0f/width*TWO_PI);
  rotateX(mouseY*1.0f/height*TWO_PI);
  noStroke();
  render.drawFacesVC(mesh);
  stroke(0);
  render.drawEdges(mesh);
}
