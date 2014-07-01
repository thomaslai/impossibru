// TetherForce class for rocket propulsion
//
//

class TetherForce implements Force{
        Asteroid a;
        GravRocket b;
  	float force;
        PVector colPos;
  	boolean on;
	
	public TetherForce( Asteroid a, GravRocket b, float k, PVector colPos){
            this.a = a;
            this.b = b;
            this.force = k;
            this.colPos = colPos;
            on = true;
	}

	protected void setA( Asteroid p ){a = p;}

	public final void turnOff(){on = false;}

	public final void turnOn(){on = true;}
  
        public final void setOn(boolean o){ on = o;}

	public final void setThrust( float k ){this.force = k;}

	public void apply()
	{
		if ( on &&  a.body.isFree() )
		{
                        // Calculate orientation of rocket
                        PVector aste = new PVector(a.x(), a.y(), a.z());
                        aste = this.colPos.cross(aste);
                        if(time > 94.41 && time < 94.41+135.3){
                            b.setMinDist(-1*abs(b.minDist));
				    
                        }
                        else{
                            b.setMinDist(1*abs(b.minDist));
                        }
			PVector dir = new PVector(b.x() - a.x(), b.y() - a.y(), b.z() - a.z());
                        // normalize
                        dir.normalize();			
			// multiply by force
                        dir.mult(this.force);
			// apply
			if ( a.body.isFree() ){
                                a.body.force().add( dir.x, dir.y, dir.z );
                        }
		}
	}

	public final float getForce(){return force;}

	public final boolean isOn(){return on;}

	public final boolean isOff(){return !on;}

        public void drawThrust(){
            if(this.isOn()){
                PVector l = this.b.getOrientation();
                l.mult(b.tubeLength/2);
            
                stroke(#FFE200);
                line(a.x() - CENTRE.x(), a.y() - CENTRE.y(), a.z() - CENTRE.z(),
                     b.x() + l.x - CENTRE.x(), b.y() + l.y - CENTRE.y(), b.z() + l.z - CENTRE.z());
            }
        }
}
