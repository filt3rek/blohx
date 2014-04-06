package ftb.app.blohx.views;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.Lib;

import ftb.app.blohx.Types;

/**
 * ...
 * @author filt3rek
 */

private class Star extends Sprite {
	public var origAngle			: Float;
	public var angle				: Float;
	public var zInc					: Float;
	public var Z					: Float;
	
	public function new( bmp : Bitmap ) {
		super();
		zInc		= .1;
		Z			= 0;
		
		bmp.x = -bmp.width * .5;
		bmp.y = -bmp.height * .5;
		addChild( bmp );
		mouseEnabled	= false;
		mouseChildren	= false;
	}
}

class StarFieldZ extends Sprite {
	
	static var _bmpdRefs	= [ "red", "green", "blue", "yellow", "purple", "brown" ];
	
	public var ANGLE_OFFSET		= 3.14 * .25;
	public var ROTATION_SPEED	= .05;
	public var SPEED_Z			= 15;
	
	public var scroll			= true;
	public var rotate			= true;
		
	var _w		: Int;
	var _h		: Int;
	var _stars	: List<Star>;
	var _i		: Float;
	
	public function new( w : Int, h : Int ) {
		super();
		_w				= w;
		_h				= h;
		_stars			= new List();
		_i				= 0;
		mouseEnabled	= false;
		mouseChildren	= false;
	}
	
	public function generate( n : Int ) {
		var star = null;
		for ( i in 0...n ) {
			star			= new Star( new Bitmap( CachedAssets.getBitmapData( _bmpdRefs[ Std.int( Math.random() * _bmpdRefs.length ) ] ) ) );
			star.zInc		= ( .25 + Math.random() * .75 ) * SPEED_Z;
			star.Z			= Math.random() * _w * .5;
			star.angle		= ( ( 360 * i ) / n ) / Math.PI * 2;
			star.origAngle	= star.angle;
			star.x			= _w * .5 + Math.cos( star.angle ) * star.Z;
			star.y			= _h * .5 + Math.sin( star.angle ) * star.Z;
			star.width		= star.height = star.Z * .1;
			star.rotation	= star.angle * 180 / Math.PI;	
			
			_stars.add( star );
			addChild( star );
		}
	}
	
	public function play() {
		Lib.current.addEventListener( Event.ENTER_FRAME, cb_EnterFrame );
	}
	
	public function stop() {
		Lib.current.removeEventListener( Event.ENTER_FRAME, cb_EnterFrame );
	}
	
	function cb_EnterFrame(_) {
		var sin = 0.0;
		if ( rotate ) {
			_i 	+= ROTATION_SPEED;
			sin = Math.sin( _i ) * ANGLE_OFFSET;
		}
		for ( star in _stars ) {
			if( scroll )
				star.Z 		+= star.zInc;
			star.angle		= star.origAngle + sin;
			star.x			= _w * .5 + Math.cos( star.angle ) * star.Z;
			star.y			= _h * .5 + Math.sin( star.angle ) * star.Z;
			star.width		= star.height = star.Z * .1;
			star.rotation	= star.angle * 180 / Math.PI;
			
			if ( star.x > _w || star.x < 0 || star.y > _h || star.y < 0 )
				star.Z	= 0;
		}
	}	
}