/**
* Copyright (c) 2013-2014 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
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
package pony;
import pony.events.Signal;

/**
 * MultyTumbler
 * @author AxGord <axgord@gmail.com>
 */
class MultyTumbler extends Tumbler<MultyTumbler> {

	private var states:Array<Bool>;
	
	public function new(tumblers:Array<Tumbler<MultyTumbler>>, ?on:Array<Signal>, ?off:Array<Signal>, ?defStates:Array<Bool>) {
		super();
		states = [];
		var n:Int = 0;
		if (tumblers != null) {
			for (t in tumblers) {
				t.onEnable.add(setState.bind(n, true));
				t.onDisable.add(setState.bind(n++, false));
				states.push(t.enabled);
			}
		}
		if (on != null) {
			if (defStates == null) defStates = [];
			var i:Int = n;
			for (s in on) {
				s.add(setState.bind(i++, true));
				states.push(defStates.shift());
			}
			var j:Int = n;
			for (s in on) s.add(setState.bind(j++, false));
			if (j != i) throw 'on length != off length ($i, $j)';
		}
	}
	
	private function setState(n:Int, v:Bool):Void {
		states[n] = v;
		enabled = state();
	}
	
	private function state():Bool {
		for (s in states) if (!s) return false;
		return true;
	}
	
}