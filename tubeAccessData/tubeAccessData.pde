// CASA MRes Visulation by Gareth, Gianfranco, Katerina, Stelios

HashMap<Integer, Tube> tubeList; // global hashmap for storing bus objects
Minute[] minuteList;
Minute[] selectedList;
PFont orator48, orator24, orator12, orator10; // custom fonts
int clock = 0; // create and initialise global clock variable
int maxFrames = 8*1440; //number of frames to display
int days = 0;
int hours = 0;
int minutes = 0;
String targetCard = "Freedom Pass (Disabled)";

void setup (){
 size (1000,1000);
 
 // load and set fonts for text
 orator48 = loadFont("OratorStd-48.vlw");
 orator24 = loadFont("OratorStd-24.vlw");
 orator12 = loadFont("OratorStd-12.vlw");
 orator10 = loadFont("OratorStd-10.vlw");

 // Populate minute objects into minutes hashmap
 minuteList = new Minute[maxFrames];
 selectedList = new Minute[maxFrames];
 for (int i=0; i<maxFrames; i++){
   minuteList[i]=new Minute();
   selectedList[i]=new Minute();
 }
 
 // call function to load in data to tubeList hashmap
 tubeList = new HashMap<Integer, Tube>(); // initialise the Hashmap 
 loadData();
}

// Loads in the data
void loadData(){
 println("loading csv file into memory...");
 String [] rows = loadStrings("tubeComplete.csv"); // load CSV file
 for (int i = 1; i<rows.length; i++) // start from 1 to skip headers
 {
  // Split rows using the comma as delimiter - and save as string array
  String [] thisRow = split(rows[i], ",");
  int ID = int(thisRow[0]);
  boolean cardType;
  if (targetCard.equals(thisRow[14].replace("\"",""))){; // for some ? reason this file requires manually removing ""
   cardType = true; // assign "true" if matching card type of interest
   println("row "+i);
   println("Found matching card.");
  } else {
   cardType = false;
  }
  float startx = map(float(thisRow[15]), 496048, 556167, 0, width); // map to width
  float starty = map(float(thisRow[16]), 161497, 201650, height, 0); // map to height, but keep proportions ??
  float endx = map(float(thisRow[17]), 496048, 556167, 0, width);
  float endy = map(float(thisRow[18]), 161497, 201650, height, 0);
  // Calculate minutes per day
  int day = (int(thisRow[1])-1)*1440;
  // Add minutes for total days plus current day
  int inTime = int(thisRow[5].replace("\"","")) + day; // for some ? reason this file requires manually removing ""
  int outTime = int(thisRow[7].replace("\"","")) + day; // see above
  // Populate tube objects into tubeList hashmap
  Tube t = new Tube(ID,cardType,startx,starty,endx,endy,inTime,outTime); // creates new tube object
  tubeList.put(ID, t); // places tube object in hashmap
 }
 // Sort through tube objects and add to corresponding minute objects
 // Interpolate for highlighted routes, so add for each minute between start and end
 for (Tube tubes: tubeList.values()){
  if (tubes.cardType == true){
   int start = int(tubes.inTime);
   int end = int(tubes.outTime)+1;
   for (int i=start; i<end; i++){
    selectedList[i].minuteTubes.add(tubes);
   }
   println("Added data of type selected");
  } else {
   // Nont interpolating for non-highlighted routes, so add only start time and draw once
   int time = int(tubes.inTime);
   minuteList[time].minuteTubes.add(tubes);
  }
 }
}

void draw()
{
 println(frameCount);
 
 fill(230,2);
 noStroke();
 rect(0,0,width,height);
 
 // background box for clock info
 fill(80);
 rectMode(CORNERS);
 rect(width-350,height-86,width,height-46);
 
 // clock info
 fill(230);
 textFont(orator48);
 text(days+"d_"+hours+"h_"+minutes+"m",width-350,height-50); // draws seconds to screen
 fill(80);
 textFont(orator24);
 text("Tube Access Patterns", width-350, height-25); // draws title to screen

 // retrieve each minutes entries and plot to screen
 for (int i=0; i<minuteList[clock].minuteTubes.size(); i++){
  Tube active = minuteList[clock].minuteTubes.get(i);
  active.display();
 }
 
// retrieve each minutes entries and plot to screen
 for (int i=0; i<selectedList[clock].minuteTubes.size(); i++){
  Tube selected = selectedList[clock].minuteTubes.get(i);
  selected.highlight();
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
   //background with opacity
 }

 // halt the animation if the clock exceeds 200...because we don't have more data than that
 if (clock == maxFrames){
   noLoop();
 }
}

// class for creating bus objects - called above
class Tube 
{
 int id;
 boolean cardType; // id variable
 PVector vStart, vEnd, vCurrent; // float list array for x,y coordinates
 int inTime, outTime;
 float duration;
 
 Tube(int idin, boolean cardTypeIn, float xStartIn, float yStartIn, float xEndIn, float yEndIn, int inTimeIn, int outTimeIn){
   id = idin;
   cardType = cardTypeIn;
   vStart = new PVector(xStartIn,yStartIn);
   vCurrent = vStart.get();
   vEnd = new PVector(xEndIn,yEndIn);
   inTime = inTimeIn;
   outTime = outTimeIn;
   duration = outTime-inTime;
 }
 
 // for drawing non-highlighted routes
 void display() {
  strokeWeight(0.1);
  stroke(40,150);
  line(vStart.x,vStart.y,vEnd.x,vEnd.y); // draw line for each route
 }
 
 // for drawing highlighted routes
 void highlight(){
  if (duration != 0){
   vCurrent.set(vEnd);
   vCurrent.sub(vStart);
   vCurrent.mult((clock-inTime)/duration);
   vCurrent.add(vStart);   
  } else {
   vCurrent.set(vStart);
  }
  strokeWeight(0.5);
  stroke(220,0,0);
  line(vStart.x,vStart.y,vCurrent.x,vCurrent.y); // draw line for each route
 }
}

// Minute objects for storing arrays of tube data for each point in time.
class Minute
{
 ArrayList<Tube> minuteTubes;
 
 Minute(){
  minuteTubes = new ArrayList<Tube>();
 }
}
