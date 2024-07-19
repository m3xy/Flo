import java.awt.Robot;
import java.awt.AWTException;
import java.util.Iterator;
import java.util.List;
import java.util.Arrays;

import ddf.minim.analysis.*; //For FFT
import ddf.minim.*; //For Minim and AudioPlayer
import ddf.minim.effects.*; //Low pass filter
import ddf.minim.ugens.*; //Shooting sounds

import java.util.stream.*;
import java.nio.file.*;
import java.util.Collections;
import java.util.Arrays;

//GUNS
final static String GUNS_PATH = "\\guns.txt";
List<String> shapes;
ArrayList<Gun> guns;
int gun;
Gun reward;

//MUSIC
final static String SONG_DIR = "\\music";
Radio radio; //Song player
Mic mic;   //Microphone
Minim minim;
SoundFX fx;
Convolver echo;
//float loMid = 220, hiMid = 880;
float loMid = 200, hiMid = 2000; //2.5, 0.7(5)
//float loMid = 200, hiMid = 1600;
float oldLows, oldMids, oldHighs, lows, mids, highs, score, decay; //Scoring values
float loDecay, miDecay, hiDecay;
boolean beat, kick, snare, hat;
float onBeat = 0;
float beatWindow = 0.25f; //250 ms
int beats = 0;
float maxMixLevel = 0, maxLeftLevel = 0, maxRightLevel = 0;

//GAME
State state = State.LOAD;
PVector base;
color bg, bg2;
//List<Runnable> loop = new ArrayList<>();
//boolean restarting = false;

//DISPLAY
PGraphics fps, hud; //First Person Shooter, Heads-up display
Robot robot;

//SETUP
void setup() {
  //size(1920, 1080, P2D); //Windowed Full-screen
  fullScreen(P2D, SPAN);                        //Menu
  fps = createGraphics(width, height, P3D);     //First person view
  hud = createGraphics(width, height, P2D);     //Heads-up display
  try{
    robot = new Robot();
  }catch(AWTException e) {
    System.err.println("Error: Setting up robot");
  }
  frameRate(60);
}

//DRAW
void draw() {
  //switch(radio.volume) {
  //  case NONE :
  //    break;
  //  case UP :
  //    radio.volUp();
  //    break;
  //  case DOWN :
  //    radio.volDown();
  //    break;
  //}
  background(255); //White BG
  
  
  switch(state) {
    case LOAD :
      loadMenu();
      break;
    case MENU :
      cursor();  //Show cursor
      progress();
      drawMENU();
      break;
    case PLAY :
      noCursor();  //Hide cursor
      progress();
      drawFPS();
      drawHUD();
      break;
    case WIN :
      cursor();  //Show cursor
      drawWIN();
      break;
    case LOSE :
      cursor();  //Show cursor
      drawLOSE();
      break;
  }
}

void loadMenu() {
  
  loadGuns();
  gun = 0;
  
  minim = new Minim(this);
  radio = new Radio();
  mic = new Mic();
  fx = new SoundFX();
  //float[] kernel = new float[out.bufferSize()];
  //for(int i = 0; i < kernel.length; i++) {
  //  kernel[i] = 0.5f/(i+1);
  //  //kernel[i] = 1f;
  //}
  //echo = new Convolver(kernel, out.bufferSize());
  //echo = new Convolver(new float[]{-1}, out.bufferSize());
  loadBtns();
  
  state = State.MENU;
}

void loadGuns() {
  try {
    shapes = new ArrayList<>(Files.readAllLines(Paths.get(sketchPath() + GUNS_PATH)));
  } catch(IOException e) { //File doesn't exist
    System.err.println(e.getMessage() + "");
    initGuns();
  }
  
  guns = new ArrayList<>();
  List<Float> args;
  for(String shape : shapes) {
    args = Arrays.stream(shape.split(",")).map(Float::parseFloat).collect(Collectors.toList());
    guns.add(new Gun(args.get(0), args.get(1), args.get(2), (new Supershape(args.get(3), args.get(4), args.get(5), args.get(6), args.get(7), args.get(8), args.get(9), args.get(10), floor(args.get(11)))),
    new PVector(args.get(12), args.get(13), args.get(14)), new PVector(args.get(15), args.get(16)), args.get(17), args.get(18)));
  }
}

//Creates gun file with default gun
void initGuns() {
  //Add default gun to file
  String cube = "4,-2,5,4,10,10,10,4,10,10,10,50,1,1,1,0,0,0,150";
  try {
    Files.write(Paths.get(sketchPath() + GUNS_PATH), cube.getBytes());
  } catch(IOException e) {
    System.err.println(e.getMessage());
  }
  
  //Load guns from file
  loadGuns();
}

// START
void init() {
  robot.mouseMove(width/2,height/2); //Move cursor back to center
  score = oldLows = oldMids = oldHighs = lows = mids = highs = 0;
  bg = color(0);
  radio.rewind();
  radio.play();
  t = millis();
  
  terrain = new Land();
  player = new Player();
  //loop.add(guns.get(gun));
  sun = new Sun();
  
  waves = new ArrayList<>(nWaves);
  for(int i = 0; i < nWaves; i++)
    waves.add(new Wave(nEnemies));

  trees = new ArrayList<>(nTrees);
  for(int i = 0; i < nTrees; i++)
    trees.add(new Tree());
    
  stars = new ArrayList<>(nStars);
  for(int i = 0; i < nStars; i++)
    stars.add(new Star(((radio.fft.specSize()*0.5)/nStars)*i, ((radio.fft.specSize()*0.5)/nStars)*(i+1)));

  rocks = new ArrayList<>(nRocks);
  for(int i = 0; i < nRocks; i++)
    rocks.add(new Rock(((radio.fft.specSize())/nRocks)*i, ((radio.fft.specSize())/nRocks)*(i+1)));
  initReward();
  loadHUDInputs();
  
  fps.sphereDetail(5);
}

void restart() {

  //Score
  distance = 0;
  maxDistance = 0;
  kills = -nEnemies;
  shots = nEnemies;
  hits = nEnemies;
  
  radio.rewind();
  loadGuns();
  gun = 0;
  this.state = State.MENU;
}

void progress() {
  radio.fft.forward(radio.mix());
  mic.fft.forward(mic.mix());
  //decay = exp(fft.calcAvg(0, fft.specSize()));
  //decay = pow(fft.calcAvg(0, fft.specSize()), 1.25);
  //decay = pow(fft.calcAvg(0, fft.specSize()), 0.9);
  //decay = pow(fft.calcAvg(0, fft.specSize()), 0.75);
  //decay = pow(fft.calcAvg(0, fft.specSize()), 0.5);
  //decay = log(fft.calcAvg(0, fft.specSize()))*5;
  //decay = fft.calcAvg(0, fft.specSize()) + 10;
  //decay = 1.5 * fft.calcAvg(0, fft.specSize());
  //decay = constrain(pow(fft.calcAvg(0, fft.specSize()), 0.75), 1, 25);
  //decay = 20;
  //if(pow(fft.calcAvg(0, fft.specSize()), 0.75) < 20)
  //  decay = pow(fft.calcAvg(0, fft.specSize()), 0.75);
  //decay = (decay == 0 ? score/frameRate : fft.calcAvg(0, fft.specSize())*(9/frameRate));
  //decay = (decay == 0 ? score/frameRate : log(max(1, fft.calcAvg(0, fft.specSize())))*(50/frameRate)); 
  //decay = (decay == 0 ? score/frameRate : log(max(1, fft.calcAvg(0, fft.specSize())))*(200/frameRate)); //Smoother
  //decay = (decay == 0 ? score/frameRate : pow(radio.fft.calcAvg(0, radio.fft.specSize()), 1.1)*(15/frameRate)); //Determines how often colours change in a way (using)
  //decay = (decay == 0 ? score/frameRate : (score/frameRate) + (pow(radio.fft.calcAvg(0, radio.fft.specSize()), 1.1) + pow(mic.fft.calcAvg(0, mic.fft.specSize()), 1.1)) * (15/frameRate));  //Determines how often colours change in a way (using_old)
  //decay = (score/(frameRate*10)) + (pow(radio.fft.calcAvg(0, radio.fft.specSize()), 1.2) + pow(mic.fft.calcAvg(0, mic.fft.specSize()), 1.2)) * (1/frameRate); //Determines how often colours change in a way (using)
  //decay = (decay == 0 ? score/frameRate : pow(fft.calcAvg(0, fft.specSize()), 1.1)*(20/frameRate)); //Determines how often colours change in a way (using_old(2)) 
  //decay = (decay == 0 ? score/frameRate : pow(fft.calcAvg(0, fft.specSize()), 1.1 + (beat.isOnset()? 0.1 : 0))*(15/frameRate)); //Determines how often colours change in a way
  //decay = (decay == 0 ? score/frameRate : fft.calcAvg(0, fft.specSize())*(20/frameRate));
  
  //decay = (decay == 0 ? score/frameRate : fft.calcAvg(0, fft.specSize())*(20/frameRate));
  
  //decay = (decay == 0 ? score/frameRate : min(pow(fft.calcAvg(0, fft.specSize())*(10/frameRate), 1.25), 2000/frameRate)); 
  //System.out.println(decay);
  
  //loDecay = (pow(lows, 1.2)/(frameRate * 2)) + (pow(radio.fft.calcAvg(0, radio.fft.freqToIndex(200)), 1.2) + pow(mic.fft.calcAvg(0, mic.fft.freqToIndex(200)), 1.2)) * (1/frameRate);
  //miDecay = (pow(mids, 1.2)/(frameRate * 2)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(200), radio.fft.freqToIndex(2000)), 1.2) + pow(mic.fft.calcAvg(mic.fft.freqToIndex(200), mic.fft.freqToIndex(2000)), 1.2)) * (1/frameRate);
  //hiDecay = (pow(highs, 1.2)/(frameRate * 2)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(2000), radio.fft.specSize()), 1.2) + pow(mic.fft.calcAvg(radio.fft.freqToIndex(2000), mic.fft.specSize()), 1.2)) * (1/frameRate);
  
  //loDecay = (lows/(frameRate * 1.5)) + (pow(radio.fft.calcAvg(0, radio.fft.freqToIndex(200)), 1.2) + pow(mic.fft.calcAvg(0, mic.fft.freqToIndex(200)), 1.2)) * (1/frameRate);
  //miDecay = (mids/(frameRate * 0.75)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(200), radio.fft.freqToIndex(2000)), 1.2) + pow(mic.fft.calcAvg(mic.fft.freqToIndex(200), mic.fft.freqToIndex(2000)), 1.2)) * (1/frameRate);
  //hiDecay = (highs/(frameRate * 0.5)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(2000), radio.fft.specSize()), 1.2) + pow(mic.fft.calcAvg(radio.fft.freqToIndex(2000), mic.fft.specSize()), 1.2)) * (1/frameRate);
  
  loDecay = (lows/(frameRate * 1.5)) + (pow(radio.fft.calcAvg(0, radio.fft.freqToIndex(loMid)), 1.5) + pow(mic.fft.calcAvg(0, mic.fft.freqToIndex(loMid)), 1.5)) * (1/frameRate);
  miDecay = (mids/(frameRate * 1.5)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(loMid), radio.fft.freqToIndex(hiMid)), 1.5) + pow(mic.fft.calcAvg(mic.fft.freqToIndex(loMid), mic.fft.freqToIndex(hiMid)), 1.5)) * (1/frameRate);
  hiDecay = (highs/(frameRate * 1.5)) + (pow(radio.fft.calcAvg(radio.fft.freqToIndex(hiMid), radio.fft.specSize()), 1.5) + pow(mic.fft.calcAvg(radio.fft.freqToIndex(hiMid), mic.fft.specSize()), 1.5)) * (1/frameRate);
  
  oldLows = lows;
  oldMids = mids;
  oldHighs = highs;
  lows = mids = highs = 0;
  //Calculate the new "scores"
  
  // 250 : 0 -> 5
  //500
  //for(int i = 0; i < fft.freqToIndex(500); i++) {
  //  lows += (fft.getBand(i)*1.25);
  //}
  //for(int i = 0; i < radio.fft.freqToIndex(375); i++) {
  //  lows += (radio.fft.getBand(i)*1.5);
  //}
  //for(int i = 0; i < mic.fft.freqToIndex(375); i++) {
  //  lows += (mic.fft.getBand(i)*1.5*mic.sensitivity);
  //}
  for(int i = 0; i < radio.fft.freqToIndex(loMid); i++) {
    lows += (radio.fft.getBand(i) * 2.5);
  }
  for(int i = 0; i < mic.fft.freqToIndex(loMid); i++) {
    lows += (mic.fft.getBand(i) * 2.5 * mic.sensitivity);
  }
  
  
  // 250 - 1000: 5 -> 21 (1.5)
  // 500 - 2000
  //for(int i = fft.freqToIndex(500); i < fft.freqToIndex(2000); i++) {
  //  mids += (fft.getBand(i) * 0.8);
  //}
  //for(int i = radio.fft.freqToIndex(375); i < radio.fft.freqToIndex(1500); i++) {
  //  mids += (radio.fft.getBand(i) * 0.85);
  //}
  //for(int i = mic.fft.freqToIndex(375); i < mic.fft.freqToIndex(1500); i++) {
  //  mids += (mic.fft.getBand(i) * 0.85 * mic.sensitivity);
  //}
  for(int i = radio.fft.freqToIndex(loMid); i < radio.fft.freqToIndex(hiMid); i++) {
    mids += (radio.fft.getBand(i) * 1);
  }
  for(int i = mic.fft.freqToIndex(loMid); i < mic.fft.freqToIndex(hiMid); i++) {
    mids += (mic.fft.getBand(i) * 1 * mic.sensitivity);
  }
  
  //System.out.println(radio.fft.freqToIndex(500) + " " + radio.fft.freqToIndex(2000) + " " + radio.fft.freqToIndex(4000));
  
  //1000+ : 21 -> 513 (2.5)
  //2000+
  //for(int i = fft.freqToIndex(2000); i < fft.specSize(); i++) {
  //  highs += (fft.getBand(i) * 0.5);
  //}
  //for(int i = radio.fft.freqToIndex(1500); i < radio.fft.specSize(); i++) {
  //  highs += (radio.fft.getBand(i) * 0.5);
  //}
  //for(int i = mic.fft.freqToIndex(1500); i < mic.fft.specSize(); i++) {
  //  highs += (mic.fft.getBand(i) * 0.5 * mic.sensitivity);
  //}
  for(int i = radio.fft.freqToIndex(hiMid); i < radio.fft.specSize(); i++) {
    highs += (radio.fft.getBand(i) * 0.75);
  }
  for(int i = mic.fft.freqToIndex(hiMid); i < mic.fft.specSize(); i++) {
    highs += (mic.fft.getBand(i) * 0.75 * mic.sensitivity);
  }
  
  //System.out.println(radio.fft.freqToIndex(loMid) + ", " + radio.fft.freqToIndex(hiMid) + ", " + radio.fft.freqToIndex(3200) + ", " +radio.fft.specSize());
  
  //lows += (0.75 * radio.sensitivity * radio.fft.getAvg(0)) + (mic.fft.getAvg(0) * mic.sensitivity);
  //mids += (2.5 * radio.sensitivity * radio.fft.getAvg(1)) + (mic.fft.getAvg(1) * mic.sensitivity);
  //highs += (10 * radio.sensitivity * radio.fft.getAvg(2)) + (mic.fft.getAvg(2) * mic.sensitivity);
  
  
  //System.out.println("Highs: " + highs);
  //System.out.println("Mids: " + mids);
  //System.out.println("Lows: " + lows);
  //Slow down the descent.
  if (oldLows > lows) {
    //lows = oldLows - (0.01*decay);
    //lows = oldLows - (0.05*decay);
    //lows = oldLows - decay;
    lows = oldLows - loDecay;
  }
  
  if (oldMids > mids) {
    //mids = oldMids - (0.25 * decay);
    //mids = oldMids - (1.25 * decay);
    //mids = oldMids - (2 * decay);
    //mids = oldMids - decay;
    mids = oldMids - miDecay;
  }
  
  if (oldHighs > highs) {
    //highs = oldHighs - (3*decay);
    //highs = oldHighs - decay;
    highs = oldHighs - hiDecay;
  }
  
  ////higher frequencies are more noticeable therefore have higher weight
  //score = 0.66*lows + 0.8*mids + 1*highs;
  //PVector scores = new PVector(lows, mids, highs).normalize().mult(255);
  //score = scores.x + scores.y + scores.z;
  score = lows + mids + highs;
  
  
  //bg = color(pow(lows*0.5, 1.2), pow(mids*0.5, 1.2), pow(highs*0.5, 1.2));
  //bg = color(pow(lows*0.5, 1.1), pow(mids*0.5, 1.1), pow(highs*0.5, 1.1));
  //bg = color(lows*0.3, mids*0.25, highs * 0.2);
  //bg = color(pow(lows, 1), pow(mids, 0.85), pow(highs, 0.75));
  //bg = color(pow(lows, 0.9), pow(mids, 0.85), pow(highs, 0.75));
  //bg = color(pow(lows, 0.85), pow(mids, 0.78), pow(highs, 0.75));
   
  //bg = color(pow(lows, 0.88), pow(mids, 0.85), pow(highs, 0.8));
  //bg = color(lows*0.5, mids*0.5, highs*0.5);
  
  //bg = color(pow(lows, 0.86), pow(mids, 0.85), pow(highs, 0.8));
  //bg = color(pow(lows, 0.875), pow(mids, 0.85), pow(highs, 0.8)); //using
  //bg = color(pow(lows, 0.8), pow(mids, 0.8), pow(highs, 0.8));
  //bg = color(lows*0.3, mids*0.25, highs * 0.2);
  //bg = color(pow(lows, 0.85), pow(mids, 0.83), pow(highs, 0.81));
  
  beatDetect();
  
  //float a;  //Alpha
  base = new PVector(lows, mids, highs).normalize();
  PVector top = base.copy();
  if(beat) {
    //bg = color(pow(lows*0.5, 1.1), pow(mids*0.5, 1.1), pow(highs*0.5, 1.1));
    //bg = color(pow(lows, 0.875), pow(mids, 0.85), pow(highs, 0.8)); //using
    //PVector colour = new PVector(lows*0.55, mids*0.5, highs*0.45);
    //PVector colour = new PVector(lows*0.4, mids*0.4, highs*0.4);
    //if(colour.mag() < 50)
    //  colour.normalize().mult(50);
    //bg = color(colour.x, colour.y, colour.z);
    //bg = color(lows*0.55, mids*0.5, highs*0.45);
    //a = max(30, colour.mag() * 0.35);
    top.mult(score/8);
    onBeat = (frameRate * beatWindow);  //250ms -> 15 frames for 60fps
  } else {
    //PVector colour = new PVector(lows*0.5, mids*0.45, highs*0.4);
    //PVector colour = new PVector(lows*0.35, mids*0.35, highs*0.35);
    //if(colour.mag() < 25)
    //  colour.normalize().mult(25);
    //bg = color(colour.x, colour.y, colour.z);
    //bg = color(lows*0.5, mids*0.45, highs*0.4);
    //a = max(30, colour.mag() * 0.3);
    top.mult(score/10);
    onBeat = max(0, onBeat - 1);
  }
  //colour.normalize().mult(a);
  bg = color((base.x*30)+top.x, (base.y*30)+top.y, (base.z*30)+top.z);
  
  //if(beat) {
  //  PVector colour = new PVector(lows, mids, highs);
  //  if(colour.mag() < 50)
  //    colour.normalize().mult(50);
  //  bg = color(colour.x, colour.y, colour.z);
  //  //bg = color(lows*0.55, mids*0.5, highs*0.45);
  //} else {
  //  PVector colour = new PVector(lows, mids, highs);
  //  if(colour.mag() < 25)
  //    colour.normalize().mult(25);
  //  bg = color(colour.x, colour.y, colour.z);
  //}
  
  bg2 = color(255 - bg>>16 & 0xFF, 255 - bg>> 8 & 0xFF, 255 - bg& 0xFF, 255); //Complimentary colour

}

void beatDetect() {
  radio.beatNrg.detect(radio.mix());
  mic.beatNrg.detect(mic.mix());
  radio.beatFreq.detect(radio.mix());
  mic.beatFreq.detect(mic.mix());
  beat = radio.beatNrg.isOnset() || mic.beatNrg.isOnset();
  kick = radio.beatFreq.isKick() || mic.beatFreq.isKick();
  snare = radio.beatFreq.isSnare() || mic.beatFreq.isSnare();
  hat = radio.beatFreq.isHat() || mic.beatFreq.isHat();
}

int bpm() {
  return (60000*beats)/millis();
}

float log2(float x) {
  return (log(x) / log(2));
}

enum State {
  LOAD,  //Loading
  MENU,  //Game menu
  PLAY,  //Game play
  WIN,   //Game win
  LOSE,  //Game lose
}


  
