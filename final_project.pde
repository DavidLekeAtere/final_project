/* //<>//
 Mr. Marty
 Final Processing project
 Xim Aim Trainer - 3D Reflex Simulation
 */

boolean homePage = true;
float x, y, z;
float screenSX, screenSY, screenR;
float r = 15;
int score = 0;
int highScore = 0;
int timer = 30;
boolean timerStarted = false;
float startTime;
float ms;

void setup() {
  size(800, 600, P3D);
  noStroke();
  randomizeTarget();
  frameRate(240);

  JSONObject obj = loadJSONObject("highscore.json");
  if (obj != null) {
    highScore = obj.getInt("score");
  }
}

  void randomizeTarget() {
    x = random(-150, 150);
    y = random(-250, -30);
    z = random(-150, 150);
  }

  void draw() {
    camera(); // reset to the default camera each frame

    if (homePage) {
      background(0);

      textSize(40);
      fill(255);
      textAlign(CENTER, CENTER);
      text("Xim Aim Trainer", 400, 125);

      if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 350) {
        fill(0, 200, 0);
      } else {
        fill(0, 255, 0);
      }
      triangle(350, 250, 350, 350, 450, 300);

      textSize(30);
      fill(255);
      text("Play", 400, 400); // 400 = center of the triangle
    } else {
      background(220, 225, 235);
      lights();

      camera(0, -200, 500, 0, -100, 0, 0, 1, 0);

      // Floor
      fill(240);
      box(1200, 10, 1200);

      // Walls
      fill(180, 190, 205);

      push();
      translate(-400, -150, 0);
      box(50, 300, 800);
      pop();

      push();
      translate(400, -150, 0);
      box(50, 300, 800);
      pop();

      // Back platform
      fill(210);
      push();
      translate(0, -80, -300);
      box(250, 150, 250);
      pop();

      // Target sphere
      fill(255, 0, 0);
      push();
      translate(x, y, z);
      sphere(r);

      // Capture where the sphere appears on screen
      screenSX = screenX(0, 0, 0);
      screenSY = screenY(0, 0, 0);
      screenR  = abs(screenX(r, 0, 0) - screenSX);
      pop();

      // ==========================================
      // 2D HUD OVERLAY
      // ==========================================
      hint(DISABLE_DEPTH_TEST); // Prevents 3D objects from overlapping text
      camera();                 // Resets camera to 2D screen space coordinates
      noStroke();

      // Score display (Top Left Corner)
      fill(0); // Black text for clean contrast
      textSize(25);
      textAlign(LEFT, TOP);
      text("Score: " + score, 20, 20);

      // FrameRate display (Top Right Corner)
      fill(100); // Muted gray text
      textSize(14);
      textAlign(RIGHT, TOP);
      text("FPS: " + int(frameRate), width - 20, 20);

      hint(ENABLE_DEPTH_TEST); // CRITICAL: Turn 3D depth engine back on for next frame
      // ==========================================
    }
    ms = millis() - startTime;
    timer = 30 - ceil(ms / 1000) % 1000;
    
    
  }

  void mousePressed() {
    if (homePage) {
      if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 350) {
        homePage = false;
        // Crosshair (instead of diagonal fullscreen line)
        cursor(CROSS);
      }
    } else {
      if (dist(mouseX, mouseY, screenSX, screenSY) < screenR) {
        timerStarted = false;
        if (timer == 0) {
          startTime = millis();
          timer = 30;
        randomizeTarget();
        score++;
      } else if (mouseButton == RIGHT) {
        // save the high score
        JSONObject obj = new JSONObject();
        obj.setInt("score", score);

        println(obj);

        saveJSONObject(obj, "highscore.json");
      }
    }
  }
