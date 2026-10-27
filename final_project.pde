/*
 Mr. Marty
 Final Processing project
 TODO: Add brief description of final project here
 */

boolean homePage = true;

void setup() {
  size(800, 600, P3D); // P3D tells Processing to use 3D mode
  noStroke();          // Removes rough black outlines for a clean look
}

void draw() {
  // FIX: Reset to the standard 2D camera view at the start of every frame 
  // so the homePage displays correctly in P3D mode.
  camera(); 
  
  if (homePage) {
    background(0);
    
    // Title text in white
    textSize(40);
    fill(255);
    textAlign(CENTER, CENTER); // Centers text math automatically
    text("Xim Aim Trainer", 400, 125);
    
    // --- PLAY BUTTON TRIANGLE ---
    // A right-pointing triangle centered on the screen
    // Top-left corner: (350, 250), Bottom-left corner: (350, 350), Right tip: (450, 300)
    if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 350) {
      fill(0, 200, 0); // Darker green when hovering
    } else {
      fill(0, 255, 0); // Bright green normally
    }
    triangle(350, 250, 350, 350, 450, 300);
    
    // --- PLAY TEXT UNDER BUTTON ---
    textSize(30);
    fill(255);
    text("Play", 380, 400); // Placed exactly under the triangle base
    
  } else {
    background(220, 225, 235); // Light gray-blue sky color
    lights();                  // Turns on shading so blocks look 3D

    // --- SIMPLE 3D CAMERA SETTING ---
    camera(0, -200, 500, 0, -100, 0, 0, 1, 0);

    // --- DRAW THE FLOOR ---
    fill(240); // Clean white-gray
    box(1200, 10, 1200);

    // --- DRAW THE ELEVATED WALLS / BLOCKS ---
    fill(180, 190, 205); // Blue-gray wall color

    // Left Wall
    push();
    translate(-400, -150, 0); 
    box(50, 300, 800);        
    pop();

    // Right Wall
    push();
    translate(400, -150, 0);  
    box(50, 300, 800);        
    pop();

    // Center Target Platform (Far back)
    fill(210);
    push();
    translate(0, -80, -300);  
    box(250, 150, 250);       
    pop();
  }
}

// Optional: Add a mouse click function to actually start the game
void mousePressed() {
  if (homePage) {
    // Check if the user clicks near the play button boundaries
    if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 410) {
      homePage = false; 
    }
  }
}
