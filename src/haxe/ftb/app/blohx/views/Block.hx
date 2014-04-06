package ftb.app.blohx.views;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;

import ftb.app.blohx.Types;

using feffects.Tween.TweenObject;

/**
 * ...
 * @author filt3rek
 */

class Block extends Sprite {
	
	public var xInc		: Float;
	public var yInc		: Float;
	public var weight	: Float;
	public var sens		: Int;
	
	var _bmp		: Bitmap;
	var _bmpd		: BitmapData;
	var _fired		: Bool;
	var _initScaleX	: Float;
		
	public function new( color : BlockColor ) {
		super();
		
		_bmpd			= CachedAssets.getBitmapData( Type.enumConstructor( color ) );
		_bmp			= new Bitmap( _bmpd, PixelSnapping.AUTO, true );
		_bmp.x			= - _bmp.width * .5;
		_bmp.y			= - _bmp.height * .5;
		mouseChildren	= false;
		_fired			= false;
		
		addChild( _bmp );
	}
	
	public function mutate( color : BlockColor ) {
		_bmpd		= CachedAssets.getBitmapData( Type.enumConstructor( color ) );
		_initScaleX	= scaleX;
		var tween	= null;
		if( !_fired )
			tween	= this.tween( { alpha : 0, scaleX : 0 }, Std.int( 125 + Math.random() * 125 ), true, mutateNext );
		else
			tween	= this.tween( { alpha : 0 }, Std.int( 125 + Math.random() * 125 ), true, mutateNext );
	}
	
	function mutateNext() {
		_bmp.bitmapData	= _bmpd;
		_bmp.smoothing	= true;
		if( !_fired )
			this.tween( { alpha : .5, scaleX : -_initScaleX }, Std.int( Math.random() * 125 + 125 ), true );
		else
			this.tween( { alpha : .5 }, Std.int( Math.random() * 125 + 125 ), true );
		_fired 			= true;
	}
}