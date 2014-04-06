package ftb.app.blohx.views;

import flash.display.Sprite;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.filters.GlowFilter;

import ftb.app.blohx.Types;

/**
 * ...
 * @author filt3rek
 */

class Label extends Sprite {
	
	public var text		(default, set_text)	: String;
	public var centered						: Bool;
	
	var _tf	: TextField;
	
	public function new( s = "", ?size = 100, centered = false ) {
		super();
		
		this.centered 			= centered;
		
		var tfx 				= new TextFormat();
		tfx.font				= CachedAssets.getFont( "absender" ).fontName;
		tfx.size				= size;
		tfx.color				= 0xFFFFFF;
		
		_tf						= new TextField();
		_tf.selectable			= false;
		_tf.autoSize			= TextFieldAutoSize.LEFT;
		_tf.embedFonts			= true;
		_tf.defaultTextFormat	= tfx;
		
		if ( s != "" )
			text = s;
			
		_tf.filters				= [ new GlowFilter( 0x000000 ) ];
		
		addChild( _tf );
		
		mouseChildren			= false;
	}
	
	function set_text( s : String ) {
		text 		= s;
		_tf.text	= text;
		
		if ( !centered )
			return text;
			
		_tf.x		= -_tf.width * .5;
		_tf.y		= -_tf.height * .5;
				
		return text;
	}
}
