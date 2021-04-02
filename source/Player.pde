class Player {
  PVector pos;
  PVector vel;
  Rect upHit, leftHit, downHit, rightHit;
  int[] standAble = {1, 2, 3, 4, 5, 6};
  int jumpTimer = 0;
  boolean canToggle = false;
  float respawnTimer = 0;
  float levelCooldown = 0;

  public Player(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
  }

  public void render() {
    levelCooldown--;
    fill(51);
    stroke(0);
    float size=tileSize/2;
    if (respawnTimer>0) {
      size = map(respawnTimer, 100, 0, tileSize/2, 0);
    }
    rect(width/2-(size/2), height/2-(size/2), size, size);
    if (respawnTimer==1) {
      loadLevel(levelPack.getJSONObject(level));
      println("Respawning...");
      onoffstate=true;
      pos.x = respawnPos.x;
      pos.y = respawnPos.y;
      pos.mult(tileSize);
      pos.x+=tileSize/2;
      pos.y+=tileSize-(tileSize/4);
      this.vel = new PVector(0, 0);
      respawnTimer--;
    } else {
      respawnTimer-=3;
    }
  }

  public void respawn(boolean ded) {
    if (godMode && ded) return;
    fade=200;
    respawnTimer = 100;
    if (ded) {
      deaths++;
      death.stop();
      death.play();
    }
  }

  public void updatePhysics(ArrayList<Tile> collide, int timeStep) {
    if (this.pos.y>(currentLevel.t[0].length*tileSize) && respawnTimer<=0) respawn(true);
    scrollX=-pos.x+(width/2);
    scrollY=-pos.y+(height/2);
    jumpTimer--;
    jumpTimer = max(jumpTimer, 0);
    upHit = new Rect(width/2-(tileSize/4)+(tileSize/9), height/2-(tileSize/4), tileSize/2-(tileSize/9)*2, tileSize/9);
    downHit = new Rect(width/2-(tileSize/4)+(tileSize/9), height/2-(tileSize/4)+(tileSize/2)-(tileSize/9), tileSize/2-(tileSize/9)*2, tileSize/9);
    leftHit = new Rect(width/2-(tileSize/4), height/2-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
    rightHit = new Rect(width/2-(tileSize/4)+(tileSize/2)-(tileSize/9), height/2-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
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

    if ((upTouch.id == 2 || downTouch.id == 2 || leftTouch.id == 2 || rightTouch.id == 2) && levelCooldown<=0) {
      levelCooldown = 50;
      levelPack.getJSONObject(level).setBoolean("completed", true);
      level++;
      if (level>=levelPack.size()) {
        if (story) {
          saveJSONArray(levelPack, "levels/defaultPack.savepack");
        }
        complete.stop();
        complete.play();
        end = System.currentTimeMillis();
        setMode(Mode.CompletionStats);
        return;
      }
      win.stop();
      win.play();
      respawn(false);
    }

    if (jumpTimer==0) {
      if (downTouch.id == 6 || downTouch.id==3) {
        if (arrows[0]==1) {
          this.vel.set(new PVector(this.vel.x, (-tileSize/(5f*1.5))));
          jumpTimer=1000;
        }
      }
      if (downTouch.isSolid()) {
        if (arrows[0]==0) {
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


    if (arrows[3]==1) {
      this.vel.add(new PVector(-tileSize/512f, 0));
    }

    if (arrows[2]==1) {
      this.vel.add(new PVector(tileSize/512f, 0));
    }

    if (rightTouch.isCollidable()) {
      if (arrows[3]==0) {
        if (jumpTimer==0 || this.vel.x>=-1e-5)
          this.vel.set(new PVector(0, this.vel.y));
        else if (jumpTimer>0)
          this.vel.set(new PVector(-tileSize, this.vel.y));
      } else {
        this.vel.add(new PVector(-tileSize/512f, 0));
      }
      if (arrows[0]==1&&jumpTimer==0) {
        this.vel.set(new PVector(-tileSize/512f, (-tileSize/5f)));
        jumpTimer=2000;
      }
    }

    if (leftTouch.isCollidable()) {
      if (arrows[2]==0) {
        if (jumpTimer==0 || this.vel.x<=1e-5)
          this.vel.set(new PVector(0, this.vel.y));
        else if (jumpTimer>0)
          this.vel.set(new PVector(tileSize, this.vel.y));
      } else {
        this.vel.add(new PVector(tileSize/512f, 0));
      }
      if (arrows[0]==1&&jumpTimer==0) {
        this.vel.set(new PVector(tileSize/512f, (-tileSize/5f)));
        jumpTimer=2000;
      }
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

    //println(this.vel);

    //this.vel.limit(tileSize);
    if (upTouch.id == 6 || downTouch.id == 6 || leftTouch.id == 6 || rightTouch.id == 6) {
      this.vel.x*=0.90;
    } else {
      this.vel.x*=0.99;
    }
    this.pos.y += this.vel.y/timeStep;
    this.pos.x += this.vel.x/timeStep;
    scrollX=-pos.x+(width/2);
    scrollY=-pos.y+(height/2);
    if (respawnTimer<=-1)
      for (Tile t : collide) {
        if (upHit.isTouching(t.hitBox) && t.isCollidable() && upTouch.id == -1) upTouch=t;
        if (downHit.isTouching(t.hitBox) && t.isCollidable() && downTouch.id == -1) downTouch=t;
        if (leftHit.isTouching(t.hitBox) && t.isCollidable() && leftTouch.id== -1) leftTouch=t;
        if (rightHit.isTouching(t.hitBox) && t.isCollidable() && rightTouch.id == -1) rightTouch=t;
      }

    if (upTouch.id == 3 || downTouch.id == 3 || leftTouch.id == 3 || rightTouch.id == 3) {
      respawn(true);
    }

    if (debug) {
      fill(255);
      rect(upHit.x, upHit.y, upHit.w, upHit.h);
      fill(255, 0, 0);
      rect(downHit.x, downHit.y, downHit.w, downHit.h);
      fill(0, 255, 0);
      rect(leftHit.x, leftHit.y, leftHit.w, leftHit.h);
      fill(0, 0, 255);
      rect(rightHit.x, rightHit.y, rightHit.w, rightHit.h);
    }

    for (Enemy e : enemies) {
      Rect enemyHit = new Rect(e.pos.x, e.pos.y, tileSize/2, tileSize/2);
      downHit = new Rect(pos.x-(tileSize/4)+(tileSize/9), pos.y-(tileSize/4)+(tileSize/2)-(tileSize/9), tileSize/2-(tileSize/9)*2, tileSize/9);
      leftHit = new Rect(pos.x-(tileSize/4), pos.y-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
      rightHit = new Rect(pos.x-(tileSize/4)+(tileSize/2)-(tileSize/9), pos.y-(tileSize/4)+(tileSize/9), tileSize/9, tileSize/2-(tileSize/9)*2);
      upHit = new Rect(pos.x-(tileSize/4)+(tileSize/9), pos.y-(tileSize/4), tileSize/2-(tileSize/9)*2, tileSize/9);
      if (downHit.isTouching(enemyHit)) {
        kill.add(e);
        continue;
      }
      if (upHit.isTouching(enemyHit) || rightHit.isTouching(enemyHit) || leftHit.isTouching(enemyHit)) {
        respawn(true);
      }
    }
  }
}
