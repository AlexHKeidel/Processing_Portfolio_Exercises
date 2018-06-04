/**
Particle Factory and Particle classes
Created by Alexander Keidel, 22397868 on 25.10.2016
last edited 03.11.2016

*/
import java.util.Iterator;
/**Particle factory class for exploding asteroids, the spaceship thrusters, and bombs
  */
class ParticleFactory {
  //Asteroid Colour Types
  final color TYPE_A = color(195, 25, 55);
  final color TYPE_A_STROKE = color(210, 35, 65);
  final color TYPE_B = color(55, 25, 195);
  final color TYPE_B_STROKE = color(75, 45, 215);
  
    final float PARTICLE_LIFESPAN_DECREMENT = 0.01; //decrement value for the lifespan of a particle
    float mass; //size of the particles
    PVector origin = new PVector(); //origin of the emitter
    PVector direction = new PVector(); //direction of the emitter (if applicable)
    ArrayList<Particle> particles; //dnyamic list of individual particles
    char colourType; //colour type for asteroid explosions 
    color col; //colour value for asteroid explosions
    float intensity, xConeSize, yConeSize; //intensity of the particle factory, as well as x and y cones for thrusters
    
    public ParticleFactory(float mass, PVector origin, color col){//constructor for asteroid explosion particle factory and bomb particle factories
      this.mass = mass;
      this.origin.set(origin);
      this.col = col;
      intensity = mass / 5;
      particles = new ArrayList<Particle>();
      for(int i = 0; i < (int) intensity; i++){
        particles.add(new Particle(mass, origin, col)); //adding all the particles to the factory
      }
    }
    
    //Particle Factory constructor for space ship thrusters
    public ParticleFactory(float mass, PVector origin, PVector direction, color col, float intensity, float xConeSize, float yConeSize){ //use this for space ship thrusters as it hase a pre-set direction for the particles
      this.mass = mass;
      this.origin.set(origin);
      this.direction.set(direction);
      this.col = col;
      this.intensity = intensity;
      this.xConeSize = xConeSize;
      this.yConeSize = yConeSize;
      particles = new ArrayList<Particle>();
    }
    
    //Asteroid particle factory constructor using the type of asteroids (red or blue)
    public ParticleFactory(float mass, PVector origin, PVector direction, char type, float intensity, float xConeSize, float yConeSize){ //use this for space ship thrusters as it hase a pre-set direction for the particles
      this.mass = mass;
      this.origin.set(origin);
      this.direction.set(direction);
      this.colourType = type;
      switch(type){
       case 'a':
         col = TYPE_A;
       break;
         
       case 'b':
         col = TYPE_B;
       break;
       
       default:
         col = color(255); //error
       break;
      }
      this.intensity = intensity;
      this.xConeSize = xConeSize;
      this.yConeSize = yConeSize;
      particles = new ArrayList<Particle>();
    }
    
    //setter for intensity for outside access, used to adjust the intensity of the space ship thrusters based on acceleration
    void setIntensity(float intensity){
     this.intensity = intensity; 
    }
    
    //setter for origin for outside access, used to update the location of the particle factories when the spaceship moves around the screen
    void setOrigin(PVector origin){
       this.origin = origin; 
    }
    
    //make the explosion for the asteroid
    boolean makeExplosion(){
      //println("particles.size() = " + particles.size());
      if(particles.size() == 0) return false; //if all particles are dead return false
      Iterator<Particle> itr = particles.iterator();
      while(itr.hasNext()){ //while there are particles left
        Particle tmp = (Particle) itr.next();
        if(!tmp.applyForce()) itr.remove(); //remove the particle if it is dead
      }
      return true; //there are particles still left, return true
    }
    
    //make the thruster particle factories run (endlessly)
    boolean run(){
      for(int i = 0; i < (int) intensity; i++){ //the more intense the more particles are added
        particles.add(new Particle(mass, origin, direction, col, xConeSize, yConeSize));
      }
      Iterator<Particle> itr = particles.iterator();
      while(itr.hasNext()){ //while there are particles left
        Particle tmp = (Particle) itr.next();
        if(!tmp.applyForce()) itr.remove(); //remove the particle if it is dead
      }
      if(particles.size() == 0) return false; //if all particles are dead return false
      else return true; //there are particles still left, return true
    }
    
    /**Inner Particle class used by th Particle Factory to produce particles
    */
     class Particle{
       float mass; //mass or size of particle
       PVector direction = new PVector(); //direction of the particle
       PVector location = new PVector(); //location of the particle
       float lifespan; //lifespan of the particle
       color col;
       final float rrrnd = 1.0; //random values final value
       
       //asteroid explosion Particles
       Particle(float mass, PVector origin, color col){
         this.mass = mass / 10; //asteroid explosion fragment size
         location.set(origin); //important to do this instead of this.location = location, as this results in a pointer not a copy / refernce!!!
         this.col = col;
         direction = new PVector(random(-rrrnd, rrrnd), random(-rrrnd, rrrnd)); //set a new random direction for the explosion particle
         //println(this.toString() + " this asteroids direction x and y are " + direction.x + " and " + direction.y);
         lifespan = 1.0;
       }
       
       //Spaceship thruster particles
       Particle(float mass, PVector origin, PVector direction, color col, float xConeSize, float yConeSize){ //use for spaceship thrusters
         this.mass = mass; 
         lifespan = 1.0; //lifespan of the particle
         this.col = col;
         location.set(origin);
         this.direction.set(direction);
         if(xConeSize == 0.0 && yConeSize == 0.0){ random(-1.0, 1.0); direction.y = random(-1.0, 1.0); return; }
         else if(xConeSize == 0.0){ direction.y = random(-yConeSize, yConeSize); return; }
         else if (yConeSize == 0.0) { direction.x = random(-xConeSize, xConeSize); }
       }
       
       //Apply the force to the particle
       boolean applyForce(){
         if(lifespan < 0.0) return false; //lifespan has ended
         lifespan -= PARTICLE_LIFESPAN_DECREMENT;
         location.add(direction); //apply the force by adding the direction (velocity) to the location
         drawMe();
         return true; //lifespan is still running
       }
       
       //draw the individual particle
       void drawMe(){
         ellipseMode(CENTER); //set ellipse mode
         color lspancol = color(red(col) * lifespan, green(col) * lifespan, blue(col) * lifespan); //color depending on lifespan
         fill(lspancol);
         stroke(lspancol);
         ellipse(location.x, location.y, mass, mass); //draw an ellipse of the size of the mass and the defined color
       }
     }
  }