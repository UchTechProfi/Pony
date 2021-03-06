package pony.flash.ui;

import flash.display.MovieClip;
import flash.events.MouseEvent;
import pony.events.Signal;
import pony.events.Signal1;

/**
 * Bar
 * @author AxGord
 */
class Bar extends MovieClip implements FLSt {
#if !starling
	@:st private var bar:MovieClip;
	
	private var total:Float;
	
	public var value(default, set):Float = 0;
	public var onComplete:Signal1<Bar, Float>;
	public var onDynamic:Signal1<Bar, Float>;
	
	public function new() {
		super();
		onComplete = Signal.create(this);
		onDynamic = Signal.create(this);
		FLTools.init < init;
		addEventListener(MouseEvent.CLICK, clickHandler);
	}
	
	private function clickHandler(_):Void {
		value = mouseX / total;
	}
	
	private function init():Void {
		total = width;
		bar.width = 0;
	}
	
	public function set_value(v:Float):Float {
		if (value == v) return v;
		onDynamic.dispatch(v);
		onComplete.dispatch(v);
		bar.width = v * total;
		return value = v;
	}
#end
}