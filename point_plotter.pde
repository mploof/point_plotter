// Graphing sketch
 
class Button {
  
    int m_posX, m_posY, m_height, m_width;
    String m_text;
    
    Button(){
        m_text = "default";
        m_height = 50;
        m_width = 100;
    }
    
    Button(String p_button_text, int p_posX, int p_posY){
      
        m_text = p_button_text;
        m_posX = p_posX;
        m_posY = p_posY;
        m_height = 50;
        m_width = 100;
    }
    
    Button(String p_button_text, int p_posX, int p_posY, int p_button_height, int p_button_width){
        
        m_text = p_button_text;
        m_posX = p_posX;
        m_posY = p_posY;
        m_height = p_button_height;
        m_width = p_button_width;
    }
    
    void refresh(){
        // Determine corner location
        int rectX = m_posX - (m_width / 2);
        int rectY = m_posY - (m_height / 2);
        
        stroke(0);
        strokeWeight(1);
        fill(200, 200, 200);
        rect(rectX, rectY, m_width, m_height);
        fill(0);
        textSize(12);
        textAlign(CENTER, CENTER);
        text(m_text, m_posX, m_posY);
    }
    
    boolean overButton(){
      
      if(mouseX >= (m_posX - m_width/2) && mouseX <= (m_posX + m_width/2) &&
      mouseY >= (m_posY - m_height/2) && mouseY <= (m_posY + m_height/2)){
        return true;
      }
      else {
        return false;
      }     
    } 
    
};

int choice_count = 4;
Button title;
Button[] choice = new Button[choice_count];

enum States {

final int NONE = -1;
final int DRAW_INPUT_COUNT = 0;
final int INPUT_COUNT = 1;
final int INPUT = 2;
final int CONFIRM = 3;
final int CTRL = 4;
final int INTERP = 5;
 
import processing.serial.*;
 
Serial myPort;        // The serial port
float xPos = -1000;   // horizontal position of the graph
float yPos = -1000;
int line_count = 20;   // Number of grid lines to draw
int line_interval = 1;

boolean do_this = true;
boolean mouse_bounce = false;
boolean load_vals = false;
String val = "null";
int command = 0;
int state = NONE;

void setup () {
 // set the window size:
   size(800, 800);        
   
   myPort = new Serial(this, Serial.list()[1], 9600);
   
   // don't generate a serialEvent() unless you get a newline character:
   myPort.bufferUntil('\n');
     
   // Create graph
   drawGraph();
   

}
 
void draw () {  
  
  updateMousePos();  
  checkState();
  if(mouse_bounce == false && mousePressed == true){
    mouse_bounce = true;
    state++;
    print("State: ");
    println(state);    
  }
  
  if(mousePressed == false){
    mouse_bounce = false;
  }

  
}

void checkState(){
  // Check the current state and take appropriate acction  
  switch(state){
    case DRAW_INPUT_COUNT:
      drawInputCount();
      state++;
      break;
      
    case INPUT_COUNT:
      getInputCount();
      break;
      
    case INPUT:
      getInput();
      break;
    
    case CONFIRM:
      confirm();
      break;
    
    case CTRL:
      getCtrlPts();
      break;
    
    case INTERP:
      getInterpPts();
      break;
    
    default:
      break;
    
  }
}

void drawInputCount(){
  print("Getting input count");
  clear();
  background(255, 255, 255);
  int choice_count = 4;
 
  title = new Button("Select Input Count", width / 4, height / 2, 300, 200);
  title.refresh();  
  
  for(byte i = 0; i < choice_count; i++){
    choice[i] = new Button();
    choice[i].m_posX = width / 2;
    choice[i].m_posY = (height / (choice_count+1)) * (i+1);  
    choice[i].refresh();
  } 
}

int getInputCount(){
  while(true){   
    if(mousePressed){
      for(int i = 0; i < choice.length; i++) {
        if(choice[i].overButton()){
          return i;
        }
      } 
    }    
  }  
}

void getInput(){
}
void confirm(){
  // Get interpolation points
        getPoints('1', 10, 255, 0, 0);
}
void  getCtrlPts(){
   // Get control points
        getPoints('2', 3, 0, 0, 255);
}
void getInterpPts(){
   // Get Bezier curve points   
        getPoints('3', 5, 139, 0, 139);
}
      

void getPoints(char p_command,int p_size, int p_r, int p_g, int p_b){
  println("getting points");
  println("delay");
  delay(500);
  
  if(p_command != 0){
    print("sending command ");
    println(p_command);
    myPort.write(p_command);
  }
 
  println("entering loop");
  while(true){
    delay(10);
    if(myPort.available() > 0){
      // get the ASCII string:
       String inString = myPort.readStringUntil('\n');
       print("inString: ");
       println(inString);
       
       if (inString != null) {
       
         // trim off any whitespace:
         inString = trim(inString);
         
         // convert to an int and map to the screen height:
         float inByte = float(inString);
        
        if(inByte > 5000){
           println("reached stop code");
           myPort.write('0');  // Stop arduino-side loop
           return;
         }
         
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
    }  
  }
}

void updateMousePos() {
 
  // Draw rectangle
  stroke(0);
  strokeWeight(2);
  fill(220, 220, 220);
  rect(0, 0, 60, 50);
  
  // Determine graph location
  float x = (mouseX - (width / 2)) / 2 / (float)line_count;
  float y = -(mouseY - (height / 2)) / 2 / (float)line_count;
  
  // Update text
  fill(0);
  textAlign(CENTER, CENTER);
  text(String.format("%.2f", x), 30, 15);
  text(String.format("%.2f", y), 30, 35);
}

void drawGraph() {
  
  clear();
  
  // set white background:
   background(255, 255, 255);
   
  // draw grid lines:   
   for(byte i = 0; i < line_count; i++){
     stroke(200);
     strokeWeight(1);
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
}









