/**Portfolio 5 Exercise
By Alexander Keidel, 22397868 created on 03.10.16
last edited 04.10.16
Version 1: Agents will seek out the location of the mouse.
*/
import java.util.Iterator;

ArrayList<MyVehicle> vs;
MyVehicle myvhcl;
char state;
//Setup method, initally called to set up all the things needed for this example
void setup(){
  size(800, 800); //800 by 800 pixel window
  frameRate(60); //60 frames per second (fps)
  background(0); //set background colour
  vs = new ArrayList<MyVehicle>(); //initialise the array list
  for(int i = 0; i < 50; i++){
     vs.add(new MyVehicle(random(0, 800), random(0, 800), random(5, 15), random(1.0, 10.0), random(0.001, 0.1))); 
  }
}

//called every frame
void draw(){
  background(0); //draw background
  PVector mouseVec = new PVector(mouseX, mouseY);
  println(mouseVec.x + " " + mouseVec.y);
  Iterator<MyVehicle> itr = vs.iterator();
  while(itr.hasNext()){
    MyVehicle tmp = (MyVehicle) itr.next();
    tmp.seekTarget(mouseVec);
    tmp.drawMe();
  }
  fill(15, 50, 15);
  stroke(25, 65, 25);
  ellipse(mouseX, mouseY, 10, 10);
}