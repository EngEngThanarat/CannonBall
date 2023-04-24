final float CANNONBALL_RADIUS = 25/2;
final float TARGET_WIDTH = 55;
final float TARGET_HEIGHT = 50;
final float GUIDELINE_LENGTH = 50;
final float CANNONBALL_POS_X = 108.5;
final float CANNONBALL_POS_Y = 327.5;
final float MAXIMUM_VELOCITY = 150;

boolean aimCannonballState = false;
boolean isProjectilePathActive = false;
boolean isWin = false;
boolean isGameOver = false;
boolean playAgainHover;
boolean playHover;

float angle = 0;
float velocity = 0;
float time = 0;
float desiredTragetPositionX;
int desiredTragetIndex = (int)random(0,10);
float centreX, centreY;
int score = 0;
int highScore;

PImage gameBackground;
PFont montserratRegular, montserratBold;

PShape cannonLogo;

void setup() {
  size(700, 545);
  surface.setTitle("Cannon Ball");
  centreX = width / 2;
  centreY = height / 2;
  gameBackground = loadImage("game_background.png");
  montserratRegular = createFont("Montserrat-Regular.otf", 192);
  montserratBold = createFont("Montserrat-Bold.otf", 192);
}

void draw() {
  if (!isGameOver) {
    image(gameBackground, 0, 0);

    drawCliff();
    drawCurrentVelocityAndAngle(velocity, degrees(angle));
    drawCurrentScore();
    desiredTragetPositionX = drawTargets(desiredTragetIndex);

    if (isProjectilePathActive) {
      drawCannonballAlongProjectilePath(time);
      time += 0.1;
    } else {
      drawCannonball();
    }

    drawAngleGuides();

    if (mousePressed && !isProjectilePathActive) {
      drawAimCannonball(aimCannonballState);
    } else {
      aimCannonballState = false;
    }
  } else {
    drawExitOptions();
  }
}

void drawCliff() {
  fill(#350528);
  strokeWeight(1);
  stroke(#3472C5);
  quad(-1, 324.5, 108.5, 327.5, 130.5, height, -1, height);
}

void drawCannonball() {
  fill(255);
  stroke(#080340);
  strokeWeight(1);
  ellipse(CANNONBALL_POS_X, CANNONBALL_POS_Y, CANNONBALL_RADIUS * 2, CANNONBALL_RADIUS * 2);
}

float drawTargets(int desiredTragetPosition) {
  float initialTargetPosX = 162.5;
  float targetPosY = 521.5;
  float desiredTragetPositionX = 0;

  strokeWeight(1);
  rectMode(CORNER);
  for (int i = 0; i < 10; i++) {
    if (i == desiredTragetPosition) {
      fill(#26ECE2);
      desiredTragetPositionX = initialTargetPosX;
    } else {
      fill(#350528);
    }

    rect(initialTargetPosX, targetPosY, TARGET_WIDTH, TARGET_HEIGHT/2,2);
    initialTargetPosX += 55;
  }

  return desiredTragetPositionX;
}

void drawAngleGuides() {
  // minimum angle guide
  strokeWeight(1);
  stroke(#3472C5);
  line(CANNONBALL_POS_X, CANNONBALL_POS_Y, CANNONBALL_POS_X + GUIDELINE_LENGTH, CANNONBALL_POS_Y);

  // maximum angle guide
  line(CANNONBALL_POS_X, CANNONBALL_POS_Y, CANNONBALL_POS_X, CANNONBALL_POS_Y - GUIDELINE_LENGTH);

  // active angle guide
  strokeWeight(5);
  if (aimCannonballState && !isProjectilePathActive) {
    float activeGuideEndpointX = CANNONBALL_POS_X - (GUIDELINE_LENGTH * cos(angle));
    float activeGuideEndpointY = CANNONBALL_POS_Y - (GUIDELINE_LENGTH * sin(angle));
    line(CANNONBALL_POS_X, CANNONBALL_POS_Y, activeGuideEndpointX, activeGuideEndpointY);
  }
}

boolean isMouseInsideTheCannonball(float x, float y, float xC, float yC, float radius) {
  float distanceSquared = (x - xC) * (x - xC) + (y - yC) * (y - yC);
  return distanceSquared <= radius * radius;
}

void mousePressed() {
  if (isMouseInsideTheCannonball(mouseX, mouseY, CANNONBALL_POS_X, CANNONBALL_POS_Y, CANNONBALL_RADIUS)) {
    aimCannonballState = true;
  }
}

void mouseReleased() {
  if (aimCannonballState) {
    isProjectilePathActive = true;
  }
}

void drawAimCannonball(boolean aimBallState) {
  if (aimBallState) {
    float aimCannonballPosX = mouseX;
    float aimCannonballPosY = mouseY;

    if (aimCannonballPosX >= CANNONBALL_POS_X) {
      aimCannonballPosX = CANNONBALL_POS_X - 0.01;
    }
    if (aimCannonballPosY <= CANNONBALL_POS_Y) {
      aimCannonballPosY = CANNONBALL_POS_Y + 0.01;
    }

    float distance = dist(aimCannonballPosX, aimCannonballPosY, CANNONBALL_POS_X, CANNONBALL_POS_Y);
    angle = atan2(aimCannonballPosY - CANNONBALL_POS_Y, aimCannonballPosX - CANNONBALL_POS_X);

    if (distance >= MAXIMUM_VELOCITY) {
      aimCannonballPosX = (CANNONBALL_POS_X - 0.01) + (MAXIMUM_VELOCITY * cos(angle));
      aimCannonballPosY = (CANNONBALL_POS_Y + 0.01) + (MAXIMUM_VELOCITY * sin(angle));
    }

    angle = atan2(aimCannonballPosY - CANNONBALL_POS_Y, aimCannonballPosX - CANNONBALL_POS_X);

    strokeWeight(1);
    fill(#26ECE2);
    stroke(#3472C5);
    ellipse(aimCannonballPosX, aimCannonballPosY, CANNONBALL_RADIUS * 2, CANNONBALL_RADIUS * 2);
    strokeWeight(5);
    line(aimCannonballPosX, aimCannonballPosY, CANNONBALL_POS_X, CANNONBALL_POS_Y);

    velocity = getVelocity(aimCannonballPosX, aimCannonballPosY, CANNONBALL_POS_X, CANNONBALL_POS_Y);
  }
}

float getVelocity(float x1, float y1, float x2, float y2) {
  float velocity = dist(x1, y1, x2, y2);

  if (velocity >= MAXIMUM_VELOCITY) {
    velocity = MAXIMUM_VELOCITY;
  }

  return velocity;
}

void drawCannonballAlongProjectilePath(float t) {
  float vX = velocity * cos(angle);
  float vY = velocity * sin(angle);
  float cliffW = CANNONBALL_POS_X;
  float cliffH = CANNONBALL_POS_Y;
  float posX = cliffW - (vX * t);
  float posY = 16 * pow(t, 2) - (vY * t) + cliffH;

  fill(#26ECE2);
  stroke(#080340);
  strokeWeight(1);
  ellipse(posX, posY, CANNONBALL_RADIUS * 2, CANNONBALL_RADIUS * 2);

  if ((posX < 162.5 - CANNONBALL_RADIUS || posX > 492.5 + CANNONBALL_RADIUS) && posY > height + CANNONBALL_RADIUS) {
    isProjectilePathActive = false;
    time = 0;
    isGameOver = true;
  }

  if (posX >= 162.5 - CANNONBALL_RADIUS && posX <= 492.5 + CANNONBALL_RADIUS && posY >= 521.5 - CANNONBALL_RADIUS) {
    isProjectilePathActive = false;
    time = 0;

    if (posX >= desiredTragetPositionX + CANNONBALL_RADIUS && posX <= (desiredTragetPositionX + TARGET_WIDTH) - CANNONBALL_RADIUS) {
      reset();
      score++;
      println(score);
    } else {
      isGameOver = true;
    }
  }
}

void drawCurrentVelocityAndAngle(float velocity, float angle) {
  String angleText;
  String velocityText = "Velocity: " + String.format("%.2f", velocity);
  if (angle == 0) {
    angleText = "Angle: " + String.format("%.2f", angle);
  } else {
    angleText = "Angle: " + String.format("%.2f", 180 - angle);
  }

  textSize(14);
  fill(#3472C5);
  textAlign(BASELINE);
  text(velocityText, 10, height - 26);
  text(angleText, 10, height - 11);
}

void drawExitOptions() {
  String result;
  color textFill;
  if (isWin) {
    result = "You Win!";
    textFill = color(#468847);
  } else {
    result = "You Lost!";
    textFill = color(#350528);
  }

  float posX = centreX;
  float resultTextPosY = centreY - 106;
  float playAgainButtonPosY = centreY;

  rectMode(CENTER);
  strokeWeight(3);
  textAlign(CENTER, CENTER);
  if (isGameOver) {

    fill(#26ECE2);
    stroke(#FEAE0D);
    rect(posX, resultTextPosY, 260, 57, 2);
    fill(textFill);
    textSize(17);
    text("Your Score: " + score + "\n" + result, posX, resultTextPosY);

    PlayAgain();

    if (playAgainHover) {
      fill(#26ECE2);
      stroke(#FEAE0D);
    } else {
      stroke(#FF7D5A);
      fill(#9DDBF0);
    }
    rect(posX, playAgainButtonPosY, 124, 57, 2);
    fill(#080340);
    text("Play Again", posX, playAgainButtonPosY);
  }
}

void PlayAgain() {
     if (mouseX >= centreX - 62 && mouseX <= centreX + 62 && mouseY >= 244 && mouseY <= 301) {
    cursor(HAND);
    playAgainHover = true;
    if (mousePressed) {
      reset();
    }
     }
}

void reset() {
  isGameOver = false;
  velocity = 0;
  angle = 0;
  score = 0;
  desiredTragetIndex = (int)random(0, 10);
  isWin = false;
}

void drawCurrentScore() {
  textSize(21);
  fill(#3472C5);
  textAlign(BASELINE);
  text("Your Score: " + score, 557.5, 80.5);
}

void startPlaying() {
  isGameOver = false;
}
