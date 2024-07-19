final class Mic extends AudioSrc {
  
  boolean muted;
  AudioInput in;
  
  Mic() {
    sensitivity = 5;
    //in = minim.getLineIn();
    in = minim.getLineIn(Minim.MONO);
    mute();
  }
  
  void mute() {
     muted = true;
     src = minim.getLineOut();
     this.init();
  }
  
  void unmute() {
    muted = false;
    src = in;
    ((AudioInput)src).disableMonitoring();
    this.init();
  }
  
  void init() {
    fft = new FFT(src.bufferSize(), src.sampleRate());
    //fft.logAverages(int(src.sampleRate()/8) - 1, 1); //Nyquist Frequency/2 twice
    fft.noAverages();
    beatNrg = new BeatDetect();
    beatFreq = new BeatDetect(src.bufferSize(), src.sampleRate());
  }
}
