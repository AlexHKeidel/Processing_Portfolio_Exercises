/**
File created by Alexander Keidel, 22397868 on 7th October 2016
Last edited 8th October 2016

Custom Pong game using Vectors and Perlin Noise or Random numbers
*/
//The following values are required globally across the program
boolean gameOver = true; //initially the game is over, so the user needs to start it
int score = 0;
int level = 1;
int highscore = 0;

//game window resolution
final int windowWidth = 760; 
final int windowHeight = 640;

//the final values are used when first starting the game or when resetting it
final int BASE_WALL_WIDTH = 10;
int wallWidth = BASE_WALL_WIDTH; //width of side and top walls
final int BASE_BALL_SIZE = 10;
int ballSize = BASE_BALL_SIZE; //size of the ball (since it is a circle it only needs one value for x and y)
final int BASE_BAT_HEIGHT = 10;
int batHeight = BASE_BAT_HEIGHT;
final int BASE_BAT_WIDTH = 100;
int batWidth = BASE_BAT_WIDTH;
final float ballBaseSpeed = 2;
boolean ballJustBounced = false;
int bouncedTimer = 1;
int time = 0; //time counter


//vectors representing the location and velocity of the ball
PVector bLoc = new PVector(windowWidth / 2, windowHeight / 2); //center of the screen
PVector bVel = new PVector(0,ballBaseSpeed); //the speed the ball moves at, initially down at 90%

//Perlin noise values
float xoffset = 0.0; //x axis offset
float yoffset = 0.0; //y axis offset
float xyincrement = 0.005; //increment value 

//The setup() method is called once in the beginning of the program and is used to initialise all the required resources for the program
void setup(){
  size(760 , 640);
}

//The draw() method is called on each frame to render the program. It contains the main logic of the game and checks for keypresses
void draw(){
  if(gameOver == true){
    showMenu();
    return;
  }
  time += 1; //increment the time
  if(bLoc.y == windowHeight) gameOver = true; //the ball has touched the bottom of the screen, you lose!
  if(!gameOver && keyPressed){ //game is over or key is being pressed by the user
    if(key == 'r' || key == 'R'){ //if the key pressed is r or R and the game is not over, reset the game
    System.out.println("The r button was pressed. Resetting the game");
      gameOver = true; //end the game
      showMenu();
    }
  }
  
  //Main game logic loop
    //increment the noise values used to change the speed of the ball and other values such as wall and bat widths
  xoffset += xyincrement;
  yoffset += xyincrement;
  float multiplier = 0.5 + noise(xoffset, yoffset) * (1.0 + (level * 0.05)); //muttiplier is based around 0.5, including the noise value and the level multiplier
  
  //if(noise(xoffset, yoffset) < 0.5){ //noise value is below 0.5 
  //  multiplier = 0.92; //recude ball speed by 8%
  //} else {
  //  multiplier = 1.08; //increase ball speed by 8%
  //}
  
  
  //Draw the game arena
  background(209,157,44);
  stroke(51, 149, 24); //colour of the stroke / outline
  fill(51, 149, 24); //colour of the fill / inside
  rect(0,0,windowWidth, wallWidth); //top wall
  rect(0,0,wallWidth, windowHeight); //left wall
  rect(windowWidth - wallWidth, 0, windowWidth, windowHeight); //right wall
   
  //Check the ball location and change direction if necessary
  if(bLoc.x >= (windowWidth - wallWidth - (ballSize / 2)) || bLoc.x <= (wallWidth + (ballSize / 2))){ // side wall has been hit, revert x axis
    //invert x velocity and add a noise controlled speed increase or decrease
    bVel.x = bVel.x * -1 * multiplier; 
    bVel.y = bVel.y * multiplier;
  }
  if(bLoc.y <= (wallWidth + (ballSize / 2))){ //hit the ceiling
    //invert y velocity and add a noise controlled speed multiplier (increase or decrease, as the values are between 0.0 and 1.0)
    bVel.y = bVel.y * -1 * multiplier; 
    bVel.x = bVel.x * multiplier;
    score += 1 + level; //increment score based on level
    if(score % 10 == 0){ //every 10 points increase the level
      level++;
    }
  }
  if(bLoc.y >= (windowHeight - batHeight - (ballSize / 2))){ //the ball is within range to be hit
    if((bLoc.x + (ballSize / 2)) >= (mouseX - batWidth) && (bLoc.x - (ballSize / 2)) <= (mouseX + batWidth)){ //bat has hit the ball
      bVel.y = bVel.y * -1 * multiplier; //invert y velocity and multiply by noise multiplier
      if(bLoc.x <= mouseX){ //the ball is to the left of the mouse (center of bat) or in the center
        bVel.x = 0 - (mouseX - bLoc.x) * 0.1; //hitting the ball on the left side of the bat will result in it moving strongly to the left, depending on the distance from the middle of the bat
      } else {
        bVel.x = 0 + (bLoc.x - mouseX) * 0.1; //hitting the ball on the right side of the bat will result in it moving right, proportional to the distance from the middle of the bat
      }
      //change the size of the bat
      batWidth = (int) (batWidth * multiplier);
    }
  }
  //Move the ball using Euclidean Vectors
  bLoc.add(bVel); //adding the velocity of the ball to it's current location
  
  
  //Draw the ball
  stroke(190, 20, 15);
  fill(140, 10, 10);
  ellipse(bLoc.x, bLoc.y, ballSize, ballSize); //10 by 10 ball
  
  //Draw the player controlled bat at the bottom of the screen
  stroke(20, 200, 10);
  fill(20, 200, 10);
  rect(mouseX - (batWidth / 2), windowHeight - batHeight, batWidth, batHeight);
  
  //update the score and display it at the top
  textSize(10);
  fill(0,0,150);
  text("Level: " + level + " Score: " + score, windowWidth/2, 10);
}

//mouse clicked event handler
void mouseClicked(){
  if(gameOver){ //start the game
    gameOver = false;
  }
}



//Show the main menu for the game
void showMenu(){
    background(190, 190, 190);
    if(highscore < score) highscore = score; //a new highscore!
    fill(0,0,0); //black colour
    stroke(0,0,0);
    textAlign(CENTER);
    textSize(20);
    text("Highscore = " + highscore + "\nClick to start the game!\nPress R to reset the game.", windowWidth / 2, windowHeight / 2);
    score = 0; //reset score
    level = 0; //reset level
    //resetting the ball location and velocity
    bLoc = new PVector(windowWidth / 2, windowHeight / 2); //center of the screen
    bVel = new PVector(0,ballBaseSpeed); //the speed the ball moves at
    //reset game values
    wallWidth = BASE_WALL_WIDTH;
    ballSize = BASE_BALL_SIZE;
    batHeight = BASE_BAT_HEIGHT;
    batWidth = BASE_BAT_WIDTH;
}