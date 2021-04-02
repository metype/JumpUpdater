class Button {
  Rect boundingBox;
  Method callback;
  Object main;
  String title;
  Object[] args = new Object[0];
  int forcedTextSize = 0;

  public Button(Rect r, String callback, String title, Object main) {
    this.boundingBox=r;
    this.title=title;
    this.main=main;
    try {
      Class c = Class.forName(getCallerClassName());
      this.callback = c.getMethod(callback);
    }
    catch(ClassNotFoundException ignored) {
    }
    catch (NoSuchMethodException e) {
      //handle if method isn't found
    }
  }

  public Button(Rect r, int forcedTextSize, String callback, String title, Object main) {
    this.boundingBox=r;
    this.title=title;
    this.main=main;
    this.forcedTextSize = forcedTextSize;
    try {
      Class c = Class.forName(getCallerClassName());
      this.callback = c.getMethod(callback);
    }
    catch(ClassNotFoundException ignored) {
    }
    catch (NoSuchMethodException e) {
      //handle if method isn't found
    }
  }

  public Button(Rect r, int forcedTextSize, String callback, String title, Object main, Object... args) {
    this.boundingBox=r;
    this.title=title;
    this.main=main;
    this.args=args;
    this.forcedTextSize = forcedTextSize;
    try {
      Class c = Class.forName(getCallerClassName());
      Class[] types = new Class[args.length];
      for (int i=0; i<args.length; i++) {
        types[i] = args[i].getClass();
      }
      this.callback = c.getMethod(callback, types);
    }
    catch(ClassNotFoundException ignored) {
    }
    catch (NoSuchMethodException e) {
      //handle if method isn't found
    }
  }

  public Button(Rect r, String callback, String title, Object main, Object... args) {
    this.boundingBox=r;
    this.title=title;
    this.main=main;
    this.args=args;
    try {
      Class c = Class.forName(getCallerClassName());
      Class[] types = new Class[args.length];
      for (int i=0; i<args.length; i++) {
        types[i] = args[i].getClass();
      }
      this.callback = c.getMethod(callback, types);
    }
    catch(ClassNotFoundException ignored) {
    }
    catch (NoSuchMethodException e) {
      //handle if method isn't found
    }
  }

  public void render() {
    push();
    fill((new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)?((mousePressed)?150:200):255);
    rect(boundingBox.x, boundingBox.y, boundingBox.w, boundingBox.h, 10);
    for (int i=1; i<100; i++) {
      textSize(i);
      if (textWidth(title) >= boundingBox.w) {
        textSize(i-3);
        break;
      }
    }
    if (forcedTextSize!=0) textSize(forcedTextSize);
    fill(0);
    textAlign(CENTER, CENTER);
    text(title, boundingBox.x+(boundingBox.w/2), boundingBox.y+(boundingBox.h/2));
    pop();
    if (click && (new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)) {
      button.play();
      try {
        if (this.args!=null) {
          this.callback.invoke(this.main, this.args);
        } else {
          this.callback.invoke(this.main);
        }
      }
      catch(IllegalAccessException e) {
        e.printStackTrace();
      }
      catch(InvocationTargetException e) {
        e.printStackTrace();
      }
      catch(NullPointerException e) {
        e.printStackTrace();
      }
    }
  }

  private String getCallerClassName() {
    StackTraceElement[] stElements = Thread.currentThread().getStackTrace();
    for (int i=1; i<stElements.length; i++) {
      StackTraceElement ste = stElements[i];
      if (!ste.getClassName().equals(Button.class.getName()) && ste.getClassName().indexOf("java.lang.Thread")!=0) {
        return ste.getClassName();
      }
    }
    return null;
  }
}

class RadioButton {
  Rect boundingBox;
  Boolean state = false;
  String title;
  long enableTime;

  public RadioButton(Rect r, String title) {
    this.boundingBox=r;
    this.title=title;
  }

  public RadioButton(Rect r, String title, boolean def) {
    this.boundingBox=r;
    this.title=title;
    if (def) {
      state = true;
      enableTime = System.currentTimeMillis();
    }
  }

  public void render() {
    pushStyle();
    textSize(20);
    fill(((new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)/* || this.state*/)?200:255);
    ellipseMode(CENTER);
    ellipse(boundingBox.x+10, boundingBox.y+(boundingBox.h/2), 15, 15);
    if (this.state) {
      fill(0);
      ellipse(boundingBox.x+10, boundingBox.y+(boundingBox.h/2), 5, 5);
    }
    fill(0);
    textAlign(LEFT, CENTER);
    text(title, boundingBox.x+35, boundingBox.y+(boundingBox.h/2)-2);
    popStyle();
    if (click && (new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)) {
      button.play();
      this.state = !this.state;
      if (this.state) this.enableTime = System.currentTimeMillis();
    }
  }
}

class CheckBox {
  Rect boundingBox;
  Boolean state = false;
  String title;
  long enableTime;

  public CheckBox(Rect r, String title) {
    this.boundingBox=r;
    this.title=title;
  }

  public CheckBox(Rect r, String title, boolean def) {
    this.boundingBox=r;
    this.title=title;
    if (def) {
      state = true;
      enableTime = System.currentTimeMillis();
    }
  }

  public void render() {
    pushStyle();
    textSize(20);
    fill(((new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)/* || this.state*/)?200:255);
    rectMode(CENTER);
    rect(boundingBox.x+10, boundingBox.y+(boundingBox.h/2), 15, 15);
    if (this.state) {
      fill(0);
      rect(boundingBox.x+10, boundingBox.y+(boundingBox.h/2), 5, 5);
    }
    fill(0);
    textAlign(LEFT, CENTER);
    text(title, boundingBox.x+35, boundingBox.y+(boundingBox.h/2)-2);
    popStyle();
    if (click && (new Rect(mouseX, mouseY, 1, 1)).isTouching(boundingBox)) {
      button.play();
      this.state = !this.state;
      if (this.state) this.enableTime = System.currentTimeMillis();
    }
  }
}

class RadioButtonList {
  ArrayList<RadioButton> buttons = new ArrayList();

  public RadioButtonList() {
  }

  public void add(RadioButton button) {
    buttons.add(button);
  }

  public void render() {
    RadioButton win = new RadioButton(new Rect(0, 0, 0, 0), "");
    long winTime = 0;
    for (RadioButton b : buttons) {
      if (winTime<b.enableTime) {
        winTime = b.enableTime;
        win = b;
      }
    }
    for (RadioButton b : buttons) {
      if (b != win) {
        b.state=false;
      } else {
        push();
        fill(0, 0);
        stroke(0);
        rect(b.boundingBox.x, b.boundingBox.y, b.boundingBox.w, b.boundingBox.h);
        pop();
      }
      b.render();
    }
  }

  public RadioButton activeButton() {
    for (RadioButton b : buttons) {
      if (b.state) return b;
    }
    return null;
  }

  public void offset(float x, float y) {
    for (RadioButton b : buttons) {
      b.boundingBox.x = b.boundingBox.defx + x;
      b.boundingBox.y = b.boundingBox.defy + y;
    }
  }
}
