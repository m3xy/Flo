abstract class Body implements Runnable {
  
  //Linear and Angular -> Static data: Position. Kinematic data: Velocity. Dynamic data: Acceleration.
  PVector pos, vel, acc, rPos, rVel, rAcc;
  
  //Mass and damping factor
  float mass, damping, rDamping;
  
  //Attributes
  float hp, size, dex, dmg, def, maxHP;
  color colour;
  
  float hit;
  float iframes, maxIframes;
  
  //How often Body updates (in ms)
  //float rate;
  
  Body() {
    this.pos = new PVector(0,0,0);
    this.vel = new PVector(0,0,0);
    this.acc = new PVector(0,0,0);
    //this.rPos = new PVector(PI*1.25, PI*1.25, 0);
    this.rPos = new PVector(0,0,0);
    this.rVel = new PVector(0,0,0);
    this.rAcc = new PVector(0,0,0);
    this.mass = 1;
    this.damping = this.rDamping = 0.001;
    this.maxHP = 0;
    this.hp = 0;
    this.iframes = 0;
    this.maxIframes = 0;
  }
  
  void run() {
    this.display();
    this.update();
  }
  
  void addForce(PVector force) {
    if(mass <= 0f) return; //Infinite mass
    acc.add(force.copy().div(mass));
  }
  
  void addTorque(PVector rotation) {
   if(mass <= 0f) return; //Infinite mass
   rAcc.add(rotation.copy().div(mass));
  }
  
  void update() { //or Integrate
    //https://stackoverflow.com/questions/14013248/damping-velocity-with-deltatime
    //https://gafferongames.com/post/integration_basics/
    vel.mult(pow(damping, 1/frameRate)); //Apply damping
    rVel.mult(pow(rDamping, 1/frameRate));
    vel.add(acc.copy().div(frameRate)); //Update velocity
    rVel.add(rAcc.copy().div(frameRate));
    pos.add(vel.copy().div(frameRate)); //Update position
    rPos.add(rVel.copy().div(frameRate));
    acc.mult(0); //Clear acceleration/accumlator
    rAcc.mult(0);
    iframes = max(iframes-1, 0);
  }
  
  abstract void draw();
  
  void display() {
    fps.pushMatrix();
    this.draw();
    fps.popMatrix();
  }
  
  boolean dead() {
    return hp <= 0;
  }
  
  boolean hurt(float amt, String msg) {
    if(iframes <= 0) {
      amt = min(amt, this.hp);
      this.hp -= amt;
      if((this instanceof Player)) {
        if(this.dead()) end(false, msg);
      }else {
        hitDmg = amt; 
      }
      iframes = maxIframes;
      
      return true;
    }
    return false;
  }
  
}
