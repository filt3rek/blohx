package ftb.app.blohx.views;

import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import haxe.ds.StringMap;

import ftb.app.blohx.Types;

/**
 * ...
 * @author filt3rek
 */

class SWRZText extends Sprite {
	
	static var _chars		: StringMap<Array<String>>;
	static var _bmpdRefs	= [ "red", "green", "blue", "yellow", "purple", "brown" ];
	
	public var SCROLL_X_SPEED	= 10;
	public var WARP_SPEED		= .01;
	public var WARP_OFFSET		= .01;
	public var WARP_FACTOR		= .2;
	public var WARP_WAVES		= 2;
	public var ROTATION_SPEED	= .01;
	public var ROTATION_OFFSET	= 90;
	public var ZOOM_SPEED		= .05;
	public var ZOOM_FACTOR		= .5;
	
	public var scroll			= true;
	public var warp				= false;
	public var rotate			= false;
	public var zoom				= false;
	
	public var isPlaying (default, null) : Bool;
		
	var _grid			: Array<Array<Int>>;
	var _bmps			: List<Bitmap>;
	var _containers		: List<Sprite>;
	
	var _text			: String;
	var _bmpSize		: Float;
	var _cols			: Int;
	var _width			: Float;
	var _midWidth		: Float;
	var _sineCoef		: Float;
	
	var _pointer		: Int;
	
	var _warpI			: Float;
	var _rotationI		: Float;
	var _zoomI			: Float;
	
	public function new( text : String, blockSize : Float, cols : Int ) {
		super();
		
		_text		= text;
		_bmpSize	= blockSize;
		_cols		= cols;
		_width		= _bmpSize * _cols;
		_midWidth	= _bmpSize * _cols * .5;
		_sineCoef	= Math.PI / _width;
		
		_warpI		= 0;
		_rotationI	= 0;
		_zoomI		= 0;
		
		_bmps		= new List();
		_containers	= new List();
		_pointer	= 0;
		
		_grid		= [];
		var col		= null;
		var emptyCol = [];
		var letter	= null;
		var data	= null;
		for ( n in 0...text.length ) {
			letter	= text.substr( n, 1 );
			data	= _chars.get( letter );
			for ( i in 0...data[ 0 ].length ) {
				col = [];
				for ( j in 0...data.length ) {
					col.push( data[ j ].substr( i, 1 ) == "#" ? 1 : 0 );
				}
				emptyCol.push( 0 );
				_grid.push( col );
			}
			_grid.push( emptyCol );
		}
		
		mouseEnabled	= false;
		mouseChildren	= false;
		
		for ( i in 0..._cols )
			cb_enterFrame();
			
		warp	= true;
		rotate	= true;
		zoom	= true;
		
		isPlaying	= false;
	}
	
	public function play( fromCurrentState = false ) {
		if ( fromCurrentState )	{
			_rotationI	= Math.asin( rotation / ROTATION_OFFSET );
			_zoomI		= Math.asin( ( scaleX - 1 ) / ZOOM_FACTOR );
		}
		
		addEventListener( Event.ENTER_FRAME, cb_enterFrame );
		isPlaying = true;
	}
	
	public function stop() {
		removeEventListener( Event.ENTER_FRAME, cb_enterFrame );
		isPlaying = false;
	}
	
	function cb_enterFrame(?_) {
		if ( scroll ) {
			if ( _containers.isEmpty() || _containers.last().x < _midWidth - _bmpSize + SCROLL_X_SPEED ) {
				var col 		= _grid[ _pointer ];
				var block		= null;
				var container	= new Sprite();
				var bmpd		= null;
				var bmp			= null;
				
				for ( i in 0...col.length ) {
					if ( col[ i ] != 0 ) {
						bmpd		= CachedAssets.getBitmapData( _bmpdRefs[ Std.int( Math.random() * _bmpdRefs.length ) ] );
						bmp			= new Bitmap( bmpd );
						bmp.width	= _bmpSize;
						bmp.height	= _bmpSize;
						bmp.y		= - col.length * _bmpSize * .5 + i * _bmpSize;
						
						container.addChild( bmp );
					}
				}
				
				container.x	= _midWidth;
				
				addChild( container );
				_containers.add( container );
				
				_pointer++;
				if ( _pointer >= _grid.length )
					_pointer = 0;
			}
		}
		
		var sine = 0.0;
		var calc = 0.0;
		for ( container in _containers ) {
			if ( scroll ) {
				container.x -= SCROLL_X_SPEED;
				if ( container.x <= -_midWidth ) {
					removeChild( container );
					_containers.remove( container );
				}
			}
						
			if ( warp ) {
				_warpI	-= WARP_SPEED;
				calc = container.x * _sineCoef * WARP_WAVES;
				sine = Math.sin( calc + _warpI ) * WARP_FACTOR;
				container.scaleX = container.scaleY = 1 + sine;
			}
		}
		
		if ( rotate ) {
			_rotationI += ROTATION_SPEED;
			rotation = Math.sin( _rotationI ) * ROTATION_OFFSET;
		}
		
		if ( zoom ) {
			_zoomI += ZOOM_SPEED;
			scaleX = scaleY = 1 + Math.sin( _zoomI ) * ZOOM_FACTOR;
		}
	}
	
	// DATA	
	static function __init__() {
		_chars = new StringMap();
		
		_chars.set( "A", [
			" ### ",
			"#   #",
			"#####",
			"#   #",
			"#   #",
		] );
		
		_chars.set( "B", [
			" ### ",
			"#   #",
			"#### ",
			"#   #",
			"#### ",
		] );
		
		_chars.set( "C", [
			" ### ",
			"#   #",
			"#    ",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "D", [
			" ### ",
			"#   #",
			"#   #",
			"#   #",
			"#### ",
		] );
		
		_chars.set( "E", [
			" ### ",
			"#    ",
			"###  ",
			"#    ",
			"#####",
		] );
		
		_chars.set( "F", [
			" ####",
			"#    ",
			"###  ",
			"#    ",
			"#    ",
		] );
		
		_chars.set( "G", [
			" ### ",
			"#    ",
			"#  ##",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "H", [
			"#   #",
			"#   #",
			"#####",
			"#   #",
			"#   #",
		] );
		
		_chars.set( "I", [
			"  #  ",
			"  #  ",
			"  #  ",
			"  #  ",
			"  #  ",
		] );
		
		_chars.set( "J", [
			"#### ",
			"    #",
			"    #",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "K", [
			"#    ",
			"#  # ",
			"###  ",
			"#  # ",
			"#   #",
		] );
		
		_chars.set( "L", [
			"#    ",
			"#    ",
			"#    ",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "M", [
			"## ##",
			"# # #",
			"#   #",
			"#   #",
			"#   #",
		] );
		
		_chars.set( "N", [
			"##  #",
			"# # #",
			"# # #",
			"# # #",
			"#  ##",
		] );
		
		_chars.set( "O", [
			" ### ",
			"#   #",
			"#   #",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "P", [
			" ### ",
			"#   #",
			"#### ",
			"#    ",
			"#    ",
		] );
		
		_chars.set( "Q", [
			" ### ",
			"#   #",
			"#   #",
			"#  # ",
			" ## #",
		] );
		
		_chars.set( "R", [
			" ### ",
			"#   #",
			"#### ",
			"#  # ",
			"#   #",
		] );
		
		_chars.set( "S", [
			" ### ",
			"#    ",
			" ### ",
			"    #",
			" ### ",
		] );
		
		_chars.set( "T", [
			"#### ",
			"  #  ",
			"  #  ",
			"  #  ",
			"  #  ",
		] );
		
		_chars.set( "U", [
			"#   #",
			"#   #",
			"#   #",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "V", [
			"#   #",
			"#   #",
			"#   #",
			" # # ",
			"  #  ",
		] );
		
		_chars.set( "W", [
			"#   #",
			"#   #",
			"#   #",
			"# # #",
			" # # ",
		] );
		
		_chars.set( "X", [
			"#   #",
			"#   #",
			" ### ",
			"#   #",
			"#   #",
		] );
		
		_chars.set( "Y", [
			"#   #",
			"#   #",
			" ### ",
			"  #  ",
			"  #  ",
		] );
		
		_chars.set( "Z", [
			"#####",
			"    #",
			" ### ",
			"#    ",
			"#####",
		] );
		
		_chars.set( "0", [
			" ### ",
			"#   #",
			"# # #",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "1", [
			"  #  ",
			" ##  ",
			"# #  ",
			"  #  ",
			"  #  ",
		] );
		
		_chars.set( "2", [
			" ### ",
			"    #",
			" ### ",
			"#    ",
			"#####",
		] );
		
		_chars.set( "3", [
			" ### ",
			"    #",
			"  ## ",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "4", [
			"  ## ",
			" # # ",
			"#####",
			"   # ",
			"   # ",
		] );
		
		_chars.set( "5", [
			"#####",
			"#    ",
			"#####",
			"    #",
			"#### ",
		] );
		
		_chars.set( "6", [
			" ### ",
			"#    ",
			"#### ",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "7", [
			"#### ",
			"    #",
			"  ###",
			"   # ",
			"  #  ",
		] );
		
		_chars.set( "8", [
			" ### ",
			"#   #",
			" ### ",
			"#   #",
			" ### ",
		] );
		
		_chars.set( "9", [
			" ### ",
			"#   #",
			" ####",
			"    #",
			" ### ",
		] );
		
		_chars.set( " ", [
			"     ",
			"     ",
			"     ",
			"     ",
			"     ",
		] );
		
		_chars.set( ".", [
			"     ",
			"     ",
			"     ",
			"     ",
			"  #  ",
		] );
		
		_chars.set( "!", [
			"  #  ",
			"  #  ",
			"  #  ",
			"     ",
			"  #  ",
		] );
		
		_chars.set( ":", [
			"     ",
			"  #  ",
			"     ",
			"  #  ",
			"     ",
		] );
		
		_chars.set( "/", [
			"    #",
			"   # ",
			"  #  ",
			" #   ",
			"#    ",
		] );
		
		_chars.set( "-", [
			"     ",
			"     ",
			"#####",
			"     ",
			"     ",
		] );
		
		_chars.set( "#", [
			" # # ",
			"#####",
			" # # ",
			"#####",
			" # # ",
		] );
	}
}