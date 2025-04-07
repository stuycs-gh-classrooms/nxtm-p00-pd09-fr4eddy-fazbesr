class OrbNode extends Orb {
  OrbNode next;
  OrbNode previous;
  
  OrbNode(float x, float y, float s, float m) {
    super(x, y, s, m);
    c = color(50, 150, 200);
  }
  
  OrbNode() {
    super();
    c = color(50, 150, 200);
  }
}
