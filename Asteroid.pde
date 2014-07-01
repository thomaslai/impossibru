// Asteroid child class for Impossibru Planetary Destruction Simulator
//
//

public class Asteroid extends Planet{
    float tnt, blastDistance, splitDistance, n_power, blastRadius, blastRadCounter;
    PVector blastLoc, blastDir;
//    Toroid blastRing;
  
    Asteroid(){
        super();
        this.tnt           = 0;
        this.blastDistance = 0;
        this.splitDistance = 0;
        this.blastRadius   = 40;
        this.blastRadCounter = 0;
    }
    
    public void nuke(float tnt, PVector direction){
        n_power = (sqrt(tnt * 4.184 * pow(10,9) /this.body.mass() /1000) /15.6);
        direction.normalize();
        direction.mult(n_power);
        this.setVelo(this.vx() + direction.x, this.vy() + direction.y, this.vz() + direction.z);
        
        // Draw explosion
        blastLoc = new PVector(this.x(), this.y(), this.z());
        blastDir = new PVector(direction.x, direction.y, direction.z);
        blastRadCounter = blastRadius;
    }
    
    void splitApart(float tnt, PVector direction){
        n_power = (sqrt(2 * tnt * 4.184 * pow(10,9) /this.body.mass() /1000) /15.6);
        direction.normalize();
        direction.mult(n_power);
        
        // Clone current asteroid
        Asteroid a2 = new Asteroid();
        a2.name      = "Asteroid";
        a2.setMass(this.body.mass()/2); 
        a2.diam      = this.diam/2;
        a2.setLoca(this.x(), this.y(), this.z());
        a2.setVelo(this.vx() + direction.x, this.vy() + direction.y, this.vz() + direction.z);
        a2.tailColor = #FF0000; 
        a2.zoomDist  = 50;
        a2.initSetup();
        a2.tail = (ArrayList) this.tail.clone();
        
        // Shrink current asteroid and change trajectory
        this.setMass(this.body.mass()/2);
        this.diam = this.diam/2;
        this.body3D.setRadius(this.diam/2);
        this.setVelo(this.vx() - direction.x, this.vy() - direction.y, this.vz() - direction.z);
        
        // Draw explosion
        blastLoc = new PVector(this.x(), this.y(), this.z());
        blastDir = new PVector(direction.x, direction.y, direction.z);
        blastRadCounter = blastRadius;
    }
    
    void move3D(){
        body3D.moveTo( this.x() - CENTRE.x(), this.y() - CENTRE.y(), this.z() - CENTRE.z());
        body3D.rotateBy(0, degrees(rotStop*rota*dt), 0);
        
        if(blastDistance > 0){
            PVector earthDist = new PVector(this.x() - EARTH.x(), this.y() - EARTH.y(), this.z() - EARTH.z());
            if(earthDist.mag() < this.blastDistance){
                this.nuke(this.tnt, earthDist);
                this.blastDistance = 0;
            }
        }
        
        if(splitDistance > 0){
            PVector earthDist = new PVector(this.x() - EARTH.x(), this.y() - EARTH.y(), this.z() - EARTH.z());
            if(earthDist.mag() < this.splitDistance){
                earthDist = earthDist.cross(new PVector(this.vx(), this.vy(), this.vz()));
                this.splitApart(this.tnt, earthDist);
                this.splitDistance = 0;
            }
        }
    }
    
    void draw3D(){
        body3D.draw();
        drawExplosion();
    }
    
    void drawExplosion(){
        if(blastRadCounter > 0){
            PVector ppd  = blastDir.cross(new PVector(0,0,1));
            ppd.normalize();
            PVector ppd2 = blastDir.cross(new PVector(ppd.x, ppd.y, ppd.z));
            ppd2.normalize();
            PVector ppd3 = new PVector(ppd.x + ppd2.x, ppd.y + ppd2.y, ppd.z + ppd2.z);
            ppd3.normalize();
            PVector ppd4 = new PVector(-ppd.x + ppd2.x, -ppd.y + ppd2.y, -ppd.z + ppd2.z);
            ppd4.normalize();
            ppd.mult( (blastRadius - blastRadCounter));
            ppd2.mult((blastRadius - blastRadCounter));
            ppd3.mult((blastRadius - blastRadCounter));
            ppd4.mult((blastRadius - blastRadCounter));
            stroke(255);
            fill(#00FF00,0);
            beginShape();
            curveVertex(blastLoc.x + ppd.x  - CENTRE.x(), blastLoc.y + ppd.y  - CENTRE.y(), blastLoc.z + ppd.z  - CENTRE.z());
            curveVertex(blastLoc.x + ppd3.x  - CENTRE.x(), blastLoc.y + ppd3.y  - CENTRE.y(), blastLoc.z + ppd3.z  - CENTRE.z());
            curveVertex(blastLoc.x + ppd2.x - CENTRE.x(), blastLoc.y + ppd2.y - CENTRE.y(), blastLoc.z + ppd2.z - CENTRE.z());
            curveVertex(blastLoc.x + ppd4.x  - CENTRE.x(), blastLoc.y + ppd4.y  - CENTRE.y(), blastLoc.z + ppd4.z  - CENTRE.z());
            curveVertex(blastLoc.x - ppd.x  - CENTRE.x(), blastLoc.y - ppd.y  - CENTRE.y(), blastLoc.z - ppd.z  - CENTRE.z());
            curveVertex(blastLoc.x - ppd3.x  - CENTRE.x(), blastLoc.y - ppd3.y  - CENTRE.y(), blastLoc.z - ppd3.z  - CENTRE.z());
            curveVertex(blastLoc.x - ppd2.x - CENTRE.x(), blastLoc.y - ppd2.y - CENTRE.y(), blastLoc.z - ppd2.z - CENTRE.z());
            curveVertex(blastLoc.x - ppd4.x  - CENTRE.x(), blastLoc.y - ppd4.y  - CENTRE.y(), blastLoc.z - ppd4.z  - CENTRE.z());
            curveVertex(blastLoc.x + ppd.x  - CENTRE.x(), blastLoc.y + ppd.y  - CENTRE.y(), blastLoc.z + ppd.z  - CENTRE.z());
            curveVertex(blastLoc.x + ppd3.x  - CENTRE.x(), blastLoc.y + ppd3.y  - CENTRE.y(), blastLoc.z + ppd3.z  - CENTRE.z());
            curveVertex(blastLoc.x + ppd2.x - CENTRE.x(), blastLoc.y + ppd2.y - CENTRE.y(), blastLoc.z + ppd2.z - CENTRE.z());
            endShape(CLOSE);
            blastRadCounter--;
        }
    }
  
}

//Toroid makeToroid(){
//  
//}
