/**
Created by Alexander Keidel, 22397868 on 04.10.2016
Last edited 05.10.2016

Portfolio 1 Exercise
*/

int counter;
PImage baseImage1, baseImage2, baseImage3, baseImage4;

//Setting up all the required data and images
/** The reason there are four different base images are that using a the tmpImage
in each of the function equal to the baseImage creates a pointer, not an object reference.
This means that each example needs it's own original image in order to function correctly 
and not take changes from the previous example into account. 
This is due to not being able to use the loadImage() function outside of setup().
*/
void setup(){
  baseImage1 = loadImage("Aerial Campus 2013.jpg");
  baseImage2 = loadImage("Aerial Campus 2013.jpg");
  baseImage3 = loadImage("Aerial Campus 2013.jpg");
  baseImage4 = loadImage("Aerial Campus 2013.jpg");
  counter = 0;
  size(1280, 860); //set window size
  image(baseImage1, 0,0); //set baseImage as default background
  fill(0,0,0); //set the colour for the text to be displayed
  text("Base Image, please click!", 10, 15); //diplay text
}

//Called continuously as long as "noLoop()" is not called
void draw(){
}

//called when the mouse is clicked on the window
void mouseClicked(){
  if(counter > 3) exit(); //reset counter to 0
  displayExample(counter);
  counter++; //increment counter
}


void displayExample(int exampleNumber){
    switch(exampleNumber){
       case 0: //1D Example using Random Number Generator
       oneDExampleRNG();
       text("1D RNG", 10, 15);
       break;
       
       case 1: //1D Example using Perlin Noise
       oneDExamplePerlin();
       text("1D Perlin Noise", 10, 15);
       break;
       
       case 2: //2D Example using Random Number Generator
       twoDExampleRNG();
       text("2D RNG", 10, 15);
       break;
       
       case 3: //2D Example using Perlin Noise
       twoDExamplePerlin();
       text("2D Perlin Noise", 10, 15);
       break;
       
       default: 
       
       break;
    }
}

/**
A one dimensional example replacing the blue value of each pixel in the image with a pseudo random number between 0 and 255.
*/
void oneDExampleRNG(){
   PImage tmpImage = baseImage1;
   tmpImage.loadPixels();
   for(int y = 0; y < tmpImage.height; y ++){ //for each y axis pixel
     for(int x = 0; x < tmpImage.width; x++){ //and for each x axis pixel
         float red = red(tmpImage.pixels[y * width + x]); //get the red value of the pixel
         float green = green(tmpImage.pixels[y * width + x]); //get the green value of the pixel
         float blue = random(0, 255);
         color colour = color(red, green, blue);
         tmpImage.pixels[y * width +  x] = colour;
     }
   }
   tmpImage.updatePixels();
   image(tmpImage, 0,0); //redraw the new image starting from coordinates (0,0)
}

/**
A one dimensional example which replaces the blue value of each pixel based upon Perlin noise.
This shows a much smoother transition than the previous example.
*/
void oneDExamplePerlin(){
   PImage tmpImage = baseImage2; 
   float increment = 0.02;
   float xoffset = 0.0;
   float yoffset = 0.0;
   noiseDetail(8, 0.125);
   
   tmpImage.loadPixels();
   for(int x = 0; x < tmpImage.width; x ++){ //for each x axis pixel
   xoffset += increment; 
     for(int y = 0; y < tmpImage.height; y++){ //and for each y axis pixel
     yoffset += increment;
         float red = red(tmpImage.pixels[y * width + x]); //get the red value of the pixel
         float green = green(tmpImage.pixels[y * width + x]); //get the green value of the pixel
         float blue = noise(xoffset, yoffset) * 255; //noise returns a value between 0.0 and 1.0, so multiplying it by 255 to get a value for blue (ranges from 0 to 255)
         
         //float red = noise(xoffset, yoffset) * 255;
         //float green = red;
         //float blue = green;
         color colour = color(red, green, blue);
         tmpImage.pixels[y * width +  x] = colour;
     }
   }
   tmpImage.updatePixels();
   image(tmpImage, 0,0); //redraw the new image starting from coordinates (0,0)
}

/**
A two dimensional example that takes one of the surrounding pixels (or itself) for each pixel using
pseudo random numbers.
*/
void twoDExampleRNG(){
   PImage tmpImage = baseImage3; 
   tmpImage.loadPixels();
   /**float p = 0.0;
   float[][] myKernel = {{ p, p, p },
                         { p, p, p },
                         { p, p, p }}; // kernel used to investiage the values of pixels
                         */
                         
   for(int y = 1; y < tmpImage.height - 1; y++){ //y = 1 and height -1 to avoid the top and bottom edged of the image
     for(int x = 1; x < tmpImage.width -1; x++){ //x is equal to 1 and width minus one to avoid the left and right edges of the image, as you would get out of bounds exceptions
       //RANDOM ELEMENT
       int r = (int) random(0, 9); //select a random pixel between 0 and 8
       int counter = 0;
       for(int py = -1; py <= 1; py++){ //starting at -1 for the row above, 0 for the current row and 1 for pixels below
         for(int px = -1; px <= 1; px++){ //starting at -1 for pixels left of, 0 for center and 1 for on the right
           if(counter == r){ //this is the randomly selected pixel
             int pixelPosition = (y + py) * tmpImage.width + (x + px); //getting the position of the pixel on the image
             float col = color(tmpImage.pixels[pixelPosition]); //get the colour value of the selected pixel
             tmpImage.pixels[y * tmpImage.width + x] = (int) col; //replacing the colour of the current pixel with the colour of the randomly selected one
           }
           counter++;
         }
       }
     }
   }
   tmpImage.updatePixels();                   
   image(tmpImage, 0,0); //redraw the new image starting from coordinates (0,0)
}

/**
A two dimension example using Perlin noise. It selects one of the 8 pixels around (or itself)
The outcome is unexpected compared to the random number generator one.
*/
void twoDExamplePerlin(){
   PImage tmpImage = baseImage4;
    tmpImage.loadPixels();
   /**float p = 0.0;
   float[][] myKernel = {{ p, p, p },
                         { p, p, p },
                         { p, p, p }}; // kernel used to investiage the values of pixels
                         */
   float yoffset = 0.0;
   float xoffset = 0.0;
   float increment = 0.1;
   noiseDetail(16, 0.0125);
   
   for(int y = 1; y < tmpImage.height - 1; y++){ //y = 1 and height -1 to avoid the top and bottom edged of the image
     yoffset += increment;
     for(int x = 1; x < tmpImage.width -1; x++){ //x is equal to 1 and width minus one to avoid the left and right edges of the image, as you would get out of bounds exceptions
       xoffset += increment;
       //PERLIN NOISE ELEMENT
       int per = (int) noise(xoffset, yoffset) * 9; //select a perlin noise pixel between 0 and 8
       int counter = 0;
       for(int py = -1; py <= 1; py++){ //starting at -1 for the row above, 0 for the current row and 1 for pixels below
         for(int px = -1; px <= 1; px++){ //starting at -1 for pixels left of, 0 for center and 1 for on the right
           if(counter == per){ //this is the perlin noise selected pixel
             int pixelPosition = (y + py) * tmpImage.width + (x + px); //getting the position of the pixel on the image
             float col = color(tmpImage.pixels[pixelPosition]); //get the colour value of the selected pixel
             tmpImage.pixels[y * tmpImage.width + x] = (int) col; //replacing the colour of the current pixel with the colour of the randomly selected one
           }
           counter++;
         }
       }
     }
   }
   tmpImage.updatePixels();
   image(tmpImage, 0,0); //redraw the new image starting from coordinates (0,0)
}