/* //<>//
 Mr. Marty
 Final Processing project
 Xim Aim Trainer - 3D Reflex Simulation
 */

import processing.sound.*;

SoundFile hitSound;


boolean homePage = true;
boolean gameOver = false;
float screenSX, screenSY, screenR;
float targetX, targetY, targetZ;
float targetRadius = 15;
int score = 0;
int highScore = 0;
int timer = 30;
boolean timerStarted = false;
float startTime;

PImage bg;

void setup() {
  size(800, 600, P3D);
  bg = loadImage("home_bg.png");
  noStroke();
  randomizeTarget();
  frameRate(240);

  File f = new File(dataPath("highscore.json"));
  if (f.exists()) {
    JSONObject obj = loadJSONObject("highscore.json");
    highScore = obj.getInt("score");
  }
  hitSound = new SoundFile(this, "ding-sound-effect_2.mp3");
}

void randomizeTarget() {
  targetX = random(-150, 150);
  targetY = random(-250, -30);
  targetZ = random(-150, 150);
}

void saveHighScore() {
  JSONObject obj = new JSONObject();
  obj.setInt("score", highScore);
  saveJSONObject(obj, "data/highscore.json");
}

void resetGame() {
  score = 0;
  timer = 30;
  timerStarted = false;
  gameOver = false;
  randomizeTarget();
}

void draw() {
  if (homePage) {
    hint(DISABLE_DEPTH_TEST);
    image(bg, 0, 0, width, height);   // scales to whatever the window size is
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
    text("Play", 400, 400);
    hint(ENABLE_DEPTH_TEST);
    return;
  }

  // Update timer (only after first hit)
  if (timerStarted && !gameOver) {
    float elapsed = (millis() - startTime) / 1000.0;
    timer = max(0, 30 - int(elapsed));
    if (timer == 0) {
      gameOver = true;
      if (score > highScore) {
        highScore = score;
        saveHighScore();
      }
    }
  }

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
  if (!gameOver) {
    fill(255, 0, 0);
    push();
    translate(targetX, targetY, targetZ);
    sphere(targetRadius);
    screenSX = screenX(0, 0, 0);
    screenSY = screenY(0, 0, 0);
    screenR  = abs(screenX(targetRadius, 0, 0) - screenSX);
    pop();
  }

  // 2D HUD
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  fill(0);
  textSize(25);
  textAlign(LEFT, TOP);
  text("Score: " + score, 20, 20);
  text("Time: " + timer, 20, 50);
  text("Best: " + highScore, 20, 80);

  fill(100);
  textSize(14);
  textAlign(RIGHT, TOP);
  text("FPS: " + int(frameRate), width - 20, 20);

  if (gameOver) {
    fill(0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("Time's up! Score: " + score, width/2, height/2 - 20);
    textSize(20);
    text("Click to play again", width/2, height/2 + 30);
    text("Backspace to go home page", width/2, height/2 + 60);
  }

  hint(ENABLE_DEPTH_TEST);
}

void mousePressed() {
  if (homePage) {
    if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 350) {
      homePage = false;
      cursor(CROSS);
    }
    return;
  }

  if (gameOver) {
    resetGame();
    return;
  }

  if (dist(mouseX, mouseY, screenSX, screenSY) < screenR) {
    if (!timerStarted) {
      timerStarted = true;
      startTime = millis();
    }
    score++;
    randomizeTarget();
    hitSound.play();
  }
}
void keyPressed() {
  if (key == BACKSPACE && gameOver) {
    resetGame();
    homePage = true;
    cursor(ARROW);
  }
}
