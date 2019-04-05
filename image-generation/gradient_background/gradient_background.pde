color[] colors  = {  
  #FF0000, 
  #FFC000, 
  #E0FF00, 
  #7EFF00, 
  #21FF00, 
  #00FF41, 
  #00FF9F, 
  #00FDFF, 
};

int x  = 1;
int y = 6;

void setup() {
  size(500, 500);
  noStroke();
  background(51);
}


void draw() {
  color start = colors[x];
  color end = colors[y];

    for (int j = 0; j<width; j+=20) {
      color tweenColor = lerpColor(start, end, float(j)/float(width));
      fill(tweenColor);
      rect(j, 20, 20, 20);
    }
  

  fill(start);
  rect(0, 20, 20, 20);
  fill(end);
  rect(480, 20, 20, 20);
}
