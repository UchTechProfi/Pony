/**
* Copyright (c) 2012-2015 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
*
*   1. Redistributions of source code must retain the above copyright notice, this list of
*      conditions and the following disclaimer.
*
*   2. Redistributions in binary form must reproduce the above copyright notice, this list
*      of conditions and the following disclaimer in the documentation and/or other materials
*      provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY ALEXANDER GORDEYKO ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ALEXANDER GORDEYKO OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Alexander Gordeyko <axgord@gmail.com>.
**/
package pony.time;
#if nodejs
import js.Node;
#end
import pony.events.*;

/**
 * Delta Time
 * @author AxGord
 */
class DeltaTime {
	
	public static var speed:Float = 1;
	public static var update(default,null):Signal1<Void, DT>;
	public static var fixedUpdate(default,null):Signal1<Void, DT>;
	public static var value:Float = 0;
	#if (HUGS && !WITHOUTUNITY)
	public static var fixedValue(get, never):Float;
	private static inline function get_fixedValue():Float return unityengine.Time.deltaTime;
	#else
	public static var fixedValue:Float = 0;
	#end
	
	private static var t:Float;
	
	public static var nowDate(get,never):Date;
	
	#if !(flash || HUGS)
	public static inline function init(?signal:Signal0<Dynamic>):Void {
		set();
		if (signal != null) signal.add(tick);
	}
	
	#end
	#if !HUGS
	public static function tick():Void {
		fixedValue = get();
		set();
		fixedDispatch();
	}
	
	private static var lastNow:Date;
	
	inline private static function get_nowDate():Date return lastNow;
	
	private inline static function set():Void {
		lastNow = Date.now();
		t = lastNow.getTime();
	}
	private inline static function get():Float return (Date.now().getTime() - t) / 1000;
	#else
	inline private static function get_nowDate():Date return Date.now();
	#end
	
	public static inline function fixedDispatch():Void fixedUpdate.dispatch(fixedValue);
	
	#if (flash && !munit)
	private static function __init__():Void {
		createSignals();
		fixedUpdate.takeListeners.add(_ftakeListeners);
		fixedUpdate.lostListeners.add(_flostListeners);
	}
	private static function _ftakeListeners():Void {
		_set();
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, _tick, false, -1000);
	}
	private static function _flostListeners():Void flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, _tick);
	private static function _tick(_):Void tick();
	private static inline function _set():Void set();
	#end
	
	#if (!flash || munit)
	private static function __init__():Void {
		createSignals();
	}
	#end
	
	#if nodejs
	private static var imm:Dynamic;
	private static function __init__():Void {
		createSignals();
		fixedUpdate.takeListeners.add(_ftakeListeners);
		fixedUpdate.lostListeners.add(_flostListeners);
	}
	private static function _ftakeListeners():Void {
		set();
		imm = js.Node.setInterval(tick, Std.int(1000/60));//60 FPS
	}
	
	private static function _flostListeners():Void js.Node.clearInterval(imm);
	#end
	
	inline private static function createSignals():Void {
		update = Signal.createEmpty();
		fixedUpdate = Signal.createEmpty();
		update.takeListeners.add(_takeListeners);
		update.lostListeners.add(_lostListeners);
	}
	
	private static function updateHandler(dt:DT):Void if (dt > 0) update.dispatch(value = dt * speed);
	
	private static function _takeListeners():Void fixedUpdate.add(updateHandler);
	private static function _lostListeners():Void fixedUpdate.remove(updateHandler);
	
	public static function skipUpdate(f:Void->Void):Void DeltaTime.fixedUpdate < function() DeltaTime.fixedUpdate < f;
	
	#if (munit || dox)
	/**
	 * For unit tests
	 * @param	time
	 * @see pony.time.Time
	 */
	public static function testRun(time:Time = 60000):Void {
		var sec:Float = time / 1000;
		var d = if (sec < 100) 10 else if (sec < 1000) 50 else 100;//d > 100 sec - not normal lag
		while (sec > 0) {
			var r = Math.random() * d;
			if (sec >= r)
				sec -= r;
			else {
				r = sec;
				sec = 0;
			}
			fixedValue = r;
			fixedDispatch();
		}
	}
	#end
}