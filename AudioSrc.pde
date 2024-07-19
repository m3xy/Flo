abstract class AudioSrc {

  //Audio source (Either Mic or Song)
  AudioSource src;
  
  //FFT analysis
  FFT fft;
  
  //Beat detection
  BeatDetect beatNrg;
  BeatDetect beatFreq;
  
  //Audio effects
  LowPassFS lFilter;
  HighPassSP hFilter;
  NotchFilter nFilter, nFilterHi, nFilterLo;
  //BandPass bandpass;
  LowPassFS bandpass;
  
  //Sensitivity
  float sensitivity;
  
  AudioBuffer left() {
    return src.left; 
  }

  AudioBuffer right() {
    return src.right; 
  }
  
  AudioBuffer mix() {
    return src.mix; 
  }
  
  int bufferSize() {
    return src.bufferSize(); 
  }
  
  void clearFX() {
    src.clearEffects();
  }
  
  void addFX(AudioEffect fx) {
    src.addEffect(fx);
  }
  
}
