//int nParams = 16;
//List<Sample> samples;

final class Gun extends Body {

  PVector offset, tracer;
  int dist;
  Shot shot;
  color trail;
  Supershape shape;
  int cd;
  PVector scale, shear;
  float hi, lo;
  float wear;
  
  Gun() {
    this(0,-2,5,new Supershape(), new PVector(1,1,1), new PVector(0,0), 0, 150);
    this.wear = 0;
  }
  
  Gun(float offX, float offY, float offZ, Supershape shape, PVector scale, PVector shear, float wear, float dex) {
    super();
    
    //Mechanics of gun
    this.offset = new PVector(offX, offY, offZ);          //x is left and right, y is in up and down, z is back and front
    this.rPos.set(random(0,1),random(0,1),random(0,1));
    this.tracer = new PVector();
    this.dist = 0;
    this.shot = Shot.NONE;
    this.dex = dex; //Determines firerate, ms before next shot (Range between 50 -> )
    
    //Look of gun
    this.shape = shape;                 //Shape
    this.scale = scale;  //Size and Stretch
    this.shear = shear;     //Shear
    this.trail = color(255);            //Colour of tracer
    this.wear = wear;                      //Wear (Condition) of gun, determines colour of gun (brightness)
    
    //Range of gun sounds
    this.lo = 100;
    this.hi = 130;
  }
  
  void run() {
    this.addFilters();
    this.checkFire();
    this.display();
    this.updatePos();
    this.update();
  }
  
  void draw() {
    //fps.translate(player.pos.x, player.pos.y, player.pos.z); //All fine
    //fps.rotateY(player.rPos.y + PI);
    //fps.rotateX(-player.rPos.x - HALF_PI);
    //fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    switch(shot) {
      case NONE :
        break;
      case HIT :
        fps.strokeWeight(score * 0.003);
        fps.stroke(trail, score);
        fps.fill(bg>>16 & 0xFF, bg >> 8 & 0xFF, bg & 0xFF, score);
        drawTracer();
        //fps.rotateY(player.rPos.y + PI);
        //fps.rotateX(-player.rPos.x - HALF_PI);
        //fps.lightFalloff(1000/score, 1/score, 0.01/score); //Slower falloff
        //fps.pointLight(255, 255, 255, 0, 0, 0);
        //fps.lightFalloff(1.0, 0.0, 0.000005); //Faster falloff
        //fps.strokeWeight(1);
        break;
      case MISS :
        fps.strokeWeight(score * 0.001);
        fps.stroke(trail, min(score*0.5, 75));
        fps.fill(bg>>16 & 0xFF, bg >> 8 & 0xFF, bg & 0xFF, min(score, 128));
        drawTracer();
        //fps.strokeWeight(1);
        break;
    }
    
    drawGun();
  }
  
  void drawGun() {
    fps.rotateX(this.rPos.x);
    fps.rotateY(this.rPos.y);
    fps.rotateZ(this.rPos.z);
    
    fps.noStroke();
    //fps.stroke(255);
    //fps.strokeWeight(1/score);
    //fps.fill(color(255 - (lows*0.5), 255 - (mids*0.5), 255 - (highs*0.5)));
    fps.fill(this.colour);
    //fps.fill(0);
    //fps.emissive(color(lows * 0.5, mids * 0.5, highs * 0.5, score));
    //fps.noFill();
    //fps.box(constrain(score*0.001, 0.2, 2));
    fps.scale(this.size*this.scale.x, this.size*this.scale.y, this.size*this.scale.z);
    fps.shearX(this.shear.x);
    fps.shearY(this.shear.y);
    shape.draw();
    //fps.emissive(0);
  }
  
  void update() {
    this.addTorque(new PVector(lows * 0.05, mids * 0.05, highs * 0.05)); //Spin gun to song
    
    this.size = constrain(score*0.0004, 0.2, 2);
    this.colour = lerpColor(color(bg>>16 & 0xFF, bg >> 8 & 0xFF, bg & 0xFF, score), color(0), this.wear);
    super.update();
    
  }
  
  void fire() {
    this.addTorque(new PVector(lows * 0.3, mids * 0.3, highs * 0.3));
    this.colour = lerpColor(this.colour, color(255, score), 0.5);
    //this.colour = color(255, score);
    //this.size = constrain(score*0.00025, 0.2, 1);
    shots += 1;
    //Collision with Terrain (Plane)
    //color opposite = color(255 - (lows*0.5), 255 - (mids*0.5), 255 - (highs*0.5));
    //color opposite = color(255,255,200);
    
    //Find intersection then draw line to intersection point
    PVector n = new PVector(0,-1,0);                           //Normal of plane
    PVector p0 = new PVector(player.pos.x, -75, player.pos.z); //Point on plane
    PVector l = new PVector(                                   //Unit direction vector
          (sin(player.rPos.x) * sin(player.rPos.y)),  //X
          cos(player.rPos.x),                         //Y
          (sin(player.rPos.x) * cos(player.rPos.y))   //Z
     );  
    PVector l0 = player.pos.copy();                            //Point on line
    float d = ((p0.copy().sub(l0)).dot(n))/(l.dot(n));         //Distance to travel along unit l to reach point of intersection p
    PVector p = l0.copy().add(l.copy().mult(d));               //Point of intersection with plane
   
    if(l.dot(n) >= 0 && p.x > 0 && p.x < terrain.land.length*terrain.lod  && p.z > 0 && p.z < terrain.land[0].length*terrain.lod){  //Check intersects with plane then terrain
      int hitX = constrain(Math.round(p.x/20), 0, terrain.cols - 1);
      int hitZ = constrain(Math.round(p.z/20), 0, terrain.rows - 1);
      terrain.land[hitX][hitZ].colour = lerpColor(terrain.land[hitX][hitZ].colour, this.trail, score * 0.0005);
      terrain.land[hitX][hitZ].h -= score/(frameRate*2);
      //player.firing = false;
      this.shot = Shot.HIT;
      this.dist = Math.round(d);
    } else {
      this.shot = Shot.MISS;
      this.dist = 75;  //If not hitting terrain
      p.set(l0.copy().add(l.copy().mult(this.dist)));
    }
    
    this.tracer = ((p.copy()).sub(this.pos)).normalize(); //Tracer
    
    hitSphere(sun);
    
    for(Wave wave : waves) {
      for(Enemy enemy : wave.enemies) {
        if(hitSphere(enemy)) {
          enemy.hurt(((score*this.dex*(beat?3:1))/500), "Enemy hurt");  //500 11/5/24
          //enemy.health = 0;
          //enemy.addForce(new PVector(-sin(player.rPos.y), 0, -cos(player.rPos.y)).mult(score));
          //this.trail = lerpColor(this.trail, color(enemy.colour>>16 & 0xFF,enemy.colour>> 8 & 0xFF,enemy.colour& 0xFF, 255), 0.01);
          //enemy.colour = lerpColor(enemy.colour, color(enemy.colour,0), 0.01);
          enemy.hit = (frameRate*0.1);
          //hitColour = lerpColor(bg2, color(255), 0.5);
          hitmarker = frameRate;
          //song.addEffect(bandpass); //Maybe do it based on health * multiplier?
          //bandpass.setBandWidth(constrain(fft.specSize() - enemy.health, 0, fft.specSize() - 1));
        }
      }
    }


    for(Rock rock : rocks) {
      if(hitSphere(rock)) {
        rock.hurt(((score*this.dex*(beat?3:1))/500), "Enemy hurt");
        rock.hit = (frameRate*0.1);
        rock.addForce(new PVector((sin(player.rPos.x) * sin(player.rPos.y)), cos(player.rPos.x), (sin(player.rPos.x) * cos(player.rPos.y))).mult(score*50));  //Push rock away
        //hitColour = lerpColor(bg2, color(255), 0.5);
        hitmarker = frameRate;
        //song.addEffect(bandpass); //Maybe do it based on health * multiplier?
        //bandpass.setBandWidth(constrain(fft.specSize() - enemy.health, 0, fft.specSize() - 1));
      }
    }
    
    for(Tree tree : trees) {
      if(hitSphere(tree.weakPos(), tree.size)) {
        tree.hurt(1, "Enemy hurt");
        tree.hit = (frameRate*0.1);
        //hitColour = lerpColor(bg2, color(255), 0.5);
        hitmarker = frameRate;
      }
    }
    
    
    //float loudest = octave[0], amp = -1;
    //for(int i = 0; i < octave.length; i++) {
    //  if(radio.fft.getFreq(octave[i]) > amp) {
    //    loudest = octave[i];
    //    amp = radio.fft.getFreq(octave[i]);
    //  }
    //}
    
    //for(int i = 0; i < radio.fft.avgSize(); i++) {
    //  if(radio.fft.getAvg(i) > amp) {
    //    loudest = radio.fft.getAverageCenterFrequency(i);
    //    amp = radio.fft.getAvg(i);
    //  }
    //}
    
    //float loudest = 0, amp = -1;
    //for(int i = 0; i < radio.fft.freqToIndex(125); i++) {
    //  if(radio.fft.getBand(i) > amp) {
    //    loudest = radio.fft.indexToFreq(i);
    //    amp = radio.fft.getBand(i);
    //  }
    //}
    
    //out.clearEffects();
    //out.addEffect(echo);
    
    //fx.play(0, this.dex/1000, loudest, -20);
    
    //F -> F
    //for(int i = radio.fft.freqToIndex(loudest*4); i < radio.fft.freqToIndex(loudest*16); i++) {
    //  fx.play(1, this.dex/2000, radio.fft.indexToFreq(i), -30);
    //}
    
    //fx.play(2, this.dex/1000, loudest*8, -25);
    
    
    //float loudest = 0, amp = -1;
    //for(int i = radio.fft.freqToIndex(500); i < radio.fft.freqToIndex(2000); i++) {
    //  if(radio.fft.getBand(i) > amp) {
    //    loudest = radio.fft.indexToFreq(i);
    //    amp = radio.fft.getBand(i);
    //  }
    //  fx.play(0, this.dex/2000, radio.fft.indexToFreq(i), -35);
    //}
    
    //fx.play(1, this.dex/1000, loudest/32, -20);
    //fx.play(2, this.dex/1000, loudest/4, -25);
    
    
    //Manually
    //float loudest = 0, max = -1, amp = 0;
    //float[] real = radio.fft.getSpectrumReal();
    //float[] imaginary = radio.fft.getSpectrumImaginary();
    //for(int i = 0; i < real.length; i++) {
    //  amp = sqrt(pow(real[i], 2) + pow(imaginary[i], 2));
    //  if(amp > max){
    //    loudest = i;
    //    max = amp;
    //  }
    //}
    
    //fx.play(0, this.dex/1000, (loudest*radio.src.sampleRate())/radio.fft.timeSize(), -20);  
    //System.out.println((loudest*radio.src.sampleRate())/radio.fft.timeSize());
    
    //Using
    //float loudest = 0, max = -1, amp = 0, lo = 0, hi = 0, vol = 0;
    //for(int i = 0; i < radio.fft.specSize(); i++) {
    //  amp = radio.fft.getBand(i);
    //  if(amp > max){
    //    loudest = radio.fft.indexToFreq(i);
    //    max = amp;
    //  }
    //  if(radio.fft.indexToFreq(i) < 2000)
    //    fx.play(1, min(0.5, this.dex/2000), radio.fft.indexToFreq(i), -35);
    //}

    //lo = loudest;
    //while(lo >= 35)
    //  lo /= 2;
    
    //hi = lo;

    //while(hi <= 130)
    //  hi*=2;

    //fx.play(0, this.dex/1000, lo, -20);
    //fx.play(2, this.dex/1000, hi, -max(25, 10000/score));
    
    
    //HPS
    List<Band> bands = hps(5);
    Collections.sort(bands, Collections.reverseOrder());
    float freq = beat ? 0 : bands.get(0).freq;
    
    
    //for(int i = 1; i < 3 && (bands.get(i).amp > bands.get(0).amp * 0.5); i++)
    //  freq += ((bands.get(i).amp/bands.get(0).amp) * ((bands.get(i).freq - bands.get(0).freq)/2));
    
    if(freq > 50 && freq < 2000)
      for(int i = 1; i < bands.size() && abs(bands.get(i).index - bands.get(i-1).index) < 2; i++)
        freq += ((bands.get(i).amp/bands.get(i-1).amp) * ((bands.get(i).freq - bands.get(i-1).freq)/2));
    
    
    //if(abs(bands.get(1).index - bands.get(0).index) == 1)
    //  freq += ((bands.get(1).amp/bands.get(0).amp) * ((bands.get(1).freq - bands.get(0).freq)/2));
        
    //freq = autotune(freq);
    //if(bands.get(1).amp > bands.get(0).amp * 0.5)
    //  freq = (bands.get(0).freq + bands.get(1).freq) / 2;
    
    float bass = freq;
    while(bass >= this.lo)
      bass /= 2;
      
    float treble = max(1,bass); //Prevent endless loop
    while(treble <= this.hi)
      treble*=2;
      
    if(shot == Shot.HIT) {
      for(int i = radio.fft.freqToIndex(500); i < radio.fft.freqToIndex(2000); i++)
        fx.play(1, min(0.05, this.dex/2000), radio.fft.indexToFreq(i), -35);
      hits += 1;
    }

    
    fx.play(0, this.dex/1000, bass, -25);
      
    //if(bands.get(0).amp > bands.get(1).amp*2)
    //fx.play(3, this.dex/1000, freq, -25);
    fx.play(2, this.dex/1000, treble, -25);
      

    
    //for(int i = 0; i < radio.fft.specSize(); i++)
    //  System.out.print(radio.fft.indexToFreq(i) + " (" + radio.fft.getBand(i) + "), ");
    //System.out.println();
    //System.out.println();
    
    //for(int i = 0; i < radio.fft.avgSize(); i++)
    //  System.out.print(radio.fft.getAverageCenterFrequency(i) + " (" + radio.fft.getAvg(i) + "), ");
    //System.out.println();
    //System.out.println();
    
    //System.out.println(loudest);
    //fps.lightFalloff(1.0, 0.0, 0.000005); //Slower falloff 
    //fps.pointLight(255,255,255,this.pos.x,this.pos.y,this.pos.z);
    //fps.lightFalloff(1.0, 0.0, 0.000005); //Faster falloff
    
    
    player.addTorque(new PVector((score * (beat ? 2 : 1))/33, 0, 0)); //Upwards recoil
  }
  
  
  //Harmonic Product Spectrum (Estimate Fundamental Frequency) - http://musicweb.ucsd.edu/~trsmyth/analysis/Harmonic_Product_Spectrum.html
  List<Band> hps(int n) {
    
    int min = radio.fft.freqToIndex(50);
    int len = ceil(radio.fft.specSize()/n) - min;
    
    List<Band> bands = new ArrayList<>(len);
    for(int i = 0; i < len; i++) {
       bands.add(new Band(i+min, radio.fft.indexToFreq(i+min),pow(abs(radio.fft.getBand(i+min)),2)));
       
      //Multiply by downsampled versions
      for(int j = 1; j <= n ; j++) {
        bands.get(i).amp *= pow(abs(radio.fft.getBand(j+1+min)),2);
        //bands.get(i).amp *= radio.fft.getBand(j+1+min); //HSS - Harmonic sum spectrum
      }
    }
    
    return bands;
  }
  
  //Given a frequency, returns the closest frequency corresponding to a musical note
  float autotune(float freq) {
    float a = pow(2f, 1f/12f);
    return 440f * pow(a, 12*log2(freq/440.0f));
  }
  
  //boolean hitSphere(Body sphere) {
  //  PVector l = new PVector(                                   //Unit direction vector
  //        (sin(player.rPos.x) * sin(player.rPos.y)),  //X
  //        cos(player.rPos.x),                         //Y
  //        (sin(player.rPos.x) * cos(player.rPos.y))   //Z
  //   );  
  //  float a = l.dot(l);
  //  float b = l.dot(player.pos.copy().sub(sphere.pos));
  //  float c = player.pos.copy().sub(sphere.pos).dot(player.pos.copy().sub(sphere.pos)) - pow(sphere.size, 2);
  //  float d1 = (-b + sqrt(pow(b, 2) - (a*c))) / a;
  //  float d2 = (-b - sqrt(pow(b, 2) - (a*c))) / a;
  //  if(pow(b,2) - c >= 0 && d1 >= 0) {
  //    this.shot = Shot.HIT;
  //    this.dist = Math.round((d1+d2)/2);
  //    this.tracer = player.pos.copy().add(l.copy().mult(this.dist)).sub(this.pos).normalize();
  //    //System.out.println(this.dist + " vs " + this.pos.copy().sub(l0.copy().add(l.copy().mult((d1+d2)/2))).mag());
  //    return true;
  //  }
  //  return false;
  //}
  
  boolean hitSphere(Body body) {
    return hitSphere(body.pos, body.size);
  }
  boolean hitSphere(PVector spherePos, float sphereSize) {
    PVector l = new PVector(                                   //Unit direction vector
          (sin(player.rPos.x) * sin(player.rPos.y)),  //X
          cos(player.rPos.x),                         //Y
          (sin(player.rPos.x) * cos(player.rPos.y))   //Z
     );  
    float a = l.dot(l);
    float b = l.dot(player.pos.copy().sub(spherePos));
    float c = player.pos.copy().sub(spherePos).dot(player.pos.copy().sub(spherePos)) - pow(sphereSize, 2);
    float d1 = (-b + sqrt(pow(b, 2) - (a*c))) / a;
    float d2 = (-b - sqrt(pow(b, 2) - (a*c))) / a;
    if(pow(b,2) - c >= 0 && d1 >= 0) {
      if(onBeat > 0) crit = true;
      else crit = false;
      this.shot = Shot.HIT;
      this.dist = Math.round((d1+d2)/2);
      this.tracer = player.pos.copy().add(l.copy().mult(this.dist)).sub(this.pos).normalize();
      //System.out.println(this.dist + " vs " + this.pos.copy().sub(l0.copy().add(l.copy().mult((d1+d2)/2))).mag());
      return true;
    }
    return false;
  }
  
  void updatePos() {
    
    //Translate to Player, Rotate Y, Rotate X, Translate to Cube
    this.pos.set(
      player.pos.x + (this.offset.y * sin(player.rPos.y + PI) * sin(-player.rPos.x - HALF_PI)) + (this.offset.z * sin(player.rPos.y + PI) * cos(-player.rPos.x - HALF_PI)) + (this.offset.x * cos(player.rPos.y + PI)),
      player.pos.y + (this.offset.y * cos(-player.rPos.x - HALF_PI)) - (this.offset.z * sin(-player.rPos.x - HALF_PI)),
      player.pos.z + (this.offset.y * cos(player.rPos.y + PI) * sin(-player.rPos.x - HALF_PI)) + (this.offset.z * cos(player.rPos.y + PI) * cos(-player.rPos.x - HALF_PI)) - (this.offset.x * sin(player.rPos.y + PI))
    );
  }
  
  void drawTracer() {
    //fps.noFill();
    fps.beginShape(TRIANGLE_STRIP);
    float flux;
    for(int i = 0; i < this.dist; i++) {
      flux = radio.mix().get((int)((radio.bufferSize())*i)/this.dist);
      fps.vertex((i*this.tracer.x) + (flux*-this.offset.y), (i*this.tracer.y) + (flux*this.offset.x), (i*this.tracer.z)); //draw peaks corresponding to x-y plane so visible no matter where gun is positioned on screen
    }
    fps.endShape();
    //float off, off2;
    //for(int i = 0; i < this.dist - 1; i++) {
    //  off =  (song.mix.get((int)(song.bufferSize()*i)/this.dist)*3);
    //  off2 = (song.mix.get((int)(song.bufferSize()*(i+1))/this.dist)*3);
    //  fps.line(
    //  (i*this.tracer.x), (i*this.tracer.y) + off, (i*this.tracer.z),
    //  ((i+1)*this.tracer.x), ((i+1)*this.tracer.y) + off2, ((i+1)*this.tracer.z));
    //}
  }
  
  void addFilters() {
    //Woosh when turning?
    
    radio.clearFX();
    //if( this.shot == Shot.MISS) {
    //  song.addEffect(bandpass); //Maybe do it based on health * multiplier?
    //}
    if(player.backward) {
      radio.addFX(radio.lFilter);
    }
    if(player.forward) {
      radio.addFX(radio.nFilter);
    }
    if(player.hp > 0)
      radio.addFX(radio.bandpass);
  }
  
  void checkFire() {
    // || beat.isOnset()
    if(player.firing && (millis() - this.cd) >= this.dex) {
      fire();
      this.cd = millis();
      //player.firing = false;
    } else {
      this.shot = Shot.NONE;
    }
  }
  
  //Weapon rewards evolve throughout games
  void grow() {
    //samples.add(new Sample(lows, mids, highs, beat()));

    this.scale.add(lows, mids, highs);
    this.scale.normalize();
    
    float m = constrain(bpm(), 20, 200)/10;
    float n1 = constrain(this.scale.x*20, 5, 20);
    float n2 = constrain(this.scale.y*20, 5, 20);
    float n3 = constrain(this.scale.z*20, 5, 20);
    
    this.shape.m_1 = random(1, m);
    this.shape.n1_1 = random(5, n1);
    this.shape.n2_1 = random(5, n2);
    this.shape.n3_1 = random(5, n3);
    this.shape.m_2 = random(1, m);
    this.shape.n1_2 = random(5, n1);
    this.shape.n2_2 = random(5, n2);
    this.shape.n3_2 = random(5, n3);
    this.shape.update();
    
    this.offset.x = constrain(((this.offset.x + (radio.right().level() + mic.right().level())) - (radio.left().level() + mic.left().level())), -4, 4);
  }
  
  void show() {
    this.display();
    this.updatePos();
    this.update();
  }
  
  void save() {
    this.shear.set(maxMixLevel - maxLeftLevel, maxMixLevel - maxRightLevel);
    this.wear = 1 - (float(score())/float(maxScore()));
    this.dex = 30000/max(bpm(), 1);
    String weapon = "\n" +
      offset.x + "," + 
      offset.y + "," + 
      offset.z + "," + 
      shape.m_1 + "," +
      shape.n1_1 + "," +
      shape.n2_1 + "," +
      shape.n3_1 + "," +
      shape.m_2 + "," +
      shape.n1_2 + "," +
      shape.n2_2 + "," +
      shape.n3_2 + "," +
      shape.res + "," +
      scale.x + "," + 
      scale.y + "," + 
      scale.z + "," +
      shear.x + "," + 
      shear.y + "," +
      wear + "," +
      dex;
    try {
      Files.write(Paths.get(sketchPath() + GUNS_PATH), weapon.getBytes(), StandardOpenOption.APPEND);
    } catch(IOException e) {
      System.err.println(e.getMessage());
    }
    
  }
}

enum Shot {
  NONE,
  HIT,
  MISS,
}

void initReward() {
  reward = new Gun();
  //reward.iframes = radio.length()/nParams;
  //samples = new ArrayList<Sample>(nParams);
}
