/**
* Copyright (c) 2012-2014 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
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

import pony.events.*;
import pony.math.MathTools;

/**
 * DeltaTime Timer
 * Can work as Clock
 * todo: use macro for parsing Time String in compile time
 * @author AxGord
 */
class DTimer implements ITimer<DTimer> {
	
	public var beginTime:Time;
	public var endTime:Time;
	public var currentTime:Time;
	
	public var repeatCount:Int = -1;
	
	public var update:Signal1<DTimer, Time>;
	public var progress:Signal1<DTimer, Float>;
	public var complite:Signal0<DTimer>;
	
	private var sumdt:DT = 0;
	private var back:Bool = false;
	
	private var updateSignal:Signal1<Void, Float>;
	
	public inline static function createTimer(?endTime:Time, ?beginTime:Time, repeat:Int = 0):DTimer
		return new DTimer(DeltaTime.update, endTime, beginTime, repeat);
		
	public inline static function createFixedTimer(?endTime:Time, ?beginTime:Time, repeat:Int = 0):DTimer
		return new DTimer(DeltaTime.fixedUpdate, endTime, beginTime, repeat);

	public function new(updateSignal:Signal1 < Void, Float > , ?endTime:Time, ?beginTime:Time, repeat:Int = 0) {
		this.updateSignal = updateSignal;
		update = Signal.create(this);
		progress = Signal.create(this);
		complite = Signal.create(this);
		progress.takeListeners.add(takeProgress);
		progress.lostListeners.add(lostProgress);
		this.beginTime = beginTime == null ? 0 : beginTime;
		this.endTime = endTime;
		this.repeatCount = repeat;
		reset();
	}
	
	private function takeProgress():Void update.add(_progress);
	private function lostProgress():Void update.remove(_progress);
	
	public function reset():DTimer {
		back = endTime != null && beginTime > endTime;
		currentTime = back ? endTime : beginTime;
		return this;
	}
	
	public inline function start():DTimer {
		updateSignal.add(_update);
		return this;
	}
	
	public inline function stop():DTimer {
		updateSignal.remove(_update);
		return this;
	}
	
	private function _update(dt:DT):Void {
		sumdt += dt;
		if (dt >= 0.001) {
			var t:Time = sumdt;
			sumdt -= t;
			if (endTime != null) {
				if (back) {
					currentTime -= t;
					while (currentTime <= endTime) if (loop()) break;
				} else {
					currentTime += t;
					while (currentTime >= endTime) if (loop()) break;
				}
			} else {
				currentTime += t;
				dispatchUpdate();
			}
		}
	}
	
	private function loop():Bool {
		if (repeatCount > 0) {
			currentTime -= endTime - beginTime;
			repeatCount--;
			dispatchUpdate();
			complite.dispatch();
		} else if (repeatCount == -1) {
			currentTime -= endTime - beginTime;
			dispatchUpdate();
			complite.dispatch();
		} else {
			currentTime = endTime;
			stop();
			dispatchUpdate();
			complite.dispatch();
			return true;
		}
		return false;
	}
	
	public inline function dispatchUpdate():DTimer return update.dispatch(currentTime);
	
	public function destroy():Void {
		stop();
		progress.destroy();
		update.destroy();
		complite.destroy();
	}
	
	private function _progress():Void progress.dispatch(MathTools.percentCalcd(currentTime, beginTime, endTime));
	
	static public inline function delay      (time:Time, f:Void->Void):DTimer return DTimer.createTimer(time).complite.once(f).start();
	static public inline function fixedDelay (time:Time, f:Void->Void):DTimer return DTimer.createFixedTimer(time).complite.once(f).start();
	static public inline function repeat     (time:Time, f:Void->Void):DTimer return DTimer.createTimer(time, null, -1).complite.add(f).start();
	static public inline function fixedRepeat(time:Time, f:Void->Void):DTimer return DTimer.createFixedTimer(time, null, -1).complite.add(f).start();
	
}