Player player;
float gravity = -2500; //-2500?
final class Player extends Body {
  
  boolean forward = false, backward = false, left = false, right = false, firing = false, jumping = false, flying = false;
  
  Supershape heart;
  
  int iFrames;
  
  Player() {
    super();
    this.pos.set(((terrain.cols * terrain.lod)/2) - 10, 0, ((terrain.rows * terrain.lod) /3) - 10);
    //this.rPos.set(PI*1.25, PI*1.25, 0); //Face front
    this.rPos.set(PI*1.5, PI, 0);
    heart = new Supershape(2.8f, 1.5f, 7.9f, 2.2f, 1, 1, 1, 1, 30);
    this.size = 20;
    //this.size = 10;
    this.maxHP = this.hp = 3;
    //this.size = 50;
    this.rDamping = 0; //For gun recoil to feel more "sudden"
    this.maxIframes = frameRate;
    //loop.add(this);
  }
  
  void update() {
    super.update();
    //if(forward)
    //  this.addForce(new PVector(-sin(this.rPos.y),0,-cos(this.rPos.y)));
    //if(backward)
    //  this.addForce(new PVector(sin(this.rPos.y),0,cos(this.rPos.y)));
    if(left)
      //this.addForce(new PVector(-2500,0,0));
      this.addForce(new PVector(sin(this.rPos.y + HALF_PI)*(beat ? 3333 : 1000),0,0));
    //  this.addForce(new PVector(sin(this.rPos.y + HALF_PI),0,cos(this.rPos.y + HALF_PI)));
    if(right)
      //this.addForce(new PVector(2500,0,0));
      this.addForce(new PVector(sin(this.rPos.y - HALF_PI)*(beat ? 3333 : 1000),0,0));
    //  this.addForce(new PVector(sin(this.rPos.y - HALF_PI),0,cos(this.rPos.y - HALF_PI)));
    
    float terrainH = terrain.heightAt(this.pos) + 75;
    
    this.addForce(new PVector(0, gravity, 0));  //Weight = Mass (1) * Gravity
    this.addForce(new PVector(0,max(0, terrainH - (this.pos.y - player.size))*-gravity*0.05,0));  //Buoyancy
    if((this.pos.y - player.size) <= terrainH) {
      if(jumping)
        //this.addForce(new PVector(0,((beat||kick||snare||hat) ? 50000 : 25000),0));
        this.addForce(new PVector(0,(onBeat > 0 ? 100000 : 50000),0));
      flying = false;
    } else {
      flying = true; 
    }

    //this.addForce(new PVector(0,-750,0));
    //if(this.pos.y <= 0) {
    //  if(jumping) {
    //    this.addForce(new PVector(0,((beat||kick||snare||hat) ? 100000 : 50000),0));
    //    //this.addForce(new PVector(0,(beat.isOnset() ? 50000 : 25000),0));
    //  } else {
    //    player.pos.y = 0;
    //  //this.addForce(new PVector(0,pow(terrain.heightAt(this.pos), 2) * -10000  ,0));
    //  }
    //}
    jumping = false;
      
    
    //this.pos.y = terrain.heightAt(player.pos) + 75;
    
    if(this.pos.y - this.size/2 <= terrain.heightAt(this.pos)) {
      //end(false, "The terrain");
      player.hurt(1, "The terrain");
    }
    this.rPos.z += 0.02; //Rotating hearts
//    this.pos.x = constrain(this.pos.x, 0, terrain.cols * terrain.lod);
  }
  
  
  void draw() {
    //fps.lightFalloff(0.1, 0.001, 0.0); //Slower falloff
    //fps.pointLight(255, 255, 255, this.pos.x, this.pos.y + 5, this.pos.z);  //Vision light
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    //fps.hint(DISABLE_DEPTH_TEST);
    //fps.fill(bg, 100);
    //fps.sphere(this.size);
    //fps.hint(ENABLE_DEPTH_TEST);
    fps.rotateY(player.rPos.y + PI);
    fps.rotateX(-player.rPos.x - HALF_PI);
    
    //if(firing) {
    //  fps.lightFalloff(0.5, 0.0, 0.000001); //Slower falloff
    //  fps.spotLight(255, 255, 255, 0, 0, 0, 0, 0, 1, QUARTER_PI/4, 1);  //Flashlight light
    //  fps.lightFalloff(1.0, 0.0, 0.000005); //Faster falloff
    //}
    
    //if(firing) {
    //  //fps.lightFalloff(0.5, 0.0, 0.000002); //Slower falloff
    //  //fps.spotLight(255, 255, 255, 0, 0, 0, 0, 0, 1, QUARTER_PI/2, 1);  //Flashlight light
      
    //  fps.lightFalloff(0.75, 0.0, 0.000003); //Slower falloff
    //  fps.pointLight(255,255,255,0,0,0);
    //  fps.lightFalloff(1.0, 0.0, 0.000005); //Faster falloff
    //}
    
    
    fps.noStroke();
    
    //fps.fill(136, 8, 8);
    fps.fill(255,0,0, hudAlpha);
    //fps.translate(-7, -4, 8);
    //fps.translate(i * 0.3, 0.5, 18);
    for(int i = 0; i < hp; i++) {
    fps.pushMatrix();
    fps.translate((-0.1*maxHP) + (0.3 * i), -0.75, 18);
    fps.rotateZ(HALF_PI);
    fps.rotateX(this.rPos.z);
    //fps.scale(beat.isOnset() ? this.hp/20 : this.hp/30);
    fps.scale(onBeat > 0 ? 0.15 : 0.1);
    fps.specular(0);
    heart.draw();
    fps.popMatrix();
    }

  }
  
  boolean hurt(float dmg, String msg) {
     //radio.bandpass.setBandWidth(map(hp, 0, maxHP, 0, radio.fft.specSize()-1));
     boolean harmed = super.hurt(dmg, msg);
     if(harmed)
       radio.bandpass = new LowPassFS(new float[]{60, 500, 1500, radio.fft.indexToFreq(radio.fft.specSize())}[(int)(hp)], radio.src.sampleRate());
     return harmed;
  }
  
  void heal(float health) {
    hp = min(hp + health, maxHP);
    //radio.bandpass.setBandWidth(map(hp, 0, maxHP, 0, radio.fft.specSize()-1));
    radio.bandpass = new LowPassFS(new float[]{60, 500, 1500, radio.fft.indexToFreq(radio.fft.specSize())}[(int)hp], radio.src.sampleRate());
  }
}
