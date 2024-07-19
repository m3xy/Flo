ArrayList<Rock> rocks;

int cd = 0;
final class Rock extends Body {
  
  float lo, hi, sum;
  
  Rock(float lo, float hi) {
    this.hi = hi;
    this.lo = lo;
    this.colour = color(map((hi-lo)/2, 0, (radio.fft.specSize())/30, 200, 255));
    spawn();
    //loop.add(this);
  }
  
  void draw() {
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.rotateX(this.rPos.x);
    fps.rotateY(this.rPos.y);
    fps.rotateZ(this.rPos.z);
    
    fps.scale(this.size);
    if(this.hit > 0) fps.fill(color(255), (this.hit/(frameRate*0.1)) * 255);
    else fps.fill(this.colour, this.dmg);
      
    
    fps.stroke(lerpColor(color(255), this.colour, this.dmg > 200 ? 0 : 0.5));
    fps.strokeWeight(0.1);
    fps.box(1);
    
    //if(this.dmg >= 200) {
    //  fps.strokeWeight(0.01);
    //  //fps.stroke(this.colour, 255);
    //  fps.sphere(0.5);    
    //}

    this.hit--;
  }
  
  void update() {
    sum = 0;
    for(float i = lo; i < hi; i++) {
      sum += radio.fft.getBand((int)i);
    }
    this.dmg = (sum*100)/nStars;
    this.addForce(new PVector(0,0,(player.forward ? -3000 : (player.backward ? -2000 : -2500)) * constrain(score/1000, 0.9, 1.1)));
    this.addTorque(new PVector(sum, sum, sum).mult(this.hit > 0 ? 1.1 : 1));
    //this.size = score/25;
    //this.size = 0.95 * max(1, pow(sum/(hi-lo), 0.5));
    //this.size = 10 * pow(sum/(hi-lo), 0.5);
    //this.size = max(10, sum);
  
    //Collision with player
    if(PVector.dist(player.pos, this.pos) <= (this.size/2) + player.size) {
      player.hurt(1, "A rock");
      this.hp = 0;
    }
      
 
    if(this.pos.z < 0 || this.hp <= 0)
      spawn();
   
    super.update();
  }
  
  void spawn() {
    if(millis() - cd < 333) {
      this.pos.y = -1000;
      return;
    }
    if(this.hp <= 0) {
      //kills += 1;
      if(this.dmg >= 200)
        player.heal(1);
    }
      
    cd = millis();
    this.colour = color(base.x*255, base.y*255, base.z*255);
    this.hp = score;
    //this.size = random(25, 50);
    //this.size = random(10, 15);
    this.size = max(10, score/25);
    this.pos.z = (terrain.rows - 1.1) * terrain.lod;
    this.pos.x = random(0.1, terrain.cols - 0.1) * terrain.lod;
    this.pos.y = random(terrain.heightAt(this.pos) + this.size, terrain.heightAt(this.pos) + (player.size * 15));
  }
}
