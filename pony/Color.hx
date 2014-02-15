package pony;

/**
 * Color
 * @author AxGord <axgord@gmail.com>
 */
abstract Color(UInt) {

	public var argb(get,never):UInt;
	public var rgb(get,never):UInt;
	
	public var a(get,never):UInt;
	public var r(get,never):UInt;
	public var g(get,never):UInt;
	public var b(get,never):UInt;
	
	public var af(get,never):Float;
	public var rf(get,never):Float;
	public var gf(get,never):Float;
	public var bf(get,never):Float;
	
	inline public function new(v:UInt) this = v;
	
	inline public static function fromRGB(r:Int, g:Int, b:Int):Color return (r << 16) + (g << 8) + b;
	inline public static function fromARGB(a:Int, r:Int, g:Int, b:Int):Color return (a << 24) + (r << 16) + (g << 8) + b;
	
	@:from inline static private function fromUInt(v:UInt):Color return new Color(v);
	
	@:to inline private function get_argb():UInt return this;
	inline private function get_rgb():UInt return this & 0xFFFFFF;
	
	inline private function get_a():UInt return (this >> 24) & 255;
	inline private function get_r():UInt return (this >> 16) & 255;
	inline private function get_g():UInt return (this >> 8) & 255;
	inline private function get_b():UInt return this & 255;
	#if cs
	private function get_af():Float return a / 255;
	private function get_rf():Float return r / 255;
	private function get_gf():Float return g / 255;
	private function get_bf():Float return b / 255;
	#else
	inline private function get_af():Float return a / 255;
	inline private function get_rf():Float return r / 255;
	inline private function get_gf():Float return g / 255;
	inline private function get_bf():Float return b / 255;
	#end
	
	@:to inline public function toString():String return '#' + StringTools.hex(this);
	
	@:from public static function fromString(s:String):Color {
		s = StringTools.trim(s);
		return new Color(
			if (s.substr(0, 1) == '#') Std.parseInt('0x' + s.substr(1))
			else if (s.substr(0, 3) == 'rgb') {
				s = StringTools.ltrim(s.substr(3));
				if (StringTools.startsWith(s, '(') && StringTools.endsWith(s, ')')) {
					var d = s.substr(1, s.length - 2).split(',').map(Std.parseInt);
					if (d.length != 3) throw 'Color params error';
					fromRGB(d[0],d[1],d[2]);
				} else throw 'Color syntax error';
			}
			else if (s.substr(0, 4) == 'argb') {
				s = StringTools.ltrim(s.substr(4));
				if (StringTools.startsWith(s, '(') && StringTools.endsWith(s, ')')) {
					var d = s.substr(1, s.length - 2).split(',').map(Std.parseInt);
					if (d.length != 4) throw 'Color params error';
					fromARGB(d[0],d[1],d[2],d[3]);
				} else throw 'Color syntax error';
			}
			else switch s {
				case 'red': 0xFF0000;
				case 'green': 0x00FF00;
				case 'blue': 0x0000FF;
				case _: throw 'Unknown color';
			}
		);
	}
	
	#if HUGS
	@:to inline public function toUnity():unityengine.Color {
		return new unityengine.Color(rf, gf, bf, 1-af);
	}
	#end
	
}