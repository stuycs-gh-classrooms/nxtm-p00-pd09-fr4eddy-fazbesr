// Constants for simulation
int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 0.5;
float D_COEF = 0.1;

int SPRING_LENGTH = 100;
float SPRING_K = 0.01;

// Toggles for different simulation options
boolean MOVING = true;
boolean BOUNCE = true;

// Current simulation mode
int currentSimulation = 1; // 1: Gravity, 2: Spring, 3: Drag, 5: Combination

// Orbs for different simulations
ArrayList<Orb> orbs;
FixedOrb centralOrb;
OrbNode springNode1, springNode2, springNode3;

void setup() {
  size(600, 600);
  
  // Initialize orbs for simulations
  orbs = new ArrayList<Orb>();
  centralOrb = new FixedOrb(width/2, height/2, 40, 500);
  
  // Create initial orbs
  resetSimulation();
}

void draw() {
  background(255);
  displayMenu();
  
  // Apply forces based on current simulation
  if (MOVING) {
    switch(currentSimulation) {
      case 1: // Gravity
        applyGravityForces();
        break;
      case 2: // Spring
        applySpringForces();
        break;
      case 3: // Drag
        applyDragForces();
        break;
      case 5: // Combination
        applyGravityForces();
        applyDragForces();
        break;
    }
  }
  
  // Move and display orbs
  centralOrb.display();
  
  if (currentSimulation == 2) {
    // Draw lines between spring nodes
    stroke(100);
    line(springNode1.center.x, springNode1.center.y, 
         springNode2.center.x, springNode2.center.y);
    line(springNode2.center.x, springNode2.center.y, 
         springNode3.center.x, springNode3.center.y);
    
    // Display spring nodes
    springNode1.display();
    springNode2.display();
    springNode3.display();
    
    // Move spring nodes if movement is enabled
    if (MOVING) {
      springNode1.move(BOUNCE);
      springNode2.move(BOUNCE);
      springNode3.move(BOUNCE);
    }
  } else {
    // Display and move regular orbs
    for (Orb orb : orbs) {
      orb.display();
      if (MOVING) {
        orb.move(BOUNCE);
      }
    }
  }
}//draw


void applyGravityForces() {
  for (Orb orb : orbs) {
    PVector gravForce = orb.getGravity(centralOrb, G_CONSTANT);
    orb.applyForce(gravForce);
  }
}

void applySpringForces() {
  // Apply spring forces between nodes
  PVector springForce1 = springNode1.getSpring(springNode2, SPRING_LENGTH, SPRING_K);
  PVector springForce2 = springNode2.getSpring(springNode1, SPRING_LENGTH, SPRING_K);
  PVector springForce3 = springNode2.getSpring(springNode3, SPRING_LENGTH, SPRING_K);
  PVector springForce4 = springNode3.getSpring(springNode2, SPRING_LENGTH, SPRING_K);
  
  // Apply gravity for a more interesting simulation
  PVector gravForce1 = springNode1.getGravity(centralOrb, G_CONSTANT * 0.1);
  PVector gravForce2 = springNode2.getGravity(centralOrb, G_CONSTANT * 0.1);
  PVector gravForce3 = springNode3.getGravity(centralOrb, G_CONSTANT * 0.1);
  
  springNode1.applyForce(springForce1);
  springNode1.applyForce(gravForce1);
  springNode2.applyForce(springForce2);
  springNode2.applyForce(springForce3);
  springNode2.applyForce(gravForce2);
  springNode3.applyForce(springForce4);
  springNode3.applyForce(gravForce3);
}

void applyDragForces() {
  for (Orb orb : orbs) {
    PVector dragForce = orb.getDragForce(D_COEF);
    orb.applyForce(dragForce);
    
    // Add a small random force to keep things moving
    PVector randomForce = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    orb.applyForce(randomForce);
  }
}

void resetSimulation() {
  orbs.clear();
  
  // Setup specific nodes for spring simulation
  springNode1 = new OrbNode(width/2 - 100, height/2, 20, 30);
  springNode2 = new OrbNode(width/2, height/2 + 100, 20, 30);
  springNode3 = new OrbNode(width/2 + 100, height/2, 20, 30);
  
  // Set initial velocities for spring nodes
  springNode1.velocity = new PVector(2, 0);
  springNode3.velocity = new PVector(-2, 0);
  
  // Create orbs for other simulations
  for (int i = 0; i < NUM_ORBS; i++) {
    Orb newOrb = new Orb();
    // Give orbs initial velocity for interesting motion
    newOrb.velocity = new PVector(random(-2, 2), random(-2, 2));
    orbs.add(newOrb);
  }
}

void displayMenu() {
  // Display information bar at the top
  fill(0);
  textSize(16);
  textAlign(LEFT, TOP);
  
  // Show current simulation
  String currentMode = "";
  switch(currentSimulation) {
    case 1: currentMode = "Gravity"; break;
    case 2: currentMode = "Spring Force"; break;
    case 3: currentMode = "Drag"; break;
    case 5: currentMode = "Combination"; break;
  }
  
  // Display menu bar background
  noStroke();
  fill(220);
  rect(0, 0, width, 30);
  
  // Display simulation info
  fill(0);
  text("Simulation: " + currentMode, 10, 5);
  
  // Display toggle states
  String movementStatus = MOVING ? "ON" : "OFF";
  String bounceStatus = BOUNCE ? "ON" : "OFF";
  
  fill(MOVING ? color(0, 150, 0) : color(150, 0, 0));
  text("Movement: " + movementStatus, 200, 5);
  
  fill(BOUNCE ? color(0, 150, 0) : color(150, 0, 0));
  text("Bounce: " + bounceStatus, 350, 5);
  
  // Key instructions
  fill(100);
  textSize(12);
  text("Press 1-5 to change simulation, SPACE to toggle movement, B to toggle bounce", 10, height - 20);
}

void keyPressed() {
  // Toggle movement with space
  if (key == ' ') {
    MOVING = !MOVING;
  }
  
  // Toggle bounce with 'b'
  if (key == 'b' || key == 'B') {
    BOUNCE = !BOUNCE;
  }
  
  // Change simulation with number keys
  if (key == '1') {
    currentSimulation = 1; // Gravity
    resetSimulation();
  } else if (key == '2') {
    currentSimulation = 2; // Spring Force
    resetSimulation();
  } else if (key == '3') {
    currentSimulation = 3; // Drag
    resetSimulation();
  } else if (key == '5') {
    currentSimulation = 5; // Combination
    resetSimulation();
  }
  
  // Reset simulation with 'r'
  if (key == 'r' || key == 'R') {
    resetSimulation();
  }
}
