package pony.magic;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using pony.macro.Tools;
#end

/**
 * HasAbstract
 * @author AxGord <axgord@gmail.com>
 */
#if !macro
@:autoBuild(pony.magic.HasAbstractBuilder.build())
#end
interface HasAbstract { }

/**
 * AbstractBuilder
 * @author AxGord <axgord@gmail.com>
 * @author Simn <simon@haxe.org>
 * @link https://gist.github.com/Simn/5011604
 */
class HasAbstractBuilder {
  macro static public function build():Array<Field> {
		var fields:Array<Field> = [];
		var cCur = Context.getLocalClass().get();
		
		for (f in Context.getBuildFields()) if (f.meta.checkMeta([":abstract", "abstract"])) {
			switch f.kind {
				case FFun(fun):
					fields.push( {
						kind: FFun( { expr:macro return throw "not implemented", args:fun.args, params:fun.params, ret:fun.ret } ),
						access: f.access,
						doc: f.doc,
						meta: f.meta,
						name: f.name,
						pos: f.pos
					});
				case _: Context.error(f.kind.getName() +" can't be abstract", f.pos);
			}
			
		} else fields.push(f);
		
		var fieldMap = [for (f in fields) f.name => true];
		function loop(c:ClassType) {
			for (f in c.fields.get()) {
				if (f.meta.has(":abstract") || f.meta.has("abstract")) {
					if (!fieldMap.exists(f.name)) {
						Context.error("Missing implementation for abstract field " +f.name, cCur.pos);
					}
				} else {
					fieldMap.set(f.name,true);
				}
			}
			if (c.superClass != null)
				loop(c.superClass.t.get());
		}
		if (cCur.superClass != null)
			loop(cCur.superClass.t.get());
			
		return fields;
	}
}
