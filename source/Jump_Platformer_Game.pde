import java.util.concurrent.TimeUnit;
import static javax.swing.JOptionPane.*;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.DisplayMode;
import java.awt.GridBagLayout;
import java.awt.Window;
import java.awt.Graphics2D;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.Container;
import java.awt.Canvas;
import java.awt.Color;
import java.io.PrintWriter;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.util.*;
import java.lang.reflect.*;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import processing.sound.*;

SoundFile death;
SoundFile win;
SoundFile toggle;
SoundFile button;
SoundFile complete;

Mode GameMode = Mode.Launcher;
Mode ReturnMode = Mode.LevelEditor;
Player p;
RadioButtonList resList;
RadioButtonList fullResList;
CheckBox fullScreenBox;
Tile editTile;
ArrayList<Enemy> enemies = new ArrayList();
ArrayList<Enemy> kill = new ArrayList();

byte[] arrows = new byte[5];

boolean click = false;
boolean debug = false;
boolean onoffstate = true;
boolean godMode = false;
boolean story=false;

String version = "";
String defRes = "";
String saveFilePath = "";
JSONArray levelPack;

JSONObject settings;

PImage eraser;

float scrollX=0;
float scrollY=0;
float vol = 0;

int tileSize = 0;
int selectedTile = 0;
int scrX = 40;
int[][] inventoryTiles = {{1, 2, 4, 5}, {6, 13, 3}, {7, 8, 14}, {9, 10, 11}, {12}};
int selectedWidth = 1;
int selectedHeight = 1;
int level=0;
int deaths=0;
int fade = 0;
int scrollArb1=0;
int scrollArb2=0;
int scrollArb3=0;

long time=0;
long end=0;

PFont gameFont;

PVector respawnPos = new PVector(0, 0);

Level currentLevel;
File[] levels;

void settings() {
  PVector midRange = new PVector(0, 0);
  for (float x=800; x<=displayWidth; x+=10) {
    for (float y=600; y<=displayHeight; y+=10) {
      if (x/y == 4f/3) {
        if (x>(displayWidth/2)-(displayWidth/5) && x<(displayWidth/2)+(displayWidth/5) && y>(displayHeight/2)-(displayWidth/5) && y<(displayHeight/2)+(displayWidth/5)) {
          midRange = new PVector(x, y);
        }
      }
    }
  }
  size((int)midRange.x, (int)midRange.y);
  settings = loadJSONObject("settings.json");
  version = settings.getString("version");
  defRes = settings.getString("defRes");
  gameFont = loadFont("Cambria-BoldItalic-48.vlw");
  death = new SoundFile(this, "death.wav");
  win = new SoundFile(this, "win.wav");
  toggle = new SoundFile(this, "click.wav");
  complete = new SoundFile(this, "complete.wav");
  button = new SoundFile(this, "button.wav");
}

void setup() {
  surface.setTitle("Jump! - A Launch Screen");
  resList = new RadioButtonList();
  fullResList = new RadioButtonList();
  textFont(gameFont);
  int i=0;
  int j=0;
  int k=0;
  for (float x=800; x<=displayWidth; x+=10) {
    for (float y=600; y<=displayHeight; y+=10) {
      if (x/y == 4f/3 || x/y == 16f/9) {
        textSize(20);
        String name = int(x)+"x"+int(y)+ " ("+((x/y == 4f/3)?"4:3":"16:10")+")";
        if (name.equalsIgnoreCase(defRes))
          resList.add(new RadioButton(new Rect(10 + (250*j), 6+(34*i), 40 + textWidth(name), 32), name, true));
        else
          resList.add(new RadioButton(new Rect(10 + (250*j), 6+(34*i), 40 + textWidth(name), 32), name));
        i++;
        if (x==displayWidth || y == displayHeight) {
          if (name.equalsIgnoreCase(defRes))
            fullResList.add(new RadioButton(new Rect(10, 6+(34*k), 40 + textWidth(name), 32), name, true));
          else
            fullResList.add(new RadioButton(new Rect(10, 6+(34*k), 40 + textWidth(name), 32), name));
          k++;
        }
        if (i>10) {
          i=0;
          j++;
        }
      }
    }
  }
  boolean any = false;
  for (RadioButton r : fullResList.buttons)if (r.state) any=true;
  if (!any) {
    fullResList.buttons.get(0).state=true;
    fullResList.buttons.get(0).enableTime=System.currentTimeMillis();
  }
  println(fullResList.buttons.get(0).state);
  any = false;
  for (RadioButton r : resList.buttons)if (r.state) any=true;
  if (!any) {
    resList.buttons.get(0).state=true;
    resList.buttons.get(0).enableTime=System.currentTimeMillis();
  }
  surface.setResizable(false);
  tileSize = floor(height/11);
  eraser = loadImage("eraser.png");
  eraser.resize(60, 60);
  p = new Player(0, 0);
  fullScreenBox = new CheckBox(new Rect(20, height-50, 75, 50), "Fullscreen");
  try {
    fullScreenBox.state = settings.getBoolean("fullscreen");
  }
  catch(NullPointerException ignored) {
  }
  float amp = settings.getFloat("amp");
  complete.amp(amp);
  toggle.amp(amp);
  death.amp(amp);
  win.amp(amp);
  button.amp(amp);
}

void draw() {
  fade-=3;
  float menuButtonWidth = width/2.7;
  float titleTextSize = width/30;
  float subTitleTextSize = width/50;
  if (GameMode != Mode.LevelEditor && GameMode != Mode.EditorInventory && GameMode != Mode.SaveLevel && GameMode != Mode.LoadLevel && GameMode != Mode.EditTile) {
    tileSize = floor(height/11);
  }
  if (GameMode!=Mode.MainGame) {
    story=false;
    enemies.clear();
  }
  background(151);
  strokeWeight(1);
  switch(GameMode) {
  case Launcher:
    (new Button(new Rect(width-100, height-75, 75, 50), "launchGame", "Launch Game", this)).render();
    fullScreenBox.render();
    fill(255);
    rect(10, 380, width-20, 20);
    fill(100);
    rect(scrX-30, 380, 60, 20);
    if (mousePressed && (new Rect(10, 380, width-20, 20)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
      scrX=mouseX;
      scrX = max(scrX, 40);
      scrX = min(scrX, width-40);
    }
    push();
    if (fullScreenBox.state) {
      if ((10 + (250*(fullResList.buttons.size()/10)))>width)
        fullResList.offset(map(scrX, 40, width-40, 0, width-(10 + (250*((fullResList.buttons.size()/10)+1)))), 0);
      fullResList.render();
    } else {
      if ((10 + (250*(resList.buttons.size()/10)))>width)
        resList.offset(map(scrX, 40, width-40, 0, width-(10 + (250*((resList.buttons.size()/10)+1)))), 0);
      resList.render();
    }
    pop();
    break;
  case LoadLevelPack:
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    text("Jump!", width/2, height/16);
    textSize(subTitleTextSize);
    text("A Platforming Game", width/2, (height/16)+64);
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + height/20)*2, menuButtonWidth, height/10), width/40, "beginPack", "Main \"Story\"", this, "/levels/defaultPack.savepack")).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + height/20), menuButtonWidth, height/10), width/40, "setModeClear", "Editor", this, Mode.EditorMenu)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2), menuButtonWidth, height/10), width/40, "setModeClear", "Options", this, Mode.Options)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)+(height/10 + height/20), menuButtonWidth, height/10), width/40, "setMode", "Custom Levels", Mode.SelectFile, Mode.LoadLevelPack)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)+(height/10 + height/20)*2, menuButtonWidth, height/10), width/40, "exit", "Exit Game", this)).render();
    fill(150, 220);
    rect(0, 0, width, height);
    if (saveFilePath == null) {
      setMode(Mode.MainMenu);
      break;
    }
    if (saveFilePath.equals("")) {
      break;
    }
    beginPack(saveFilePath);
    setMode(Mode.MainGame);
    saveFilePath="";
    break;
  case MainMenu:
    story=false;
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Jump!", width/2, height/16);
    textSize(subTitleTextSize);
    text("A Platforming Game", width/2, (height/16)+64);
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + height/20)*2, menuButtonWidth, height/10), width/40, "setMode", "Main \"Story\"", this, Mode.LevelSelect, Mode.MainGame)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + height/20), menuButtonWidth, height/10), width/40, "setModeClear", "Editor", this, Mode.EditorMenu)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2), menuButtonWidth, height/10), width/40, "setModeClear", "Options", this, Mode.Options)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)+(height/10 + height/20), menuButtonWidth, height/10), width/40, "loadPack", "Custom Levels", this)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)+(height/10 + height/20)*2, menuButtonWidth, height/10), width/40, "exit", "Exit Game", this)).render();
    break;
  case Options:
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Options", width/2, height/16);
    textSize(subTitleTextSize);
    text("A Settings Screen", width/2, (height/16)+64);
    fill(255);
    rect(width/10, height/4, width-width/5, height/16);
    fill(100);
    rect(vol, height/4, width/30, height/16);
    fill(100);
    rect(width/2-width/20, height/4+height/16+height/16, width/10, width/10);
    if (mousePressed && (new Rect(width/10, height/4, width-width/5, height/16)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
      vol=mouseX;
      vol = max(vol, width/10);
      vol = min(vol, width-width/5+width/10-width/30);
    }
    if (click && (new Rect(width/2-width/20, height/4+height/16+height/16, width/10, width/10)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
      float rand = random(1);
      if (rand<0.2) complete.play();
      else if (rand<0.4) toggle.play();
      else if (rand<0.6) death.play();
      else if (rand<0.8) win.play();
      else button.play();
    }
    float amp = map(vol, width/10, width-width/5+width/10-width/30, 0, 1);
    complete.amp(amp);
    toggle.amp(amp);
    death.amp(amp);
    win.amp(amp);
    button.amp(amp);
    textAlign(LEFT, TOP);
    fill(0);
    text("Volume : " + round(amp*100) +"%", width/10, height/4-height/32);
    settings.setFloat("amp", amp);
    saveJSONObject(settings, "data/settings.json");
    (new Button(new Rect((width/2)-((width/5)/2), height-(height/10)-15, width/5, height/10), width/40, "setModeClear", "Back", this, Mode.MainMenu)).render();
    break;
  case CompletionStats:
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Stats", width/2, height/16);
    textSize(subTitleTextSize);
    text("For What You Just Did", width/2, (height/16)+64);
    (new Button(new Rect((width/2)-((width/3)/2), height-(height/10)-15, width/3, height/10), width/40, "setModeClear", "Back To Menu", this, Mode.MainMenu)).render();
    textSize(width/20);
    text("Completion Time : " + convertTime(time), width/2, height/3);
    text("Death Count : " + deaths, width/2, height/3+height/3);
    break;
  case LevelSelect:
    //beginPack("/levels/defaultPack.savepack");
    if (levelPack==null) {
      levelPack = loadJSONArray("/levels/defaultPack.savepack");
      story=true;
    }
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Jump!", width/2, height/16);
    textSize(subTitleTextSize);
    text("Select A Level", width/2, (height/16)+64);
    int ja=0;
    for (int i=0; i<levelPack.size(); i++) {
      rectMode(CENTER);
      ja=floor(i/8);
      boolean hover = false;
      try {
        hover = (new Rect((i%8*width/8 + width/16) - width/20, (ja*(width/8)+height/3) - width/20, width/10, width/10)).isTouching(new Rect(mouseX, mouseY, 1, 1)) && (levelPack.getJSONObject(i-1).getBoolean("completed"));
      }
      catch(Exception e) {
        hover = (new Rect((i%8*width/8 + width/16) - width/20, (ja*(width/8)+height/3) - width/20, width/10, width/10)).isTouching(new Rect(mouseX, mouseY, 1, 1));
      }
      if (hover) {
        fill(150);
        if (mousePressed) {
          fade=200;
          fill(100);
          level = i;
          loadLevel(levelPack.getJSONObject(i));
          setMode(ReturnMode);
          p.levelCooldown=100;
          p.respawn(false);
          time=System.currentTimeMillis();
        }
      } else
        fill(200);
      strokeWeight(1);
      rect(i%8*width/8 + width/16, ja*(width/8)+height/3, width/10, width/10);
      textAlign(CENTER, CENTER);
      fill(0);
      textSize(width/50);
      try {
        text(levelPack.getJSONObject(i).getString("name"), i%8*width/8 + width/16, ja*(width/8)+height/3);
      }
      catch(Exception e) {
        text("Untitled", i%8*width/8 + width/16, ja*(width/8)+height/3);
      }
      try {
        if (!levelPack.getJSONObject(i-1).getBoolean("completed")) {
          fill(100);
          stroke(0);
          rect(i%8*width/8 + width/16, ja*(width/8)+height/3, width/10, width/10);
          fill(150, 0, 0);
          stroke(150, 0, 0);
          strokeWeight(2);
          line((i%8*width/8 + width/16) - width/20, (ja*(width/8)+height/3) - width/20, (i%8*width/8 + width/16) - width/20+width/10, (ja*(width/8)+height/3) - width/20+width/10);
        }
      }
      catch(Exception ignored) {
        println(i);
      }
    }
    rectMode(CORNER);
    break;
  case SelectFile:
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Select File", width/2, height/16);
    textSize(subTitleTextSize);
    text("A File Browser", width/2, (height/16)+64);
    if (levels==null) {
      File f = new File(sketchPath()+"/levels");
      FilenameFilter filter = new FilenameFilter() {
        @Override
          public boolean accept(File f, String name) {
          return name.endsWith(".save") || name.endsWith(".savepack");
        }
      };
      levels = f.listFiles(filter);
    }
    for (int i=0; i<levels.length; i++) {
      File f = levels[i];
      rectMode(CENTER);
      if ((new Rect(width/2-width/4, i*(height/16)+((height/16)+128)-(height/40), width/2, height/20)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
        fill(150);
        if (mousePressed) {
          fill(100);
          levelPack = loadJSONArray(f.getAbsolutePath());
          setMode(Mode.LevelSelect, ReturnMode);
        }
      } else
        fill(200);
      rect(width/2, i*(height/16)+((height/16)+128), width/2, height/20);
      textAlign(CENTER, CENTER);
      fill(0);
      text(f.getName(), width/2, i*(height/16)+((height/16)+128));
    }
    rectMode(CORNER);
    break;
  case EditorMenu:
    textAlign(CENTER, CENTER);
    textSize(titleTextSize);
    fill(0);
    text("Jump!", width/2, height/16);
    textSize(subTitleTextSize);
    text("The Editor", width/2, (height/16)+64);
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + 15)*2, menuButtonWidth, height/10), width/40, "beginPack", "Create A Level Pack", this, "default")).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2)-(height/10 + 15), menuButtonWidth, height/10), width/40, "setModeClear", "Create A New Level", this, Mode.LevelEditor)).render();
    (new Button(new Rect((width/2)-(menuButtonWidth/2), (height/2), menuButtonWidth, height/10), width/40, "setMode", "Load A Level/Pack From File", this, Mode.SelectFile, Mode.LevelEditor)).render();
    (new Button(new Rect((width/2)-((width/5)/2), height-(height/10)-15, width/5, height/10), width/40, "setModeClear", "Back", this, Mode.MainMenu)).render();
    break;
  case MainGame:
    if (currentLevel!=null) {
      currentLevel.render(scrollX, scrollY);
      p.render();
      for (Enemy e : enemies) {
        e.render();
        e.AI(p);
      }
      if (p.respawnTimer<=0) {
        for (int i=0; i<100; i++) {
          ArrayList<Tile> tiles = new ArrayList();
          for (int j=0; j<currentLevel.t.length; j++) {
            for (int k=0; k<currentLevel.t[j].length; k++) {
              Tile t = currentLevel.t[j][k];
              t.setHitBox(new Rect(scrollX+(j*tileSize), scrollY+(k*tileSize), tileSize, tileSize));
              if (t.hitBox.isTouching(new Rect(-t.hitBox.w, -t.hitBox.w, width+t.hitBox.w*2, height+t.hitBox.w*2))) {
                tiles.add(t);
              }
            }
          }
          p.updatePhysics(tiles, 100);
        }
      }
      for (Enemy k : kill) {
        enemies.remove(k);
      }
      for (int i=0; i<25; i++) {
        ArrayList<Tile> tiles = new ArrayList();
        for (int j=0; j<currentLevel.t.length; j++) {
          for (int k=0; k<currentLevel.t[j].length; k++) {
            Tile t = currentLevel.t[j][k];
            t.setHitBox(new Rect((j*tileSize), (k*tileSize), tileSize, tileSize));
            if (t.hitBox.isTouching(new Rect(-t.hitBox.w, -t.hitBox.w, width+t.hitBox.w*2, height+t.hitBox.w*2))) {
              tiles.add(t);
            }
          }
        }
        for (Enemy e : enemies) {
          e.updatePhysics(tiles, 50);
        }
      }
      if (!keyPressed)
        key = 'a';
      if (key=='r') {
        p.respawn(false);
      }
    }
    break;
  case EditTile:
    currentLevel.render(scrollX, scrollY, editTile);
    noStroke();
    fill(150, 150);
    rect(width/3+width/3, 0, width/3, height);
    fill(0);
    stroke(0);
    strokeWeight(2);
    line(width/3+width/3, 0, width/3+width/3, height);
    if (editTile.id==12) {
      int c = editTile.text.split("\n").length;
      textSize(height/32);
      if (textWidth(editTile.text.split("\n")[c-1])>width/4) {
        int h = editTile.text.split(" ").length;
        String buf = "";
        if (editTile.text.split("\n")[c-1].split(" ").length==1) {
          buf=editTile.text.substring(0, max(0, editTile.text.length()-1))+"\n"+editTile.text.substring(editTile.text.length()-1);
        } else {
          for (int i = 0; i < h; i++) {
            String s = editTile.text.split(" ")[i];
            if (i==h-1) s = "\n"+s;
            if (i<h-1)
              buf+=s+" ";
            else
              buf+=s;
          }
        }
        editTile.text=buf;
      }
      fill(0, 1);
      rect(width-width/4, height/16, width/4, height/32*c);
      textAlign(TOP, LEFT);
      fill(0);
      text("Text:", (width-width/4)-textWidth("Text: "), height/16+height/32);
      text(editTile.text+((frameCount%60>30)?"|":""), width-width/4, height/16+height/32);
    } else if (editTile.id==14) {
      fill(255);
      rect(width/3+width/3+(width/3-width/4)/2, height/16, width/4, height/32);
      fill(100);
      rect(scrollArb1, height/16, width/30, height/32);
      fill(100);
      if (mousePressed && (new Rect(width/3+width/3+(width/3-width/4)/2, height/16, width/4, height/32)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
        scrollArb1=mouseX;
      }

      fill(255);
      rect(width/3+width/3+(width/3-width/4)/2, height/16*3, width/4, height/32);
      fill(100);
      rect(scrollArb2, height/16*3, width/30, height/32);
      fill(100);
      if (mousePressed && (new Rect(width/3+width/3+(width/3-width/4)/2, height/16*3, width/4, height/32)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
        scrollArb2=mouseX;
      }
      scrollArb1 = max(scrollArb1, width/3+width/3+(width/3-width/4)/2);
      scrollArb1 = min(scrollArb1, width/3+width/3+(width/3-width/4)/2+width/4-width/30);
      scrollArb2 = max(scrollArb2, width/3+width/3+(width/3-width/4)/2);
      scrollArb2 = min(scrollArb2, width/3+width/3+(width/3-width/4)/2+width/4-width/30);
      editTile.limit = (int)map(scrollArb2, width/3+width/3+(width/3-width/4)/2, width/3+width/3+(width/3-width/4)/2+width/4-width/30, 0, 100);
      editTile.spawnDelay = (int)map(scrollArb1, width/3+width/3+(width/3-width/4)/2, width/3+width/3+(width/3-width/4)/2+width/4-width/30, 500, 15000);
      textAlign(LEFT, TOP);
      fill(0);
      text("Spawn Delay : " + nf(editTile.spawnDelay/1000, 2, 1) + "s", width/3+width/3+(width/3-width/4)/2, (height/16)-height/32);
      text("Spawn Limit : " + (editTile.limit==0?"None":editTile.limit), width/3+width/3+(width/3-width/4)/2, (height/16*3)-height/32);
    } else {
      textSize(height/24);
      textAlign(CENTER, CENTER);
      text("No Data To Modify", width-(width/6), height/16);
    }
    break;
  case LevelEditor:
    if (currentLevel==null) {
      if (!saveFilePath.equals("")) {
        levelPack = loadJSONArray(saveFilePath);
        setMode(Mode.LevelSelect, Mode.LevelEditor);
      }
      textAlign(CENTER, CENTER);
      textSize(titleTextSize);
      fill(0);
      text("The Editor!", width/2, height/16);
      textSize(subTitleTextSize);
      text("Please Select Level Dimentions", width/2, (height/16)+64);
      fill(0);
      textAlign(LEFT, CENTER);
      text("Level Width : "+selectedWidth, 10, height/3-20);
      fill(255);
      rect(10, height/3, width-20, 20);
      fill(100);
      rect(map(selectedWidth, 1, 15, 40, width-40)-30, height/3, 60, 20);
      if (mousePressed && (new Rect(10, height/3, width-20, 20)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
        selectedWidth=mouseX;
        selectedWidth = max(selectedWidth, 40);
        selectedWidth = min(selectedWidth, width-40);
        selectedWidth = round(map(selectedWidth, 40, width-40, 1, 15));
      }
      fill(0);
      text("Level Height : "+selectedHeight, 10, height/2-20);
      fill(255);
      rect(10, height/2, width-20, 20);
      fill(100);
      rect(map(selectedHeight, 1, 15, 40, width-40)-30, height/2, 60, 20);
      if (mousePressed && (new Rect(10, height/2, width-20, 20)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
        selectedHeight=mouseX;
        selectedHeight = max(selectedHeight, 40);
        selectedHeight = min(selectedHeight, width-40);
        selectedHeight = round(map(selectedHeight, 40, width-40, 1, 15));
      }
      (new Button(new Rect((width/2)-((width/5)*1.1), height-(height/10)-15, width/5, height/10), width/40, "setModeClear", "Back", this, Mode.MainMenu)).render();
      (new Button(new Rect((width/2)+((width/5)*1.1)-(width/5), height-(height/10)-15, width/5, height/10), width/40, "createLevel", "Create Level", this)).render();
      break;
    }
    currentLevel.render(scrollX, scrollY);
    if (arrows[0]==1)scrollY+=tileSize/(8/(arrows[4]+1));
    if (arrows[1]==1)scrollY-=tileSize/(8/(arrows[4]+1));
    if (arrows[2]==1)scrollX-=tileSize/(8/(arrows[4]+1));
    if (arrows[3]==1)scrollX+=tileSize/(8/(arrows[4]+1));
    if (mousePressed) {
      int mx = floor((mouseX-scrollX)/tileSize);
      int my = floor((mouseY-scrollY)/tileSize);
      try {
        if (mouseButton==LEFT) {
          currentLevel.t[mx][my].id = selectedTile;
        }
        if (mouseButton==RIGHT) {
          editTile = currentLevel.t[mx][my];
          setMode(Mode.EditTile);
          scrollArb1 = (int)map(editTile.spawnDelay, 500, 1500, width/3+width/3+(width/3-width/4)/2, width/3+width/3+(width/3-width/4)/2+width/4-width/30);
          scrollArb2 = (int)map(editTile.limit, 0, 100, width/3+width/3+(width/3-width/4)/2, width/3+width/3+(width/3-width/4)/2+width/4-width/30);
        }
      }
      catch(ArrayIndexOutOfBoundsException ignored) {
      }
    }
    if (!keyPressed)
      key = 'a';
    File start1 = new File(sketchPath("")+"/levels/*");
    if (key=='s') {
      key='a';
      GameMode = Mode.SaveLevel;
      saveFilePath="";
      selectInput("Save As", "fileSelected", start1);
    }
    if (key=='l') {
      key='a';
      setMode(Mode.LoadLevel);
      saveFilePath="";
      selectInput("File to Load", "fileSelected", start1);
    }
    break;
  case SaveLevel:
    currentLevel.render(scrollX, scrollY);
    fill(150, 220);
    rect(0, 0, width, height);
    if (saveFilePath == null) {
      setMode(Mode.LevelEditor);
      break;
    }
    if (saveFilePath.equals("")) {
      break;
    }
    JSONObject out = new JSONObject();
    String tiles = "";
    ArrayList<String> text = new ArrayList();
    ArrayList<JSONObject> gen = new ArrayList();
    tiles+=(toBase64(currentLevel.t.length/15));
    tiles+=(toBase64(currentLevel.t[0].length/11));
    tiles+=("?");
    for (int i=0; i<currentLevel.t.length; i++)
      for (int j=0; j<currentLevel.t[i].length; j++) {
        tiles+=(toBase64(currentLevel.t[i][j].id));
        if (currentLevel.t[i][j].id == 12) text.add(currentLevel.t[i][j].text);
        if (currentLevel.t[i][j].id == 14) {
          JSONObject curGen = new JSONObject();
          curGen.setInt("delay", currentLevel.t[i][j].spawnDelay);
          curGen.setInt("limit", currentLevel.t[i][j].limit);
          gen.add(curGen);
        }
      }
    JSONArray textTiles = new JSONArray();
    for (int i=0; i<text.size(); i++) {
      textTiles.setString(i, text.get(i));
    }
    JSONArray gens = new JSONArray();
    for (int i=0; i<gen.size(); i++) {
      gens.setJSONObject(i, gen.get(i));
    }
    out.setString("tiles", tiles);
    out.setJSONArray("text", textTiles);
    out.setJSONArray("generators", gens);
    JSONArray finished = new JSONArray();
    finished.setJSONObject(0, out);
    saveJSONArray(finished, saveFilePath);
    setMode(Mode.LevelEditor);
    break;
  case LoadLevel:
    currentLevel.render(scrollX, scrollY);
    fill(150, 220);
    rect(0, 0, width, height);
    if (saveFilePath == null) {
      setMode(Mode.LevelEditor);
      break;
    }
    if (saveFilePath.equals("")) {
      break;
    }
    loadLevel(loadJSONArray(saveFilePath).getJSONObject(0));
    setMode(ReturnMode);
    break;
  case EditorInventory:
    currentLevel.render(scrollX, scrollY);
    stroke(0);
    strokeWeight(2);
    fill(150, 220);
    rect(40, 40, width-80, height-80);
    (new Button(new Rect(width-60, 20, 40, 40), width/40, "setMode", "X", this, Mode.LevelEditor)).render();
    strokeWeight(1);
    rect(40, 40, width/21, width/21);
    if (selectedTile==0) {
      fill(50);
      rect(40, 40, width/21, width/21);
    }
    if ((new Rect(40, 40, width/21, width/21)).isTouching(new Rect(mouseX, mouseY, 1, 1))) {
      if (mousePressed && mouseButton==LEFT) {
        selectedTile = 0;
      }
    }
    image(eraser, 40, 40, width/21, width/21);

    for (int i=0; i<inventoryTiles.length; i++) {
      for (int j=0; j<inventoryTiles[i].length; j++) {
        Tile t = new Tile(inventoryTiles[i][j]);
        Rect hitBox = new Rect(80+(j*width/18), 120+(i*height/7), width/21, width/21);
        t.setHitBox(hitBox);
        hitBox = new Rect((80-(((width/18)-(width/21))/2))+(j*width/18), (120-(((width/18)-(width/21))/2))+(i*height/7), width/18, width/18);
        if (inventoryTiles[i][j]==selectedTile) {
          fill(50);
          rect(hitBox.x, hitBox.y, hitBox.w, hitBox.h);
        }
        if (hitBox.isTouching(new Rect(mouseX, mouseY, 1, 1))) {
          if (inventoryTiles[i][j]!=selectedTile) {
            fill(75);
            rect(hitBox.x, hitBox.y, hitBox.w, hitBox.h);
          }
          if (mousePressed && mouseButton==LEFT) {
            selectedTile = inventoryTiles[i][j];
            //try {
            //  TimeUnit.MILLISECONDS.sleep(100);
            //}
            //catch(InterruptedException ignored) {
            //}
            //setMode(Mode.LevelEditor);
          }
        }
        t.render(0, 0, true, false, true, true, true, true, true, true);
      }
    }
    if (!keyPressed)
      key = 'a';
    break;
  }
  textSize(15);
  textAlign(LEFT, CENTER);
  fill(255);
  stroke(0);
  text("Version : "+version, width-10-textWidth("Version : "+version), height-15);
  click=false;
  if (fade>100) {
    fill(0, map(fade, 200, 100, 0, 255));
  } else {
    fill(0, map(fade, 100, 0, 255, 0));
  }
  rect(0, 0, width, height);
}

void launchGame() {
  GameMode = Mode.MainMenu;
  RadioButton b;
  if (fullScreenBox.state) {
    b = fullResList.activeButton();
  } else {
    b = resList.activeButton();
  }
  String name = b.title;
  int x = Integer.parseInt(name.split("x")[0]);
  int y = Integer.parseInt(name.split("x")[1].split(" \\(")[0]);
  settings.setString("defRes", name);
  settings.setBoolean("fullscreen", fullScreenBox.state);
  saveJSONObject(settings, "data/settings.json");
  surface.setSize(x, y);
  surface.setLocation(displayWidth/2-width/2, displayHeight/2-height/2);
  surface.setTitle("Jump!");
  float amp = settings.getFloat("amp");
  vol = map(amp, 0, 1, width/10, width-width/5+width/10-width/30);
  complete.amp(amp);
  toggle.amp(amp);
  death.amp(amp);
  win.amp(amp);
  button.amp(amp);
  p = new Player(width/2, height/2);
  if (fullScreenBox.state) {
    Frame f = ((SmoothCanvas)surface.getNative()).getFrame();
    f.removeNotify();
    f.setExtendedState(Frame.MAXIMIZED_BOTH);
    f.setUndecorated(true);
    f.setVisible(true);
    f.setLayout(new GridBagLayout());
    f.getGraphics().setColor(Color.BLACK);
    f.getGraphics().fillRect(0, 0, displayWidth, displayHeight);
    ((Graphics2D)f.getGraphics()).scale(2, 2);
    println("Fullscreen");
  }
}

void mouseReleased() {
  click=true;
}

void beginPack(String lvlPkName) {
  levelPack = loadJSONArray(lvlPkName);
  setModeClear(Mode.LevelSelect);
}

void loadLevel(JSONObject obj) {
  enemies.clear();
  JSONArray text = obj.getJSONArray("text");
  JSONArray gen = obj.getJSONArray("generators");
  String code = obj.getString("tiles");
  String[] cc = code.split("\\?");
  String[] loadCode = cc[1].split("");
  String[] dim = cc[0].split("");
  int numText = 0;
  int numGen = 0;
  currentLevel = new Level(fromBase64(dim[0]), fromBase64(dim[1]));
  for (int i=0; i<currentLevel.t.length; i++) {
    for (int j=0; j<currentLevel.t[i].length; j++) {
      try {
        currentLevel.t[i][j].id = fromBase64(loadCode[i * currentLevel.t[i].length  + j]);
      }
      catch(ArrayIndexOutOfBoundsException e) {
        currentLevel.t[i][j].id=1;
      }
      if (currentLevel.t[i][j].id==7) respawnPos = new PVector(i, j);
      if (currentLevel.t[i][j].id==12) {
        currentLevel.t[i][j].text = text.getString(numText);
        numText++;
      }
      if (currentLevel.t[i][j].id==14) {
        currentLevel.t[i][j].spawnDelay = gen.getJSONObject(numGen).getInt("delay");
        currentLevel.t[i][j].limit = gen.getJSONObject(numGen).getInt("limit");
        numGen++;
      }
    }
  }
}

void setModeClear(Mode m) {
  scrollArb1=0;
  scrollArb2=0;
  scrollArb3=0;
  ReturnMode = GameMode;
  scrollX=0;
  scrollY=0;
  level=0;
  deaths=0;
  onoffstate=true;
  time=System.currentTimeMillis();
  currentLevel=null;
  p = new Player(width/2, height/2);
  GameMode = m;
}

void setMode(Mode m) {
  scrollArb1=0;
  scrollArb2=0;
  scrollArb3=0;
  ReturnMode = GameMode;
  GameMode = m;
}

void setMode(Mode m, Mode r) {
  scrollArb1=0;
  scrollArb2=0;
  scrollArb3=0;
  ReturnMode = r;
  GameMode = m;
}

void keyPressed() {
  if (keyCode == UP) {
    arrows[0] = 1;
  }
  if (keyCode == DOWN) {
    arrows[1] = 1;
  }
  if (keyCode == RIGHT) {
    arrows[2] = 1;
  }
  if (keyCode == LEFT) {
    arrows[3] = 1;
  }
  if (keyCode == SHIFT) {
    arrows[4] = 1;
  }
  if (key == ESC) {
    if (GameMode == Mode.LevelEditor) {
      int ans = showConfirmDialog(null, "Discard changes?", "Are you sure?", YES_NO_CANCEL_OPTION);
      if (ans==0) {
        setModeClear(Mode.MainMenu);
      }
      if (ans==1) {
        setMode(Mode.SaveLevel);
        selectInput("Save As", "fileSelected");
        fill(150, 220);
        rect(0, 0, width, height);
      }
    }
    if (GameMode == Mode.EditTile) {
      setMode(Mode.LevelEditor);
    }
    if (GameMode == Mode.LevelSelect) {
      setMode(Mode.MainMenu);
    }
    if (GameMode == Mode.SelectFile) {
      setMode(Mode.MainMenu);
    }
    if (GameMode == Mode.MainGame) {
      int ans = showConfirmDialog(null, "Leave game?", "Would you like to return to the main menu?", YES_NO_OPTION);
      if (story) {
        saveJSONArray(levelPack, "levels/defaultPack.savepack");
      }
      story=false;
      if (ans==0) {
        setModeClear(Mode.MainMenu);
      }
    }
    if (GameMode == Mode.EditorInventory) {
      setMode(Mode.LevelEditor);
    }
    key = 0;
    return;
  }
  if (key == 'i') {
    if (GameMode == Mode.LevelEditor) {
      setMode(Mode.EditorInventory);
      return;
    }
    if (GameMode == Mode.EditorInventory) {
      setMode(Mode.LevelEditor);
      return;
    }
    key=' ';
  }
}

void loadPack() {
  setMode(Mode.SelectFile, Mode.MainGame);
}

void keyReleased() {
  if (keyCode == UP) {
    arrows[0] = 0;
  }
  if (keyCode == DOWN) {
    arrows[1] = 0;
  }
  if (keyCode == RIGHT) {
    arrows[2] = 0;
  }
  if (keyCode == LEFT) {
    arrows[3] = 0;
  }
  if (keyCode == SHIFT) {
    arrows[4] = 0;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (GameMode == Mode.LevelEditor)
    tileSize-=e;
  tileSize = (int)max(tileSize, height/33);
  tileSize = (int)min(tileSize, height/(11/1.5));
}

void fileSelected(File selection) {
  if (selection==null) {
    saveFilePath=null;
    return;
  }
  saveFilePath = selection.getAbsolutePath();
}

String toBase64(int num) {
  String[] codes = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "+", "_"};
  if (num<10) {
    return ""+num;
  } else {
    return codes[num-10];
  }
}

int fromBase64(String chr) {
  try {
    return Integer.parseInt(chr);
  }
  catch(Exception e) {
    String[] codes = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "+", "_"};
    return Index.findIndex(codes, chr)+10;
  }
}

void createLevel() {
  currentLevel = new Level(selectedWidth, selectedHeight);
}
void keyTyped() {
  if (GameMode == Mode.EditTile) {
    if (editTile.id == 12) {
      if (key == BACKSPACE)  editTile.text = editTile.text.substring(0, max(0, editTile.text.length()-1));
      else if (key == ENTER || key == RETURN) editTile.text += "\n";
      else if (key == TAB)  editTile.text += "    ";
      else if (key == DELETE)  editTile.text = "";
      else if (key >= ' ')     editTile.text += str(key);
    }
  }
}

String convertTime(long start) {
  long millis = end-start;
  int minutes = floor(millis/1000/60);
  millis-=minutes*1000*60;
  int seconds = floor(millis/1000);
  millis-=seconds*1000;
  return nf(minutes, 2)+":"+nf(seconds, 2)+"."+nf((int)millis, 4);
}
