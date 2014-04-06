package ftb.app.blohx;

import haxe.ds.StringMap;

import flash.display.BitmapData;
import flash.media.Sound;
import flash.text.Font;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.utils.ByteArray;

#if openfl
import openfl.Assets;
#elseif flash
@:bitmap( "assets/img/Haxe_logo_grayscale.png" )
class Logo extends BitmapData { }
@:sound( "assets/snd/bounce.wav" )
class BounceSnd extends Sound { }
@:sound( "assets/snd/explosion.wav" )
class ExplosionSnd extends Sound { }
@:sound( "assets/snd/fired.wav" )
class FiredSnd extends Sound { }
@:sound( "assets/snd/mutation.wav" )
class MutationSnd extends Sound { }
@:sound( "assets/snd/no_match.wav" )
class NoMathSnd extends Sound { }
@:font( "assets/font/absender1.ttf" )
class Absender extends Font {}
class Assets {
	public static function getBitmapData( s : String ) {
		return switch( s ) {
			case "gray"	:	new Logo( 0, 0 );
			default		:	null;
		}
	}
	public static function getSound( s : String ) {
		return switch( s ) {
			case "bounce"		:	new BounceSnd();
			case "explosion"	:	new ExplosionSnd();
			case "fired"		:	new FiredSnd();
			case "mutation"		:	new MutationSnd();
			case "no_match"		:	new NoMathSnd();
			default		:	null;
		}
	}
	public static function getFont( s : String ) {
		return switch( s ) {
			case "absender"		:	new Absender();
			default		:	null;
		}
	}
}
#end

enum BlockColor{
	red;
	green;
	blue;
	yellow;
	purple;
	brown;
}

typedef TBlock = {
	color	: BlockColor,
	fired	: Bool
}

typedef TMutations	= Array<{ index : Int, color : BlockColor }>
typedef TSelection	= Array<Array<Int>>

class CachedAssets { 
	
	static var _gfx		: StringMap<BitmapData>;
	static var _sfx		: StringMap<Sound>;
	static var _fonts	: StringMap<Font>;
	
	public static function initialize() {
		_gfx 	= new StringMap<BitmapData>();
		_sfx	= new StringMap<Sound>();
		_fonts	= new StringMap<Font>();
		
		var bmpdBase	= Assets.getBitmapData( "gray" );
		var colors		= [ red, green, blue, yellow, purple, brown ];
		for ( color in colors ) {
			var bmpd = bmpdBase.clone();
			
			bmpd.colorTransform( new Rectangle( 0, 0, bmpd.width, bmpd.height ), switch ( color ) {
				case red	:
					new ColorTransform( 1, 0, 0 );
				case green	:
					new ColorTransform( 0, 1, 0 );
				case blue	:
					new ColorTransform( 0.3, 0.6, 0.9 );
				case yellow	:
					new ColorTransform( 1, 1, 0 );
				case purple	:
					new ColorTransform( 1, 0, 1 );
				case brown	:
					new ColorTransform( 0.6, 0.3, 0.0 );
			} );
			_gfx.set( Type.enumConstructor( color ) , bmpd  );
		}
		bmpdBase.dispose();
		
		_sfx.set( "bounce", Assets.getSound( "bounce" ) );
		_sfx.set( "explosion", Assets.getSound( "explosion" ) );
		_sfx.set( "fired", Assets.getSound( "fired" ) );
		_sfx.set( "mutation", Assets.getSound( "mutation" ) );
		_sfx.set( "no_match", Assets.getSound( "no_match" ) );
		
		_fonts.set( "absender", Assets.getFont( "absender" ) );
	}
	
	public static function dispose() {
		for ( bmpd in _gfx )
			bmpd.dispose();
			
		_gfx	= null;
		_sfx	= null;
		_fonts	= null;
	}
	
	public static function getBitmapData( id : String ) {
		return _gfx.get( id );
	}
	
	public static function getSound( id : String ) {
		return _sfx.get( id );
	}
	
	public static function getFont( id : String ) {
		return _fonts.get( id );
	}
}