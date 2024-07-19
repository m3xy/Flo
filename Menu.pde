String msg = "";

PlayBtn playBtn;
ProgressBar progressBar;

SkipBtn nextSongBtn;
SkipBtn prevSongBtn;

ArrowBtn nextGunBtn;
ArrowBtn prevGunBtn;
GunInfo gunInfo;

void drawMENU() {
  background(20,20,25);
  
  //Title
  write(this.g, "F L Ō", width/2, height*4/16, CENTER, TOP, height/16, color(255));
  
  //Music Player
  playBtn.run();
  prevSongBtn.run();
  nextSongBtn.run();
  progressBar.run();
  write(this.g, radio.playing(), width/2, height*21/32, CENTER, BASELINE, height/40, color(255));
  //write(this.g, song.getMetaData().fileName(), width/2, height*21/32, CENTER, BASELINE, height/48, color(255));
  if(radio.pos() == radio.length()) {
    nextSongBtn.press();
  }
    
  //Gun Preview
  stroke(255);
  strokeWeight(2);
  nextGunBtn.run();
  prevGunBtn.run();
  gunInfo.x = width/2;
  gunInfo.y = height*15/32;
  gunInfo.run(guns.get(gun));
  showGun(guns.get(gun), gunInfo.x, gunInfo.y);
  
  write(this.g, "PRESS ENTER TO START", width/2, height*7/8, CENTER, BOTTOM, height/64, color(255));
}

//Writes text
void write(PGraphics ctx, String text, float x, float y, int alignX, int alignY, float size, color colour)  {
  ctx.stroke(255 - colour>>16 & 0xFF, 255 - colour>> 8 & 0xFF, 255 - colour& 0xFF);
  ctx.strokeWeight(0.5);
  ctx.fill(colour);
  ctx.textSize(size);
  ctx.textAlign(alignX, alignY);
  ctx.text(text, x, y);
}

void drawLOSE() {
  background(102,0,0); //blood colour
  write(this.g, "D E F E A T", width/2, height * 4/16, CENTER, TOP, height/16, color(255));
  write(this.g, "Score: " + score() + "/" + maxScore(), width/2, height * 12/32, CENTER, BOTTOM, 25, color(255));
  write(this.g, "Nice try! You died to " + msg + " and missed out on unlocking this weapon",  width/2, height * 3/4, CENTER, TOP, 18, color(255));
  //3D
  lows = mids = highs = 500;
  score = lows + mids + highs;
  bg = color(255);
  gunInfo.x = width/2;
  gunInfo.y = height*18/32;
  gunInfo.run(reward);
  showGun(reward, gunInfo.x, gunInfo.y);
  write(this.g, "PRESS ENTER TO RESTART", width/2, height*7/8, CENTER, BOTTOM, height/64, color(255));
}

void end(boolean win, String message) {
  msg = message;
  radio.clearFX();
  radio.pause();
  if(win) {
    state = State.WIN;
    reward.save();
  } else {
    state = State.LOSE;
  }
}

void drawWIN() {
  background(0,102,102); //Opposite of blood colour
  write(this.g, "V I C T O R Y", width/2, height * 4/16, CENTER, TOP, height/16, color(255));
  write(this.g, "Score: " + score() + "/" + maxScore(), width/2, height * 12/32, CENTER, BOTTOM, 25, color(255));
  write(this.g, "Congratulations! You survived " + msg + " and unlocked a new weapon!",  width/2, height * 3/4, CENTER, TOP, 18, color(255));
  //3D
  lows = mids = highs = 500;
  score = lows + mids + highs;
  bg = color(255);
  gunInfo.x = width/2;
  gunInfo.y = height*18/32;
  gunInfo.run(reward);
  showGun(reward, gunInfo.x, gunInfo.y);
  write(this.g, "PRESS ENTER TO RESTART", width/2, height*7/8, CENTER, BOTTOM, height/64, color(255));
}

void showGun(Gun gun, float x, float y) {
  gun.update();
  fps.beginDraw();
  fps.background(0,0);
  fps.perspective();
  fps.camera();
  fps.lights();
  fps.pushMatrix();
  fps.translate(x, y);
  fps.scale(width/32);
  gun.drawGun();
  fps.popMatrix();
  fps.endDraw();
  image(fps, 0, 0);
}

void loadBtns() {
  playBtn = new PlayBtn(width/2, height*3/4, height/64, this.g);
  progressBar = new ProgressBar(width/2, height*7/10, width/8, height/128, this.g);
  prevSongBtn = new SkipBtn(width*15/32, height*3/4, height/64, true, this.g);
  nextSongBtn = new SkipBtn(width*17/32, height*3/4, height/64, false, this.g);
  prevGunBtn = new ArrowBtn(width*6/16, height*15/32, height/64, true, this.g);
  nextGunBtn = new ArrowBtn(width*10/16, height*15/32, height/64, false, this.g);
  gunInfo = new GunInfo(width/2, height*15/32, height/8, this.g);
}
