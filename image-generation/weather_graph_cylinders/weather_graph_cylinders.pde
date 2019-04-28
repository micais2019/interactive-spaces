import peasy.PeasyCam;
PeasyCam cam;

float apparentTemperature = 61.48;
float dewPoint = 57.94;
float humidity = 0.88*100;
float pressure = 1019.6/10;
float uvIndex = 61.48;

void setup() {
  cam = new PeasyCam(this, 400);
  size(600, 600, P3D);
}

void draw() {

  background(255);
    pointLight(255, 255, 255, 400, 200, 300);

lights();

  //temp
  fill(255, 128, 0);
  noStroke();
  pushMatrix();   
  translate( 0, -(apparentTemperature/2), 0 );
  rotateX(1.57);
  drawCylinder( 20, 5, apparentTemperature );
  popMatrix();

  //dewpoint
  fill(194, 244, 66);
  pushMatrix();   
  translate(50, -(dewPoint/2), 0 );
  rotateX(1.57);
  drawCylinder( 20, 5, dewPoint );
  popMatrix();

  //humidity
  fill(255, 53, 113);
  pushMatrix();   
  translate( 100, -(humidity/2), 0 );
  rotateX(1.57);
  drawCylinder( 20, 5, humidity );
  popMatrix();

  //pressure
  fill(53, 255, 207);
  pushMatrix();   
  translate( 150, -(pressure/2), 0 );
  rotateX(1.57);
  drawCylinder( 20, 5, pressure );
  popMatrix();

  //uvIndex
  fill(56, 85, 255);
  pushMatrix();   
  translate( 200, -(uvIndex/2), 0 );
  rotateX(1.57);
  drawCylinder( 20, 5, uvIndex );
  popMatrix();

  //baseX
  fill(51);
  pushMatrix();   
  translate( 100, 0, 0 );
  rotateY(1.57);
  drawCylinder( 20, 5, 210 );
  popMatrix();
  
  //baseZ
  fill(51);
  pushMatrix();   
  translate( 0, 0, -52 );
  rotateZ(1.57);
  drawCylinder( 20, 5, 105 );
  popMatrix();
}



void drawCylinder( int sides, float r, float h)
{
  float angle = 360 / sides;
  float halfHeight = h / 2;

  // draw top of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  // draw bottom of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
  }
  endShape(CLOSE);

  // draw sides
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);
}


// rotateY( radians( frameCount ) );
//rotateZ( radians( frameCount ) );
