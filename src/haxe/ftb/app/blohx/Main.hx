package ftb.app.blohx;

import flash.system.System;
import haxe.ds.GenericStack;
import haxe.Timer;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;

import ftb.app.blohx.Types;
import ftb.app.blohx.views.UI;

/**
 * ...
 * @author filt3rek
 */

class Main extends Sprite{
		
	var LEVEL_BLOCKS		: Array<Int>;
	var LEVEL_COLORS		: Array<Int>;
	
	var _ui					: UI;
	var _tblocks			: Array<TBlock>;
	
	var _level				: Int;
	var _score				: Int;
	var _scoreMultiplier	: Int;
	var _multiplierTimer	: Timer;
	
	public function new() {
		super();
				
		LEVEL_BLOCKS	= [ 0, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ];
		LEVEL_COLORS	= [ 0, 2, 2, 2, 3, 3, 4,  4,  5,  5,  6,  6 ];
		//LEVEL_COLORS	= [ 0, 1, 1, 1, 1, 1, 1,  1,  1,  1,  1,  1 ];
		
		#if iphone
			Lib.current.stage.addEventListener( Event.RESIZE, init );
		#else
			addEventListener( Event.ADDED_TO_STAGE, init );
		#end
	}

	function init( e ) {
		#if iphone
			Lib.current.stage.removeEventListener( Event.RESIZE, init );
		#else
			removeEventListener( Event.ADDED_TO_STAGE, init );
		#end
		
		// entry point
		CachedAssets.initialize();
								
		_ui = new UI( Lib.current.stage.stageWidth, Lib.current.stage.stageHeight );
		
		_ui.gameBoard.onSelection.add( checkSelection );
		_ui.gameBoard.onValidate.add( validateSelection );
		_ui.onExit.add( cb_exit );
		_ui.onReplay.add( cb_replay );
		
		addChild( _ui );
		startGame();
	}
	
	// CALLBACKS
	function cb_exit() {
		if ( _multiplierTimer != null )
			_multiplierTimer.stop();
		_multiplierTimer	= null;
		
		CachedAssets.dispose();
		_ui.gameBoard.dispose();
		#if !js
		_ui.runExitAnim( System.exit.bind( 0 ) );
		#end
		
		_ui.stop();
	}
	
	function cb_replay() {
		if ( _multiplierTimer != null )
			_multiplierTimer.stop();
		_multiplierTimer	= null;
		
		_ui.listen( false );
		_ui.gameBoard.listen( false );
		_ui.switchBoard( replayGame );
	}
	
	// GAME
	function startGame() {
		_ui.showGameView();
		initGame();
		startLevel();
	}
	
	function initGame() {
		_level	= 1;
		_score	= 0;
	}
	
	function replayGame() {
		if ( _level < LEVEL_BLOCKS.length )
		{
			initGame();
			_ui.gameBoard.clearBlocks( startLevel );
		}
		else
		{
			initGame();
			startLevel();
		}
	}
	
	function startLevel() {
		
		var nbColors	= LEVEL_COLORS[ _level ];
		var nbCols		= LEVEL_BLOCKS[ _level ];
		var nbRows		= LEVEL_BLOCKS[ _level ];
		
		_tblocks	= [];
		var n 		= 0;
		for ( j in 0...nbRows ){
			for ( i in 0...nbCols ) {
				var tb : TBlock = { color : Type.createEnumIndex( BlockColor, Math.floor( Math.random() * nbColors ) ), fired : false };
				_tblocks[ n++ ] = tb;
			}
		}
		
		_ui.setLevel( _level );
		_ui.setScore( _score );
		_ui.gameBoard.drawBlocks( nbCols, nbRows, _tblocks, cb_blocksReady );
	}
	
	function cb_blocksReady() {
		_ui.listen( true );
		_ui.gameBoard.listen( true );
		
		_multiplierTimer		= new Timer( 1000 );
		_scoreMultiplier		= LEVEL_BLOCKS[ _level ];
		_multiplierTimer.run	= cb_countDownMultiplier;
	}
	
	function finishLevel() {
		if ( _multiplierTimer != null )
			_multiplierTimer.stop();
		_multiplierTimer	= null;
		
		if ( ++_level < LEVEL_BLOCKS.length )
			_ui.gameBoard.clearBlocks( startLevel );
		else
			_ui.gameBoard.clearBlocks( cb_finishGame );
	}
	
	function cb_finishGame() {
		_ui.listen( true );
		_ui.switchBoard();
	}
	
	// CONTROLER
	function isValidSelection( selection : TSelection ) : Bool {
		var tl = _tblocks[ selection[ 0 ][ 0 ] ];
		var tr = _tblocks[ selection[ 0 ][ selection[ 0 ].length - 1 ] ];
		var bl = _tblocks[ selection[ selection.length - 1 ][ 0 ] ];
		var br = _tblocks[ selection[ selection.length - 1 ][ selection[ selection.length - 1 ].length - 1 ] ];
		
		if ( tl.color == tr.color && tr.color == bl.color && bl.color == br.color && selection.length > 1 && selection[ 0 ].length > 1 )
			return true;

		return false;
	}
	
	function checkSelection( selection : TSelection ) {
		_ui.gameBoard.drawSelection( selection, isValidSelection( selection ) );
	}
	
	function validateSelection( selection : TSelection ) {
		if ( isValidSelection( selection ) )
		{
			_multiplierTimer.stop();
			
			var nbFired 		= 0;
			var mutations		= [];
			var tblock			= null;
			var index 			= 0;
			for ( j in 0...selection.length ) {
				for ( i in 0...selection[ j ].length ) {
					index 			= selection[ j ][ i ];
					tblock 			= _tblocks[ index ];
					tblock.color	= Type.createEnumIndex( BlockColor, Math.floor( Math.random() * LEVEL_COLORS[ _level ] ) );
					mutations.push( { index : index, color : tblock.color } );
					if ( !tblock.fired )
					{
						tblock.fired = true;
						nbFired++;
					}
				}
			}
			
			var gain	= 	getGain( nbFired );
			_score 		+=	gain;
			
			function mutateBlocks() {
				_ui.gameBoard.mutateBlocks( mutations );
			}
			
			if ( nbFired > 0 )
			{
				_ui.gameBoard.showResult( true, selection, nbFired + "x" + _scoreMultiplier, mutateBlocks );
				_ui.setScore( _score );
				checkEndLevel();
			}
			else
				_ui.gameBoard.showResult( true, selection, "", mutateBlocks );
			
			_multiplierTimer		= new Timer( 1000 );
			_scoreMultiplier		= LEVEL_BLOCKS[ _level ];
			_multiplierTimer.run	= cb_countDownMultiplier;
			
		}
		else
			_ui.gameBoard.showResult( false, selection );
	}
	
	function checkEndLevel() {
		var allEmpty = true;
		for ( tblock in _tblocks ){
			if ( !tblock.fired )
			{
				allEmpty = false;
				break;
			}
		}
		
		if ( allEmpty )
		{
			_ui.listen( false );
			_ui.gameBoard.listen( false );
			Timer.delay( finishLevel, 1250 );
		}
	}
	
	function cb_countDownMultiplier() {
		_scoreMultiplier--;
		
		if ( _scoreMultiplier < 1 )
		{
			_multiplierTimer.stop();
			_scoreMultiplier = 1;
		}
	}
	
	function getGain( nbFired : Int ) {
		return nbFired * _scoreMultiplier;
	}
	
	public static function main() {
		
		var stage 		= Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align 	= flash.display.StageAlign.TOP_LEFT;
		
		stage.addEventListener( Event.DEACTIVATE, pauseApp );
		stage.addEventListener( Event.ACTIVATE, resumeApp );
		
		Lib.current.addChild( new Main() );
	}
	
	static function pauseApp(_) {
		for ( tween in feffects.Tween.getActiveTweens() )
			tween.pause();
		// Special NME
		//nme.Lib.pause();
	}
	
	static function resumeApp(_) {
		for ( tween in feffects.Tween.getPausedTweens() )
			tween.resume();
		// Special NME
		//nme.Lib.resume();
	}
}