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

float ringX, ringY;
int ringStart = -1000;
boolean ringIsBonus = false;

boolean bonusTarget = false;
int targetValue = 1;

// Size of the Play button (it is positioned from width/height so it stays centered)
float buttonSize = 100;

PImage bg;

void setup() {
  fullScreen(P3D);  // use size(800, 600, P3D); instead if you want a normal window
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

// True when the mouse is over the Play button (always centered on the screen)
boolean overPlayButton() {
  float half = buttonSize / 2;
  return mouseX > width/2 - half && mouseX < width/2 + half &&
    mouseY > height/2 - half && mouseY < height/2 + half;
}

void randomizeTarget() {
  targetX = random(-150, 150);
  targetY = random(-250, -30);
  targetZ = random(-150, 150);

  // Difficulty: lose 0.5 radius per point, down to a minimum of 8
  float baseRadius = 15 - min(score * 0.5, 7);

  // Bonus: about 1 in 8 targets is gold, smaller, and worth 3
  if (random(1) < 0.125) {
    bonusTarget = true;
    targetValue = 3;
    targetRadius = baseRadius * 0.7;
  } else {
    bonusTarget = false;
    targetValue = 1;
    targetRadius = baseRadius;
  }
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
    text("Xim Aim Trainer", width/2, height * 0.2);

    if (overPlayButton()) {
      fill(0, 200, 0);
    } else {
      fill(0, 255, 0);
    }
    float half = buttonSize / 2;
    triangle(width/2 - half, height/2 - half,
      width/2 - half, height/2 + half,
      width/2 + half, height/2);

    textSize(30);
    fill(255);
    text("Play", width/2, height/2 + half + 50);
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

  // Target sphere (gold if it's a bonus target)
  if (!gameOver) {
    if (bonusTarget) {
      fill(255, 200, 0);
    } else {
      fill(255, 0, 0);
    }
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

  // Hit ring (drawn in 2D so it lines up with the screen position of the hit)
  int age = millis() - ringStart;
  if (age < 300) {
    float alpha = map(age, 0, 300, 255, 0);
    noFill();
    if (ringIsBonus) {
      stroke(255, 200, 0, alpha);
    } else {
      stroke(255, 80, 80, alpha);
    }
    strokeWeight(3);
    ellipse(ringX, ringY, age * 0.5, age * 0.5);
    noStroke();
  }

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
    if (overPlayButton()) {
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
    score += targetValue;
    ringX = screenSX;
    ringY = screenSY;
    ringStart = millis();
    ringIsBonus = bonusTarget;
    randomizeTarget();
    hitSound.play();
  } else if (bonusTarget) {
    // Missed the gold ball, so it disappears and is replaced by a new target
    randomizeTarget();
  }
}

void keyPressed() {
  if (key == BACKSPACE && gameOver) {
    resetGame();
    homePage = true;
    cursor(ARROW);
  }
}