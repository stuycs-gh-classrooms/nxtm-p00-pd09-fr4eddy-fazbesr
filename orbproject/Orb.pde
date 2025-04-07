class Orb {
  // Instance variables
  PVector center;
  PVector velocity;
  PVector acceleration;
  float bsize;
  float mass;
  color c;

  Orb() {
    bsize = random(MIN_SIZE, MAX_SIZE);
    float x = random(bsize/2, width-bsize/2);
    float y = random(bsize/2, height-bsize/2);
    center = new PVector(x, y);
    mass = random(MIN_MASS, MAX_MASS);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }

  Orb(float x, float y, float s, float m) {
    bsize = s;
    mass = m;
    center = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }

  // Movement behavior
  void move(boolean bounce) {
    if (bounce) {
      xBounce();
      yBounce();
    }

    velocity.add(acceleration);
    // Apply velocity limit
    velocity.limit(10);
    center.add(velocity);
    acceleration.mult(0);
  }

  void applyForce(PVector force) {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }

  PVector getDragForce(float cd) {
    float dragMag = velocity.mag();
    dragMag = -0.5 * dragMag * dragMag * cd;
    PVector dragForce = velocity.copy();
    dragForce.normalize();
    dragForce.mult(dragMag);
    return dragForce;
  }

  PVector getGravity(Orb other, float G) {
    float strength = G * mass * other.mass;
    // Dont want to divide by 0!
    float r = max(center.dist(other.center), MIN_SIZE);
    strength = strength / pow(r, 2);
    PVector force = other.center.copy();
    force.sub(center);
    force.normalize();
    force.mult(strength);
    return force;
  }

  // Spring force between calling orb and other
  PVector getSpring(Orb other, int springLength, float springK) {
    PVector direction = PVector.sub(other.center, this.center);
    float distance = direction.mag();
    direction.normalize();

    float displacement = distance - springLength;
    float mag = springK * displacement;
    direction.mult(mag);

    return direction;
  }

  boolean yBounce() {
    if (center.y > height - bsize/2) {
      velocity.y *= -0.9; // Slight energy loss on bounce
      center.y = height - bsize/2;
      return true;
    } else if (center.y < bsize/2) {
      velocity.y *= -0.9; // Slight energy loss on bounce
      center.y = bsize/2;
      return true;
    }
    return false;
  }
  
  boolean xBounce() {
    if (center.x > width - bsize/2) {
      center.x = width - bsize/2;
      velocity.x *= -0.9; // Slight energy loss on bounce
      return true;
    } else if (center.x < bsize/2) {
      center.x = bsize/2;
      velocity.x *= -0.9; // Slight energy loss on bounce
      return true;
    }
    return false;
  }

  boolean collisionCheck(Orb other) {
    return (this.center.dist(other.center) <= (this.bsize/2 + other.bsize/2));
  }

  void setColor() {
    color c0 = color(0, 255, 255);
    color c1 = color(0);
    c = lerpColor(c0, c1, (mass-MIN_MASS)/(MAX_MASS-MIN_MASS));
  }

  // Visual behavior
  void display() {
    noStroke();
    fill(c);
    circle(center.x, center.y, bsize);
  }
}
