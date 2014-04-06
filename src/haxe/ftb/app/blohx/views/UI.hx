package ftb.app.blohx.views;

import haxe.Timer;

import flash.display.Bitmap;

import flash.display.Shape;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.MouseEvent;

import feffects.easing.Expo;
import feffects.easing.Bounce;
import feffects.Tween;

import ftb.app.blohx.Types;

using feffects.Tween.TweenObject;

/**
 * ...
 * @author filt3rek
 */

class UI extends Sprite {
	
	public var onExit		(default, null)	: List<Void->Void>;
	public var onReplay		(default, null)	: List<Void->Void>;
	
	public var gameBoard	: GameBoard;
	
	var _switchSensor		: Sprite;
	var _swrzText			: SWRZText;
	var _sf					: StarFieldZ;
	var _levelLabel			: Label;
	var _scoreLabel			: Label;
	var _replayBtn			: Label;
	var _exitBtn			: Label;
	var _bounceSound		: Sound;
	var _bounceSoundChannel	: SoundChannel;
	
	var _width				: Float;
	var _height				: Float;
	var _tween				: TweenObject;
	var _isSwitched			: Bool;
	
	public function new( width : Float, height : Float ) {
		super();
		
		_width			= width;
		_height			= height;
		
		onExit	 		= new List();
		onReplay 		= new List();
				
		gameBoard		= new GameBoard( _width, _height );
		_switchSensor	= new Sprite();
		_levelLabel		= new Label( "0" );
		_scoreLabel		= new Label( "0" );
		_replayBtn		= new Label( "Replay", 60 );
		_exitBtn		= new Label( "Exit", 60 );
		
		_bounceSound	= CachedAssets.getSound( "bounce" );
		
		_levelLabel.y	= _height - _levelLabel.height;
		_scoreLabel.x	= _width - _scoreLabel.width;
		_scoreLabel.y	= _height - _scoreLabel.height;
		_replayBtn.x	= _width - _replayBtn.width;
		_replayBtn.y	= _levelLabel.y + height - _replayBtn.height;
		_exitBtn.y		= _scoreLabel.y + height - _replayBtn.height;
		
		// C++ target bug
		_switchSensor.graphics.beginFill( 0x000000, .01 );
		_switchSensor.graphics.drawRect( 0, _width, _width, 2 * _height - _width - _levelLabel.height );
	}
	
	public function stop() {
		if ( _tween != null )
			_tween.stop();
		
		gameBoard.stop();
		_swrzText.stop();
		_sf.stop();
		
		_bounceSoundChannel.stop();
	}
	
	public function listen( b : Bool ) {
		if ( b ) {
			_switchSensor.addEventListener( MouseEvent.CLICK, cb_switchBoard );
			_replayBtn.addEventListener( MouseEvent.CLICK, cb_replayClick );
			_exitBtn.addEventListener( MouseEvent.CLICK, cb_exitClick );
		}
		else {
			_switchSensor.removeEventListener( MouseEvent.CLICK, cb_switchBoard );
			_replayBtn.removeEventListener( MouseEvent.CLICK, cb_replayClick );
			_exitBtn.removeEventListener( MouseEvent.CLICK, cb_exitClick );
		}
	}
	
	// CALLBACKS	
	function cb_switchBoard( e : MouseEvent ) {
		switchBoard();
	}
	
	function cb_replayClick(_) {
		for ( f in onReplay )
			f();
	}
	
	function cb_exitClick(_) {
		for ( f in onExit )
			f();
	}
	
	// GAME	
	public function showGameView() {
		if ( _swrzText != null )
			_swrzText.stop();
		
		_swrzText	= new SWRZText( "BLOHX HAXE/OPENFL MULTIPLATFORM GAME BY FILT3REK - HTTP://MROMECKI.FR   ", 20, 30 );
		_swrzText.x	= _width * .5;
		_swrzText.y	= 1.5 * _height - _levelLabel.height;
		
		_sf = new StarFieldZ( Std.int( _width ), Std.int( _height ) );
		_sf.y = _height - _levelLabel.height;
		_sf.generate( 50 );
		
		while ( numChildren > 0 )
			removeChildAt( 0 );
		
		for ( i in [ gameBoard, _levelLabel, _scoreLabel, _switchSensor, _exitBtn, _replayBtn ] )
			addChild( i );
	}
	
	public function setLevel( n : Int ) {
		_levelLabel.text = Std.string( n );
	}
	
	public function setScore( n : Int ) {
		new Tween( Std.parseInt( _scoreLabel.text ), n, 1000, true, cb_tweenScore );
	}
	
	function cb_tweenScore( n : Float ) {
		_scoreLabel.text 	= Std.string( Std.int( n ) );
		_scoreLabel.x		= _width - _scoreLabel.width;
	}
	
	var _cb_switchTweenFinish	: Void->Void;
	public function switchBoard( ?onFinish : Void->Void  ) {
		if ( _tween != null )
			return;
		_cb_switchTweenFinish	= onFinish;	
		if ( _isSwitched )
			_tween = this.tween(  { y : 0 }, 750, Bounce.easeOut, true, cb_switchTween );
		else {
			_tween = this.tween( { y : - _scoreLabel.y }, 750, Bounce.easeOut, true, cb_switchTween );
			 addChildAt( _swrzText, 0 );
			 addChildAt( _sf, 0 );
			_swrzText.play();
			_sf.play();
		}
	
		Timer.delay( function() _bounceSoundChannel = _bounceSound.play(), 250 );
	}
	
	function cb_switchTween() {
		_isSwitched = !_isSwitched;
		_tween		= null;
		if ( !_isSwitched ) {
			_swrzText.stop();
			_sf.stop();
			 removeChild( _swrzText );
			 removeChild( _sf );
		}
		
		if ( _cb_switchTweenFinish != null ) {
			_cb_switchTweenFinish();
			_cb_switchTweenFinish = null;
		}
	}
	
	public function runExitAnim( ?onFinish : Void->Void ) {
		stop();

		while ( numChildren > 0 )
			removeChildAt( 0 );
				
		var line = new Shape();
		line.graphics.beginFill( 0xFFFFFF, 1 );
		line.graphics.drawRect( -_width * .5, -1, _width, 2 );
		line.x = _width * .5;
		line.y = 1.5 * _height - _levelLabel.height;
		addChild( line );
		line.tween( { width : 2 }, 500, Expo.easeOut, true, onFinish );
	}
}