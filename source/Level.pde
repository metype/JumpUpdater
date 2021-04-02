class Level {
  Tile[][] t;
  public Level(Boolean... code) {
  }


  public Level(int scrX, int scrY) {
    t = new Tile[scrX*15][scrY*11];
    for (int i=0; i<scrX*15; i++) {
      for (int j=0; j<scrY*11; j++) {
        if (i==0||j==0||i==scrX*15-1||j==scrY*11-1)
          t[i][j]= new Tile(1);
        else
          t[i][j]= new Tile(0);
      }
    }
  }

  public void render(float x, float y, Tile... highlight) {
    for (int i=0; i<t.length; i++) {
      for (int j=0; j<t[i].length; j++) {
        int[] visible = {1, 2, 4, 5, 9, 1, 1};
        if (t[i][j].id!=1) {
          visible[5]=3;
          visible[6]=6;
        }
        t[i][j].setHitBox(new Rect(x+(i*tileSize), y+(j*tileSize), tileSize, tileSize));
        Boolean[] b = new Boolean[12];
        if (i==0||j==0)b[0]=true;
        else if (Index.findIndex(visible, t[i-1][j-1].id)!=-1)b[0]=true;
        else b[0]=false;

        if (j==0)b[1]=true;
        else if (Index.findIndex(visible, t[i][j-1].id)!=-1)b[1]=true;
        else b[1]=false;

        if (i==t.length-1||j==0)b[2]=true;
        else if (Index.findIndex(visible, t[i+1][j-1].id)!=-1)b[2]=true;
        else b[2]=false;

        if (i==t.length-1)b[3]=true;
        else if (Index.findIndex(visible, t[i+1][j].id)!=-1)b[3]=true;
        else b[3]=false;

        if (i==t.length-1||j==t[i].length-1)b[4]=true;
        else if (Index.findIndex(visible, t[i+1][j+1].id)!=-1)b[4]=true;
        else b[4]=false;

        if (j==t[i].length-1)b[5]=true;
        else if (Index.findIndex(visible, t[i][j+1].id)!=-1)b[5]=true;
        else b[5]=false;

        if (i==0||j==t[i].length-1)b[6]=true;
        else if (Index.findIndex(visible, t[i-1][j+1].id)!=-1)b[6]=true;
        else b[6]=false;

        if (i==0)b[7]=true;
        else if (Index.findIndex(visible, t[i-1][j].id)!=-1)b[7]=true;
        else b[7]=false;

        if (i==0)b[8]=true;
        else if (t[i-1][j].id==3)b[8]=true;
        else b[8]=false;

        if (i==t.length-1)b[9]=true;
        else if (t[i+1][j].id==3)b[9]=true;
        else b[9]=false;

        if (i==0)b[10]=true;
        else if (t[i-1][j].id==6)b[10]=true;
        else b[10]=false;

        if (i==t.length-1)b[11]=true;
        else if (t[i+1][j].id==6)b[11]=true;
        else b[11]=false;

        t[i][j].render(i, j, b);
      }
    }
    for (int i=0; i<t.length; i++) {
      for (int j=0; j<t[i].length; j++) {
        for (Tile tile : highlight) {
          if (t[i][j]==tile) {
            noFill();
            stroke(255);
            strokeWeight(2);
            rect(t[i][j].hitBox.x, t[i][j].hitBox.y, t[i][j].hitBox.w, t[i][j].hitBox.w);
            strokeWeight(1);
          }
        }
      }
    }
  }
}

class Tile {
  int id = 0;
  Rect hitBox;
  float angle = 0;
  String text = "";
  long timer = 0;
  int limit=3;
  int spawned=0;
  int spawnDelay=1000;

  public Tile(int id) {
    this.id=id;
  }

  public void setHitBox(Rect r) {
    this.hitBox=r;
  }

  public boolean isCollidable() {
    int[] colliding = {1, 4, 5, 9, 1, 3, 6, 2};
    if (onoffstate) {
      colliding[4]=10;
    } else {
      colliding[4]=11;
    }
    return Index.findIndex(colliding, id)!=-1;
  }

  public boolean isSolid() {
    int[] colliding = {1, 4, 5, 9, 1, 2};
    if (onoffstate) {
      colliding[4]=10;
    } else {
      colliding[4]=11;
    }
    return Index.findIndex(colliding, id)!=-1;
  }

  public void render(int x, int y, Boolean... surrounded) {
    noStroke();
    if (!hitBox.isTouching(new Rect(-hitBox.w, -hitBox.w, width+hitBox.w*2, height+hitBox.w*2)))
      return;
    push();
    translate(hitBox.x+hitBox.w/2, hitBox.y+hitBox.w/2);
    rotate(angle);
    translate(-hitBox.w/2, -hitBox.w/2);
    switch(this.id) {
      case(0):
      break;
      case(1):
      fill(0);
      /*
       0 - tl
       1 - t
       2 - tr
       3 - r
       4 - br
       5 - b
       6 - bl
       7 - l
       8 - Lava Left
       9 - Lava Right
       10 - Water Left
       11 - Water Right
       */
      if (surrounded.length>0) {
        if (surrounded.length>8)
          if (surrounded[8]|surrounded[10]) {
            if (surrounded[8]) fill(#FF0000);
            else  fill(#0A67FF);
            if (!surrounded[1]) {
              beginShape();
              vertex(hitBox.w/2, hitBox.w);
              vertex(0, hitBox.w);
              for (int i=0; i<15; i+=1) {
                float off=0;
                vertex(
                  map(i, 0, 14, 0, hitBox.w/2), (off+ sin((hitBox.x+map(i, 0, 14, 0, hitBox.w/2))/5+frameCount/5f)+1)*5);
              }
              endShape();
            }
          }
        if (surrounded.length>8)
          if (surrounded[9]|surrounded[11]) {
            if (surrounded[9]) fill(#FF0000);
            else  fill(#0A67FF);
            if (!surrounded[1]) {
              beginShape();
              vertex(hitBox.w, hitBox.w);
              vertex(hitBox.w/2, hitBox.w);
              for (int i=0; i<15; i+=1) {
                float off=0;
                vertex(
                  map(i, 0, 14, hitBox.w/2, hitBox.w), (off+ sin((hitBox.x+map(i, 0, 14, hitBox.w/2, hitBox.w))/5+frameCount/5f)+1)*5);
              }
              endShape();
            }
          }
        fill(0);
        rect(0, 0, hitBox.w, hitBox.w, (!surrounded[0] && !surrounded[7] && !surrounded[1])?15:0, (!surrounded[2] && !surrounded[3] && !surrounded[1])?15:0, (!surrounded[4] && !surrounded[5] && !surrounded[3])?15:0, (!surrounded[6] && !surrounded[5] && !surrounded[7])?15:0);
      } else {
        rect(0, 0, hitBox.w, hitBox.w);
      }
      fill(100);
      noStroke();
      int num = 16;
      break;
      case(2):
      fill(255, 255, 0);
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(3):
      fill(255, 0, 0);
      if (surrounded.length>0) {
        if (!surrounded[1]) {
          beginShape();
          vertex(hitBox.w, hitBox.w);
          vertex(0, hitBox.w);
          for (int i=0; i<31; i+=1) {
            float off=0;
            vertex(
              map(i, 0, 30, 0, hitBox.w), (off+ sin((hitBox.x+map(i, 0, 30, 0, hitBox.w))/5+frameCount/5f)+1)*5);
          }
          endShape();
          break;
        }
      }
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(4):
      fill(#1BDE22);
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(5):
      fill(#1B67DE);
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(6):
      fill(#0A67FF);
      if (surrounded.length>0) {
        if (!surrounded[1]) {
          beginShape();
          vertex(hitBox.w, hitBox.w);
          vertex(0, hitBox.w);
          for (int i=0; i<31; i+=1) {
            float off=0;
            vertex(
              map(i, 0, 30, 0, hitBox.w), (off+ sin((hitBox.x+map(i, 0, 30, 0, hitBox.w))/5+frameCount/5f)+1)*5);
          }
          endShape();
          break;
        }
      }
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(7):
      if (GameMode!=Mode.LevelEditor && GameMode!=Mode.EditorInventory) {
        pop();
        return;
      }
      fill(#946E9D);
      rect(0, 0, hitBox.w, hitBox.w);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(hitBox.w/2);
      text("S", hitBox.w/2, hitBox.w/2);
      break;
      case(8):
      if (GameMode!=Mode.LevelEditor && GameMode!=Mode.EditorInventory) {
        pop();
        return;
      }
      fill(#946E9D);
      rect(0, 0, hitBox.w, hitBox.w);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(hitBox.w/2);
      text("C", hitBox.w/2, hitBox.w/2);
      break;
      case(9):
      stroke(0);
      strokeWeight(3);
      if (onoffstate) {
        fill(#7502A0);
        rect(0, 0, hitBox.w, hitBox.w);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(hitBox.w/2);
        text("ON", hitBox.w/2, hitBox.w/2);
      } else {
        fill(#1A78D3);
        rect(0, 0, hitBox.w, hitBox.w);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(hitBox.w/2);
        text("OFF", hitBox.w/2, hitBox.w/2);
      }
      break;
      case(10):
      stroke(0);
      strokeWeight(3);
      if (onoffstate) {
        fill(#7502A0);
        rect(0, 0, hitBox.w, hitBox.w);
      } else {
        stroke(#7502A0);
        fill(0, 0);
        rect(0, 0, hitBox.w, hitBox.w);
      }
      break;
      case(11):
      stroke(0);
      strokeWeight(3);
      if (!onoffstate) {
        fill(#1A78D3);
        rect(0, 0, hitBox.w, hitBox.w);
      } else {
        stroke(#1A78D3);
        fill(0, 0);
        rect(0, 0, hitBox.w, hitBox.w);
      }
      break;
      case(12):
      textAlign(LEFT, CENTER);
      if (text.equalsIgnoreCase("")) {
        fill(100);
        textSize(tileSize/3);
        text("ABC...", 0, hitBox.w/2);
        break;
      }
      fill(0);
      textSize(tileSize/3);
      text(this.text, 0, hitBox.w/2);
      break;
      case(13):
      fill(#0A67FF);
      if (surrounded.length>0) {
        if (!surrounded[1]) {
          beginShape();
          vertex(hitBox.w, hitBox.w);
          vertex(0, hitBox.w);
          for (int i=0; i<31; i+=1) {
            float off=0;
            vertex(
              map(i, 0, 30, 0, hitBox.w), ((off+ sin((hitBox.x+map(i, 0, 30, 0, hitBox.w))/5+frameCount/5f)+1)*5)+((hitBox.w/3)*2));
          }
          endShape();
          break;
        }
      }
      rect(0, 0, hitBox.w, hitBox.w);
      break;
      case(14):
      if (limit==0) spawned=-1;
      if (timer+spawnDelay<System.currentTimeMillis() && GameMode == Mode.MainGame && spawned < limit) {
        Enemy e = new Enemy(0, 0);
        e.spawn(x*tileSize, y*tileSize);
        enemies.add(e);
        timer=System.currentTimeMillis();
        spawned++;
      }
      if (GameMode!=Mode.LevelEditor && GameMode!=Mode.EditorInventory) {
        pop();
        return;
      }
      fill(#946E9D);
      rect(0, 0, hitBox.w, hitBox.w);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(hitBox.w/2);
      text("G", hitBox.w/2, hitBox.w/2);
      break;
    }
    //fill(0);
    //textAlign(CENTER, CENTER);
    //textSize(hitBox.w/2);
    //text(this.id, hitBox.w/2, hitBox.w/2);
    pop();
  }
}

public static class Index {

  // Linear-search function to find the index of an element
  public static int findIndex(Object arr[], Object t)
  {

    // if array is Null
    if (arr == null) {
      return -1;
    }

    // find length of array
    int len = arr.length;
    int i = 0;

    // traverse in the array
    while (i < len) {

      // if the i-th element is t
      // then return the index
      if (arr[i].equals(t)) {
        return i;
      } else {
        i = i + 1;
      }
    }
    return -1;
  }

  public static int findIndex(int arr[], int t)
  {

    // if array is Null
    if (arr == null) {
      return -1;
    }

    // find length of array
    int len = arr.length;
    int i = 0;

    // traverse in the array
    while (i < len) {

      // if the i-th element is t
      // then return the index
      if (arr[i] == t) {
        return i;
      } else {
        i = i + 1;
      }
    }
    return -1;
  }
}
