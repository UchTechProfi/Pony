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
package pony.math;

/**
 * MathTools
 * @author AxGord <axgord@gmail.com>
 */
class MathTools {
	
	#if neko
	//todo: google it
	public static inline var maxInt:Int = 536870911;
	public static inline var minInt:Int = -536870911;
	#else
	/**
	 * The largest representable 32-bit signed integer, which is 2,147,483,647.
	 */
	public static inline var maxInt:Int = 2147483647;

	/**
	 * The smallest representable 32-bit signed integer, which is -2,147,483,648.
	 */
	public static inline var minInt:Int = -2147483648;
	#end

	public static function arithmeticMean(a:Iterable<Float>):Float {
		var s:Float = 0;
		var count = 0;
		for (e in a) {
			count++;
			s += e;
		}
		return s / count;
	}
	
	public static function arraySum(a:Iterable<Float>):Float {
		var s:Float = 0;
		for (e in a) s += e;
		return s;
	}
	
	inline public static function percentCalc(p:Float, min:Float, max:Float):Float return (max - min) * p + min;
	inline public static function percentBackCalc(p:Float, min:Float, max:Float):Float return  (p - min) / (max - min);
	inline public static function percentCalcd(p:Float, a:Float, b:Float):Float return a > b ? percentCalc(p, b, a) : percentCalc(p, a, b);
	inline public static function inRange(v:Float, min:Float, max:Float):Bool return min <= v && v <= max;
	inline public static function approximately(a:Float, b:Float, range:Float = 1):Bool return inRange(a, b - range, b + range);
	inline public static function limit(v:Float, min:Float, max:Float):Float return if (v < min) min; else if (v > max) max; else v;
	inline public static function cultureAdd(a:Float, b:Float, max:Float):Float return a + b >= max ? max : a + b;
	inline public static function cultureSub(a:Float, b:Float, min:Float):Float return a - b <= min ? min : a - b;
	inline public static function cultureTarget(a:Float, b:Float, step:Float):Float return a > b ? cultureSub(a, step, b) : cultureAdd(a, step, b);
	inline public static function midValue(a:Float, b:Float, aCount:Float, bCount:Float):Float return (aCount * a + bCount * b) / (aCount + bCount);
	inline public static function cabs(v:Int):Int return v < 0 ? -v : v; 
	inline public static function cmin(a:Int, b:Int):Int return a < b ? a : b; 
	inline public static function cmax(a:Int, b:Int):Int return a > b ? a : b; 
	inline public static function roundTo(v:Float, count:Int):Float return Math.round(v * Math.pow(10, count)) / Math.pow(10, count);
	
}