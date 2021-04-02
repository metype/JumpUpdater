class Rect {
  float x, y, w, h, defx, defy;

  public Rect(float x, float y, float w, float h) {
    this.x=x;
    this.y=y;
    this.defx=x;
    this.defy=y;
    this.w=w;
    this.h=h;
  }
  
  public void render(){
   rect(x,y,w,h); 
  }

  public boolean isTouching(Rect r) {
    return !(x + w < r.x
      || x > r.x + r.w
      || y > r.y+r.h
      || y+h < r.y );
  }
}
