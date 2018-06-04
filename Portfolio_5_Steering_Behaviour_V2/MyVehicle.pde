/**Portfolio 5 Exercise
By Alexander Keidel, 22397868 created on 03.10.16
last edited 03.10.16
*/

//custom vehicle class
class MyVehicle{
  PVector location; //location of the vehicle
  PVector velocity; //velocity or force of the vehicle
  PVector acceleration; // acceleration of the vehicle
  float size = 5.0; //size of the vehicle
  float maxSpeed = 4.0; //maximum forward speed values
  float maxSteering = 0.1; //maximum steering speed
  char type;
  color myCol;
  final color BLUE_FILL = color(10, 10, 30);
  final color BLUE_STROKE = color(15, 15, 35);
  final color RED_FILL = color(30, 10, 10);
  final color RED_STROKE = color(35, 15, 15);

  //constructor passing x and y values for location
  MyVehicle(float x, float y){
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }
  
  //constructor using x y location, size, maxSpeed and maxSteering values
  MyVehicle(float x, float y, float size, float maxSpeed, float maxSteering){
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    this.size = size;
    this.maxSpeed = maxSpeed;
    this.maxSteering = maxSteering;
  }
    //constructor using x y location, size, maxSpeed and maxSteering values
  MyVehicle(char type, float x, float y, float size, float maxSpeed, float maxSteering){
    this.type = type;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    this.size = size;
    this.maxSpeed = maxSpeed;
    this.maxSteering = maxSteering;
  }
  
  //constructor using a PVector
  MyVehicle(PVector location){
    this.location.set(location);
    velocity = new PVector(0, -2);
    acceleration = new PVector(0, 0);
  }
  
  //seeking function, incorporating the maximum steering speed and maximum movment speed
  void seekTarget(PVector target){
    PVector desired = PVector.sub(target, location); //vector of the distance between the location and the target
    desired.normalize(); //normalise the vector
    desired.mult(maxSpeed); //multiply by the maximum forward speed
    PVector steering = PVector.sub(desired, velocity); //vector of the distance between the desired location and the current velocity
    steering.limit(maxSteering); //limit the value to the maximum steering speed
    addAcceleration(steering); //add the steering value to the acceleration
  }
  
  void addAcceleration(PVector acc){
    acceleration.add(acc);
  }
  
  //apply force to this vehicle using a vector
  void applyForce(PVector force){
    velocity.add(force);
  }

//V1 Code
  //void drawMe(){
  //   velocity.add(acceleration); //add acceleration
  //   velocity.limit(maxSpeed); //limit to maximum speed
  //   location.add(velocity); //apply new location
  //   acceleration = new PVector(0,0); //reset acceleration
  //   fill(25);
  //   stroke(50);
  //   ellipse(location.x, location.y, size, size);
  //}
  
  //draw the agent by first adding the acceleration to the velocity, which is added to its location. The location provides the x and y coordinate for the ellipse to be drawn.
  void drawMe(){
     velocity.add(acceleration); //add acceleration
     velocity.limit(maxSpeed); //limit to maximum speed
     location.add(velocity); //apply new location
     acceleration = new PVector(0,0); //reset acceleration
     switch(type){
        case 'b': //blue
        fill(BLUE_FILL);
        stroke(BLUE_STROKE);
        break;
        
        case 'r': //red
        fill(RED_FILL);
        stroke(RED_STROKE);
        break;
     }
     if(location.x > 800) location.x = 0;
     if(location.x < 0) location.x = 800;
     if(location.y > 800) location.y = 0;
     if(location.y < 0) location.y = 800;
     
     ellipse(location.x, location.y, size, size);
  }
}