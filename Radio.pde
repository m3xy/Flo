final class Radio extends AudioSrc {
  
  ArrayList<String> songs;
  int playing;
  //Volume volume = Volume.NONE;
  
  Radio() {
    sensitivity = 50;
    songs = new ArrayList<>();
    loadSongs();
    playing = 0;
    loadSong(playing);
  }
  
  void loadSongs() {
    try (Stream<Path> paths = Files.walk(Paths.get(sketchPath() + SONG_DIR))) {
      paths.filter(Files::isRegularFile).forEach(file -> songs.add(file.toString()));
    } catch(IOException e) {
      System.err.println(e.getMessage()); 
    }
    
    Collections.sort(songs);
  }
  
  void loadSong(int n) {
    
    oldLows = oldMids = oldHighs = lows = mids = highs = 0;
    
    //Maybe silence = cannot shoot, can only dodge, special monsters?
    src = minim.loadFile(songs.get(n));
    
    //Requires song
    src.setGain(-25);
    fft = new FFT(src.bufferSize(), src.sampleRate());
    //fft.logAverages(int(src.sampleRate()/8) - 1, 1); //Nyquist Frequency/2 twice
    fft.noAverages();
    fft.window(FFT.NONE);
    beatNrg = new BeatDetect();
    beatFreq = new BeatDetect(src.bufferSize(), src.sampleRate());
    lFilter = new LowPassFS(250, src.sampleRate());
    hFilter = new HighPassSP(1000, src.sampleRate());
    nFilter = new NotchFilter(500, src.bufferSize(), src.sampleRate());
    //nFilterHi = new NotchFilter(1000, src.bufferSize(), src.sampleRate());
    //nFilterLo = new NotchFilter(250, src.bufferSize(), src.sampleRate());
    //bandpass = new BandPass(750, 250, src.sampleRate());
    //bandpass = new BandPass(fft.indexToFreq(fft.specSize())/2, fft.indexToFreq(fft.specSize()), src.sampleRate());
    bandpass = new LowPassFS(fft.indexToFreq(fft.specSize()), src.sampleRate());
    //System.out.println(fft.indexToFreq(fft.specSize())/2 + " " + bandpass.getBandWidth());
  }
  
  void play() {
    ((AudioPlayer)src).play();
  }
  
  void pause() {
    ((AudioPlayer)src).pause();
  }
  
  void rewind() {
    ((AudioPlayer)src).rewind();
  }
  
  void switchSong(int n) {
  
    ((AudioPlayer)src).pause();
    //((AudioPlayer)src).close();
    //minim.stop();
    loadSong(n);
    ((AudioPlayer)src).rewind();
    ((AudioPlayer)src).play();
  }
  
  void volUp() {
    src.setGain(src.getGain()+0.05);
  }
  
  void volDown() {
    src.setGain(src.getGain()-0.05);
  }
  
  boolean isPlaying() {
    return ((AudioPlayer)src).isPlaying(); 
  }
  
  int pos() {
    return ((AudioPlayer)src).position(); 
  }
  
  int length() {
    return ((AudioPlayer)src).length();
  }
  
  void cue(int millis) {
    ((AudioPlayer)src).cue(millis);
  }
  
  void skip(boolean back) {
    if(back) {
      playing = ((playing - 1) + (songs.size())) % (songs.size());
    } else {
      playing = (playing + 1) % (songs.size());
    }
    switchSong(playing); //load new song
  }
  
  String playing() {
    return new File(songs.get(playing)).getName();
  }
}

enum Volume {
  NONE,
  UP,
  DOWN
}
