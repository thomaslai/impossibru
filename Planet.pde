// Planet class file for use in Impossibru Planetary Destruction Simulator
//
//

////////////////////////////////////////////////////////////////////////////////////////
// GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD GOD /
static class God{ //////////////////////////////////////////////////////////////////////
    static int noP = 0;
    static ArrayList planArray = new ArrayList();
    static ParticleSystem physics;
    static boolean notYetInitialized = true;
    
    God(){
    }
    
    static Planet pArray(int a){
        return (Planet) planArray.get(a);
    }
}

///////////////////////////////////////////////////////////////////////////////////
// PLANET PLANET PLANET PLANET PLANET PLANET PLANET PLANET PLANET PLANET PLANET ///
class Planet extends God{ /////////////////////////////////////////////////////////
    String name;
    Particle body;
    Attraction[] attrArray;
    float diam, rota, zoomDist;
    Ellipsoid  body3D;
    ArrayList tail;
    int tailColor, planetIndex;
    char hotKey;
    
    // Class constructor
    Planet(){        
        if(notYetInitialized){ // First planet to create God
            God.physics = new ParticleSystem(); // New particle system without gravity
            God.physics.setIntegrator( ParticleSystem.RUNGE_KUTTA); 
            God.physics.setDrag(0);
            God.notYetInitialized = false;
        }    
        planetIndex = noP; // is the latest planet to be added to the array
        noP++; // increment planet count
        God.planArray.add(this);
        diam      = 10;
        rota      = 0.02;
        tail      = new ArrayList();
        tailColor = 255; // default tail color white
        zoomDist  = 300;
        body      = God.physics.makeParticle(0,0,0,0); // Create particle
    }
    
    float x(){
        return this.body.position().x();
    }
    
    float y(){
        return this.body.position().y();
    }
    
    float z(){
        return this.body.position().z();
    }
    
    float vx(){
        return this.body.velocity().x();
    }
    
    float vy(){
        return this.body.velocity().y();
    }
    
    float vz(){
        return this.body.velocity().z();
    }
    
    void setLoca(float x, float y, float z){
        body.position().set(x, y, z); // Set initial velocities
    }
    
    void setVelo(float vx, float vy, float vz){
        body.velocity().set(vx, vy, vz); // Set initial velocities
    }
    
    void setMass(float m){
        body.setMass(m);
    }
    
    void initSetup(){        
        for(i=0; i<planetIndex; i++){ // Create attractions
            God.physics.makeAttraction(this.body, God.pArray(i).body, grav, mindist);
        }
        body3D = AddEllipsoid(20,30,name + ".jpg",diam/2); // Create 3D object
        body3D.rotateBy(radians(-90), 0, 0); //correcting image orientation
        tail.add(new PVector(this.x(),this.y(),this.z()));
    }
    
    void draw3D(){
        body3D.draw();
    }
    
    void move3D(){
        body3D.moveTo( this.x() - CENTRE.x(), this.y() - CENTRE.y(), this.z() - CENTRE.z());
        body3D.rotateBy(0, degrees(rotStop*rota*dt), 0);
    }
    
    void popTrail(){
        tail.add(new PVector(this.x(), this.y(), this.z()));
        if(tail.size() > tailLength) // Remove oldest value if exceeding max trail length
            tail.remove(0);
    }
    
    void drawTrail(){
        PVector P1    = new PVector(0,0,0);
        PVector P2    = new PVector(0,0,0);
        int tailSize  = 0;
        
        tailSize = tail.size() - 1;
        for(j=tailSize; j>1; j-=1){
            stroke(tailColor, (int) 255*j/tailSize);
            
            // Get 4 points
            P1 = (PVector) tail.get(j);
            P2 = (PVector) tail.get(j-1);
            
            // Draw line
            line(P1.x - CENTRE.x(), P1.y - CENTRE.y(), P1.z - CENTRE.z(),
                 P2.x - CENTRE.x(), P2.y - CENTRE.y(), P2.z - CENTRE.z());
        }
    }
    
    Planet keySearch(char c){
        if(hotKey == c){
            distance = zoomDist;
            return this;
        }
        else
            return CENTRE;
    }
    
    void nuke(float tnt, PVector direction){}
    
    void splitApart(float tnt, PVector direction){}
} // end planet class

//////////////////////////////////////////////////////////////////////////////////////
// ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID /////
Ellipsoid AddEllipsoid(int slices, int segments, String textureFile, float radius){ //
    Ellipsoid aShape = new Ellipsoid(this, slices, segments);
    aShape.setTexture(textureFile);
    aShape.drawMode(Shape3D.TEXTURE);
    aShape.setRadius(radius);
    return aShape;
} // end AddEllipsoid
