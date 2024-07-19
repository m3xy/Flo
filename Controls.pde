boolean dragging = false;

void keyPressed() {
  switch(state) {
    case MENU :
      switch(key) {
        case ENTER :
          state = State.PLAY;
          init();
          break;
      }
      break;
    case PLAY :
      if (key == CODED) {
        switch(keyCode) {
          //case UP :
          //  vol = Volume.UP; //Able to hold down
          //  break;
          //case DOWN :
          //  vol = Volume.DOWN;
          //  break;
          //case LEFT :
          //  song.skip(-1000*10);
          //  break;
          //case RIGHT :
          //  song.skip(1000*10);
          //  break;

        }
        
        
        //System.out.println(keyCode);
        //switch (keyCode) {
        //  case java.awt.event.KeyEvent.VK_F1:
        //  case java.awt.event.KeyEvent.VK_NUMPAD1:
        //    help = true;
        //    break;
        //}
      } else {
        switch (key) {  //Movement
          case 'w' :
          case 'W':
            player.forward = true;
            //lows=mids=highs=0;
            break;
          case 'a' :
          case 'A' :
            player.left = true;
            break;
          case 's' :
          case 'S' :
            //lows=mids=highs=0;
            player.backward = true;
            break;
          case 'd' :
          case 'D' :
            player.right = true;
            break;
          case ' ' :
            player.jumping = true;
            break;
          case 'v' :
          case 'V' :
            if(mic.muted)
              mic.unmute();
            else
              mic.mute();
            break;
        }
      }
      break;
    case WIN :
    case LOSE :
      switch (key) {
        case ENTER :
          restart();
          break;
      }
      break;
  } 
}

void keyReleased() {
  if(state != State.PLAY) return;
  if (key == CODED) {
    switch (keyCode) {
      //case UP :
      //case DOWN :
      //  radio.volume = Volume.NONE;
      //  break;
    }
    
  } else {
    switch (key) {  //Movement
      case 'w' :
      case 'W' :
        player.forward = false;
        break;
      case 'a' :
      case 'A' :
        player.left = false;
        break;
      case 's' :
      case 'S' :
        player.backward = false;
        break;
      case 'd' :
      case 'D' :
        player.right = false;
        break;
    }
  }
}

void mousePressed() {
  switch(state) {
    case MENU:
      switch(mouseButton) {
        case LEFT :
          if(playBtn.over()) playBtn.press();
          if(nextSongBtn.over()) nextSongBtn.press();
          if(prevSongBtn.over()) prevSongBtn.press();
          if(progressBar.over()) dragging = true;
          if(nextGunBtn.over()) nextGunBtn.press();
          if(prevGunBtn.over()) prevGunBtn.press();
          break;
      }
      break;
    case PLAY:
      switch(mouseButton) {
        case LEFT :
          player.firing = true;
          break;
        case RIGHT :
          //player.hurt(1, "Player");
          //end(true, "test");
          //end(false, "test");
          break;
      }
      break;
    case WIN:
    case LOSE:
      //state = State.MENU;
      break;
  }
}

void mouseReleased() {
  //if(state != State.PLAY) return;
  switch(state) {
    case MENU:
      switch(mouseButton) {
        case LEFT: dragging = false;
      }
      break;
    case PLAY:
      switch(mouseButton) {
        case LEFT :
          player.firing = false;
          break;
      }
      break;
    case WIN:
    case LOSE:
      break;
  }
}

void mouseWheel(MouseEvent event) {
  radio.src.setGain(radio.src.getGain()-event.getCount());
}

//void dmg() {
  
//  radio.bandpass.setBandWidth(map(player.hp, 0, player.maxHP, 0, radio.fft.indexToFreq(radio.fft.specSize())));
//}
