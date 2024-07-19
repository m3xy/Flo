int enemyCD = 0;
final class Enemy extends Body {
 
  Supershape shape;
  float jitter;
  boolean isHead;
  boolean hasLegs;
  boolean hasWings;
  Leg[] legs;
  Wing[] wings;
  float scale;
  int lastAlive;
  
  Enemy(boolean isHead) {
    super();
    //shape = new Supershape(0f,1f,1f,1f,0f,1f,1f,1f,50); //Sphere
    shape = new Supershape(0,0,0,0,0,0,0,0,50);
    //this.pos.set(min(player.pos.x + random((terrain.cols/8)*terrain.lod), terrain.cols*terrain.lod), terrain.heightAt(player.pos.x, (terrain.rows - 1.1) * terrain.lod) + (this.size), (terrain.rows - 1.1) * terrain.lod);
    //this.pos.set(random(terrain.cols * terrain.lod), terrain.heightAt(player.pos.x, (terrain.rows - 1.1) * terrain.lod) + (this.size), (terrain.rows - 1.1) * terrain.lod);
    //this.damping = 0.9;
    jitter = 0;
    this.isHead = isHead;
    //hasLegs = isHead ? false : true;
    legs = new Leg[2];
    for(int i = 0; i < legs.length; i++) legs[i] = new Leg();
    //hasWings = true;
    wings = new Wing[2];
    for(int i = 0; i < wings.length; i++) wings[i] = new Wing();
    this.scale = isHead ? 1.25 : 1;
    this.hit = 0;
    
    //Init spawn
    //spawn();
    //this.hp = 255;
  }
  
  
  void draw() {
    
    if(hasLegs) {
      fps.stroke(lerpColor(this.colour, color(0), 0.75));
      fps.strokeWeight(this.size/4);
      
      PVector reset = new PVector();
      
      //Left leg
      reset.set(this.pos.x - legs[0].size, this.pos.y, this.pos.z + (legs[0].size*2.5));
      if(this.pos.dist(legs[0].pos) > this.pos.dist(reset))
        legs[0].pos.set(reset.copy());
      fps.line(this.pos.x, this.pos.y, this.pos.z, legs[0].pos.x - this.size, legs[0].pos.y - this.size + (this.size/4), legs[0].pos.z + this.size);
      //fps.line(this.pos.x, this.pos.y, this.pos.z, reset.x - this.size, reset.y, reset.z + this.size);
      //Right leg
      reset.set(this.pos.x + legs[1].size, this.pos.y, this.pos.z + (legs[1].size*2.5));
      if(this.pos.dist(legs[1].pos) > this.pos.dist(reset))
        legs[1].pos.set(reset.copy());
      
      fps.line(this.pos.x, this.pos.y, this.pos.z, legs[1].pos.x + this.size, legs[1].pos.y - this.size + (this.size/4), legs[1].pos.z + this.size);
      //fps.line(this.pos.x, this.pos.y, this.pos.z, reset.x + this.size, reset.y, reset.z + this.size);
      //fps.line(this.pos.x, this.pos.y, this.pos.z, this.pos.x - 2, 0, 2.25);
    }
    
    if(hasWings) {
      fps.stroke(lerpColor(this.colour, color(255), 0.75));
      fps.strokeWeight(this.size/8);
      fps.fill(this.colour, 64);
      PVector reset = new PVector();
      
      //Left wing
      reset.set(this.pos.x - (this.size*3), this.pos.y + this.size, this.pos.z);
      if(this.pos.dist(wings[0].pos) > this.pos.dist(reset) * 1.5)
        wings[0].pos.set(reset.copy());
      fps.beginShape();
      fps.vertex(this.pos.x, this.pos.y, this.pos.z);
      fps.vertex(reset.x, min(wings[0].pos.y, reset.y), wings[0].pos.z);
      fps.vertex(reset.x, min(wings[0].pos.y, reset.y), wings[0].pos.z - (this.size*5));
      fps.endShape(CLOSE);
      
      //Right wing
      reset.set(this.pos.x + (this.size*3), this.pos.y + this.size, this.pos.z);
      if(this.pos.dist(wings[1].pos) > this.pos.dist(reset) * 1.5)
        wings[1].pos.set(reset.copy());
      fps.beginShape();
      fps.vertex(this.pos.x, this.pos.y, this.pos.z);
      fps.vertex(reset.x, min(wings[1].pos.y, reset.y), wings[1].pos.z);
      fps.vertex(reset.x, min(wings[1].pos.y, reset.y), wings[1].pos.z - (this.size*5));
      fps.endShape(CLOSE);
    }
    
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.noStroke();
    fps.rotateY(this.rPos.y);
    //fps.rotateX(this.rPos.x);
    //fps.rotateZ(this.rPos.z);
    fps.scale(this.size);
    
    //fps.fill(this.colour, 200);
    //this.shape.draw();
    
    
    fps.hint(DISABLE_DEPTH_TEST);
    //fps.fill(this.colour, 150);
    if(hit > 0) fps.fill(color(255), (hit/(frameRate*0.1)) * 255);
    else fps.fill(this.colour, 150);
    //fps.fill(hit ? color(255) : this.colour, 150);
    this.shape.draw();
    
    fps.hint(ENABLE_DEPTH_TEST);

    //fps.fill(this.colour, 50);
    if(isHead) fps.fill(bg2, 100);
    //fps.fill(color(255), hit||isHead ? 255 : 0);
    fps.stroke(255, 100);  //Outlines
    fps.strokeWeight(0.08);
    fps.sphere(1);
    this.hit--;



    //fps.fill(this.colour, 150);
    //fps.hint(DISABLE_DEPTH_TEST);
    //fps.sphere(this.size);
  
    //fps.rotateY(this.rPos.y);
    //fps.rotateX(this.rPos.x);
    //fps.rotateZ(this.rPos.z);
    //fps.scale(this.size*map(score/100, 0, 30, 0.5, 2));
    //fps.fill(this.colour, 100);
    //fps.hint(ENABLE_DEPTH_TEST);
    //this.shape.draw();
  }
  
  
  //void follow(Body body) {
  //  this.rPos.y = atan2(body.pos.x-this.pos.x, (body.pos.z + this.size + body.size)-this.pos.z);
  //  this.addForce(new PVector(10000 * sin(this.rPos.y), 0, 10000 * cos(this.rPos.y)));
  //}
  
  //void follow() {
  //  this.rPos.y = atan2((player.pos.x-this.pos.x) + (sin(this.jitter) * (50000/score)), player.pos.z-this.pos.z); //Stares at player
  //  //this.addForce(new PVector(score * sin(this.rPos.y), 0, score*cos(this.rPos.y)));
  //  //if(beat.isOnset())
  //  //  this.addForce(new PVector(50000 * sin(this.rPos.y), 0, 0));
  //  //else
  //  //  this.addForce(new PVector(100 * sin(this.rPos.y), 0, 0));
  //  this.addForce(new PVector(10000 * sin(this.rPos.y), 0, 0));
  //}
  
  void moveTo() { //Player
    this.addForce(new PVector(0,0,(player.forward ? -600 : (player.backward ? -400 : -500)) * constrain(score/1000, 0.9, 1.1)));
    this.rPos.y = atan2((player.pos.x-this.pos.x) + (sin(this.jitter) * (score/10)), player.pos.z-this.pos.z);
    //this.rPos.x = atan2(player.pos.y-this.pos.y, player.pos.z-this.pos.z);
   
    this.addForce(new PVector(constrain(score * (beat ? 10 : 5) * sin(this.rPos.y), -5000, 5000),0 , 0));
  }
  
  void moveTo(Enemy body) {
    //if(body.dead()) {
    //  this.hp = 0;
    //  body.spawn();
    //  return;
    //}
    this.addForce(new PVector(0,0,player.forward ? -3000 : (player.backward ? -2000 : -2500)));
    this.rPos.y = atan2(body.pos.x-this.pos.x, body.pos.z-this.pos.z);
    //this.rPos.x = atan2(body.pos.y-this.pos.y, body.pos.z-this.pos.z);
    
    //this.pos.y = constrain(this.pos.y, body.pos.y - ((this.size + body.size) * 1.5), body.pos.y + ((this.size + body.size) * 1.5));
    this.pos.x = body.pos.x - (sin(this.rPos.y) * ((this.size + body.size) * 1.5));
    this.pos.z = body.pos.z - (cos(this.rPos.y) * ((this.size + body.size) * 1.5));
    //this.pos.set(body.pos.x - (sin(this.rPos.y) * ((this.size + body.size) * 1.5)), 0, body.pos.z - (cos(this.rPos.y) * ((this.size + body.size) * 1.5))); //Small gap
  }
  
  void update() {
    
    
    //this.rPos.x += 0.25;
    
    //this.rPos.y = atan2((player.pos.x-this.pos.x) + (sin(this.jitter) * (50000/score)), player.pos.z-this.pos.z); //Stares at player
    
    //if(beat.isOnset())
    //  this.addForce(new PVector(50000 * sin(this.rPos.y), 0, 0));
    //else
    //  this.addForce(new PVector(100 * sin(this.rPos.y), 0, 0));
    
    
    //Fly
    if(beat && hasWings && this.pos.y < 50)
      this.addForce(new PVector(0,score*22,0));
    this.addForce(new PVector(0,-2500 * (hasWings ? 0.3 : 1),0));  //Gravity
    
    //Walk
    if(hasLegs || hasWings) {
      this.jitter += score/45000;
      float floor = terrain.heightAt(this.pos) + (this.size*2);
      if(this.pos.y <= floor)
        this.pos.y = floor;
    } else {
      this.jitter += score/30000;
      this.pos.y = 0;   
    }

    if(this.isHead) {
      if(beat) this.reShape();
      this.colour = color(this.colour>>16 & 0xFF,this.colour>> 8 & 0xFF,this.colour& 0xFF, this.hp * 10);
    }
    else this.colour = color(waves.get(0).enemies.get(0).colour>>16 & 0xFF,waves.get(0).enemies.get(0).colour>> 8 & 0xFF,waves.get(0).enemies.get(0).colour& 0xFF, this.hp * 10);
    this.size = constrain(this.scale * score/85, 2, 25);  // divide 64 - 11/05/2024
    //if(this.health <= 0) {
      
    //  this.pos.y = -75 -this.size;
    //  this.pos.z = -1;
    // }
    
    if(this.pos.z < 0) {
      spawn();
    }
    lastAlive = millis();
    
    //this.rPos.y = 0.01;
    //this.rPos.x += 0.25;
    
    int hitX = constrain(Math.round(this.pos.x/terrain.lod), 0, terrain.cols - 1);
    int hitZ = constrain(Math.round(this.pos.z/terrain.lod), 0, terrain.rows - 1);
    
    //terrain.land[hitX][hitZ].h -= (score*0.1)/frameRate;
    terrain.land[hitX][hitZ].colour = lerpColor(terrain.land[hitX][hitZ].colour, color(this.colour>>16 & 0xFF,this.colour>> 8 & 0xFF,this.colour& 0xFF), score * 0.0001);
          
    //Collision with player
    if(PVector.dist(player.pos, this.pos) <= this.size + player.size) {
      player.hurt(1, "A" + (hasWings ? "n Air " : (hasLegs ? "n Earth " : " Water ")) + "Worm");
      this.hp = 0;
    }


    //System.out.println(terrain.heightAt(this.pos.x, this.pos.z));
    
    for(Leg leg : legs)
      leg.update();
    
    super.update();
  }
  
  void run() {
    if(this.dead() || waves.get(0).enemies.get(0).dead()) {
      if(beat && ((millis() - lastAlive) > 1000)) {
      //if(beat && (millis() - enemyCD > 50)) {
          //enemyCD = millis();
          kills += 1;
          spawn();
        }
      this.pos.y = -1000;
      return;
    }
    this.update();
    this.display();
  }
  
  void spawn() {

    //this.colour = bg;
    this.colour = color(base.x*255, base.y*255, base.z*255);
    this.maxHP = this.hp = score * (isHead ? 3 : 1) * 0.8;  //Added 0.8 11/05/2024
    
    if(isHead) {
      if(highs > mids && highs > lows) {
        hasLegs = false;
        hasWings = true;
      } else if(lows > highs && lows > mids) {
        hasWings = false;
        hasLegs = true;
      } else {
        hasWings = hasLegs = false;
      }
      this.pos.z = (terrain.rows - 1) * terrain.lod;
      //this.pos.x = min(player.pos.x + random(-(terrain.cols/8)*terrain.lod, (terrain.cols/8)*terrain.lod), terrain.cols*terrain.lod);
      this.pos.x = random(0, terrain.cols - 1) * terrain.lod;
      
      //this.pos.y = terrain.heightAt(this.pos) + this.size;
      //System.out.println(this.pos);
      this.vel.mult(0);

    }
    
     for(Enemy enemy : waves.get(0).enemies) {
       enemy.hasLegs = waves.get(0).enemies.get(0).hasLegs;
       enemy.hasWings = waves.get(0).enemies.get(0).hasWings;
     }
    
    reShape();
  }
  
  void reShape() {
    //PVector scores = new PVector(lows, mids, highs).normalize();
    float m = constrain(bpm(), 20, 200)/10;
    float n1 = constrain(base.x*20, 5, 20);
    float n2 = constrain(base.y*20, 5, 20);
    float n3 = constrain(base.z*20, 5, 20);
    this.shape.m_1 = random(1, m);
    this.shape.n1_1 = random(5, n1);
    this.shape.n2_1 = random(5, n2);
    this.shape.n3_1 = random(5, n3);
    this.shape.m_2 = random(1, m);
    this.shape.n1_2 = random(5, n1);
    this.shape.n2_2 = random(5, n2);
    this.shape.n3_2 = random(5, n3);
    this.shape.update();
  }
  
  void drop() {
    
  }
}
