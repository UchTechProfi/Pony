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
package pony.net.http.modules.mmodels.actions;

import pony.net.http.modules.mmodels.Action;
import pony.net.http.WebServer;
import pony.Stream;
import pony.text.tpl.ITplPut;
import pony.text.tpl.Tpl;
import pony.text.tpl.TplData;
import pony.text.tpl.Valuator;

using pony.Tools;

class Single extends Action
{

	override public function tpl(d:CPQ, parent:ITplPut):ITplPut {
		return new SinglePut(this, d, parent);
	}
	
}


@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class SinglePut extends pony.text.tpl.TplPut<Single, CPQ> {
	
	@:async
	override public function tag(name:String, content:TplData, arg:String, args:Map<String, String>, ?kid:ITplPut):String
	{
		trace(name);
		var a:Dynamic = @await data.call([]);
		if (args.exists('!'))
			return a == null ? @await parent.tplData(content) : '';
		else {
			if (args.exists('div')) {
				return @await div(arg, args, a);
			} else
				return @await sub(this, a, SinglePutSub, content);
		}
	}
	
	@:async
	private function div(arg:String, args:Map<String, String>, e:Dynamic):String {
		var n:String = args.get('div') == null ? 'single' : args.get('div');
		var na:Array<String> = [];
		if (args.exists('cols')) {
			var s:String = '<div class="' + n + '">';
			for (f in args.get('cols').split(',').map(StringTools.trim))
				s += '<div class="' + f + '">'
					+ @await html(e, f)
					+ '</div>';
			s += '</div>';
			na.push(s);
		} else {
			var s:String = '<div class="' + n + '">';
			for (f in Reflect.fields(e))
				s += '<div class="' + f + '">'
					+ @await html(e, f)
					+ '</div>';
			s += '</div>';
			na.push(s);
		}
		return na.join(arg == null ? '' : arg);
	}
	
	@:async
	private function html(e:Dynamic, f:String):String {
		var c = data.model.columns[f];
		if (c.tplPut != null) {
			var o:Dynamic = Type.createInstance(c.tplPut, [c, e, this]);
			return @await o.html(f);
		} else {
			return Reflect.field(e, f);
		}
	}
	
}

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class SinglePutSub extends Valuator<SinglePut, Dynamic> {
	
	@:async
	override public function tag(name:String, content:TplData, arg:String, args:Map<String, String>, ?kid:ITplPut):String
	{
		trace(name);
		var c = data.data.model.columns[name];
		if (c.tplPut != null) {
			var o = Type.createInstance(c.tplPut, [c, datad, this]);
			return @await o.tag(name, content, arg, args, kid);
		} else
			return @await super1_tag(name, content, arg, args, kid);
	}
	
	@:async
	override public function shortTag(name:String, arg:String, ?kid:ITplPut):String 
	{
		var c = data.data.model.columns[name];
		if (c.tplPut != null) {
			var o = Type.createInstance(c.tplPut, [c, datad, this]);
			return @await o.shortTag(name, arg, kid);
		} else
			return @await super1_shortTag(name, arg, kid);
	}
	
	@:async
	override public function valu(name:String, arg:String):String {
		if (Reflect.hasField(datad, name))
			return Std.string(Reflect.field(datad, name));
		else
			return null;
	}
	
}