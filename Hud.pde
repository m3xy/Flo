color hitColour = color(255);
float hitSize = 20;
float hitDmg = 0;
float hitmarker = 0;
float bar = 25, maxBar = 100;
float hudAlpha = 0;
HUDInput[] keys;
boolean crit;

//int score = 0;
void drawHUD() {
  hudAlpha = pow(score, 3);
  hud.beginDraw();
  hud.background(color(102,0,0, map(player.hp, 0, player.maxHP, 100, 0)), 255);
  write(hud, (int)frameRate + " fps", width, 0, RIGHT, TOP, 15, color(255)); //FPS
  //for(int i = 0; i < fft.specSize() * 0.75; i++)
  //{
  //  hud.stroke(255);
  //  // draw the line for frequency band i, scaling it up a bit so we can see it
  //  hud.line( i, height, i, height - fft.getBand(i)*8 );
  //}
  //hud.rect( 0, 0, song.left.level()*width, 100 );
  //hud.rect( 0, 100, song.right.level()*width, 100 );
  
  
  //Score
  write(hud, "Score: " + score(), width/2, 50, CENTER, TOP, 25, color(255));
  
  //Enemy HP
  //hud.fill(255);
  //hud.stroke(1);
  //hud.rect();
  //hud.rect((width/2)-map(bar, 0, maxBar, 0, width/32), (height *15/32), map(bar, 0, maxBar, 0, width/32), 10);
  
  //Crosshair

  
  //hud.circle(width/2, height/2, beat.isOnset() ? 6 : 10);
  //hud.circle(width/2, height/2, 10);
  
  if(hitmarker > 0) {
    float dur = (hitmarker/frameRate);
    color c = crit ? color(255, 36, 0, dur*255) : color(255, dur * 255);
    hud.stroke(c);
    hud.fill(c);
    hud.strokeWeight(4);
    drawHitmarker();
    write(hud, String.valueOf((int)hitDmg), width/2, (height*15/32) - (abs(dur - 1) * height/16), CENTER, CENTER, constrain((hitDmg * (crit ? 3 : 1))/10, height/50, height/25), c);
    hitmarker--;
  }else {
    hitColour = color(255); 
  }
  
  hud.noFill();
  hud.strokeWeight(2);
  hud.stroke(hitColour, hudAlpha);
  drawWaveform(hud, width/2, height/2, height/256, height/256, 20);
  
  
  //Preview reward (Length of song)
  //hud.stroke(255);
  //hud.strokeWeight(height/128);
  //hud.fill(128, 64);
  //hud.circle(width/2, height*217/256, height/8);
  
  //write(hud, "MIC " + (mic.muted ? "OFF" : "ON"), 0, 0, LEFT, TOP, 16, mic.muted ? color(255, 0, 0) : color(0, 255, 0));
  
  //HUD Inputs
  keys[0].draw(player.forward, onBeat);
  keys[1].draw(player.left, onBeat);
  keys[2].draw(player.backward, onBeat);
  keys[3].draw(player.right, onBeat);
  keys[4].draw(!mic.muted);
  keys[5].draw(player.flying, onBeat);
  keys[6].draw(player.firing, onBeat);
  
  hud.endDraw();
  image(hud, 0, 0);
}

void drawHitmarker() {
    ////hud.line((width/2) - hitSize, (height/2) + hitSize, (width/2) + hitSize, (height/2) - hitSize);
    ////hud.line((width/2) + hitSize, (height/2) + hitSize, (width/2) - hitSize, (height/2) - hitSize);
    float l1 = hitSize;
    float l2 = hitSize*2/3;
    
    hud.line((width/2) - l1, (height/2) + l1, (width/2) - l2, (height/2) + l2); //Bottom left
    hud.line((width/2) + l1, (height/2) + l1, (width/2) + l2, (height/2) + l2);
    hud.line((width/2) + l1, (height/2) - l1, (width/2) + l2, (height/2) - l2);
    hud.line((width/2) - l1, (height/2) - l1, (width/2) - l2, (height/2) - l2);
}

//Draw waveform in context ctx, of radius r
void drawWaveform(PGraphics ctx, float x, float y, float r, float h, float res) {
  ctx.beginShape();
  
  //Waveform
  for(int i = 0; i < 360/res; i++) {
    ctx.vertex(
    x + ((radio.mix().get((int)map(i, 0, 360/res, 0, radio.bufferSize())) + mic.mix().get((int)map(i, 0, 360/res, 0, radio.bufferSize()))) * h * cos(radians(i*res))) + (cos(radians(i*res)) * r * 1.5), 
    y + ((radio.mix().get((int)map(i, 0, 360/res, 0, radio.bufferSize())) + mic.mix().get((int)map(i, 0, 360/res, 0, radio.bufferSize()))) * h * sin(radians(i*res))) + (sin(radians(i*res)) * r * 1.5));
  }
  ctx.endShape(CLOSE);
}

void loadHUDInputs() {
  keys = new HUDInput[8];
  keys[0] = new HUDInput(width*3/32, height*57/64, height/25, height/25, "W", hud);
  keys[1] = new HUDInput(width*2/32, height*30/32, height/25, height/25, "A", hud);
  keys[2] = new HUDInput(width*3/32, height*30/32, height/25, height/25, "S", hud);
  keys[3] = new HUDInput(width*4/32, height*30/32, height/25, height/25, "D", hud);
  keys[4] = new HUDInput(width*8/32, height*30/32, height/25, height/25, "V", hud);
  keys[5] = new HUDInput(width*12/32, height*30/32, width*8/32, height/25, "⸻", hud);
  keys[6] = new HUDInput(width*24/32, height*30/32, height/25, height/25, "\u0490", hud);
}
