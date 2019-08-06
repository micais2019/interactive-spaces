// utility class so we're not passing arrays of 2 values around
class Point {
   float x,y;
   
   Point(float x, float y) {
     this.x = x;
     this.y = y;
   }
   
   Point(int x, int y) {
     this.x = float(x);
     this.y = float(y);
   }
   
   Point() {
     this.x = 0;
     this.y = 0;
   }
}
