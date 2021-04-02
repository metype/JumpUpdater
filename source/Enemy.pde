class Enemy {
  PVector pos;
  PVector vel;
  Rect upHit, leftHit, downHit, rightHit;
  int[] standAble = {1, 2, 3, 4, 5, 6};
  int jumpTimer = 0;
  byte[] arrows = new byte[4];
  boolean canToggle = false;

  public Enemy(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
  }

  public void render() {
    fill(255,0,0);
    stroke(0);
    float size=tileSize/2;
    rect(pos.x-(size/2)+scrollX, pos.y-(size/2)+scrollY, size, size);
  }

  public void spawn(float x, float y) {
    pos.x = x;
    pos.y = y;
    this.vel = new PVector(0, 0);
  }

  public void AI(Player p) {
    if (p.pos.x<this.pos.x) {
      this.arrows[3]=1;
      this.arrows[2]=0;
    }
    if (p.pos.x>this.pos.x) {
      this.arrows[3]=0;
      this.arrows[2]=1;
    }
    if (p.pos.y<this.pos.y) {
      this.arrows[0]=1;
    }
    if (p.pos.y>this.pos.y) {
      this.arrows[0]=0;
    }
  }

  public void updatePhysics(ArrayList<Tile> collide, int timeStep) {
    if (this.pos.y>(currentLevel.t[0].length*tileSize)) kill.add(this);
    jumpTimer--;
    jumpTimer = max(jumpTimer, 0);
    upHit = new Rect(pos.x-(tileSize/4)+(tileSize/9), pos.y-(tileSize/4), tileSize/2-(tileSize/9)*2, tileSize/9);
    downHit = new Rect(pos.x-(tileSize/4)+(tileSize/9), pos.y-(tileSize/4)+(tileSize/2)-(tileSize/9), tileSize/2-(tileSize/9)*2, tileSize/9);
    leftHit = new Rect(pos.x-(tileSize/4), pos.y-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
    rightHit = new Rect(pos.x-(tileSize/4)+(tileSize/2)-(tileSize/9), pos.y-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
    Tile rightTouch = new Tile(-1), leftTouch = new Tile(-1), downTouch = new Tile(-1), upTouch = new Tile(-1);
    for (Tile t : collide) {
      if (upHit.isTouching(t.hitBox) && t.isSolid()) upTouch=t;
      if (downHit.isTouching(t.hitBox) && t.isSolid()) downTouch=t;
      if (leftHit.isTouching(t.hitBox) && t.isSolid()) leftTouch=t;
      if (rightHit.isTouching(t.hitBox) && t.isSolid()) rightTouch=t;
    }
    if (debug) {
      fill(255);
      if (upTouch.hitBox!=null) upTouch.hitBox.render();
      fill(255, 0, 0);
      if (downTouch.hitBox!=null) downTouch.hitBox.render();
      fill(0, 255, 0);
      if (leftTouch.hitBox!=null) leftTouch.hitBox.render();
      fill(0, 0, 255);
      if (rightTouch.hitBox!=null) rightTouch.hitBox.render();
    }

    if (upTouch.id == 6 || downTouch.id == 6 || leftTouch.id == 6 || rightTouch.id == 6) {
      timeStep*=1.5;
    }

    if (jumpTimer==0) {
      if (downTouch.id == 6 || downTouch.id==3) {
        if (this.arrows[0]==1) {
          this.vel.set(new PVector(this.vel.x, (-tileSize/(5f*1.5))));
          jumpTimer=1000;
        }
      }
      if (downTouch.isSolid()) {
        if (this.arrows[0]==0) {
          if (downTouch.id==4) {
            this.vel.set(new PVector(this.vel.x, this.vel.y*-0.66f));
          } else {
            this.vel.set(new PVector(this.vel.x, 0));
          }
        } else {
          if (upTouch.id == 6 || downTouch.id == 6 || leftTouch.id == 6 || rightTouch.id == 6) {
            this.vel.set(new PVector(this.vel.x, (-tileSize/(5f*1.5))));
          } else {
            if (downTouch.id==4) {
              this.vel.set(new PVector(this.vel.x, (-tileSize/3f)));
            } else {
              this.vel.set(new PVector(this.vel.x, (-tileSize/4f)));
            }
          }
          jumpTimer=2000;
        }
      } else {
        this.vel.add(new PVector(0, (tileSize/64f/timeStep)));
      }
    } else {
      jumpTimer--;
    }

    if (upTouch.isCollidable()) {
      if (upTouch.id==9 && canToggle) {
        onoffstate = !onoffstate;
        toggle.play();
      }
      canToggle=false;
      float dist = (upTouch.hitBox.y+upTouch.hitBox.h)-upHit.y;
      this.vel.set(new PVector(this.vel.x, dist));
      this.vel.add(new PVector(0, 0.01));
    } else {
      canToggle=true;
    }

    if (this.arrows[3]==1) {
      this.vel.add(new PVector(-tileSize/1024f, 0));
    }

    if (this.arrows[2]==1) {
      this.vel.add(new PVector(tileSize/1024f, 0));
    }

    if (rightTouch.isCollidable()) {
      if (this.arrows[3]==0) {
        if (jumpTimer==0 || this.vel.x>=-1e-5)
          this.vel.set(new PVector(0, this.vel.y));
        else if (jumpTimer>0)
          this.vel.set(new PVector(-tileSize, this.vel.y));
      } else {
        this.vel.add(new PVector(-tileSize/512f, 0));
      }
      if (this.arrows[0]==1&&jumpTimer==0) {
        this.vel.set(new PVector(-tileSize/512f, (-tileSize/5f)));
        jumpTimer=2000;
      }
    }

    if (leftTouch.isCollidable()) {
      if (this.arrows[2]==0) {
        if (jumpTimer==0 || this.vel.x<=1e-5)
          this.vel.set(new PVector(0, this.vel.y));
        else if (jumpTimer>0)
          this.vel.set(new PVector(tileSize, this.vel.y));
      } else {
        this.vel.add(new PVector(tileSize/512f, 0));
      }
      if (this.arrows[0]==1&&jumpTimer==0) {
        this.vel.set(new PVector(tileSize/512f, (-tileSize/5f)));
        jumpTimer=2000;
      }
    }

    if (upTouch.isCollidable()) {
      float dist = (upTouch.hitBox.y+upTouch.hitBox.h)-upHit.y;
      this.vel.set(new PVector(this.vel.x, dist));
      this.vel.add(new PVector(0, 0.01));
    }
    if (upTouch.id == 6 || downTouch.id == 6 || leftTouch.id == 6 || rightTouch.id == 6) {
      this.vel.x*=0.90;
    } else {
      this.vel.x*=0.99;
    }
    this.pos.y += this.vel.y/timeStep;
    this.pos.x += this.vel.x/timeStep;
    for (Tile t : collide) {
      if (upHit.isTouching(t.hitBox) && t.isCollidable() && upTouch.id == -1) upTouch=t;
      if (downHit.isTouching(t.hitBox) && t.isCollidable() && downTouch.id == -1) downTouch=t;
      if (leftHit.isTouching(t.hitBox) && t.isCollidable() && leftTouch.id== -1) leftTouch=t;
      if (rightHit.isTouching(t.hitBox) && t.isCollidable() && rightTouch.id == -1) rightTouch=t;
    }

    if (upTouch.id == 3 || downTouch.id == 3 || leftTouch.id == 3 || rightTouch.id == 3) {
      kill.add(this);
    }

    if (debug) {
      fill(255);
      rect(upHit.x+scrollX, upHit.y+scrollY, upHit.w, upHit.h);
      fill(255, 0, 0);
      rect(downHit.x+scrollX, downHit.y+scrollY, downHit.w, downHit.h);
      fill(0, 255, 0);
      rect(leftHit.x+scrollX, leftHit.y+scrollY, leftHit.w, leftHit.h);
      fill(0, 0, 255);
      rect(rightHit.x+scrollX, rightHit.y+scrollY, rightHit.w, rightHit.h);
    }
  }
}
