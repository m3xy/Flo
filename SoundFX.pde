//float[] octave = {16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87};
//float[] octave = {329.63, 349.23, 369.99, 392, 415.3, 440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25};
class SoundFX {

  AudioOutput notes[];
  
  SoundFX() {
    notes = new AudioOutput[5];
    
    for(int i = 0; i < notes.length; i++) {
      notes[i] = minim.getLineOut();
    }
  }
  
  void play(int note, float duration, float frequency, float volume) {
    notes[note].setGain(volume);
    //notes[note].playNote(0, duration, new Pew(frequency, notes[note]));
    notes[note].playNote(0, duration, new DefaultInstrument(frequency, notes[note]));
  }
}
