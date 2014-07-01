// IMPOSSIBRU PLANETARY DESTRUCTION SIMULATOR
// BY ANZOVINO, GABO, LAI, SANCHEZ, WATANABE
// 
// Changelog:
// V3.30.4   Added rocket
// V3.30.0n  Changed pause key to space
// V3.29.18n Changed everything to object oriented
// V3.29.2   Added danger detection system and graphics
// V3.29.0   Made ASTEROID crash into earth
// V3.28.11  Added Saturn Uranus and Neptune as well as realistic values from nasa jpl horizons dated 28 March 2012
// V3.27.20  Added HUD and cleaned up indexes
// V3.27.12  Added ASTEROID
// V3.27.2   Fixed Trails
// V3.27.00  Added Mercury, Venus, Mars (and Jupiter)
// V3.26.23  Added trails and reverse time
// V3.26.11  Added asteroid
// V3.26.10  Added numerical indexing of planets, setup and focus

import shapes3d.*;
import traer.physics.*;

// Planetary index
// Remember to add the initial conditions in SETUP as well as the parameters for the 3D bodies.
Planet CENTRE; // CENTRE planet, class files dependent on this, do not rename
Planet SUN;
Planet EARTH;  
Planet MOON;    
Planet MERCURY; 
Planet VENUS;  
Planet MARS;    
Planet JUPITER;  
Planet SATURN; 
Planet URANUS;  
Planet NEPTUNE;
Asteroid ASTEROID;
GravRocket POSSIBLE;

// Physical parameters
float duniverse  = 100000000;
float grav       = 2.019 * pow(10,-16); // Gravitational constant
float pxConv     = 1351.36666666667; // km/px
float TNTConv    = 4.184*pow(10,15); //J/Mt

//Trails parameters
int tailLength   = 1000;
int tailSkip     = 0; // Number of data points to skip before sampling for trails
int tailTick     = 0;
int tailOn       = 1;
int axesOn       = -1;

// Navigation parameters
int pause_p      = 1;
int dragY;             // for mouse zoom
float oldDistance;

// Simulation parameters
float mindist    = 1; // minimum distance for gravitation to work
float dt         = 0.1; // time step
int rotStop      = 1; // flag for stopping rotation
float time       = 0; // time elapsed in simulation (days)
float maxsSpeed  = 1; // maximum time step
int fForward     = 1;
int rewind       = 1;
float countDown  = 365.25;
float crashFrame = 5;

// Asteroid parameters
float totalVelocity;
float dangerDistance = 0;
float closestApproach;
float nukePower = 50 * pow(10,6);
PVector collisPos = new PVector(-109544.789, -13304.608, -5767.934);
float BLASTDISTANCE = 0;
float SPLITDISTANCE = 0;

// Rocket param
float TETDIST = 3; // tethering distance
float rocketForce = 100000;

// Ellipsoid stuff
Ellipsoid stars;
float rotx       = HALF_PI;
float rotz       = 0;
float distance   = 300000;

// Universal counter
int i, j         = 0;

/////////////////////////////////////////////////////////////////////////////////////////
//SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP SETUP ///
void setup() {///////////////////////////////////////////////////////////////////////////
  size(displayWidth/2,displayHeight/2, P3D); // Always fullscreen
  frameRate(60);
    
  // create the FUCKING UNIVERSE
  stars = AddEllipsoid (20,30, "bintang.jpg", duniverse/2); 
  stars.setTexture("bintang.jpg",5,5); 
  stars.rotateBy(degrees(90), 0, 0); //correcting image orientation
  
  reset(); // Please declare all the initial condition thingys in reset at the bottom

  println("setup complete");
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW DRAW /////
void draw() /////////////////////////////////////////////////////////////////////////////////////
{
  // physics movement simulation
  if(pause_p < 0){ // When it is not paused
      if(dt > 0){
          for(i = fForward; i > 0; i--){
              God.physics.tick(dt); // Physics engine calculation
              time += dt;
          }
          fForward = 1;
      }
      else{
          for(i = rewind; i > 0; i--){
              God.physics.tick(dt); // Physics engine calculation
              time += dt;
          }
          rewind = 1;
      }
      rotStop = 1;
      
      // Tailticking for trails
      if(tailTick > tailSkip)
          tailTick = 0;
      else
          tailTick++;
          
      // popTrails
      for(i=0; i<God.noP; i++){
          if(tailTick == 0)
              God.pArray(i).popTrail();
      }
  }
  else{
      rotStop = 0;
  }
  
  // Move 3D Objects
  for(i=0; i<God.noP; i++)
          God.pArray(i).move3D();
  
  // Asteroid calculations
  dangerDistance = sqrt( pow((EARTH.x() - ASTEROID.x()),2) +
                         pow((EARTH.y() - ASTEROID.y()),2) +
                         pow((EARTH.z() - ASTEROID.z()),2) );
  closestApproach = min(closestApproach, dangerDistance);
  
  totalVelocity  = sqrt(pow(ASTEROID.vx(),2)+pow(ASTEROID.vy(),2) + 
                        pow(ASTEROID.vz(),2)) * (1351000.0) * (1.0/86400.0);
 
  // simulating rotation of stars. aesthetic only
  stars.rotateBy(0,degrees( rotStop*-.000003*dt), 0);
  
  camera(0, 0, distance, 0, 0, 0, 0, 1, 0);
  
  if (mousePressed){
      if (mouseButton == LEFT){
          rotx = constrain(rotx + (pmouseY-mouseY)*0.003, -PI, PI);
          rotz = rotz + (pmouseX-mouseX)*0.003;
      }
  }
  rotateX(rotx);
  rotateZ(rotz);
  
  //////////////////////////////////////////////////////////////////////////////////////////
  // Start Drawing Start Drawing Start Drawing Start Drawing Start Drawing Start Drawing ///
  background(0); ///////////////////////////////////////////////////////////////////////////
  
  // Trails
  stroke(255,200);
  if(tailOn > 0){
      for(i=0; i<God.noP; i++)
          God.pArray(i).drawTrail();
  }
  
  // lighting
  ambientLight(40,40,40);
  directionalLight(255, 255, 255, -150, 40, -140);
  
  // draw planets
  for(i=0; i<God.noP; i++)
      God.pArray(i).draw3D();
   
  // background yo
  noLights();
  ambientLight(180,180,180);
  
  // Move the galaxy to the sun position
  stars.moveTo(SUN.x() - CENTRE.x(),
               SUN.y() - CENTRE.y(),
               SUN.z() - CENTRE.z());
  stars.draw();
  
  // Drawing the axes
  if(axesOn > 0){
      // Positive x y z
      stroke(#0AD600);     line(0,0,0,99999,0,0); // green = x
      stroke(#006CD6);     line(0,0,0,0,99999,0); // blue  = y
      stroke(255);         line(0,0,0,0,0,99999); // white = z
      
      // Negative x y z
      stroke(#0AD600,140); line(-99999,0,0,0,0,0);
      stroke(#006CD6,140); line(0,-99999,0,0,0,0);
      stroke(140);         line(0,0,-99999,0,0,0);
  }
  
  // Drawing the danger tint
  tint(255, (int) (min(dangerDistance, 1000)*150)/1000 + 105, 
            (int) (min(dangerDistance, 1000)*200)/1000 + 55 ); // Danger tint red
            
  // Pause for dramatic effect while the earth is destroyed
  if(dangerDistance < 1000) dt = min(0.5,dt);
  if(dangerDistance < 500) dt = min(0.05,dt);
  if(dangerDistance < 300) dt = min(0.01,dt);
  if(dangerDistance < 100) dt = min(0.002,dt);
  if((dangerDistance < EARTH.diam/2 + ASTEROID.diam/2) && crashFrame > 0){
      PImage img = loadImage("Toolate.jpg");
      img.resize(width,height);
      background(img);
      pause_p = 1;
      crashFrame--;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD HUD ///
  //textMode(SCREEN); //////////////////////////////////////////////////////////////////////////////////////////////
  fill(180);
  // Global information
  text("time  :", 10, 15); text(nfs(time,1,2), 60, 15);     text("days", 150, 15); // time
  text("tstep :", 10, 30); text(nfs(dt,1,3), 60, 30);       text("*60 days/s", 150, 30); // speed
  text("zoom  :", 10, 45); text(nfs(distance*pxConv/1000.0,1,2), 60, 45); text("Mm", 150, 45); // zoom distance
  if(pause_p > 0) text("PAUSED", 10, 60);
  
  text("Count down to impact :", width/2 - 140, 15); text(nfs(countDown - time,1,2), width/2, 15);  
  text("days", width/2 + 60, 15); // time
  
  // Focus information
  text(CENTRE.name, 10, height - 50); // Name of planet of focus
  text("Position :", 10, height - 50 + 15); 
    text(nfs(CENTRE.x()*pxConv/1000.0,1,3),   70, height - 50 + 15); 
    text(nfs(CENTRE.y()*pxConv/1000.0,1,3),  160, height - 50 + 15);
    text(nfs(CENTRE.z()*pxConv/1000.0,1,3),  250, height - 50 + 15); text("Mm", 340, height - 50 + 15);
    
  text("Velocity :", 10, height - 50 + 30); 
    text(nfs(CENTRE.vx()*pxConv/1000.0,1,3),  70, height - 50 + 30);
    text(nfs(CENTRE.vy()*pxConv/1000.0,1,3), 160, height - 50 + 30);
    text(nfs(CENTRE.vz()*pxConv/1000.0,1,3), 250, height - 50 + 30); text("Mm/day", 340, height - 50 + 30);
    
  // Distance from earth to asteroid
  text("Distance from earth to asteroid :", width - 330, 15);
    text(nfs(dangerDistance*pxConv/1000.0, 1,3), width - 120, 15); text("Mm", width - 30, 15);
  text("Closest approach :", width - 330, 30);
    text(nfs(closestApproach*pxConv/1000.0,1,3), width - 120, 30); text("Mm", width - 30, 30);
    
     text("Asteroid energy: ", width - 330, 45);
   text(nfs(.5*ASTEROID.body.mass()*1000*pow(totalVelocity,2)/TNTConv,1,2),width - 120,45);
   text(" mt TNT", width - 50, 45); 
   
    text("Velo Difference :", width - 330, 60);
    text("x:"+ ((ASTEROID.vx()-EARTH.vx())*pxConv/1000.0) 
      +", y:"+((ASTEROID.vy()-EARTH.vy())*pxConv/1000.0)
      +", z:"+((ASTEROID.vz()-EARTH.vz())*pxConv/1000.0), width - 330, 75); text("Mm/day", width - 55, 75);
}//end draw

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED KEYPRESSED ////
void keyPressed(){ /////////////////////////////////////////////////////////////////////////////////////////////////
     if(key == CODED){
         if (keyCode == RIGHT){dt = abs(dt); fForward+=10;}
         if( keyCode == LEFT){dt = -1*abs(dt); rewind+=10;}
         if( keyCode == UP)
             distance = constrain(distance*1.1, 0, duniverse);
         if( keyCode == DOWN)
             distance = constrain(distance*0.9, 0, duniverse);
     } //  end key coded
     
     if(key == 'p'){pause_p = -1 * pause_p;}   
     else if(key == 't'){tailOn  = -1 * tailOn;}
     if(key == 'x'){axesOn  = -1 * axesOn;}
     if(key == ']'){
         if(dt <= 0.05 && dt >= -0.05)
             dt = constrain( dt + 0.001, -maxsSpeed, maxsSpeed);
         else{
             if(dt>0)
                 dt = constrain( dt*1.1, -maxsSpeed, maxsSpeed);
             else
                 dt = constrain( dt*0.9, -maxsSpeed, maxsSpeed);
         }
     }
     if(key == '['){
         if(dt <= 0.05 && dt >= -0.05)
             dt = constrain( dt - 0.001, -maxsSpeed, maxsSpeed);
         else{
             if(dt<0)
                 dt = constrain( dt*1.1, -maxsSpeed, maxsSpeed);
             else
                 dt = constrain( dt*0.9, -maxsSpeed, maxsSpeed);
         }
     }
     if(key == 'z'){reset();}
     if(key == 'u'){CENTRE.setVelo(CENTRE.vx() + 10, CENTRE.vy(), CENTRE.vz());}
     if(key == 'i'){CENTRE.setVelo(CENTRE.vx(), CENTRE.vy() + 10, CENTRE.vz());}
     if(key == 'o'){CENTRE.setVelo(CENTRE.vx(), CENTRE.vy(), CENTRE.vz() + 10);}
     if(key == 'j'){CENTRE.setVelo(CENTRE.vx() - 10, CENTRE.vy(), CENTRE.vz());}
     if(key == 'k'){CENTRE.setVelo(CENTRE.vx(), CENTRE.vy() - 10, CENTRE.vz());}
     if(key == 'l'){CENTRE.setVelo(CENTRE.vx(), CENTRE.vy(), CENTRE.vz() - 10);} // instanceof
     if(key == 'm'){POSSIBLE.setOn(!POSSIBLE.rocketOn);}
     if(key == 'n'){
         for(i=0; i<God.noP; i++){
             if(God.pArray(i) instanceof Asteroid){
                 God.pArray(i).nuke(nukePower, new PVector(God.pArray(i).x() - EARTH.x(), 
                  God.pArray(i).y() - EARTH.y(), God.pArray(i).z() - EARTH.z()));
             }
         }
     }
     if(key == 'b'){
         ArrayList astes = new ArrayList();
         for(i=0; i<God.noP; i++){
             if(God.pArray(i) instanceof Asteroid)
                 astes.add(God.pArray(i));
         }
         for(j=0; j<astes.size(); j++){
             Asteroid thisAste = (Asteroid) astes.get(j);
             PVector dir = new PVector(thisAste.x() - EARTH.x(), thisAste.y() - EARTH.y(), thisAste.z() - EARTH.z());
             dir = dir.cross(new PVector(thisAste.vx(), thisAste.vy(), thisAste.vz()));
             thisAste.splitApart(nukePower, dir);
         }
     }
     for(i=0; i<God.noP; i++) // Look for matching hotkey
         CENTRE = God.pArray(i).keySearch(key);
     
}//end keypressed

void mousePressed(){
    if(mouseButton==RIGHT){
        dragY = mouseY;
        oldDistance = distance;
    }
}

void mouseDragged(){
    if(mouseButton==RIGHT){
        distance = oldDistance*( 1.0+(mouseY-dragY)/(350.0f));
        if(distance<2) distance = 2;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
// RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET RESET ///
void reset(){ //////////////////////////////////////////////////////////////////////////////////
    // Clear planet array
    God.noP = 0;
    God.planArray.clear();
    God.notYetInitialized = true;
    
    // Reset variables
    countDown  = 365.25;
    crashFrame = 5;
    time = 0;
    
    // Asteroid parameters
    dangerDistance = 0;
    closestApproach = 100000;
  
    // Reinitialize objects
    // Declare and setup initial conditions
    SUN                = new Planet(); // Create a new planet
    SUN.name           = "Sun"; // NAME OF PLANET TEXTURE JPG MUST BE THE SAME AS THIS
    SUN.setMass(1.9891 * pow(10,27)); // IN UNITS OF MEGAGRAMS
    SUN.diam           = 1029.3258 * 5; // in px
    SUN.setLoca(61.169, 49.382, 19.857); // x y z in px
    SUN.setVelo(-0.364, -0.221, -0.087); // vx vy vz in px/day
    SUN.rota           = -0.0001; // just for asthetics
    SUN.tailColor      = #FFC400; // Colour of the trails
    SUN.zoomDist       = 300000;
    SUN.hotKey         = '`';
    SUN.initSetup(); // Must call setup or the values wont be initialized
    
    EARTH              = new Planet();
    EARTH.name         = "Earth";
    EARTH.setMass(5.9736 * pow(10,21));
    EARTH.diam         = 9.43945774; 
    EARTH.setLoca(-109627.148, -11982.705, -5196.091);
    EARTH.setVelo(194.058, -1742.092, -755.293);
    EARTH.tailColor    = #00FF00;
    EARTH.zoomDist     = 50;
    EARTH.hotKey       = '1';
    EARTH.initSetup();
    
    MOON               = new Planet();
    MOON.name          = "Moon";
    MOON.setMass(7.3477 * pow(10,19)); 
    MOON.diam          = 2.57131652;
    MOON.setLoca(-109524.414, -12235.74, -5294.745);
    MOON.setVelo(254.603, -1726.583, -742.848);
    MOON.tailColor     = 100;
    MOON.zoomDist      = 50;
    MOON.hotKey        = '2';
    MOON.initSetup();
    
    ASTEROID           = new Asteroid();
    ASTEROID.name      = "Asteroid";
    ASTEROID.setMass(2.7000 * pow(10,7)); 
    ASTEROID.diam      = 2.57;
    ASTEROID.setLoca(-114462.102, 81433.531, 32203.832);
    ASTEROID.setVelo(-798.102, -669.176, -271.504);
    ASTEROID.tailColor = #FF0000; 
    ASTEROID.zoomDist  = 50;
    ASTEROID.hotKey    = '3';
    ASTEROID.tnt       = nukePower;
    ASTEROID.blastDistance = BLASTDISTANCE;
    ASTEROID.splitDistance = SPLITDISTANCE;
    ASTEROID.initSetup();
    
    POSSIBLE            = new GravRocket(ASTEROID, TETDIST, rocketForce, collisPos);
    POSSIBLE.name       = "Tethering Rocket";
    POSSIBLE.setMass(10); // 10 Tonnes
    POSSIBLE.diam       = 0.2;
    POSSIBLE.tubeLength = 2;
    POSSIBLE.hotKey     = 'r';
    POSSIBLE.tailColor  = 255;
    POSSIBLE.initSetup();
    POSSIBLE.setOn(false);
    
    MERCURY            = new Planet();
    MERCURY.name       = "Mercury";
    MERCURY.setMass(3.3022 * pow(10,20)); 
    MERCURY.diam       = 3.611;
    MERCURY.setLoca(-31362.688, 17623.143, 12665.477);
    MERCURY.setVelo(-2377.656, -2258.589, -959.982);
    MERCURY.tailColor  = #FA7100;
    MERCURY.zoomDist   = 50;
    MERCURY.hotKey     = '4';
    MERCURY.initSetup();
    
    VENUS              = new Planet();
    VENUS.name         = "Venus";
    VENUS.setMass(4.8685 * pow(10,21));
    VENUS.diam         = 8.9565;
    VENUS.setLoca(9454.495, -72600.117, -33261.438);
    VENUS.setVelo(2209.843, 282.505, -12.743);
    VENUS.tailColor    = #FFFF00;
    VENUS.zoomDist     = 50;
    VENUS.hotKey       = '5';
    VENUS.initSetup();
    
    MARS               = new Planet();
    MARS.name          = "Mars";
    MARS.setMass(6.4185 * pow(10,20)); 
    MARS.diam          = 5.0263;
    MARS.setLoca(149665.781, -27707.648, -16752.293);
    MARS.setVelo(384.391, 1501.997, 678.548);
    MARS.tailColor     = #FF3300;
    MARS.zoomDist      = 50;
    MARS.hotKey        = '6';
    MARS.initSetup();
    
    JUPITER            = new Planet();
    JUPITER.name       = "Jupiter";
    JUPITER.setMass(1.8986 * pow(10,24));
    JUPITER.diam       = 103.467;
    JUPITER.setLoca(527861.5, 138795.656, 46638.359);
    JUPITER.setVelo(-232.987, 775.118, 337.914);
    JUPITER.tailColor  = #FFD152; 
    JUPITER.hotKey     = '7';
    JUPITER.initSetup();
    
    SATURN             = new Planet();
    SATURN.name        = "Saturn";
    SATURN.setMass(5.6832 * pow(10,23));
    SATURN.diam        = 86.182;
    SATURN.setLoca(-1033515.562, -245632.25, -56941.945);
    SATURN.setVelo(110.185, -554.226, -233.679);
    SATURN.tailColor   = #FF00FF;
    SATURN.hotKey      = '8';
    SATURN.initSetup();
    
    URANUS             = new Planet();
    URANUS.name        = "Uranus";
    URANUS.setMass(8.6810 * pow(10,22));
    URANUS.diam        = 37.535;
    URANUS.setLoca(2223560, 20183.252, -22603.752);
    URANUS.setVelo(-5.558, 380.607, 166.773);
    URANUS.tailColor   = #FF0080;
    URANUS.hotKey      = '9';
    URANUS.initSetup();
    
    NEPTUNE            = new Planet();
    NEPTUNE.name       = "Neptune";
    NEPTUNE.setMass(1.0243 * pow(10,23));
    NEPTUNE.diam       = 36.443;
    NEPTUNE.setLoca(2831514.5, -1582540.25, -718220.062);
    NEPTUNE.setVelo(178.991, 278.117, 109.392);
    NEPTUNE.tailColor  = #00B0FF;
    NEPTUNE.hotKey     = '0';
    NEPTUNE.initSetup();
      
      CENTRE = SUN; // Starting with sun as CENTRE
      
      // Asteroid params initialization
      closestApproach = sqrt( pow(EARTH.x() - ASTEROID.x(),2) +
                              pow(EARTH.y() - ASTEROID.y(),2) +
                              pow(EARTH.z() - ASTEROID.z(),2) );
    println("reset complete");
}

