ArrayList<Star> stars;


final class Star extends Body {
  
  Supershape shape;
  float lo, hi;
  
  Star(float lo, float hi) {
    this.lo = lo;
    this.hi = hi;
    this.shape = new Supershape(4,10,10,10,4,10,10,10,50);
    spawn();
    this.colour = color(map((hi-lo)/2, 0, (radio.fft.specSize()*0.5)/nStars, 200, 255));
    //loop.add(this);
  }
  
  void update() {
    float sum = 0;
    for(float i = lo; i < hi; i++) {
      sum += radio.fft.getBand((int)i);
    }
    //this.size = 0.95 * max(1, pow(sum/(hi-lo), 0.5));
    this.size = 0.95 * pow(sum/(hi-lo), 0.5);
  }
  
  void draw() {
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.noStroke();
    fps.fill(this.colour, 255);
    //fps.scale(this.size);
    //this.shape.draw();
    fps.sphere(this.size);
    //fps.box(this.size);
  }
  
  
  
  void spawn() {  //Sets position of star
    float maxR = (player.size*100);
    float theta = random(PI + HALF_PI, PI + HALF_PI + QUARTER_PI);
    float phi = random(HALF_PI + QUARTER_PI, PI + QUARTER_PI);

    //float theta = random(PI, TWO_PI);
    //float phi = random(TWO_PI);
    
    this.pos.set(
      player.pos.x + (sin(theta) * sin(phi) * maxR),
      player.pos.y + (cos(theta) * maxR),                         //Y
      player.pos.z + (sin(theta) * cos(phi) * maxR)
    );
  }
  
  
}
