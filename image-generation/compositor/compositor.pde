
//// 
// Book Cover Generator 0.1
////

/* 
Flow:
- get data at timestamp
- call drawings, passing them data and timestamp
- composite drawings into cover image
- add time and text values
*/

long now;

void setup() {
  now = getTimestampFromArgs();
  println("-- running at", now, "--");
  
  DataGetter dg = new DataGetter();
  String val = dg.getValue("motion", now);
  println("motion:", val);
  
  ArrayList<String> vals = dg.getHistory("sound", now, 10);
  println("sounds:", vals);
}

void draw() {
  exit();
}
