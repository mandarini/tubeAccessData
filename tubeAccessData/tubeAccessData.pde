// submitted for CASA MRes Visulation by Gareth, Gianfranco, Katerina, Stelios

HashMap<Integer, Tube> tubeList; // global hashmap for storing bus objects
Minute[] minuteList;
PFont orator48, orator24, orator12, orator10; // custom fonts
int clock = 0; // create and initialise global clock variable
int maxFrames = 8*1440; //number of frames to display
int days = 0;
int hours = 0;
int minutes = 0;


void setup (){
 size (1000,1000); // ratio of size based on general proportions of data
 background(0);
 // load and set fonts for text
 orator48 = loadFont("OratorStd-48.vlw");
 orator24 = loadFont("OratorStd-24.vlw");
 orator12 = loadFont("OratorStd-12.vlw");
 orator10 = loadFont("OratorStd-10.vlw");

 // Populate minute objects into minutes hashmap
 minuteList = new Minute[maxFrames];
 for (int i=0; i<maxFrames; i++){
   minuteList[i]=new Minute();
 }
 
 // call function to load in data to tubeList hashmap
 tubeList = new HashMap<Integer, Tube>(); // initialise the Hashmap 
 loadData();
}

// Loads in the data
void loadData(){
 String [] rows = loadStrings("tube.csv"); // load CSV file
 for (int i = 0; i<rows.length; i++)
 {
  // Split rows using the comma as delimiter - and save as string array
  String [] thisRow = split(rows[i], ",");
  int ID = int(thisRow[0]);
  int cardType = int(thisRow[16]);
  float startx = map(float(thisRow[17]), 496048, 556167, 0, width); // map to width
  float starty = map(float(thisRow[18]), 161497, 201650, height, 0); // map to height, but keep proportions ??
  float endx = map(float(thisRow[19]), 496048, 556167, 0, width);
  float endy = map(float(thisRow[20]), 161497, 201650, height, 0);   
  int day = (int(thisRow[1])-1)*1440;
  int inTime = int(thisRow[6]) + day;
  int outTime = int(thisRow[8]) + day;
  // Populate tube objects into tubeList hashmap
  colorMode(HSB,21,100,100);
  Tube t = new Tube(ID,cardType,startx,starty,endx,endy,inTime,outTime); // creates new tube object
  tubeList.put(ID, t); // places tube object in hashmap
  colorMode(RGB,255,255,255);
 }
 // Sort through tube objects and add to corresponding minute objects
 for (Tube tubes: tubeList.values())
 {
   int start = int(tubes.inTime);
   int end = int(tubes.outTime)+1;
   int id = tubes.id;
   for (int i=start; i<end; i++){
    minuteList[i].minuteTubes.add(tubes);
  }
 }
}

void draw()
{
 println(frameCount);
 
 //background with opacity
 fill(80,150);
 noStroke();
 rect(0,0,width,height);
 
 // background box for clock info
 fill(230);
 rectMode(CORNERS);
 rect(width-350,height-86,width,height-46);
 
 // clock info
 fill(80);
 textFont(orator48);
 text(days+"d_"+hours+"h_"+minutes+"m",width-350,height-50); // draws seconds to screen
 fill(240);
 textFont(orator24);
 text("Tube Access Patterns", width-350, height-25); // draws title to screen

 // retrieve each minutes entries and plot to screen
 for (int i=0; i<minuteList[clock].minuteTubes.size(); i++){
   Tube t = minuteList[clock].minuteTubes.get(i);
   t.display();
 }
 
 // iterate the global clock after each framerate
 clock ++;
 minutes ++;
 if (minutes == 60){
  minutes = 0;
  hours ++;
 }
 if (hours == 24){
   hours = 0;
   days ++;
 }

 // halt the animation if the clock exceeds 200...because we don't have more data than that
 if (clock > maxFrames){
   noLoop();
 }
}

// class for creating bus objects - called above
class Tube 
{
 int id, cardType; // id variable
 PVector vStart, vEnd, vCurrent; // float list array for x,y coordinates
 int inTime, outTime;
 float duration;
 color c;
 
 Tube(int idin, int cardTypeIn, float xStartIn, float yStartIn, float xEndIn, float yEndIn, int inTimeIn, int outTimeIn){
   id = idin;
   cardType = cardTypeIn;
   vStart = new PVector(xStartIn,yStartIn);
   vCurrent = vStart.get();
   vEnd = new PVector(xEndIn,yEndIn);
   inTime = inTimeIn;
   outTime = outTimeIn;
   duration = outTime-inTime;
   c = color(cardType,random(50,75),100);
 }
 
 // display function called by each draw loop for each bus object - called above
 void display()
 {
  // Calculate current position
  if (duration != 0){
   vCurrent.set(vEnd);
   vCurrent.sub(vStart);
   vCurrent.mult((clock-inTime)/duration);
   vCurrent.add(vStart);
  } else {
  vCurrent.set(vStart);
  }
  if (cardType == 9){
    strokeWeight(2);
    stroke(c);
    line(vStart.x,vStart.y,vEnd.x,vEnd.y); // draw line for each route
    stroke(80);
    fill(255,50,50);
    ellipse(vCurrent.x,vCurrent.y,10,10);
  } else {
    noStroke();
    fill(c);
    ellipse(vCurrent.x,vCurrent.y,2,2);
  }
  
 }
}

class Minute
{
 ArrayList<Tube> minuteTubes;
 
 Minute(){
  minuteTubes = new ArrayList<Tube>();
 }
}
