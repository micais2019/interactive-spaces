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
