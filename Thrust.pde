//// Thrust class for rocket propulsion
////
////
//
//class Thrust implements Force{
//        Planet a;
//  	float thrust;
//  	boolean on;
//	
//	public Thrust( Planet a, float k){
//            this.a = a;
//            this.thrust = k;
//            on = true;
//	}
//
//	protected void setA( Planet p ){a = p;}
//
//	public final void turnOff(){on = false;}
//
//	public final void turnOn(){on = true;}
//
//	public final void setThrust( float k ){this.thrust = k;}
//
//	public final Planet getObject(){return a;}
//
//	public void apply()
//	{
//		if ( on &&  a.body.isFree() )
//		{
//                        // Calculate orientation of rocket
//			PVector orie = new PVector(a.bodyTop.position().x() - a.x(),
//                                                   a.bodyTop.position().y() - a.y(),
//                                                   a.bodyTop.position().z() - a.z());
//
//                        // normalize
//                        orie.normalize();
//			
//			// multiply by force
//                        orie.mult(this.thrust);	
//
//			// apply
//			
//			if ( a.body.isFree() )
//				a.body.force().add( orie.x, orie.y, orie.z );
//		}
//	}
//
//	public final float getThrust(){return thrust;}
//
//	public final boolean isOn(){return on;}
//
//	public final boolean isOff(){return !on;}
//
//        public void drawThrust(){
//            if(this.isOn()){
//                stroke(#FFE200);
//                PVector l = this.a.getOrientation();
//                l.mult(this.thrust/30);
//                line(this.a.x() - CENTRE.x(), this.a.y() - CENTRE.y(), this.a.z() - CENTRE.z(),
//                     this.a.x() - l.x - CENTRE.x(), this.a.y() - l.y - CENTRE.y(), this.a.z() - l.z - CENTRE.z());
//            }
//        }
//}
//
//class SideThrust extends Thrust{
//    String direction;
//    
//    public SideThrust(Rocket a, float k){
//        super(a,k);
//    }
//    
//    public void turnAllOff(){ this.direction = "off"; }
//    
//    public void leftOn(){ this.direction = "left"; }
//    
//    public void rightOn(){ this.direction = "right"; }
//    
//    public void upOn(){ this.direction = "up"; }
//    
//    public void downOn(){ this.direction = "down"; }
//    
//    public void apply(){
//        // Calculate orientation of rocket
//        PVector orie = this.a.getOrientation();   
//        PVector xp = (new PVector(0,0,1)).cross(orie);
//        PVector zp = orie.cross(xp);        
//        xp.normalize();
//        zp.normalize();
//        xp.mult(this.thrust);
//        zp.mult(this.thrust);
//        
//        if(  a.body.isFree() ){
//            if ( direction == "up" ){
//                a.bodyTop.force().add( -zp.x, -zp.y, -zp.z );
//            }
//            if ( direction == "down" ){  
//                a.bodyTop.force().add( zp.x, zp.y, zp.z );
//            }
//            if ( direction == "right" ){  
//                a.bodyTop.force().add( -xp.x, -xp.y, -xp.z );
//            }
//            if ( direction == "left" ){  
//                a.bodyTop.force().add( xp.x, xp.y, xp.z );
//            }
//        }
//    }
//    
//    public void drawThrust(){
//        stroke(#FFE200);
//        
//        PVector orie = this.a.getOrientation();   
//        PVector xp = (new PVector(0,0,1)).cross(orie);
//        PVector zp = orie.cross(xp);        
//        xp.normalize();
//        zp.normalize();
//        xp.mult(this.thrust/30);
//        zp.mult(this.thrust/30);
//        
//        if ( direction == "up" ){
//            line(this.a.bodyTop.position().x() - CENTRE.x(), this.a.bodyTop.position().y() - CENTRE.y(), this.a.bodyTop.position().z() - CENTRE.z(),
//                 this.a.bodyTop.position().x() + zp.x - CENTRE.x(), this.a.bodyTop.position().y() + zp.y - CENTRE.y(), this.a.bodyTop.position().z() + zp.z - CENTRE.z());
//        }
//        if ( direction == "down" ){  
//            line(this.a.bodyTop.position().x() - CENTRE.x(), this.a.bodyTop.position().y() - CENTRE.y(), this.a.bodyTop.position().z() - CENTRE.z(),
//                 this.a.bodyTop.position().x() - zp.x - CENTRE.x(), this.a.bodyTop.position().y() - zp.y - CENTRE.y(), this.a.bodyTop.position().z() - zp.z - CENTRE.z());
//        }
//        if ( direction == "right" ){  
//            line(this.a.bodyTop.position().x() - CENTRE.x(), this.a.bodyTop.position().y() - CENTRE.y(), this.a.bodyTop.position().z() - CENTRE.z(),
//                 this.a.bodyTop.position().x() + xp.x - CENTRE.x(), this.a.bodyTop.position().y() + xp.y - CENTRE.y(), this.a.bodyTop.position().z() + xp.z - CENTRE.z());
//        }
//        if ( direction == "left" ){  
//            line(this.a.bodyTop.position().x() - CENTRE.x(), this.a.bodyTop.position().y() - CENTRE.y(), this.a.bodyTop.position().z() - CENTRE.z(),
//                 this.a.bodyTop.position().x() - xp.x - CENTRE.x(), this.a.bodyTop.position().y() - xp.y - CENTRE.y(), this.a.bodyTop.position().z() - xp.z - CENTRE.z());
//        }
//    } // end draw stroke
//}
