final class Pew implements Instrument {
  AudioOutput out;
  Oscil wave;
  Line ampEnv;
  
  Pew(float frequency, AudioOutput out) {
    this.out = out;
    this.wave = new Oscil(frequency, 0, Waves.SINE);
    this.ampEnv = new Line();
    this.ampEnv.patch(wave.amplitude);
  }
  
  void noteOn(float duration) {
    this.ampEnv.activate(duration, 0.5f, 0);
    this.wave.patch(this.out);
  }
  
  void noteOff() {
    this.wave.unpatch(this.out);
  }
}
