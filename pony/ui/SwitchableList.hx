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
package pony.ui;
import pony.events.Signal;
import pony.events.Signal1;
import pony.geom.IWards;

/**
 * ...
 * @author AxGord
 */
class SwitchableList implements IWards<SwitchableList> {
	
	public var change(default, null):Signal1<SwitchableList, Int>;
	public var lostState(default, null):Signal1<SwitchableList, Int>;
	public var currentPos(default,null):Int;

	private var list:Array<ButtonCore>;
	public var state(get,set):Int;
	private var swto:Int;
	private var ret:Bool;
	private var def:Int;
	
	public function new(a:Array<ButtonCore>, def:Int = 0, swto:Int = 2, ret:Bool = false) {
		this.swto = swto;
		this.ret = ret;
		this.def = def;
		state = def;
		change = Signal.create(this);
		lostState = Signal.create(this);
		list = a;
		for (i in 0...a.length) {
			if (i == def)
			{
				a[i].locked = true;
				a[i].mode = swto;
			}
			//select.listen(a[i].click.sub([0], [i]));
			a[i].click.sub(0).bind(i).add(change);
			if (ret) a[i].click.sub(swto).bind(i).add(changeRet);
		}
		change.add(setState, -1);
	}
	
	private function changeRet():Void change.dispatch( -1 );
	
	private function setState(n:Int):Void {
		if (state == n) return;
		//if (list[state] != null) list[state].mode = 0;
		if (list[state] != null) {
			list[state].locked = false;
			list[state].mode = 0;
		}
		//if (list[n] != null) list[n].mode = swto;
		if (list[n] != null) {
			list[n].locked = true;
			list[n].mode = swto;
		}
		lostState.dispatch(state);
		state = n;
	}
	
	public function next():Void {
		if (state + 1 < list.length) change.dispatch(state+1);
	}
	
	public function prev():Void {
		if (state - 1 >= 0) change.dispatch(state-1);
	}
	
	inline private function get_state():Int return currentPos;
	inline private function set_state(v:Int):Int return currentPos = v;
	
}