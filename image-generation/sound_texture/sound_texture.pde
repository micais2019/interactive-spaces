
FloatList scores; 
float MAX_LEVEL;

void setup() {
  size(1600, 800);   
  scores = new FloatList();
  
  String[] data = split("750 610 1853 636 923 381 485 220 532 351 308 533 310 319 1069 655 801 521 694 332 621 359 214 550 405 801 476 745 313 504 346 623 333 492 325 9404 2336 1098 1344 432 592 379 897 403 678 379 382 707 413 1219 715 1025 485 711 414 376 817 532 411 669 387 376 836 480 338 961 1335 513 1962 833 928 447 1060 678 630 1551 607 802 333 638 420 293 511 541 278 505 221 438 289 442 345 519 311 651 301 459 252 620 294 529 256 459 316 627 343 273 501 316 578 333 769 415 696 409 500 336 315 612 663 463 381 188 502 324 451 364 510 270 604 248 613 297 199 915 352 539 337 286 425 233 508 320 489 341 613 373 270 457 259 416"," ");
  // String[] data = split("371 492 276 413 268 562 260 514 235 482 312 536 357 500 236 532 220 305 534 219 479 571 205 514 289 482 317 604 229 329", " ");
  
  for (int i=0; i < data.length; i++) {
    scores.append(soundToScore(int(data[i])));
  }
  
  MAX_LEVEL = log2(10000);
  
  println(scores);
}

float soundToScore(int level) {
  level = constrain(level, 200, 10000);
  return float(level) / 10000.0;
}

float log2 (int x) {
  return (log(x) / log(2));
}

void draw() {
  noStroke();
  fill(255);
  background(0);
  
 
  int hh = height/2;
  int pixelsize = int(hh / 128);
  float barwidth = float(width) / scores.size();
  float score;
 
  for(int idx=0; idx < scores.size(); idx++) {
    pushMatrix();
    translate(idx * barwidth, height/2);
    score = scores.get(idx);
    for (int y = -(hh - 1); y < hh; y += pixelsize) {
      float adj = abs(y);
      float lim = (score * hh) - pixelsize;
      if (random(adj) < random(lim)) { //<>//
        rect(0, y, barwidth, pixelsize);
      }
    }
    popMatrix();
  }
}
