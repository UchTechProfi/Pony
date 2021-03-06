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
package pony.net.http.platform.nodejs;

import js.Node;
import pony.fs.File;
import pony.net.http.Cookie;
import pony.net.http.IHttpConnection;
import pony.net.http.ServersideStorage;
import pony.text.ParseBoy;

using Reflect;
/**
 * HttpConnection
 * @author AxGord
 */
class HttpConnection extends pony.net.http.HttpConnection implements IHttpConnection {
	
	
	private static var mime(get, never):Dynamic;
	
	inline private static function get_mime():Dynamic return Node.require('mime');
	
	private var res:NodeHttpServerResp;
	
	public function new(url:String, storage:ServersideStorage, req:NodeHttpServerReq, res:NodeHttpServerResp, post:Map<String, String>) {
		super(url);
		method = req.method;
		this.post = post;
		this.res = res;
		if (req.headers.hasField('accept-language')) {
			var pb:ParseBoy<Void> = new ParseBoy<Void>(req.headers.field('accept-language'));
			var n:Int;
			do {
				n = pb.gt([',', ';']);
				var s:String = pb.str();
				if (s.substr(0, 2) == 'q=') continue;
				var a:Array<String> = s.toLowerCase().split('-');
				if (a.length == 1) {
					langPush(a[0] + '-' + a[0]);
					langPush(a[0]);
				} else {
					langPush(a[0] + '-' + a[1]);
					langPush(a[1]);
					langPush(a[0]);
				}
			} while (n != -1);
		}
		cookie = new Cookie(req.headers.cookie);
		sessionStorage = storage.getClient(cookie);
		//re
		if (method == 'POST' && params.exists('re')) {
			sessionStorage.set('post', post);
			endAction();
		} else if (sessionStorage.exists('post')) {
			this.post = sessionStorage.get('post');
			sessionStorage.remove('post');
		}
	}
	
	private function langPush(s:String):Void {
		if (s != '' && Lambda.indexOf(languages, s) == -1)
			languages.push(s);
	}
	
	public inline function sendFile(file:File):Void {
		writeCookie();
		var f = file.firstExists;
		Node.fs.stat(f, function(err:NodeErr, stat:NodeStat):Void {
			if (err != null) {
				error(err.toString());
			} else {
				var type = mime.lookup(f);
				res.writeHead(200, {
					'Content-Length': stat.size,
					'Content-Type': type
				});
				var readStream = Node.fs.createReadStream(f);
				// We replaced all the event handlers with a simple call to readStream.pipe()
				readStream.pipe(res);
			}
		});
		
		
	}
	
	public function endAction():Void {
		writeCookie();
		res.setHeader('Location', '/'+url);
		res.setHeader('Cache-Control', 'private');
		res.statusCode = 302;
		var t:String = '<html><body><a href=".">Click here</a></body></html>';
		res.setHeader('Content-Length', NodeBuffer.byteLength(t, 'utf8'));
		res.end(t);
		end = true;
	}
	
	public function error(?message:String):Void {
		writeCookie();
		res.setHeader('Content-Type', 'text/html; charset=UTF-8');
		res.end(message == null ? 'Error' : 'Error: '+message);
		end = true;
	}
	
	public function sendHtml(text:String):Void {
		writeCookie();
		res.setHeader('Content-Type', 'text/html; charset=UTF-8');
		res.setHeader('Content-Length', NodeBuffer.byteLength(text, 'utf8'));
		res.end(text);
		end = true;
	}
	
	public function sendText(text:String):Void {
		writeCookie();
		res.setHeader('Content-Type', 'text/plain; charset=UTF-8');
		res.setHeader('Content-Length', NodeBuffer.byteLength(text, 'utf8'));
		res.end(text);
		end = true;
	}
	
	private function writeCookie():Void {
		var s:String = cookie.toString();
		if (s != '')
			res.setHeader('Set-Cookie', s);
		end = true;
	}
	
}