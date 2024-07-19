ArrayList<Tree> trees;
int cooldown = 0;

final class Tree extends Body {
  
  String form;
  
  float branchSize;
  float branchAngle;
  float branchAngleY;
  float thickness;
  float peak;
  
  int age, maxAge, minAge;
  color opposite;
  
  Tree() {
    super();
    form = "S"; //S = Start
    this.size = 0;
    branchSize = 5;
    thickness = 25;  //Of branches
    this.damping = 0;
    this.age = 0;
    this.maxAge = 7;
    this.minAge = 5;
    this.peak = 0;
    plant();
    //loop.add(this);
  }
  
  void grow() {
    String newForm = "";
    for(int i = 0; i < form.length(); i++) {
      switch(form.charAt(i)) {
        case 'S' :          //Start
          newForm += "FB";  //-> Forward, Branch
          break;
        case 'F' :          //Forward
          if(random(2) < 1) {
            newForm += "FF";  //-> Forward, Forward
          } else {
            newForm += "F";   //-> Forward
          }
          break;
        case 'B' :                  //Branch
          if(kick) {
            newForm += "[+llFB-][+FB-][+rFB-]";  //-> [Left, Left, Forward, Branch][Forward, Branch][Right, Forward, Branch]
          } else if(snare) {
            newForm += "[+lFB-][+FFB-][+rFB-]";  //-> [Left, Forward, Branch][Forward, Forward, Branch][Right, Forward, Branch]
          } else if (hat) {
            newForm += "[+lFB-][+FB-][+rrFB-]";  //-> [Left, Forward, Branch][Forward, Branch][Right, Right, Forward, Branch]
          } else {
            newForm += "[+lFB-][+FB-][+rFB-]";  //-> [Left, Forward, Branch][Forward, Branch][Right, Forward, Branch]
          }
          break;
        default :
          newForm += form.charAt(i);
          break;
      } 
    }
    form = newForm;
    this.age += 1;
    branchAngle = log(score)/9;
    branchAngleY = log(score)/3;
    this.size = (this.age/2);
  }
  
  void update() {
    this.peak = trunkSize() * this.branchSize;
    if(this.dead())
      this.pos.y = -1000;
    else if(player.pos.dist(new PVector(this.pos.x, min(player.pos.y, this.peak + this.pos.y), this.pos.z)) <= this.size + player.size) {
      player.hurt(1, "A tree");
      this.hp = 0;
    }
      
    if(this.pos.z < 0) plant();
    if(beat && (this.age < this.maxAge)) this.grow();
    //this.pos.y = terrain.heightAt(this.pos);
    this.addForce(new PVector(0,0,(player.forward ? -42500 : (player.backward ? -26500 : -33333)) * constrain(score/1000, 0.9, 1.1)));
    
    super.update();
  }
  
  void draw() {
    //if(this.dead()) return;
    fps.translate(this.pos.x, this.pos.y, this.pos.z);
    fps.pushMatrix();
    fps.translate(0,min((player.pos.y + 75), this.peak),0);
    fps.stroke(this.opposite);
    fps.sphere(this.size);
    fps.popMatrix();
    for(int i = 0; i < form.length(); i++) {
      switch(form.charAt(i)) {
        case 'F' :
          fps.strokeWeight(thickness);
          fps.stroke(this.colour);
          fps.line(0,0,0,0,branchSize,0);
          //fps.sphere(this.size);
          fps.translate(0,branchSize,0);
          
          break;
        case 'l' :
          fps.rotateZ(-branchAngle);
          fps.rotateY(branchAngleY);
          break;
        case 'r' :
          fps.rotateZ(branchAngle);
          fps.rotateY(branchAngleY);
          break;
        case '[' :
          fps.pushMatrix();
          break;
        case ']' :
          fps.popMatrix();
          break;
        case '+' :
          thickness *= 0.8;
          //this.colour = lerpColor(this.colour, color(255), 0.5);
          this.colour = color((this.colour>>16 & 0xFF) + 25, (this.colour>> 8 & 0xFF) + 25, (this.colour& 0xFF) + 25);
          break;
        case '-' :
          thickness *= 1/0.8;
          //this.colour = lerpColor(this.colour, color(255), 0.5);
          this.colour = color((this.colour>>16 & 0xFF) - 25, (this.colour>> 8 & 0xFF) - 25, (this.colour& 0xFF) - 25);
          break;
      }
    }
  }
  
  void plant() {
    //if(!beat.isOnset() || millis() - cooldown < 250)
    //  return;
    if(millis() - cooldown < 250)
      return;
      
    cooldown = millis();
   
    this.hp = 1;
    this.pos.z = (terrain.rows - 1.1) * terrain.lod;
    this.pos.x = random(0.1, terrain.cols - 0.1) * terrain.lod;
    this.pos.y = terrain.heightAt(this.pos);
    
    //System.out.println(this.pos.y);
    this.vel.mult(0);
    
    this.colour = lerpColor(color(base.x*255, base.y*255, base.z*255), color(102, 73, 58), 0.75); //Mix in brown for wood
    //this.colour = lerpColor(bg, color(102, 73, 58), 0.5); //Mix in brown for wood
    this.opposite = lerpColor(this.colour, color(255), 0.5);
    form = "S";
    this.age = 0;
    this.peak = 0;
    for(int i = 0; i < minAge; i++) {
      grow(); 
    }
  }
  
  int trunkSize() {
    if(this.form.isEmpty()) return 0;
    int max = 1, i = 0;
    while(i < this.form.length() - 1) {
      int j = i;
      while(this.form.charAt(++i) == this.form.charAt(j));
      if((i - j) > max) max = i - j;
    }
    
    return max;
  }
  
  PVector weakPos() {
    return this.pos.copy().add(0,min((player.pos.y + 75), this.peak),0); 
  }
}
