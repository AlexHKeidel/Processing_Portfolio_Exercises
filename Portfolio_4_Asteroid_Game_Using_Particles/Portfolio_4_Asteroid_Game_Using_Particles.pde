/** Portfolio 4 Exercise
Vector-based Asteroid game extended to incorporate task 4 including particle systems
Created by Alexander Keidel 22397868 on 11.10.2016
Last updated 03.11.2016
Please note that the images used for the background and player model are not mine, but have been taken off google image search. It was ensured that these images are flagged as re-usable and editable with non-commercial re-use.

*/

import java.util.Iterator; //iterator library in Java

final float MIN_MASS = 50.0; //minimum mass of asteroids
final float MAX_MASS = 200.0; //maximum mass of asteroids
final float G = 0.002; //gravitational constant for this game
final color TYPE_A = color(195, 25, 55);
final color TYPE_A_STROKE = color(210, 35, 65);
final color TYPE_B = color(55, 25, 195);
final color TYPE_B_STROKE = color(75, 45, 215);
float xoffset = 0.0; //X axis offset for Perlin noise
float yoffset = 0.0; //Y axis offset for Perlin noise
float xyincrement = 0.02; //increment for Perlin noise
Spaceship player;
boolean gameOver = false;
ArrayList<Asteroid> asteroids;
ArrayList<ParticleFactory> asteroidExplosions;
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
    imageMode(CORNER);
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
  //OLD CODE: AsteroidParticleFactory pf; 
  char type;
  color col;
  Asteroid(int size){
    switch((int) random(0,2)){//define the asteroid type, asteroids of the same type are attracted to another
      case 0: 
      type = 'a';
      col = TYPE_A;
      break;
      
      case 1:
      type = 'b';
      col = TYPE_B;
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

  
  //influence the acceleration of this asteroid by providing the other asteroids location, mass and type (for repelling or attraction)
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
         stroke(TYPE_A_STROKE);
       break;
         
       case 'b':
         fill(TYPE_B);
         stroke(TYPE_B_STROKE);
       break;
    }
    ellipse(location.x, location.y, mass, mass);
    return true;
  }
  
  /**Internal Particle factory class for exploding asteroids
  */
  class AsteroidParticleFactory {
    float mass;
    PVector origin;
    ArrayList<Particle> particles;
    
    AsteroidParticleFactory(float mass){
      this.mass = mass;
    }
    
    void run(){
      Iterator<Particle> itr = particles.iterator();
      while(itr.hasNext()){ //while there are particles left
        Particle tmp = (Particle) itr.next();
        if(!tmp.applyForce()) itr.remove(); //remove the particle if it is dead
      }
    }
    
    /**Inner Particle class used by th Particle Factory to produce particles
    */
     class Particle{
       float mass; //mass or size of particle
       PVector myDirection; //direction of the particle
       PVector location; //location of the particle
       float lifespan; //lifespan of the particle
       Particle(float mass, PVector origin){
         this.mass = mass / 100; //divide the mass by 100
         lifespan = this.mass * random(0.01, 10.01); //lifespan of the particle
         location = origin;
         myDirection = new PVector(random(-1, 1), random(-1, 1)); //random direction
       }
       
       boolean applyForce(){
         if(lifespan >= 0.0) return false; //lifespan has ended
         location.add(myDirection); //apply the force by adding the direction (velocity) to the location
         return true; //lifespan is still running
       }
     }
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
    
    //default constructor using the type of bullet, the power level and the x y position of the origin of the bullet
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
        stroke(TYPE_A_STROKE);
        break;
        
        case 'b':
        fill(TYPE_B);
        stroke(TYPE_B_STROKE);
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
            if(score >= difficulty * 1000) difficulty++; player.bombs++; //increase difficulty every 1000 points and give the user a bomb!
            //Make the asteroid expode using the ParticleFactory class
            Asteroid tmp = asteroids.get(i);
            asteroidExplosions.add(new ParticleFactory(tmp.mass, tmp.location, tmp.col)); //add a new particle factory for the asteroid explosion
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
  int lives; //lives of the playerd
  int bombs = 1;
  boolean firingBomb = false; //state of firing a bomb
  int bombFrameCounter = 0; //frame counter used to time the bomb
  final int BOMB_TIMER = 60*3; //60 frames per second times 3 = bomb explodes after 3 seconds
  float shield; //shield level of the player
  int powerlevel = 1; //player power level, determinse size of bullets
  PImage model; 
  char bulletType = 'a'; //initial bullet type
  PVector acceleration = new PVector(0,0); //acceleration of the spaceship
  PVector velocity = new PVector(0,0); //speed at which the spaceship moves
  PVector location = new PVector(width/2, height - 100); //initial position of the spaceship
  final float MAX_SPEED = 8;
  final color SPACESHIP_THRUSTER_COLOUR = color(100, 220, 255);
  final float THRUSTER_PARTICLE_MASS = 5.0;
  final float BOTTOM_THRUSTER_INTENSITY = 3.0;
  final float BOTTOM_THRUSTER_CONE_SIZE = 2.0;
   float side_thruster_intensity = 0.0; //this value changes based on the acceleration the player applies to the space ship
  final float SIDE_THRUSTER_CONE_SIZE = 1.333;
  ParticleFactory[] pfs; //particle factories for space ship thrusters
  Spaceship(){
    pfs = new ParticleFactory[3]; //3 particle factories, one for the bottom thrusters and two for left and right
    //bottom thruster
    pfs[0] = new ParticleFactory(THRUSTER_PARTICLE_MASS, location, new PVector(0, 1), SPACESHIP_THRUSTER_COLOUR, BOTTOM_THRUSTER_INTENSITY, BOTTOM_THRUSTER_CONE_SIZE, 0.0);
    //left thruster
    pfs[1] = new ParticleFactory(THRUSTER_PARTICLE_MASS, location, new PVector(-1, 0), SPACESHIP_THRUSTER_COLOUR, side_thruster_intensity, 0.0, SIDE_THRUSTER_CONE_SIZE);
    //right thruster
    pfs[2] = new ParticleFactory(THRUSTER_PARTICLE_MASS, location, new PVector(1, 0), SPACESHIP_THRUSTER_COLOUR, side_thruster_intensity, 0.0, SIDE_THRUSTER_CONE_SIZE);

    bullets = new ArrayList<Bullet>();
    model = loadImage("spaceship.png"); //load player model texture
    lives = 1;
    shield = 1.0; //100% shield
  }
  
  void updateParticleFactories(){
    
  }
  
  void addAcceleration(PVector nAcc){
    velocity.add(nAcc);
    //make sure the ship does not go faster than the max speed in either direction.
    if(velocity.x > MAX_SPEED) velocity.x = MAX_SPEED;
    if(velocity.x < -MAX_SPEED) velocity.x = -MAX_SPEED;
    if(velocity.x > 0){ //set thruster intensity
      pfs[1].setIntensity(velocity.x);
      pfs[2].setIntensity(0);
    } else {
      pfs[1].setIntensity(0);
      pfs[2].setIntensity(-velocity.x);
    }
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
    //apply force
    velocity.add(acceleration);
    location.add(velocity);
    if(location.x > width) location.x = 0; //check if the spaceship is off the screen and move it accordingly
    if(location.x < 0) location.x = width;
    //Check if colliding with an asteroid
    for(int i = 0; i < asteroids.size(); i++){ //this is optimised to check the y axis first, as this is more significant to the asteroid hitting the player
      if(asteroids.get(i).location.y + asteroids.get(i).mass / 2 >= location.y){ //y location is correct
        if(Math.abs((int) (asteroids.get(i).location.x - location.x)) <= (asteroids.get(i).mass / 2)){ //x location is correct
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
    color shieldcolour = color(255 - (shield * 255), shield * 255, 0);
    fill(shieldcolour); //decide the colour of the shield (green when full and red when empty)
    stroke(shieldcolour);
    ellipseMode(CENTER); //make sure to set the correct ellipse mode to draw the shield
    ellipse(location.x, location.y, 100, 50); //draw the shield
    imageMode(CENTER);
    image(model, location.x, location.y); //draw depending on the mouse position (300 is the height of the player model texture)
    try{ //draw the bullets
      for(int i = 0; i < bullets.size(); i++){
        if(!bullets.get(i).drawMe()) bullets.remove(i); //the bullet has left the screen, remove it from the array
      }
    } catch (Exception e){
      //no bullets on screen
    }
    
    try{
      for(ParticleFactory p : pfs){
        p.setOrigin(location); //update spaceship location
        p.run(); //run the factory
      }
    } catch (Exception e){
      //not all thrusters are being used
    }
}
  
  //fire the players guns
  void fireGuns(){
    bullets.add(new Bullet(bulletType, powerlevel, (int) location.x, (int) location.y));
  }
  
  //fire a bomb, destroying all asteroids on the screen
  boolean fireBomb(){
    if(firingBomb || bombs <= 0) return false; //unsuccessfull due to a bomb being fired or not having any more bombs
    else firingBomb = true; bombs--; //set flag and decrement counter
    return true; //successfully launched a bomb
  }
  
  //check the status of the bomb every frame
  void checkBombStatus(){
    if(!firingBomb) return; //the bomb is not travelling, return without doing anything
    bombFrameCounter++; //increment the counter
    //draw the bomb on screen
    fill(30, 90, 150);
    stroke(40, 100, 160);
    ellipse(400, 800 - (bombFrameCounter * 2), 20, 35);
    
    if(bombFrameCounter >= BOMB_TIMER){ //the bomb should explode now!
      bombFrameCounter = 0; //reset the counter
      firingBomb = false; //finished firing the bomb
      //make all asteroids disappear and add explosions in their place
      for(int i = 0; i < asteroids.size(); i++){ //for each asteroid
        asteroidExplosions.add(new ParticleFactory(asteroids.get(i).mass, asteroids.get(i).location, asteroids.get(i).col)); //add a new explosion
      }
      asteroids.clear(); //clear the list of asteroids
      asteroidExplosions.add(new ParticleFactory(250.0, new PVector(400, 800 - (BOMB_TIMER * 2)), color(30, 90, 150))); //add a new explosion for the bomb itself
    }
  }
}

//Setup is called once in the beginning of the program and is used to set up all the components needed for the game
void setup(){
  size(800, 800); //set the size of the window
  frameRate(60); //set the framerate of the window to 60Hz4
  space = new Space();
  player = new Spaceship(); //initialise the player
  asteroids = new ArrayList<Asteroid>(); //initialise the asteroid array list (dynamic array)
  asteroidExplosions = new ArrayList<ParticleFactory>(); //initialise the array list for the asteroid explosion particle factories
}

//called on every frame
void draw(){
  if(gameOver){ //display that the game is over
    textSize(40);
    fill(255, 0, 0);
    stroke(255, 0, 0);
    text("Game Over", width/2, height/2);
    return;
  }
  if(time % (120 - difficulty * 2) == 0){ //every 2 seconds minus the difficulty times two
    asteroids.add(new Asteroid((int) random(50, 200)));
  }
  space.drawMe(); //space is drawn every frame (this should always happen first in order not to draw on top of other objects)
  player.drawMe(); //draw the player spaceship
  player.checkBombStatus(); //check the status of the bomb, if it is fired increment counter until it explodes
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
  
  //draw explosions on screen
  try{
    Iterator explIterator = asteroidExplosions.iterator(); //init. iterator
    int explcounter = 0;
    while(explIterator.hasNext()){
      explcounter++;
      //println("explcounter = " + explcounter);
      ParticleFactory tmp = (ParticleFactory) explIterator.next(); //create pointer to the particle factory
      //println(tmp.toString() + " " + tmp.makeExplosion());
      if(!tmp.makeExplosion()) explIterator.remove(); //remove dead factories
    }
  } catch (Exception ex){
    //no explosions left and iterator failed for some reason
    ex.printStackTrace();
  }
  //write the score on top of the screen
  fill(10, 255, 10);
  stroke(10, 255, 20);
  textSize(12);
  textAlign(CENTER);
  text("Score: " + score + " Level: " + difficulty + "\n" + player.shield * 100 + "% Shield " + player.bombs + " Bombs", (width /2), 50);
  time++; //a frame has passed
}

//When the game is running fire the players guns
/**
void mouseClicked(){
 if(!gameOver){
   player.fireGuns();
 }
}
*/ 

//This version of the game uses the keyboard instead of the mouse
void keyPressed(){
  if(gameOver) return;
  switch(key){
    case TAB:
    player.swapBulletType();
    break;
    
    case 'a': //LEFT
    player.addAcceleration(new PVector(-1, 0)); //go to the left
    break;
    
    case 'd': //RIGHT
    player.addAcceleration(new PVector(1, 0)); //go to the right 
    break;
    
    case 32: //space see for refernce: http://docs.oracle.com/javase/6/docs/api/constant-values.html#java.awt.event.KeyEvent.VK_SPACE
    player.fireGuns();
    break;
    
    case 'b': //fire bomb
    player.fireBomb();
    break;
  }
}