// submitted for CASA MRes Visulation by Gareth, Gianfranco, Katerina, Stelios

HashMap<Integer, Tube> underground; // global hashmap for storing bus objects
PFont orator48, orator24, orator12, orator10; // custom fonts
//PImage bgImage; // picture
int clock = 0; // create and initialise global clock variable
int index = 0; // create and initialise global index variable
boolean mouseClicked = false; // for toggling route numbers

void setup (){
 size (1000,1000); // ratio of size based on general proportions of data
 frameRate(10);
 // call function to load in data - see function below
 loadData();
 // load and set fonts for text
 orator48 = loadFont("OratorStd-48.vlw");
 orator24 = loadFont("OratorStd-24.vlw");
 orator12 = loadFont("OratorStd-12.vlw");
 orator10 = loadFont("OratorStd-10.vlw"); 
}

// Loads in the data
void loadData(){
 underground = new HashMap<Integer, Tube>(); // initialise the Hashmap 
 String [] rows = loadStrings("tube.csv"); // load CSV file
 for (int i = 1; i<rows.length; i++) // Iterate through rows. Don't start from 0 so that you don't load in headers
 {
  // Split rows using the comma as delimiter - and save as string array
  String [] thisRow = split(rows[i], ",");
  // create ID variable
  int ID = int(thisRow[0]);
  println(ID);
  // create card type variable
  int cardType = int(thisRow[16]);
  println(cardType);
  // save x and y locates to variables
  float startx = map(float(thisRow[17]), 496048, 556167, 0, width); // map to width
  float starty = map(float(thisRow[18]), 161497, 201650, height, 0); // map to height, but keep proportions ??
  float endx = map(float(thisRow[19]), 496048, 556167, 0, width);
  float endy = map(float(thisRow[20]), 161497, 201650, height, 0);  
  println(startx+" "+starty+" "+endx+" "+endy);  
  // split time value into hours, minutes, seconds
  int inTime = thisRow[6];
  int outTIme = thisRow[8];
  println(inTime+" "+outTIme);
  // check to see if bus object with this ID already exists
  Tube t = new Tube(ID,cardType,startx,starty,endx,endy,inTime,outTime); // creates new bus object
  underground.put(ID, b); // places bus object in hashmap
 }
}

void draw()
{
 // background box for clock info
 fill(230);
 noStroke();
 rectMode(CORNERS);
 rect(width-325,height-86,width,height-46);
 
 // clock info
 fill(80);
 textFont(orator48);
 text(clock+"m",width-325,height-50); // draws seconds to screen
 fill(240);
 textFont(orator24);
 text("Tube Access Patterns", width-325, height-25); // draws title to screen
 textFont(orator12);
 text("click to toggle display of card types", width-325, height-10); // alerts user to option for route display
 
 // iterate through all bus objects, and draw to screen
 for (Tube tubes: underground.values())
 {
   tubes.display(); // calls each bus object's display function. See below
 }
 
 // iterate the global clock after each framerate
 clock ++;
 
 // halt the animation if the clock exceeds 200...because we don't have more data than that
 if (clock > 1440){
   // background box for end text info
   fill(230);
   noStroke();
   rectMode(CORNERS);
   // end text
   rect(width-325,height-86,width,height-46);fill(80);
   textFont(orator48);
   text(clock+"m->Done!!",width-325,height-50); // draws seconds to screen
   // halt animation
   noLoop();
 }
}

// class for creating bus objects - called above
class Tube 
{
 int id, cardType; // id variable
 float xStart, yStart, xEnd, yEnd; // float list array for x,y coordinates
 float inTime, outTime;
 color c; // color variable for each bus object
 
 Tube(int idin, int cardTypeIn, float xStartIn, float yStartIn, float xEndIn, float yEndIn, int inTimeIn, int outTimeIn){
   id = idin; // set id
   cardType = cardTypeIn; // set route #
   xStart = xStartIn;
   yStart = yStartIn;
   xEnd = xEndIn;
   yEnd = yEndIn;
   inTime = inTimeIn;
   outTime = outTimeIn;
   colorMode(HSB, 21, 100, 100); // prepare color mode and mapping for new bus objects
   c = color(cardType, random(50,100), 100); // randomisation helps distinguish similar colours
 }
 
 // display function called by each draw loop for each bus object - called above
 void display()
 {
  // check to see if time array has x,y locate information for the current time clock value
  if ((clock>=inTime)&&(clock<=outTime)){
   stroke(c);
   line(xStart,yStart,xEnd,yEnd); // draw line for each route
  }
  if (mouseClicked == true){
   textFont(orator10);
   text(cardType,(xStart-xEnd),(yStart-yEnd);
  }
 }
}

// show route numbers if mouse clicked
void mouseClicked(){ 
 if (mouseClicked == false){
  mouseClicked = true;
  println(mouseClicked);
 } else {
  mouseClicked = false;
  println(mouseClicked);
 }
}
