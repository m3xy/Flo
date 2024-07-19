float cameraZ = ((height/2.0) / tan(PI*30.0/180.0)); //(Default) Render distance
float sensitivity = 0.001f;

int nEnemies = 5;
int nRocks = 12;
int nStars = 20;
int nTrees = 6;
int nWaves = 1;

void drawFPS() {
  fps.beginDraw();
  //fps.background(20,20,25); //Dark BG (Dark sky)
  //fps.background(biome);
  //fps.background(lerpColor(color(lows * 0.2, mids* 0.2, highs* 0.2), color(oldLows * 0.2, oldMids* 0.2, oldHighs* 0.2), 0.5));
  //fps.background(constrain(lows, 0, 30), constrain(mids, 0, 30), constrain(highs, 0, 30));
  fps.background(lows * 0.02, mids* 0.02, highs* 0.02);
  //fps.lights();  //Lighting
  fps.lightSpecular(score, score, score); //Shine depending on score
  fps.ambientLight(200,200,200);
  
  //fps.pointLight(255,255,255, sun.pos.x, sun.pos.y, sun.pos.z);
  fps.pointLight(lows,mids,highs, sun.pos.x, sun.pos.y, sun.pos.z);
  //fps.directionalLight(score, score, score, 0, -1, 0);
  

  
  //fps.perspective(PI/3.0, float(width)/float(height), cameraZ/50.0, cameraZ*25.0); //Increase render distance
  fps.perspective(PI/3.0, float(width)/float(height), cameraZ/50.0, cameraZ*25); //Increase render distance

  player.rPos.x -= sensitivity * (mouseY - height/2);
  player.rPos.y += sensitivity * (mouseX - width/2);
  robot.mouseMove(width/2,height/2); //Move cursor back to center
  player.rPos.x = constrain(player.rPos.x, PI + 0.01, TWO_PI);
  fps.camera(player.pos.x, player.pos.y, player.pos.z, 
      player.pos.x + (sin(player.rPos.x) * sin(player.rPos.y)),  //X
      player.pos.y + cos(player.rPos.x),                         //Y
      player.pos.z + (sin(player.rPos.x) * cos(player.rPos.y)),  //Z
      0, -1, 0);

  player.run();
  guns.get(gun).run();
  sun.run();
  terrain.run();
  for(Wave wave : waves)
    wave.run();

  for(Tree tree : trees)
    tree.run();
  
  for(Star star : stars)
    star.run();
    
  for(Rock rock : rocks)
    rock.run();
   
   //for(Runnable r : loop)
   //  r.run();
   
  //Reward
  //if(radio.pos() >= reward.iframes) {
  //  reward.grow();
  //  reward.iframes += radio.length()/nParams;
  //}
  if(beat) {
    reward.grow();
    beats++;
  }


  float mixLevel = max(radio.mix().level(), mic.mix().level());
  if(mixLevel > maxMixLevel)
    maxMixLevel = mixLevel;
    
  float leftLevel = max(radio.left().level(), mic.left().level());
  if(leftLevel > maxLeftLevel)
    maxLeftLevel = leftLevel;
    
  float rightLevel = max(radio.right().level(), mic.right().level());
  if(rightLevel > maxRightLevel)
    maxRightLevel = rightLevel;
    
  //reward.show();
  
  //if((song.position() == song.length() || !song.isPlaying()) && (playing + 1) < playlist.size()) {
  //  nextSongBtn.press();
  //}
 
 //  System.out.println(radio.pos() + " " + radio.length());
 if((radio.pos() == radio.length() || !radio.isPlaying()) && state == State.PLAY) {
    end(true, radio.playing());
  }
  
  fps.endDraw();
  image(fps, 0, 0);
  //System.out.println();
}
