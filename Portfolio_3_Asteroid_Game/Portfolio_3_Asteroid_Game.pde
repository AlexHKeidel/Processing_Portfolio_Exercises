/** Portfolio 3 Exercise
Vector-based Asteroid game
Created by Alexander Keidel 22397868 on 11.10.2016
Last updated 19.10.2016
Please note that the images used for the background and player model are not mine, but have been taken off google image search. It was ensured that these images are flagged as re-usable and editable with non-commercial re-use.
*/
final float MIN_MASS = 50.0; //minimum mass of asteroids
final float MAX_MASS = 200.0; //maximum mass of asteroids
final float G = 0.002; //gravitational constant for this game
final color TYPE_A = color(195, 25, 55);
final color TYPE_B = color(55, 25, 195);
float xoffset = 0.0; //X axis offset for Perlin noise
float yoffset = 0.0; //Y axis offset for Perlin noise
float xyincrement = 0.02; //increment for Perlin noise
Spaceship player;
boolean gameOver = false;
ArrayList<Asteroid> asteroids;
Space space;
int time = 0;
int difficulty = 0;
int score = 0;

//Custom Space class to draw the background of the game (Outer space with stars in the background)
class Space{
  PImage spacePicture;
  color[] swapColour1, swapColour2;
  Space(){
    spacePicture = loadImage("Space Background.jpg");
    image(spacePicture, 0,0); //set background image
    //swapColour1 = new color[width];
    //swapColour2 = new color[width]; //array of colours the size of the width of the window
  }
  /** do not use
  void drawMe(){
    spacePicture.loadPixels();
    for(int i = 0; i < swapColour1.length; i++){ //for the width of the image
      swapColour1[i] = pixels[i]; //get the top line of the image
      swapColour2[i] = pixels[width * (height - 1) + i]; //get the bottom line of the image
    }
    for(int i = 0; i < swapColour1.length; i++){ //sweap the bottom and top line
      pixels[i] = swapColour2[i];
      pixels[width * (height-1) + 1] = swapColour1[i]; 
    }
  } */
  
  void drawMe(){
    image(spacePicture, 0,0); //set background image
  }
}
/**
Custom Asteroid class including it's own location, velocity (force), acceleration and mass.
*/
class Asteroid{
  float mass = 0;
  PVector location = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  char type;
  Asteroid(int size){
    switch((int) random(0,2)){//define the asteroid type, asteroids of the same type are attracted to another
      case 0: 
      type = 'a';
      break;
      
      case 1:
      type = 'b';
      break;
    } 
    mass = size;
    location.y = 0 - mass; //start at the top of the screen
    location.x = random(mass, width - mass); //random x location between the mass and the width minus mass to prevent it from being drawn outside the screen
    velocity.x = random(-2, 2); //move left or right between -2 and 2 
    velocity.y = 5 + difficulty; //change velocity depending on size, the bigger the asteroid, the slower it moves
    velocity.div(mass * 0.1); //divide the velocity (or force) by the mass, so bigger objects more at a slower speed
    acceleration.x = 0;
    acceleration.y = 0;
}
  void influenceAcceleration(PVector otherAsteroid, float otherAsteroidMass, char type){
    PVector force;
    if(this.type == type) { //attracted to this asteroid if the type is the same
      force = (PVector.sub(otherAsteroid, location)); //calculate the difference between the two locations
    } else { //repelling one another if the type is not the same
      force = PVector.sub(location, otherAsteroid);
    }
    float distance = force.mag(); //determine the magnitude of the velocity (force)
    float m = (G * mass * otherAsteroidMass) / (distance * distance); //the number (which may be emitted) represents the gravitational constant G
    force.normalize(); //normalise the force
    force.mult(m); //multiply by the gravitational pull
    velocity.add(force);
  }
  
  private void applyForce(){
    velocity.add(acceleration); //add the acceleration to the velocity
    location.add(velocity); //update the location with the new velocity
  }
  
  boolean drawMe(){
    applyForce(); //appl the force to move the asteroid to the next position
    if(location.y + mass >= height) gameOver = true; //hit the bottom of the screen
    if(location.y < (-1 * mass)) return false; //moved off the top of the screen
    if(location.x > width) location.x = 0; else if(location.x < 0) location.x = width; //swap the asteroid from left to right or the other way round
    
    switch(type){ //determine the colour of the asteroid
       case 'a':
         fill(TYPE_A);
       break;
         
       case 'b':
         fill(TYPE_B);
       break;
    }
    ellipse(location.x, location.y, mass, mass);
    return true;
  }
}

//Spaceship controlled by the player's mouse
class Spaceship{
  class Bullet { //inner bullet class used when shooting the guns of the spaceship
    final float SPEED = -5; //speed of the bullet travelling up the screen (-5 because it travels upwards)
    PVector location = new PVector();
    PVector velocity = new PVector();
    int size = 5;
    char type;
    Bullet(char type, int powerlevel, int x, int y){
      this.type = type; //assign bullet type
      location.x = x;
      location.y = y;
      velocity.x = 0; //bullets do not travel sideways
      velocity.y = SPEED;
      size += powerlevel * 2;
    }
    
    boolean drawMe(){
      location.add(velocity);
      if(location.y <= 0) return false; //the bullet has gone off the screen
      switch(type){
        case 'a':
        fill(TYPE_A);
        break;
        
        case 'b':
        fill(TYPE_B);
        break;
      }
      ellipseMode(CENTER);
      ellipse(location.x, location.y, size / 2, size * 2);
      //Check if the bullet is hitting an asteroid
      for(int i = 0; i < asteroids.size(); i++){
        if(Math.abs((int) (asteroids.get(i).location.y - location.y)) <= (asteroids.get(i).mass / 2)){ //y location is correct
          if(Math.abs((int) (asteroids.get(i).location.x - location.x)) <= (asteroids.get(i).mass / 2)){ //x location is correct
            //The bullet hit an asteroid!
            if(type == asteroids.get(i).type){ //if they are the same type
            score += asteroids.get(i).mass; //increment score based on mass of the asteroid destoryed
            player.increaseShield(0.1); //gain 10% shield for destroying an asteroid
            if(score >= difficulty * 1000) difficulty++; //increase difficulty every 10000 points
            asteroids.remove(i); //remove the asteroid from the list
            } else {
              asteroids.get(i).mass += 5; //increase the mass of the asteroid when using the wrong bullet type
            }
            return false; //return false (will remove the bullet)
          }
        }
      }
      return true; //bullet is still flying
    }
  }
  ArrayList<Bullet> bullets;
  int lives; //lives of the player
  float shield; //shield level of the player
  int powerlevel = 1; //player power level, determinse size of bullets
  PImage model; 
  char bulletType = 'a'; //initial bullet type
  Spaceship(){
    bullets = new ArrayList<Bullet>();
    model = loadImage("spaceship.png"); //load player model texture
    lives = 1;
    shield = 1.0; //100% shield
  }
  
  //swap the selected bullet type
  void swapBulletType(){
    if(bulletType == 'a') bulletType = 'b';
    else bulletType = 'a';
  }
  
  //set the players shield
  void increaseShield(float val){
    shield += val;
    if(shield > 1.0) shield = 1.0;
  }
  
  void drawMe(){
    //Check if colliding with an asteroid
    for(int i = 0; i < asteroids.size(); i++){ //this is optimised to check the y axis first, as this is more significant to the asteroid hitting the player
      if(asteroids.get(i).location.y + asteroids.get(i).mass / 2 >= height - 100){ //y location is correct
        if(Math.abs((int) (asteroids.get(i).location.x - mouseX)) <= (asteroids.get(i).mass / 2)){ //x location is correct
        //asteroid is hitting the player, remove some shield and remove the asteroid
        if(shield <= 0.0) gameOver = true; //the player has been hit without shield
        shield -= 0.50; //remove 50% shield
        asteroids.remove(i);
        }
      }
    }
    
    int xOffset = 50;
    int yOffset = 100;
    /** old shield colour code
    if(shield >= 1.0){ //shield is full
      fill(0, 150, 50); //green shield
    } else if(shield >= 0.5){ //shield between 50% and 99%
      fill(100, 150, 50); //orange shield
    } else { //shield below 50%
      fill(200, 50, 50);
    } */
    fill(255 - (shield * 255), shield * 255, 0); //decide the colour of the shield (green when full and red when empty)
    ellipseMode(CENTER); //make sure to set the correct ellipse mode to draw the shield
    ellipse(mouseX, height - (yOffset / 2), 100, 50); //draw the shield
    image(model, mouseX - xOffset, height - yOffset); //draw depending on the mouse position (300 is the height of the player model texture)
    try{ //draw the bullets
      for(int i = 0; i < bullets.size(); i++){
        if(!bullets.get(i).drawMe()) bullets.remove(i); //the bullet has left the screen, remove it from the array
      }
    } catch (Exception e){
      //no bullets on screen
    }
}
  
  void fireGuns(){
    bullets.add(new Bullet(bulletType, powerlevel, mouseX, height - 50));
  }
}

//Setup is called once in the beginning of the program and is used to set up all the components needed for the game
void setup(){
  size(800, 800); //set the size of the window
  frameRate(60); //set the framerate of the window to 60Hz4
  space = new Space();
  player = new Spaceship(); //initialise the player
  asteroids = new ArrayList<Asteroid>(); //initialise the asteroid array list (dynamic array)
}

//called on every frame
void draw(){
  if(gameOver){ //display that the game is over
    textSize(40);
    fill(255, 0, 0);
    text("Game Over", width/2, height/2);
    return;
  }
  if(time % (120 - difficulty * 2) == 0){ //every 2 seconds minus the difficulty times two
    asteroids.add(new Asteroid((int) random(50, 200)));
  }
  space.drawMe(); //space is drawn every frame (this should always happen first in order not to draw on top of other objects)
  player.drawMe(); //draw the player spaceship
  try{
    for(int i = 0; i < asteroids.size(); i++){ //for each asteroid
      for(int j = 0; j < asteroids.size() && j != i; j++){ //for each other asteroid
        if(Math.abs(asteroids.get(j).location.y - asteroids.get(i).location.y) <= 20){ //these two asteroids are within 20 pixels of another on the y axis
          if(Math.abs(asteroids.get(j).location.x - asteroids.get(i).location.x) <= 20){ //these two asteroids are practially touching
            asteroids.get(j).mass += asteroids.get(i).mass; //add the mass to one asteroids
            asteroids.remove(i); //remove the other asteroid
            continue;
          }
        }
        //The next line applies all other asteroids gravitational pull towards the currently selected asteroid
        asteroids.get(j).influenceAcceleration(asteroids.get(i).location, asteroids.get(i).mass, asteroids.get(i).type);
      }
      if(!asteroids.get(i).drawMe()) asteroids.remove(i); //remove the asteroid if it flies up outside the screen
    }
  } catch (Exception e){
    //no asteroids are on the screen, continue the game
  }
  //write the score on top of the screen
  fill(10, 255, 10);
  textSize(12);
  textAlign(CENTER);
  text("Score: " + score + " Level: " + difficulty + "\n" + player.shield * 100 + "% Shield", (width /2), 50);
  time++; //a frame has passed
}

//When the game is running fire the players guns
void mouseClicked(){
 if(!gameOver){
   player.fireGuns();
 }
}

void keyPressed(){
  if(key == TAB){
    player.swapBulletType();
  }
}