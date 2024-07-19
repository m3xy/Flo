//Circle button
class CircleBtn implements Runnable {
  float x,y,r;
  PGraphics ctx;
  CircleBtn(float x, float y, float r, PGraphics ctx) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.ctx = ctx;
  }
  
  void run() {
    this.update();
    this.draw();
  }
  
  void update() {
    
  }
  void draw() {
    ctx.circle(this.x, this.y, this.r);
  }
  
  boolean over() {
    return (sqrt(sq(x - mouseX) + sq(y - mouseY)) < r/2);
  }
}

final class PlayBtn extends CircleBtn {

  PlayBtn(float x, float y, float r, PGraphics ctx) {
    super(x,y,r,ctx);
  }

  void draw() {
    ctx.pushMatrix();
    ctx.translate(this.x, this.y);
    
    ctx.noFill();
    ctx.stroke(255);
    ctx.strokeWeight(1);
    drawWaveform(this.ctx, 0, 0, r, r/3, 1);
    
    //Play/Pause
    ctx.scale(r/2);
    if(radio.isPlaying()) {
      ctx.noFill();
      ctx.strokeWeight(0.5);
      ctx.stroke(255);
      ctx.rotate(HALF_PI + QUARTER_PI);
      ctx.line(cos(0), sin(0), cos(TWO_PI/4), sin(TWO_PI/4));
      //ctx.line(cos((TWO_PI*2)/4) + 0.32, sin((TWO_PI*2)/4) + 0.32, cos((TWO_PI*3)/4) + 0.32, sin((TWO_PI*3)/4) + 0.32);
      ctx.line(cos((TWO_PI*2)/4), sin((TWO_PI*2)/4), cos((TWO_PI*3)/4), sin((TWO_PI*3)/4));
    } else {
      ctx.fill(255);
      ctx.noStroke();
      //https://math.stackexchange.com/questions/3786698/find-the-two-points-for-an-equilateral-triangle-inscribed-inside-a-circle
      //https://math.stackexchange.com/questions/2385147/how-do-i-represent-an-equilateral-triangle-in-cartesian-coordinates-centered-aro
      //for(int i = 0; i < 3; i++) {
      //  ctx.vertex(cos((TWO_PI*i)/3), sin((TWO_PI*i)/3));
      //}
      ctx.triangle(cos(0), sin(0), cos(TWO_PI/3), sin(TWO_PI/3), cos((TWO_PI*2)/3), sin((TWO_PI*2)/3));
    }
    ctx.popMatrix();
  }
  
  void press() {
    if(radio.isPlaying())
      radio.pause();
    else
      radio.play();
  }
}

//Rectangular button
class RectBtn implements Runnable {
  float x,y,w,h;
  PGraphics ctx;
  
  RectBtn(float x, float y, float w, float h, PGraphics ctx){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.ctx = ctx;
  }
  
  void run() {
    this.update();
    this.draw();
  }
  
  void update() {
    
  }
  
  void draw() {
   ctx.rect(x,y,w,h);
  }
  
  boolean over() {
    return (mouseX > x-w && mouseX < x+w && mouseY > y-h && mouseY < y+h);
  }
}

final class ProgressBar extends RectBtn {
  
  ProgressBar(float x, float y, float w, float h, PGraphics ctx) {
    super(x,y,w,h,ctx);
  }
  
  void update() {
    if(dragging) this.press(); 
  }
  
  void draw() {
    ctx.pushMatrix();
    ctx.noFill();
    ctx.stroke(255);
    ctx.strokeWeight(1);
    ctx.rectMode(RADIUS);
    ctx.rect(this.x, this.y, this.w, this.h);
    
    ctx.rectMode(CORNER);
    ctx.fill(255);
    ctx.rect(this.x - this.w, this.y - this.h, map(radio.pos(), 0, radio.length(), 0, this.w*2), this.h * 2);
    ctx.popMatrix();
  }
  
  void press() {
    radio.cue((int)map(mouseX, this.x - this.w, this.x + this.w, 0, radio.length()));
  }
}

final class SkipBtn extends RectBtn {
  
  boolean back;
  
  SkipBtn(float x, float y, float r, boolean back, PGraphics ctx) {
    super(x,y,r,r,ctx);
    this.back = back;
  }
  
  void draw() {
    
    ctx.pushMatrix();
    ctx.translate(this.x, this.y);
    ctx.scale(this.w/2);
    if(back) ctx.rotate(PI);
    
    //Triangle
    ctx.fill(255);
    ctx.noStroke();
    ctx.triangle(cos(0), sin(0), cos(TWO_PI/3), sin(TWO_PI/3), cos((TWO_PI*2)/3), sin((TWO_PI*2)/3));
    
    //Line
    ctx.noFill();
    ctx.strokeWeight(0.3);
    ctx.stroke(255);
    ctx.rotate(HALF_PI + QUARTER_PI);
    ctx.scale(1.25);
    ctx.line(cos((TWO_PI*2)/4), sin((TWO_PI*2)/4), cos((TWO_PI*3)/4), sin((TWO_PI*3)/4));
    ctx.popMatrix();
  }
  
  void press() {
    radio.skip(back);
  }
}

final class ArrowBtn extends RectBtn {
  boolean back;
  ArrowBtn(float x, float y, float r, boolean back, PGraphics ctx) {
    super(x,y,r,r, ctx);
    this.back = back;
  }
  
  void draw() {
    ctx.pushMatrix();
    ctx.translate(this.x, this.y);
    if(back) ctx.rotate(PI);
    ctx.line(0,0,this.w, 0);
    ctx.line(this.w, 0, this.w - 8, -8);
    ctx.line(this.w, 0, this.h - 8, 8);
    ctx.popMatrix();
  }
  
  void press() {
    if(back)  {
      gun = ((gun-1) + guns.size()) % guns.size();
    } else {
      gun = (gun + 1) % guns.size();      
    }
  }
}

final class HUDInput extends RectBtn {
  
  String text;
  HUDInput(float x, float y, float w, float h, String text, PGraphics ctx) {
    super(x,y,w,h,ctx);
    this.text = text;
  }
  
  void draw(boolean active) {
    this.draw(active, 0);
  }
  
  void draw(boolean active, float chance) {
    color bgColour, txtColour;
    
    if(chance > 0) {
      if(active) bgColour = color(255, 215, 0);  //Gold
      //else bgColour = color(220, 20, 60, (chance/(frameRate*beatWindow)) * 255);  //Red
      else bgColour = color(base.x*255, base.y*255, base.z*255, (chance/(frameRate*beatWindow)) * 255);  //Red
    }else {
      if(active) {
        bgColour = color(255);  //White
      }else {
        bgColour = color(255, 50);  //Transparent white
      }
    }

    txtColour = color(active ? 0 : 255);
    
    this.ctx.fill(bgColour);
    this.ctx.stroke(bgColour);
    super.draw();
    
    write(ctx, text, x + (w/2), y + (h/2), CENTER, CENTER, min(w,h)/2, txtColour);
  }
}

final class GunInfo extends RectBtn {
  
  GunInfo(float x, float y, float r, PGraphics ctx) {
    super(x,y,r,r,ctx);
  }
  
  void run(Gun gun) {
    this.draw(gun);
  }
  
  void draw(Gun gun) {
    if(!over()) return;
   
    float offset = gun.offset.x;
    write(ctx,(offset >= 1 ? "Right" : offset <= -1 ? "Left" : "Two") + "-Handed, " + "Wear: " + round(gun.wear * 100) + "%", x, y - (height/8), CENTER, TOP, height/64, color(255));
    //write(ctx, , x, y - (height/9), CENTER, TOP, height/64, color(255));
    write(ctx, round(60000/gun.dex) + " Rounds per minute", x, y + (height/8), CENTER, BOTTOM, height/64, color(255));
    ctx.rectMode(RADIUS);
    ctx.fill(255, 50);
    super.draw();
  }
  
}
