Land terrain;

float lag = 0, dt = 33.3;
long t = 0;

final class Land implements Runnable {
  Vertex[][] land;
  Vertex[][] landCopy;
  int lod = 20;
  int w = 1400;
  int d = 2000;
  float minH = 10;
  float maxH = 10;
  int cols;
  int rows;
  float rate;
  
  Land() {
    cols = w/lod;
    rows = d/lod; //Number of columns and rows in the land mesh
    land = new Vertex[cols][rows];  //Declare vertices
    landCopy = new Vertex[cols][rows];
    //Initialise land
    for (int z = 0; z < rows; z++) {
      for (int x = 0; x < cols; x++) {
        land[x][z] = new Vertex(-75, color(0));
        landCopy[x][z] = new Vertex(-75, color(0));
      }
    }
    //loop.add(this);    
    //updates.add(this);
    //draws.add(this);
    //this.rate = 16;
  }
  
  class Vertex {
    float h;       //Height of the vertex
    color colour;  //Colour of the vertex
    Vertex(float h, color colour) {
      this.h = h;
      this.colour = colour;
    }
  }
  
  void update() {
    
    distance += 0.05 + (player.forward ? 0.025 : player.backward ? -0.025 : 0);
    maxDistance += 0.075;
    float waveformL, waveformR, spike;
    color colour;
    for (int x = 0; x < cols/2 ; x++) {
        //waveform = (song.mix.get((((song.bufferSize())/cols)*x))*25);
        //(15000/max(score, 1))
        waveformL = (radio.left().get((((radio.bufferSize())/(cols/2))*x))*25) + (mic.left().get((((mic.bufferSize())/(cols/2))*x))*30*mic.sensitivity);
        waveformR = (radio.right().get((((radio.bufferSize())/(cols/2))*x))*25) + (mic.right().get((((mic.bufferSize())/(cols/2))*x))*30*mic.sensitivity);
        spike = (radio.fft.getBand((int) (((radio.fft.specSize()*0.5)/cols)*x) )*4) + (mic.fft.getBand((int) (((mic.fft.specSize()*1)/cols)*x) )*4*mic.sensitivity);
        //colour = color(max(25, lows*0.5), max(25, mids*0.5), max(25, highs*0.5), max(200, score));
        //colour = color(lows*0.5, mids*0.5, highs*0.5, score);
        //colour = color(bg>>16 & 0xFF, bg >> 8 & 0xFF, bg & 0xFF, max(200, score));
        colour = bg;
        land[x][rows - 1].h = -75 + waveformL + spike;
        land[x][rows - 1].colour = colour;
        land[cols - 1 - x][rows - 1].h = -75 + waveformR + spike;
        land[cols - 1 - x][rows - 1].colour = colour;
        

    }
    
    for (int z = 0; z < rows; z++) {
      for (int x = 0; x < cols; x++) {
        landCopy[x][z].h = land[x][z].h;
        landCopy[x][z].colour = land[x][z].colour;
      }
    }
    
    for (int z = 0; z < rows-1; z++) {
      for (int x = 0; x < cols; x++) {
        land[x][z].h = landCopy[x][z+1].h;
        land[x][z].colour = landCopy[x][z+1].colour;
      }
    }
    //for (int z = 1; z < rows-1; z++) {
    //  for (int x = 1; x < cols-1; x++) {
    //    land[x][z].h = heightAt((x + sin(player.rPos.y + PI)) * lod, (z+cos(player.rPos.y + PI))* lod);
    //    land[x][z].colour = landCopy[x + Math.round(sin(player.rPos.y + PI))][z+Math.round(cos(player.rPos.y + PI))].colour;
    //  }
    //}
    

    
    //https://math.stackexchange.com/questions/828878/calculate-dimensions-of-square-inside-a-rotated-square
    //int l = (int)(cols/(cos(player.rPos.y + PI)+sin(player.rPos.y + PI)));
    //https://math.stackexchange.com/questions/4001034/calculate-the-dimensions-of-a-rotated-rectangle-inside-a-bounding-box
    
    //int xDir = Math.round(sin(player.rPos.y + PI));
    //int zDir = Math.round(cos(player.rPos.y + PI));
    //System.out.println(xDir + ", " + zDir);
    //switch(xDir) {
    //  case 1 :      //East
    //    for (int z = 0; z < rows/2 ; z++) {
    //        waveform = (song.mix.get((((song.bufferSize())/cols)*z))*25);
    //        spike = (fft.getBand((int) (((fft.specSize())/cols)*z) )*4);
    //        spike = 0;
    //        colour = color(lows*0.5, mids*0.5, highs*0.5, score);
    //        land[cols - 1][z].h = -75 + waveform + spike;
    //        land[cols - 1][z].colour = colour;
    //        land[cols - 1][rows - 1 - z].h = land[cols-1][z].h;
    //        land[cols - 1][rows - 1 - z].colour = colour;
    //    }
    //    break;
    //  case -1 :     //West
    //    for (int z = 0; z < rows/2 ; z++) {
    //        waveform = (song.mix.get((((song.bufferSize())/cols)*z))*25);
    //        spike = (fft.getBand((int) (((fft.specSize())/cols)*z) )*4);
    //        spike = 0;
    //        colour = color(lows*0.5, mids*0.5, highs*0.5, score);
    //        land[0][z].h = -75 + waveform + spike;
    //        land[0][z].colour = colour;
    //        land[0][rows - 1 - z].h = land[cols-1][z].h;
    //        land[0][rows - 1 - z].colour = colour;
    //    }
    //    break;
    //}
    
    //switch(zDir) {
    //  case 1 :      //North
    //    for (int x = 0; x < cols/2 ; x++) {
    //        waveform = (song.mix.get((((song.bufferSize())/cols)*x))*25);
    //        spike = (fft.getBand((int) (((fft.specSize())/cols)*x) )*4);
    //        spike = 0;
    //        colour = color(lows*0.5, mids*0.5, highs*0.5, score);
    //        land[x][rows - 1].h = -75 + waveform + spike;
    //        land[x][rows - 1].colour = colour;
    //        land[cols - 1 - x][rows - 1].h = land[x][rows - 1].h;
    //        land[cols - 1 - x][rows - 1].colour = colour;
    //    }
    //    break;
    //  case -1 :     //South
    //    for (int x = 0; x < cols/2 ; x++) {
    //        waveform = (song.mix.get((((song.bufferSize())/cols)*x))*25);
    //        spike = (fft.getBand((int) (((fft.specSize())/cols)*x) )*4);
    //        spike = 0;
    //        colour = color(lows*0.5, mids*0.5, highs*0.5, score);
    //        land[x][0].h = -75 + waveform + spike;
    //        land[x][0].colour = colour;
    //        land[cols - 1 - x][0].h = land[x][rows - 1].h;
    //        land[cols - 1 - x][0].colour = colour;
    //    }
    //    break;
    //}
    
    //for (int z = 0; z < rows; z++) {
    //  for (int x = 0; x < cols; x++) {
    //    landCopy[x][z].h = land[x][z].h;
    //    landCopy[x][z].colour = land[x][z].colour;
    //  }
    //}
    
    //switch(xDir) {
    //  case 1 :
    //    for (int z = 0; z < rows; z++) {
    //      for (int x = 1; x < cols; x++) {
    //        land[x-1][z].h = landCopy[x][z].h;
    //        land[x-1][z].colour = landCopy[x][z].colour;
    //      }
    //    }
    //    break;
    //  case -1 :
    //    for (int z = 0; z < rows; z++) {
    //      for (int x = 0; x < cols - 1; x++) {
    //        land[x+1][z].h = landCopy[x][z].h;
    //        land[x+1][z].colour = landCopy[x][z].colour;
    //      }
    //    }
    //    break;
    //}

    //for (int z = 0; z < rows; z++) {
    //  for (int x = 0; x < cols; x++) {
    //    landCopy[x][z].h = land[x][z].h;
    //    landCopy[x][z].colour = land[x][z].colour;
    //  }
    //}
    
    //switch(zDir) {
    //  case 1 :
    //    for (int z = 0; z < rows-1; z++) {
    //      for (int x = 0; x < cols; x++) {
    //        land[x][z].h = landCopy[x][z+1].h;
    //        land[x][z].colour = landCopy[x][z+1].colour;
    //      }
    //    }
    //    break;
    //  case -1 :
    //    for (int z = 1; z < rows; z++) {
    //      for (int x = 0; x < cols; x++) {
    //        land[x][z].h = landCopy[x][z-1].h;
    //        land[x][z].colour = landCopy[x][z-1].colour;
    //      }
    //    }
    //    break;
    //}
    
  }
  
  
  void draw() {
    //fps.fill(170);
    fps.shininess(128);
    //fps.shininess(50);
    //FPS
    //fps.stroke(0);
    fps.strokeWeight(0.5);
    //fps.strokeWeight(1);
    //fps.noStroke();
    for (int z = 0; z < land[0].length-1; z++) { //Rows
      fps.beginShape(TRIANGLE_STRIP);
      //fps.noStroke();
      for (int x = 0; x < land.length; x++) {    //Cols
        //fps.emissive(land[x][z].colour);
        fps.fill(land[x][z].colour); //land colour
        fps.stroke(lerpColor(color(0), land[x][z].colour, 0.5));
        fps.vertex(x*lod, land[x][z].h, z*lod);
        //fps.emissive(land[x][z+1].colour);
        fps.fill(land[x][z+1].colour); //land colour
        fps.stroke(lerpColor(color(0), land[x][z+1].colour, 0.5));
        fps.vertex(x*lod, land[x][z+1].h, (z+1)*lod);
      }
      fps.endShape();
    }
    //HUD
  }
  
  void run() {
    lag += millis() - t;
    t = millis();

    //float update = dt * (player.forward ? 0.75 : (player.backward ? 1.25 : 1));
    //float update = dt * (player.forward ? 0.75 : (player.backward ? 1.25 : 1));
    //float update = dt - constrain((score/250), 0, dt*0.25) + ((player.forward ? - 0.2 : (player.backward ? 0.2 : 0)) * dt);
    float update = dt * (player.forward ? 0.8 : (player.backward ? 1.25 : 1)) * constrain((1000/score), 0.9, 1.1);
    //float update = dt * (player.forward ? 0.8 : (player.backward ? 1.25 : 1)) * constrain((1000/score), 0.75, 1.25);
    //float update = dt * (player.forward ? 0.8 : (player.backward ? 1.25 : 1)) * (onBeat > 0 ? 0.75 : 1);
    //float update = dt * (player.forward ? 0.8 : (player.backward ? 1.25 : 1));
    while(lag > update) {
      this.update();
      lag -= update;
    }
    
    
    
    
    //beat.detect(song.mix);
    //beat.isOnset();
    //System.out.println(frameCount);
    //Slow = 26fps, Med = 33fps, Fast = 48fps
    //if(frameCount/frameRate > (player.forward ? 1 : (player.backward ? 3 : 2))/frameRate){
    //  this.update();
    //  frameCount = 0;
    //}
    
    
    
    //if(fft.calcAvg(20, 20000) > 2){
    //  this.update();
    //}
        
    //beat.detect(song.mix);
    //if(beat.isOnset()){
    //  this.update();
    //}
    this.draw();
 
  }
  
  //Bilinear interpolation to find height
  float heightAt(PVector pos) {
    return heightAt(pos.x, pos.z);
  }
  
  float heightAt(float posx, float posz) {
    float x = posx/lod;
    float z = posz/lod;
    if(x > cols - 1 || x < 0 || z > rows - 1|| z < 0) return 0;
    int x1 = (int)Math.floor(posx/lod);
    int x2 = (int)Math.ceil(posx/lod);
    if(x1==x2) x2 = x1 + ((x1 > 0) ? -1 : 1);  //Avoid division by 0
    int z1 = (int)Math.floor(posz/lod);
    int z2 = (int)Math.ceil(posz/lod);
    if(z1==z2) z2 = z1 + ((z1 > 0) ? -1 : 1);  //Avoid division by 0
    float f11 = land[x1][z1].h;
    float f12 = land[x1][z2].h;
    float f21 = land[x2][z1].h;
    float f22 = land[x2][z2].h;
    float f1 = (((x2-x)/(x2-x1))*f11) + (((x-x1)/(x2-x1))*f21);
    float f2 = (((x2-x)/(x2-x1))*f12) + (((x-x1)/(x2-x1))*f22);
    return (((z2-z)/(z2-z1))*f1) + (((z-z1)/(z2-z1))*f2);
  }
}
