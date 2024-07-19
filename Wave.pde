Wave wave;
ArrayList<Wave> waves;

final class Wave extends Body {
  
  ArrayList<Enemy> enemies;
  
  Wave(int size) {
    this.size = size;
    enemies = new ArrayList<>();
    
    enemies.add(new Enemy(true)); //Head
    
    for(int i = 1; i < this.size; i++) {
      enemies.add(new Enemy(false));
    }
    //loop.add(this);
  }
  
  void draw() {

    
  }
  
  void update() {
    
    //Head
    enemies.get(0).moveTo();
    enemies.get(0).run();
    
    //Body
    for(int i = 1; i < enemies.size(); i++) {
      //if(enemies.get(i).pos.dist(enemies.get(i-1).pos) < (enemies.get(i).size + enemies.get(i-1).size) * 2)
      enemies.get(i).moveTo(enemies.get(i-1));
      enemies.get(i).run();
      if(!enemies.get(i-1).dead() && !enemies.get(i).dead()) {
        fps.strokeWeight(score/100);
        fps.stroke(enemies.get(i).colour);
        fps.line(enemies.get(i-1).pos.x, enemies.get(i-1).pos.y, enemies.get(i-1).pos.z, enemies.get(i).pos.x, enemies.get(i).pos.y, enemies.get(i).pos.z);
      }
      //System.out.println(i + " is at (" + enemies.get(i).pos.x + ", " + enemies.get(i).pos.z + ") from (" + enemies.get(i-1).pos.x + ", " + enemies.get(i-1).pos.z + ")");
    }
  }
  
  void run() {
    this.update();
    this.draw();
  }
}
