// Graphing sketch
 
// This program takes ASCII-encoded strings
// from the serial port at 9600 baud and graphs them. It expects values in the
// range 0 to 1023, followed by a newline, or newline and carriage return

// Created 20 Apr 2005
// Updated 18 Jan 2008
// by Tom Igoe
// This example code is in the public domain.
 
import processing.serial.*;
 
Serial myPort;        // The serial port
float xPos = -1000;   // horizontal position of the graph
float yPos = -1000;
int line_count = 20;   // Number of grid lines to draw
int line_interval = 1;

boolean do_this = true;
boolean mouse_bounce = false;
String val = "null";

void setup () {
 // set the window size:
   size(600, 600);        
   
   myPort = new Serial(this, Serial.list()[5], 9600);
   
   // don't generate a serialEvent() unless you get a newline character:
   myPort.bufferUntil('\n');
   // set inital background:
   background(255, 255, 255);
   
   // draw grid lines:
   
   for(byte i = 0; i < line_count; i++){
     stroke(200);
     line(0, (height / line_count) * i, width, (height / line_count) * i);
     line((width / line_count) * i, 0, (width / line_count) * i, height); 
   }
   strokeWeight(2);
   stroke(0);
   line(0, height/2, width, height/2);
   line(width /2, 0, width/2, height);
   
   // create text object
   PFont f;
   f = createFont("Arial", 12, true);
   textFont(f, 12);
   fill(0);
   for(byte i = 0; i < line_count; i++){
     text((line_count*line_interval/2) - (i * line_interval), (width / 2) - 20, (height / line_count) * i - 5);
     text((i * line_interval) - (line_count*line_interval/2), (width / line_count) * i + 5, (height / 2) + 15);     
   }
   
   for(byte i = 0; i < 4; i++){
     myPort.write("something");
     delay(100);
   }
}
 
void draw () {
  
  if(mouse_bounce == false && mousePressed == true){
    println("Mouse clicked, sending command ");
    //myPort.write('1');
    mouse_bounce = true;
    getPoints('1', 10, 255, 0, 0);
    getPoints('2', 5, 0, 0, 255);
    /*
    if ( myPort.available() > 0) {  // If data is available,
      val = myPort.readStringUntil('\n');         // read it and store it in val
    } 
    println(val);
    myPort.clear();
    */
  }
  
  if(mousePressed == false){
    mouse_bounce = false;
  }
  
  /*
  while(do_this){
    
    println("doing this");
  
    // Get interpolation points
    //getPoints('1', 255, 0, 0);
    
    // Get control points
    //getPoints('2', 0, 255, 0);
    
    // Get Bezier curve points   
    //getPoints('3', 0, 0, 255);
  
    do_this = false;
  }
  */
}

void getPoints(char p_command,int p_size, int p_r, int p_g, int p_b){
  println("getting points");
  
  println("sending command");
  myPort.write(p_command);
  
  println("Waiting");
  delay(5000);
  
  println("entering loop");
  while(true){
    delay(100);
    if(myPort.available() > 0){
      // get the ASCII string:
       String inString = myPort.readStringUntil('\n');
       print("inString: ");
       println(inString);
       
       if(inString == "done")
         return;
       
       if (inString != null) {
       
         // trim off any whitespace:
         inString = trim(inString);
         
         // convert to an int and map to the screen height:
         float inByte = float(inString); 
         inByte = map(inByte, -(line_count*line_interval/2), (line_count*line_interval/2), 0, height);
         
         // Set the x coordinate first  
         if(xPos == -1000)
           xPos = inByte;
         else
           yPos = height - inByte;
           
         // If both of the coordinates have now been set, draw the point:
         if(xPos != -1000 && yPos != -1000){
           // draw the point:
           strokeWeight(p_size);
           stroke(p_r, p_g, p_b);
           point(xPos, yPos);
             
           // reset the point vars:
           xPos = -1000;
           yPos = -1000;
         
         }
         
       }
       // Once we're out of input points, quit the loop
       else if(inString == null){
         println("Out of input");
         myPort.write('0');
         return;
       }
    }  
  }
}