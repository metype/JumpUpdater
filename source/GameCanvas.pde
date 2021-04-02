class GameCanvas extends PGraphics {
  public GameCanvas(PApplet main) {
    super();
    setParent(main);
    setPrimary(false);
    setSize(width, height);
    textFont(gameFont);
  }

  public void update() {
    
  }
}
