import peasy.*;

SparkleDonut sd;

void setup() {
  size(1000, 1000, P3D);
  background(255);
  sd = new SparkleDonut(1000, 1000);

}

void draw() {
  background(255);

  // shape should take some data
  sd.draw(0.1);

  // shapes are applied to the surface
  image(sd.surface, 0, 0);

  // saveFrame("big.png");
  // exit();
}
