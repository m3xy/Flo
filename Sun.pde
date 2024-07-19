Sun sun;

final class Sun extends Body {
  
  Supershape shape, aura;
  
  Sun() {
    super();
    this.shape = new Supershape(0f,1f,1f,1f,0f,1f,1f,1f, 50); //Sphere
    //this.shape = new Supershape(8f, 0.1f, 1.7f, 1.7f, 1f, 0.3f, 0.5f, 0.5f, 30); //Star
    //this.shape = new Supershape(0.01f,0.1f,0.01f,5f,0.01f,0.1f,0.01f,5f, 30); //Sphere
    //this.shape = new Supershape(2.8f, 1.5f, 7.9f, 2.2f, 1, 1, 1, 1, 30);
    this.aura = new Supershape(0,0,0,0,0,0,0,0, 50);
    this.pos.set(player.pos.x, 75, terrain.rows * terrain.lod);
    this.damping = 0.975;
    this.size = 20;
    //loop.add(this);
  }
  
  
  void draw() {

    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.noStroke();
    fps.emissive(score);
    fps.scale(this.size);
    //fps.scale(beat.isOnset() ? 1.25 * this.size : this.size);
    //fps.rotateY(HALF_PI);
    fps.rotateY(this.rPos.y);
    fps.rotateX(this.rPos.x);


    fps.rotateZ(this.rPos.z);
    //fps.rotateZ(HALF_PI); //Heart
    fps.fill(this.colour, 5);
    //fps.stroke(score, 5);
    fps.hint(DISABLE_DEPTH_TEST);
    this.aura.draw();
   
    fps.fill(this.colour, 255);
    //fps.stroke(score, 255);
    fps.hint(ENABLE_DEPTH_TEST);

    //fps.sphere(1);
    this.shape.draw();
    
    
    //fps.translate(this.pos.x, this.pos.y, this.pos.z);
    //fps.noStroke();
    ////fps.fill(255 - (lows*0.5), 255 - (mids*0.5), 255 - (highs*0.5), 255);
    ////fps.emissive(102,0,0);
    //fps.fill(this.colour);
    //fps.sphere(this.size);
    fps.emissive(0);
  }
  
  void update() {

    //this.shape.m_2 = 5f;
    //if(beat.isOnset()) {
    //  //this.shape.m_2 = this.shape.m_1;
    //  this.shape.m_2 -= 0.05;
    //}else {
    //  this.shape.m_2 += 0.01;
    //  //this.shape.m_2 = 5f;
    //}
    

    //this.vel.z = -dt * terrain.lod/2;
    //if(beat.isOnset()) {
    //  this.addForce(new PVector(0,0,1000));
    //}
      
    //this.rPos.y = atan2(player.pos.x-this.pos.x, player.pos.z-this.pos.z); //Stares at player
    //this.addForce(new PVector(0.1 * score * sin(this.rPos.y),0,0.1 * score*cos(this.rPos.y))); 
    this.shape.update();
    //this.colour = color(255 - (lows*0.5), 255 - (mids*0.5), 255 - (highs*0.5));
    //this.colour = lerpColor(color(lows * 0.5, mids * 0.5, highs * 0.5, score), color(255,0,0), 0.5);
    //this.colour = color(lows, mids, highs, score);
    this.colour = color(score);
    //beat.detect(song.mix);
    //if(beat.isOnset())
    //  this.addForce(new PVector(random(-score * 0.01,score * 0.01), 0, 0));
    
    //this.pos.y = terrain.heightAt(this.pos);
    //this.pos.x = constrain(this.pos.x, max(50, player.pos.x - 500), min((terrain.cols* terrain.lod) - 50,player.pos.x + 500));
    //this.rPos.y += 0.02;
    //this.rPos.z += 0.02;
    //this.shape.update(0.01f,0.1f,0.01f,5f, 1, 1, 0.01f,0.1f,0.01f,5f, 1, 1, 25);
    //this.size = max(score/50, 5);
    for(int i = 0; i < this.shape.res; i++)
      for(int j = 0; j < this.shape.res; j++)
        aura.vertices[i][j].set(
          this.shape.vertices[i][j].x + (random(-score, score)/(this.size*100)),
          this.shape.vertices[i][j].y + (random(-score, score)/(this.size*100)),
          this.shape.vertices[i][j].z + (random(-score, score)/(this.size*100)));

    //if(this.pos.z < 0) {
    //  this.pos.z = terrain.rows * terrain.lod;
    //  this.pos.x = player.pos.x;
    //  this.vel.mult(0);
    //}
    //for(int i = 0; i < this.shape.res; i++)
    //  for(int j = 0; j < this.shape.res; j++)
    //    System.out.println(this.shape.vertices[i][j]);
        //Check z, z is heights?
    //System.exit(0);
    this.rPos.y += lows*0.0001;
    this.rPos.z += mids*0.0001;
    this.rPos.x += highs*0.0001;
    super.update();
  }
}
