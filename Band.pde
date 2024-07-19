class Band implements Comparable<Band> {

  int index;
  float freq, amp;
  
  Band(int index, float freq, float amp){
    this.index = index;
    this.freq = freq;
    this.amp = amp;
  }
  
  int compareTo(Band b) {
    return (this.amp > b.amp ? 1 : (this.amp < b.amp ? -1 : 0));
  }
}
