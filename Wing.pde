final class Wing extends Body {
  
  Wing() {
    super();
    this.size = 9;
  }
  
  
  void update() {
    this.addForce(new PVector(0,0,-2500));
    this.size = score/70;
    super.update();
  }
  
  void draw() {
    return;
  }
}
