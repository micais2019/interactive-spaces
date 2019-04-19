/*     WEATHER FROM MICAVIBE.COM/WEATHER

{"at":1555159202016,"current":{"time":1555159201,"summary":"Mostly Cloudy",
 "icon":"partly-cloudy-day","nearestStormDistance":17,"nearestStormBearing":146,
 "precipIntensity":0,"precipProbability":0,"temperature":61.48,
 "apparentTemperature":61.48,"dewPoint":57.94,"humidity":0.88,"pressure":1019.6,
 "windSpeed":2.83,"windGust":2.83,"windBearing":141,"cloudCover":0.83,"uvIndex":1,
 "visibility":7.16,"ozone":301.83},"_id":"00u61B2bZTYO1ynB"}
 
 */
 
import peasy.PeasyCam;
PeasyCam cam;
import extruder.*;

float apparentTemperature = 61.48;
float dewPoint = 57.94;
float humidity = 0.88*100;
float pressure = 1019.6/10;
float uvIndex = 61.48;
PShape weather;
//PShape heights;
//float [] weatherArray = {apparentTemperature, dewPoint, humidity, pressure, uvIndex};

extruder e;
PShape[] weatherExtrude;

int extrudeHeight = 50;

PImage gradient;

void setup() {
  cam = new PeasyCam(this, 400);
  size(600, 600, P3D);
  gradient = loadImage("gradient.png");
  weather = createShape();
  e = new extruder(this);

  //height array
  /*
  heights = createShape();
   for (int i = 0; i < weatherArray.length; i++) {
   heights.beginShape();
   //heights.vertex(i*50, 0, 0);
   heights.vertex(i*50, weatherArray[i], weatherArray[i]);
   heights.vertex(i*50, 0, 0);
   heights.vertex(i*50, weatherArray[i], 0);
   heights.vertex(i*50, weatherArray[i], weatherArray[i]);
   
   heights.endShape(CLOSE);
   }
   */
}
void draw() {
  
 weather.beginShape();
  weather.fill(255);
  weather.texture(gradient);
  weather.vertex(0, 0, extrudeHeight,0);
  weather.vertex(0, apparentTemperature, extrudeHeight,0);
  weather.vertex(50, dewPoint, extrudeHeight);
  weather.vertex(100, humidity, extrudeHeight,800);
  weather.vertex(150, pressure, extrudeHeight,800);
  weather.vertex(200, uvIndex, extrudeHeight,800);
  weather.vertex(200, 0, extrudeHeight,800);
  weather.vertex(0, 0, extrudeHeight,0);
  weather.endShape(CLOSE);
  
  //SETTINGS/RENDERING
  background(255);
  pointLight(255, 255, 255, 400, 200, 300);
  //lights();
  fill(200);

  //SHAPES
  shape(weather);

  //EXTRUDED WEATHER COMPOSITE
  //noStroke();
  //fill(250); //EXTRUSION COLOR
 // weatherExtrude = e.extrude(weather, extrudeHeight-10, "box");

  //for (PShape p : weatherExtrude) {
    //p.texture(gradient);
  //  shape(p);
  //}

  //LINES
  strokeCap(ROUND);
  strokeWeight(5);

  //TEMPERATURE DATA
  stroke(#9fff3f);
  fill(50);//text test

  line(0, 0, extrudeHeight, 0, apparentTemperature, extrudeHeight);
  point(0, apparentTemperature, extrudeHeight);
  text("temperature", 0, apparentTemperature, extrudeHeight);

  //DEWPOINT DATA
  stroke(#00ffe5);
  line(50, 0, extrudeHeight, 50, dewPoint, extrudeHeight);
  point(50, dewPoint, extrudeHeight);
  text("dewPoint", dewPoint, dewPoint, extrudeHeight);

  //HUMIDITY DATA
  stroke(#ff1900);
  line(100, 0, extrudeHeight, 100, humidity, extrudeHeight);
  point(100, humidity, extrudeHeight);
  text("humidity", 100, humidity, extrudeHeight);

  //PRESSURE DATA
  stroke(#ffdd00);
  line(150, 0, extrudeHeight, 150, pressure, extrudeHeight);
  point(150, pressure, extrudeHeight);
  text("pressure", 150, pressure, extrudeHeight);

  //UVINDEX DATA
  stroke(#8700ff);
  line(200, 0, extrudeHeight, 200, uvIndex, extrudeHeight);
  point(200, uvIndex, extrudeHeight);
  text("uvIndex", 200, uvIndex, extrudeHeight);

  //x-axis line
  stroke(0);
  line(0, 0, extrudeHeight, 200, 0, extrudeHeight);
}
