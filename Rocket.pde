// Rocket class for Impossibru Planetary Destruction Simulator
//
//

class Rocket extends Planet{
    Particle bodyTop; // top of rocket to create a 2-particle system
    Cone noseCone;
    Tube fuselage;
    Spring bodyGlue;
    float coneLength, tubeLength, spinLimit, thrustStrength, sideStrength;
    
    Rocket(){
        planetIndex = noP; // is the latest planet to be added to the array
        noP++; // increment planet count
        God.planArray.add(this);
        diam       = 10;
        tail       = new ArrayList();
        tailColor  = 255; // default tail color white
        zoomDist   = 50;
        tubeLength = 3;
        spinLimit  = 5;
        thrustStrength = 1000;
        sideStrength   = 500;
        body       = God.physics.makeParticle(0,0,0,0); // Create particle
        bodyTop    = God.physics.makeParticle(0,0,0,0); // Create particle
        noseCone   = AddCone(20);
        fuselage   = AddFuselage(20,20);
    }
    
    void initSetup(){
        // Distribute mass
        this.bodyTop.setMass(this.body.mass()*0.5);
        this.body.setMass(this.body.mass()*0.5);
        
        // Set particles in correct orientation and add rigid spring between them
        // Calculate velocity projection
        PVector velo = new PVector(this.vx(), this.vy(), this.vz());
        velo.normalize();
        velo.mult(tubeLength);
        bodyTop.position().set(this.x() + velo.x, this.y() + velo.y, this.z() + velo.z);
        bodyTop.velocity().set(this.vx(), this.vy(), this.vz());
        
        // Add rigid spring
        bodyGlue = God.physics.makeSpring(this.body, this.bodyTop, 10000, 10000, tubeLength);
        bodyGlue.setRestLength(tubeLength);
        bodyGlue.setStrength(10000);
        bodyGlue.setDamping(100);
        for(i=0; i<planetIndex-1; i++){ // Create attractions
            God.physics.makeAttraction(this.body, God.pArray(i).body, grav, mindist);
            God.physics.makeAttraction(this.bodyTop, God.pArray(i).body, grav, mindist);
        }
        fuselage.setSize(this.diam, this.diam, this.diam, this.diam, tubeLength);
        coneLength = 3*this.diam;
        noseCone.setSize(this.diam, this.diam, coneLength);
        
        // Add thrust
//        t     = new Thrust(this, thrustStrength);
//        tside = new SideThrust(this, sideStrength);
//        God.physics.addCustomForce(t);
//        God.physics.addCustomForce(tside);
//        t.turnOff();
//        tside.turnAllOff();
        tail.add(new PVector(this.x(),this.y(),this.z()));
    }
    
    PVector getOrientation(){
        PVector orie =  new PVector(this.bodyTop.position().x() - this.x(),
                                    this.bodyTop.position().y() - this.y(),
                                    this.bodyTop.position().z() - this.z());
        orie.normalize();
        return orie;
    }
    
    PVector getOriAngles(){
        PVector dirv = this.getOrientation(); // vector of B - A
        return new PVector(0,-atan2(dirv.z, dirv.x),asin(dirv.y) + HALF_PI);
    }
    
    void draw3D(){
        fuselage.draw();
        noseCone.draw();
//        t.drawThrust();
//        tside.drawThrust();
    }
    
    void move3D(){      
        // limit position for rigid body
        PVector apos = new PVector(this.x(), this.y(), this.z());
        PVector bpos = new PVector(this.bodyTop.position().x(), this.bodyTop.position().y(), this.bodyTop.position().z());
        PVector diff = PVector.sub(bpos,apos);
//        diff.limit(tubeLength);
//        bodyTop.position().set(apos.x + diff.x,apos.y + diff.y,apos.z + diff.z);
        
        // limit spin for stability
        PVector avel = new PVector(this.vx(), this.vy(), this.vz());
        PVector bvel = new PVector(this.bodyTop.velocity().x(), this.bodyTop.velocity().y(), this.bodyTop.velocity().z());
        PVector diffv = PVector.sub(bvel,avel);
        diffv.limit(spinLimit);
        bodyTop.velocity().set(avel.x + diffv.x,avel.y + diffv.y,avel.z + diffv.z);

        diff.div(2);
        fuselage.rotateTo(this.getOriAngles());
        noseCone.rotateTo(this.getOriAngles());
        fuselage.moveTo(this.x() + diff.x - CENTRE.x(), this.y() + diff.y - CENTRE.y(), this.z() + diff.z - CENTRE.z());
        noseCone.moveTo(this.bodyTop.position().x() - CENTRE.x(), 
                        this.bodyTop.position().y() - CENTRE.y(), 
                        this.bodyTop.position().z() - CENTRE.z());
        
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ADDELLIPSOID ////////
Tube AddFuselage(int slices, int segments){ ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Tube aShape = new Tube(this, slices, segments);
    return aShape;
} // end AddEllipsoid

Cone AddCone(int slices){ ///////////////////////////////////////////////////////////////////////////////////
    Cone aShape = new Cone(this, slices);
    return aShape;
} // end AddEllipsoid
