// GravRocket class for impossibru planetary destruction simulator
//
//

class GravRocket extends Rocket{
    float minDist;
    Asteroid asteroid; // asteroid to tether with
    TetherForce tether;
    boolean rocketOn;
    PVector colPos;
    
    GravRocket(Asteroid a, float minDist, float force, PVector colPos){
        super();
        this.asteroid = a;
        this.minDist = minDist;
        this.tether = new TetherForce(a, this, force, colPos);
        God.physics.addCustomForce(this.tether);
        this.rocketOn = false;
        this.tether.setOn(this.rocketOn);
    }
    
    void initSetup(){
        // Distribute mass
        this.bodyTop.setMass(this.body.mass()*0.5);
        this.body.setMass(this.body.mass()*0.5);
        // Calculate velocity projection
        PVector aste = new PVector(asteroid.x(), asteroid.y(), asteroid.z());
        PVector vaste = new PVector(-asteroid.vx(), -asteroid.vy(), -asteroid.vz());
        aste.normalize();
        vaste.normalize();
        PVector zvec = aste.cross(vaste);
        zvec.normalize();
        zvec.mult(minDist);
        PVector btop = new PVector(vaste.x, vaste.y, vaste.z);
        aste.mult(minDist);
        btop.mult(tubeLength/2);
        body.position().set(asteroid.x() + zvec.x + btop.x, asteroid.y() + zvec.y + btop.y, asteroid.z() + zvec.z + btop.z);
        bodyTop.position().set(asteroid.x() + zvec.x - btop.x, asteroid.y() + zvec.y - btop.y, asteroid.z() + + zvec.z - btop.z);
        body.velocity().set(asteroid.vx(), asteroid.vy(), asteroid.vz());
        bodyTop.velocity().set(asteroid.vx(), asteroid.vy(), asteroid.vz());
             
        for(i=0; i<planetIndex-1; i++){ // Create attractions
            God.physics.makeAttraction(this.body, God.pArray(i).body, grav, mindist);
            God.physics.makeAttraction(this.bodyTop, God.pArray(i).body, grav, mindist);
        }
        
        fuselage.setSize(this.diam, this.diam, this.diam, this.diam, tubeLength);
        coneLength = 3*this.diam;
        noseCone.setSize(this.diam, this.diam, coneLength);
        
        tail.add(new PVector(this.x(),this.y(),this.z()));       
        
    }
   
    void draw3D(){
        if(rocketOn){
            fuselage.draw();
            noseCone.draw();
            tether.drawThrust();
        }
    }
    
    void move3D(){            
        // limit position and velocity of rocket wrt asteroid
        PVector aste = new PVector(asteroid.x(), asteroid.y(), asteroid.z());
        PVector vaste = new PVector(-asteroid.vx(), -asteroid.vy(), -asteroid.vz());
        aste.normalize();
        vaste.normalize();
        PVector zvec = aste.cross(vaste);
        zvec.normalize();
        zvec.mult(minDist);
        PVector btop = new PVector(vaste.x, vaste.y, vaste.z);
        aste.mult(minDist);
        btop.mult(tubeLength/2);
        body.position().set(asteroid.x() + zvec.x + btop.x, asteroid.y() + zvec.y + btop.y, asteroid.z() + zvec.z + btop.z);
        bodyTop.position().set(asteroid.x() + zvec.x - btop.x, asteroid.y() + zvec.y - btop.y, asteroid.z() + zvec.z - btop.z);
        body.velocity().set(asteroid.vx(), asteroid.vy(), asteroid.vz());
        bodyTop.velocity().set(asteroid.vx(), asteroid.vy(), asteroid.vz());
        
        
        // Move 3D objects
        aste.div(2);
        fuselage.rotateTo(this.getOriAngles());
        noseCone.rotateTo(this.getOriAngles());
        fuselage.moveTo(this.x() - btop.x - CENTRE.x(), this.y() - btop.y - CENTRE.y(), this.z() - btop.z - CENTRE.z());
        noseCone.moveTo(this.bodyTop.position().x() - CENTRE.x(), 
                        this.bodyTop.position().y() - CENTRE.y(), 
                        this.bodyTop.position().z() - CENTRE.z());
        
    }
    
    void drawTrail(){
        if(rocketOn){
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
    }
    
    void setMinDist(float m){
        this.minDist = m;      
    }
    
    public final void setOn(boolean o){ this.rocketOn = o; this.tether.setOn(o); }
  
}
