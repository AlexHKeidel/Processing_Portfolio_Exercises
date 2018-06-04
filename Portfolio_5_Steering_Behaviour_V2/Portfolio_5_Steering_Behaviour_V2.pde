/**Portfolio 5 Exercise
By Alexander Keidel, 22397868 created on 03.10.16
last edited 04.10.16
Version 2: red and blue agents seek smaller agents of the other colour, trying to absorb them.
Reset the simulation by pressing R.
*/
import java.util.Iterator;

ArrayList<MyVehicle> blues;
ArrayList<MyVehicle> reds;
char state;
int timeCounter = 0; //time counter used to spawn new vehicles
//Setup method, initally called to set up all the things needed for this example
void setup(){
  size(800, 800); //800 by 800 pixel window
  frameRate(60); //60 frames per second (fps)
  background(0); //set background colour
  reds = new ArrayList<MyVehicle>(); //initialise the array list
  blues = new ArrayList<MyVehicle>();
  //add a number of random new MyVehicles to the mix
  for(int i = 0; i < 10; i++){
    addNewRandomVehicle('r'); //add new red vehicle
    addNewRandomVehicle('b'); //add new blue vehicle
  }
  
  //V1 Code
  //for(int i = 0; i < 50; i++){
  //   vs.add(new MyVehicle(random(0, 800), random(0, 800), random(5, 15), random(1.0, 10.0), random(0.001, 0.1))); 
  //}
}

//add a new random vehicle with radom values, depending on the type (red or blue)
void addNewRandomVehicle(char type){
    switch(type){
       case 'b': //blue
       blues.add(new MyVehicle(type, random(0,800), random(0,800), random(5, 50), random(1.0, 5.0), random(0.001, 0.1)));
       break;
       
       case 'r': //red
       reds.add(new MyVehicle(type, random(0,800), random(0,800), random(5, 50), random(1.0, 5.0), random(0.001, 0.1)));
       break;
    } 
}

//called every frame
void draw(){
  background(0); //draw background
  if(timeCounter % 120 == 0){//every 2 seconds, based on 60 frames per second
    //add a new random MyVehicles to the mix
    addNewRandomVehicle('r');
    addNewRandomVehicle('b');
  }
  //iterators for both blue and red MyVehicles
  Iterator<MyVehicle> blueItr = blues.iterator();
  Iterator<MyVehicle> redItr = reds.iterator();
  
  //check which target to see, or whether to absorb a target
  while(blueItr.hasNext()){
    MyVehicle blueTmp = (MyVehicle) blueItr.next();
    redItr = reds.iterator();
    while(redItr.hasNext()){
      MyVehicle redTmp = (MyVehicle) redItr.next();
      if(blueTmp.size > redTmp.size){ //the blue one is bigger
        PVector dist = PVector.sub(redTmp.location, blueTmp.location); //distance from blue to red
        if(dist.mag() < blueTmp.size / 2){ //close enough to absorb
          blueTmp.size += redTmp.size;
          redItr.remove(); //remove the red vehicle
          continue;
        } else {
        blueTmp.seekTarget(redTmp.location); //seek it out
        continue;
        }
      }
    }
  }
  
  blueItr = blues.iterator(); //reset iterator
  redItr = reds.iterator(); //reset iterator
  //same for red now!
   while(redItr.hasNext()){
    MyVehicle redTmp = (MyVehicle) redItr.next();
    blueItr = blues.iterator(); //reset iterator
    while(blueItr.hasNext()){
      MyVehicle blueTmp = (MyVehicle) blueItr.next();
      if(redTmp.size > blueTmp.size){ //the blue one is bigger
        PVector dist = PVector.sub(blueTmp.location, redTmp.location); //distance from blue to red
        if(dist.mag() < redTmp.size / 2){ //close enough to absorb
          redTmp.size += blueTmp.size;
          blueItr.remove(); //remove the red vehicle
          continue;
        } else {
        redTmp.seekTarget(blueTmp.location); //seek it out
        continue;
        }
      }
    }
  }
  
  for(int i = 0; i < blues.size(); i++){
    blues.get(i).drawMe();
  }
  
  for(int i = 0; i < reds.size(); i++){
    reds.get(i).drawMe(); 
  }
  
  //OLD CODE, do not use
  ////for each red and each blue vehicle, find a smaller one of the other type
  //for(int i = 0; i < reds.size(); i++){
  //  for(int j = 0; j < blues.size(); j++){
  //    if(reds.get(i).size > blues.get(j).size){ //if the red one is bigger than the blue one
  //      PVector dist = PVector.sub(reds.get(i).location, blues.get(j).location);
  //      if(dist.mag() <= 1.0){ //the distance between the two is very small
  //        //absorb the blue one
  //        reds.get(i).size += blues.get(j).size;
  //        blues.remove(j); //remove the blue one off the list
  //        continue;
  //      } else { //otherwise seek it out
  //      reds.get(i).seekTarget(blues.get(j).location);
  //      reds.get(i).drawMe();
  //      continue;
  //      }
  //    }
  //  }
  //}
  
  //for(int i = 0; i < blues.size(); i++){
  //  for(int j = 0; j < reds.size(); j++){
  //    if(blues.get(i).size > reds.get(j).size){ //if the red one is bigger than the blue one
  //      PVector dist = PVector.sub(blues.get(i).location, reds.get(j).location);
  //      if(dist.mag() <= 1.0){ //the distance between the two is very small
  //        //absorb the blue one
  //        blues.get(i).size += reds.get(j).size;
  //        reds.remove(j); //remove the blue one off the list
  //      } else { //otherwise seek it out
  //      blues.get(i).seekTarget(reds.get(j).location); //seek the blue one
  //      blues.get(i).drawMe();
  //      continue;
  //      }
  //    }
  //  }
  //}
  
  //V1 Code
  //PVector mouseVec = new PVector(mouseX, mouseY);
  //println(mouseVec.x + " " + mouseVec.y);
  //Iterator<MyVehicle> itr = vs.iterator();
  //while(itr.hasNext()){
  //  MyVehicle tmp = (MyVehicle) itr.next();
  //  tmp.seekTarget(mouseVec);
  //  tmp.drawMe();
  //}
  //fill(15, 50, 15);
  //stroke(25, 65, 25);
  //ellipse(mouseX, mouseY, 10, 10);
  timeCounter++; //increment the timeCounter
}

void keyPressed(){
  //reset the simulation
  if(key == 'r'){
    reds.clear();
    blues.clear();
    for(int i = 0; i < 10; i++){
       addNewRandomVehicle('r');
       addNewRandomVehicle('b');
    }
  }
}