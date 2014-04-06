package ftb.app.blohx.views;

import haxe.ds.GenericStack;

import flash.Lib;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.media.Sound;
import flash.events.Event;
import flash.events.MouseEvent;

import feffects.easing.Elastic;
import feffects.easing.Bounce;
import feffects.easing.Bounce;
import feffects.Tween;

import ftb.app.blohx.Types;

using feffects.Tween.TweenObject;

/**
 * ...
 * @author filt3rek
 */

class GameBoard extends Sprite {
	
	public var onSelection			(default, null)	: List<TSelection->Void>;
	public var onValidate			(default, null)	: List<TSelection->Void>;
	
	var _width				: Float;
	var _height				: Float;
	var _nbCols				: Int;
	var _nbRows				: Int;
	var _blockWidth			: Float;
	var _blockHeight		: Float;
	var _blockMidWidth		: Float;
	var _blockMidHeight		: Float;
	var _blocks				: GenericStack<Block>;
	var _nbBlocks 			: Int;
	
	var _blocksContainer	: Sprite;
	var _selectionContainer	: Sprite;
	var _explosionSound		: Sound;
	var _firedSound			: Sound;
	var _mutationSound		: Sound;
	var _noMatchSound		: Sound;
	
	var _currentSelection	: TSelection;
	var _pressedBlock		: Block;
	var _pressedIndex		: Int;
	var _overBlock			: Block;
	
	var _isListening		: Bool;
	var _tweens				: List<TweenObject>;
	var _frame				: Int;
	
	public function new( width : Float, height : Float ) {
		super();
		
		_width					= width;
		_height					= height;
		
		onSelection				= new List();
		onValidate				= new List();
		
		_blocksContainer		= new Sprite();
		_selectionContainer		= new Sprite();
		
		_explosionSound 		= CachedAssets.getSound( "explosion" );
		_firedSound				= CachedAssets.getSound( "fired" );
		_mutationSound			= CachedAssets.getSound( "mutation" );
		_noMatchSound			= CachedAssets.getSound( "no_match" );
				
		_selectionContainer.mouseEnabled	= false;
		
		for ( i in [ _blocksContainer, _selectionContainer ] )
			addChild( i );
	}
	
	public function dispose() {
		listen( false );
		stop();
	}
	
	public function stop() {
		removeEventListener( Event.ENTER_FRAME, cb_tweenBlock );
		removeEventListener( Event.ENTER_FRAME, cb_explodeBlocks );
	}
	
	public function listen( b : Bool ) {
		_isListening = b;
		if ( b )
			_blocksContainer.addEventListener( MouseEvent.MOUSE_DOWN, cb_selectionOn );
		else {
			_blocksContainer.removeEventListener( MouseEvent.MOUSE_DOWN, cb_selectionOn );
			_blocksContainer.removeEventListener( MouseEvent.MOUSE_MOVE, cb_computeSelection );
			_blocksContainer.removeEventListener( MouseEvent.MOUSE_UP, cb_selectionOff );
			stage.removeEventListener( MouseEvent.MOUSE_UP, releaseMouse );
		}
	}
	
	// CALLBACKS
	function cb_selectionOn( e : MouseEvent ) {
		
		_pressedBlock	= cast e.target;
		_pressedIndex	= _blocksContainer.getChildIndex( _pressedBlock );
		
		cb_computeSelection( e );
		
		_blocksContainer.addEventListener( MouseEvent.MOUSE_MOVE, cb_computeSelection );
		_blocksContainer.addEventListener( MouseEvent.MOUSE_UP, cb_selectionOff );
		stage.addEventListener( MouseEvent.MOUSE_UP, releaseMouse );
	}
	
	function cb_selectionOff(_) {
		_pressedBlock	= null;
		_overBlock		= null;
		_pressedIndex	= -1;
		
		releaseMouse();
		
		for ( f in onValidate )
			f( _currentSelection );	
	}
	
	function cb_computeSelection( e : MouseEvent ) {
		var overBlock	: Block = cast e.target;
		
		if ( overBlock == _overBlock )
			return;
		
		_overBlock		= overBlock; 
		var overIndex	= _blocksContainer.getChildIndex( overBlock );

		var offsetX		= overBlock.x - _pressedBlock.x;
		var offsetY		= overBlock.y - _pressedBlock.y;
		
		var offsetI		= Math.round( offsetX / _blockWidth );
		var offsetJ		= Math.round( offsetY / _blockHeight );
				
		var corners		= [ _pressedIndex, _pressedIndex + offsetI, _pressedIndex + offsetJ * _nbCols, overIndex ];
		
		corners.sort( function( a, b ) {
			return a < b ? -1 : a > b ? 1 : 0;	
		});
		
		var maxI		= offsetI > 0 ? offsetI + 1 : -offsetI + 1;
		var maxJ		= offsetJ > 0 ? offsetJ + 1 : -offsetJ + 1;
		
		_currentSelection	= [ [ ] ];
		var num				= 0;
		for ( y in 0...maxJ ) {
			_currentSelection[ y ] = [ ];
			num = corners[ 0 ] + _nbCols * y;
			for ( x in 0...maxI ) {
				_currentSelection[ y ][ x ] = num;
				num++;
			}
		}
		
		for ( f in onSelection )
			f( _currentSelection );
	}
	
	function releaseMouse(?_) {
		
		_blocksContainer.removeEventListener( MouseEvent.MOUSE_MOVE, cb_computeSelection );
		_blocksContainer.removeEventListener( MouseEvent.MOUSE_UP, cb_selectionOff );
		stage.removeEventListener( MouseEvent.MOUSE_UP, releaseMouse );
		
		hideSelection();
	}
	
	// DRAWING BLOCKS
	var _cb_drawBlocksFinish	: Void->Void;
	var _isDrawingBlocks		: Bool;
	public function drawBlocks( nbCols : Int, nbRows : Int, tblocks : Array<TBlock>, ?onFinish : Void->Void ) {
		if ( _isDrawingBlocks )
			return;
			
		_cb_drawBlocksFinish	= onFinish;
		_isDrawingBlocks		= true;
		
		_nbCols 				= nbCols;
		_nbRows 				= nbRows;
		
		_blockWidth				= _width / _nbCols;
		_blockHeight			= _width / _nbRows;
		_blockMidWidth			= _blockWidth * .5;
		_blockMidHeight			= _blockHeight * .5;
		
		_blocks 		= new GenericStack<Block>();
		_nbBlocks 		= 0;
		for ( j in 0..._nbRows ){
			for ( i in 0..._nbCols ) {
				var tb			= tblocks[ _nbBlocks ];
				var block		= new Block( tb.color );
				block.width		= _blockWidth;
				block.height	= _blockHeight;
				block.x			= _blockWidth * i + _blockMidWidth;
				block.y			= _height + _blockHeight;
				block.rotation	= 180;
				
				_blocksContainer.addChild( block );
				_blocks.add( block );
				
				_nbBlocks++;
			}
		}
		
		_frame		= 0;
		_tweens		= new List();
		
		addEventListener( Event.ENTER_FRAME, cb_tweenBlock );
		stage.addEventListener( MouseEvent.MOUSE_UP, finishDrawingBlocks );
	}
	
	function cb_tweenBlock(_) {
		var j				= Math.floor( _frame / _nbCols );
		var block	: Block = cast _blocksContainer.getChildAt( _frame++ );
		_tweens.add( block.tween( { y : _blockHeight * j + _blockMidHeight, rotation : 0 }, 500, true, cb_blockTweened ) );
		if ( _frame == _nbBlocks )
			removeEventListener( Event.ENTER_FRAME, cb_tweenBlock );
	}
	
	function cb_blockTweened() {
		_tweens.pop();
		if ( _tweens.isEmpty() && _frame == _nbBlocks )	{
			_tweens = null;
			_isDrawingBlocks = false;
			stage.removeEventListener( MouseEvent.MOUSE_UP, finishDrawingBlocks );
			if ( _cb_drawBlocksFinish != null )
				_cb_drawBlocksFinish();
		}
	}
	
	public function finishDrawingBlocks(?_) {
		removeEventListener( Event.ENTER_FRAME, cb_tweenBlock );
		stage.removeEventListener( MouseEvent.MOUSE_UP, finishDrawingBlocks );
						
		for ( tween in _tweens )
			tween.stop();
		_tweens = null;
		
		var j 				= 0;
		var block : Block	= null;
		for ( i in 0..._blocksContainer.numChildren ) {
			j				= Math.floor( i / _nbCols );
			block			= cast _blocksContainer.getChildAt( i );
			block.rotation	= 0;
			block.y			= _blockHeight * j + _blockMidHeight;
		}

		_isDrawingBlocks = false;
		if ( _cb_drawBlocksFinish != null )
			_cb_drawBlocksFinish();
	}
	
	// EXPLODING BLOCKS
	var _cb_blocksExplosionFinish	: Void->Void;
	var _isClearingBlocks			: Bool;
	public function clearBlocks( ?onFinish : Void->Void ) {
		if ( _isClearingBlocks )
			return;
			
		_explosionSound.play();
		#if cpp
			openfl.feedback.Haptic.vibrate( 0, 125 );
		#end
			
		_isClearingBlocks			= true;
		_cb_blocksExplosionFinish	= onFinish;
		
		var middleScreen 			= _width * .5;
		
		for ( i in 0..._blocksContainer.numChildren ) {
			var block : Block	= cast _blocksContainer.getChildAt( i );
			block.x				+= ( .5 - Math.random() ) * 20; 
			block.alpha 		= 1;
			block.sens 			= block.x - middleScreen > 0 ? 1 : -1;
			block.weight		= ( ( block.x - middleScreen ) / middleScreen ) * Math.random();
			block.xInc 			= block.weight * 50;
			block.yInc 			= - ( Math.random() * .8 + .2 ) * 50;
		}
		
		addEventListener( Event.ENTER_FRAME, cb_explodeBlocks );
		stage.addEventListener( MouseEvent.MOUSE_UP, finishClearingBlocks );
	}
	
	function cb_explodeBlocks(?_) {
		if ( !_isClearingBlocks )
			return;
		
		var minX = - _blockMidWidth;
		var maxX = _width + _blockMidWidth;
		var maxY = _height + _blockMidWidth;
		
		for ( block in _blocks ) {
			block.yInc		+= 5;
			block.y			+= block.yInc;
			block.scaleX 	= block.scaleY	-= .01;
			
			if ( block.sens > 0 && block.xInc > 0 || block.sens < 0 && block.xInc < 0 )	{
				block.xInc	-= block.weight * block.sens;
				block.x 	+= block.xInc;
			}
			if ( block.y > maxY || block.x < minX || block.x > maxX ) {
				_blocksContainer.removeChild( block );
				_blocks.remove( block );
				_nbBlocks--;
			}
		}
		
		if ( _nbBlocks == 0 ) {
			stage.removeEventListener( MouseEvent.MOUSE_UP, finishClearingBlocks );
			removeEventListener( Event.ENTER_FRAME, cb_explodeBlocks );
			_blocks 			= null;
			_isClearingBlocks	= false;
			if ( _cb_blocksExplosionFinish != null ) {
				_cb_blocksExplosionFinish();
				_cb_blocksExplosionFinish = null;
			}
		}
	}
	
	public function finishClearingBlocks(?_) {
		_isClearingBlocks	= false;
		
		removeEventListener( Event.ENTER_FRAME, cb_explodeBlocks );
		stage.removeEventListener( MouseEvent.MOUSE_UP, finishClearingBlocks );
		
		for ( block in _blocks ) {
			_blocksContainer.removeChild( block );
			_blocks.remove( block );
		}
		
		_blocks = null;
				
		if ( _cb_blocksExplosionFinish != null ) {
			_cb_blocksExplosionFinish();
			_cb_blocksExplosionFinish = null;
		}
	}
	
	// GAME	
	public function mutateBlocks( mutations : TMutations ) {
		_mutationSound.play();
		
		for ( mutation in mutations )
			cast( _blocksContainer.getChildAt( mutation.index ), Block ).mutate( mutation.color );
	}
	
	public function drawSelection( selection : TSelection, shine : Bool ) {
		
		var corners = getCorners( selection );
		
		var TLBlock = _blocksContainer.getChildAt( corners[ 0 ] );
		var BRBlock = _blocksContainer.getChildAt( corners[ 3 ] );
		
		var gfx	= _selectionContainer.graphics;
		gfx.clear();
		gfx.lineStyle( 10, 0xFFFFFF );
		if( shine )
			gfx.beginFill( 0xFFFFFF, .3 );
		
		gfx.drawRect( TLBlock.x - _blockMidWidth, TLBlock.y - _blockMidHeight, ( BRBlock.x - TLBlock.x ) + _blockWidth, ( BRBlock.y - TLBlock.y ) + _blockHeight );		
		gfx.endFill();
	}
	
	public function hideSelection() {
		_selectionContainer.graphics.clear();
		// HTML5 hack to clear graphics
		_selectionContainer.graphics.moveTo( 0, 0 );		
	}
	
	public function showResult( isValid : Bool, selection : TSelection, gain = "", ?onFinish : Void->Void ) {
		
		if ( !isValid )
			_noMatchSound.play();
		else {
			if ( gain != "" ) {
				_firedSound.play();
				var corners = getCorners( selection );
				
				var TLBlock = _blocksContainer.getChildAt( corners[ 0 ] );
				var BRBlock = _blocksContainer.getChildAt( corners[ 3 ] );
				
				var gainLabel		= new Label( Std.string( gain ), true );
				gainLabel.x			= ( TLBlock.x + BRBlock.x ) * .5;
				gainLabel.y			= ( TLBlock.y + BRBlock.y ) * .5;
				gainLabel.scaleX	= 0;
				gainLabel.scaleY	= 0;
				gainLabel.alpha		= 1;
				
				addChild( gainLabel );
				
				function cb_gainLabelHide() {
					removeChild( gainLabel );
					if ( onFinish != null )
						onFinish();
				}
				
				function cb_gainLabelShow() {
					gainLabel.tween( { alpha : 0 }, 250, true, cb_gainLabelHide );
				}
							
				// HTML5 bug when tween end at 0.99 < scale < 1 ???
				gainLabel.tween( { scaleX : .9, scaleY : .9 }, 500, Elastic.easeOut, true, cb_gainLabelShow );
			}
			else
				if ( onFinish != null )
					onFinish();
		}
	}
	
	inline function getCorners( selection : TSelection ) {
		return [ selection[ 0 ][ 0 ], selection [ 0 ][ selection[ 0 ].length - 1 ], selection[ selection.length - 1 ][ 0 ], selection[ selection.length - 1 ][ selection[ selection.length - 1 ].length - 1 ] ];
	}
}