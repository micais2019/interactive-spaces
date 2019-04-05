LetterA letter_a;
LetterB letter_b;
LetterC letter_c;
LetterD letter_d;
LetterE letter_e;
LetterF letter_f;
LetterG letter_g;
LetterH letter_h;
LetterI letter_i;
LetterJ letter_j;
LetterK letter_k;
LetterL letter_l;
LetterM letter_m;
LetterN letter_n;
LetterO letter_o;
LetterP letter_p;
LetterQ letter_q;
LetterR letter_r;
LetterS letter_s;
LetterT letter_t;
LetterU letter_u;
LetterV letter_v;
LetterW letter_w;
LetterX letter_x;
LetterY letter_y;
LetterZ letter_z;

import java.util.Date;

HashMap<String, LetterForm> hm = new HashMap<String, LetterForm>();

void setup() {
  size(600, 600);
  frameRate(2);
  Date d = new Date();
  hm.put("r", new LetterR(d.getTime() % 360, 2, color(255)));
}

long a = 0;
void draw() {
  background(0);
  Date d = new Date();
  println(d.getTime()/ 1000);
  LetterForm lf = hm.get("r");
  lf.update(d.getTime());
  lf.draw();
  image(lf.surface, 0, 0);

  a += 0.005;
}
