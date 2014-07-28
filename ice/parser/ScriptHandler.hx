package ice.parser;
import flixel.FlxBasic;
import flixel.FlxG;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import ice.entity.EntityManager;
import openfl.Assets;
import openfl.events.Event;

using StringTools;

class ScriptHandler extends FlxBasic
{
	static var parser:Parser;
	
	static var modules:Map<String,Dynamic>;
	
	static public var scripts:ScriptHolder;
	
	static private var init:Bool = false;
		
	#if ICE_LIVE_RELOAD
	static private var timer:Float = 0;
	static private var reloadDelay:Float = 1;
	#end
	
	///If scripts can use <expose> elements to get access to game code
	public static var allowExpose:Bool = true;
	public static var blacklist(get, null):Map<String,Bool>;
	
	static function get_blacklist()
	{
		return blacklist;
	}
	
	static public function __init__()
	{
		parser = new Parser();
		modules = new Map<String,Dynamic>();
		scripts = new ScriptHolder();
		blacklist = new Map<String,Bool>();
		blacklist.set("ice.parser.ScriptHandler", true);
	}
	
	static public function SetReloadDelay(delay:Float)
	{
		#if ICE_LIVE_RELOAD
		reloadDelay = delay;
		#end
	}
	
	static public function ReloadAll()
	{
		for (e in EntityManager.getInstance().entities)
		{
			if (e != null)
			{
				e.scripts.ReloadScripts();
			}
		}
		scripts.ReloadScripts();
	}
	
	/**
	 * Adds a static class, or class instance to the global pool, so <request> tags can get them
	 * @param	name		how you wish to reference this class in your script
	 * @param	module		the class to add to the pool
	 */	
	static public function AddModule(name:String, module:Dynamic)
	{
		modules.set(name, module);
	}
	
	/**
	 * Gets a class from the global pool
	 * @param	name
	 * @return
	 */
	static public function GetModule(name:String):Dynamic
	{
		if (modules.exists(name))
		{
			return modules.get(name);
		}
		else
		{
			throw "Could not find the module specified";
		}
	}
	
	/**
	 * Gets or creates an instance of a class
	 * @param	path
	 * @return
	 */
	static public function GetClass(path:String):Dynamic
	{
		if (ScriptHandler.blacklist.exists(path))
		{
			throw "access to this class is blacklisted: " + path;
		}
		
		if (modules.exists(path))
		{
			return modules.get(path);
		}
		else if (ScriptHandler.allowExpose)
		{
			var myClass:Dynamic = Type.resolveClass(path);
			if (myClass != null)
			{
				modules.set(path, myClass);
				return(modules.get(path));
			}
			else
			{
				throw "expose attempt failed";
			}
		}
		else
		{
			throw "access to expose is restricted";
		}
	}
	
	/**
	 * Disallows access to a specific class in scripts
	 * @param	path	path to disallowed class. example: "flixel.FlxG"
	 */
	static public function Blacklist(path:String)
	{
		blacklist.set(path, false);
	}
	
	static public function Parse(func:String, script:String, ?interp:Interp):Expr
	{		
		var returnScript = ParseString(func, script, interp);
		if (returnScript != null)
		{
			return parser.parseString(returnScript);
		}
		return null;
	}
	
	static private function GetFunctionLine(offset:Int, func:String, script:String):Int
	{
		while (true)
		{
			var startLine:Int = script.indexOf("function", offset);
			if (startLine < 0)
			{
				return -1;
			}
			var endLine:Int = script.indexOf("\n", startLine);
			if (endLine < 0)
			{
				endLine = script.indexOf("\r");
			}
			
			var line:String = script.substring(startLine, endLine);
			
			if (line.indexOf(func) >= 0)
			{
				return endLine;
			}
			offset = endLine;
		}
		return -1;
	}
	
	static public function ParseString(func:String, script:String, ?interp:Interp):String
	{
		var startIndex = GetFunctionLine(0, func, script);
		
		if (startIndex == -1)
		{
			return null;
		}
		
		var braces:Int = 0;
		var startCheck:Bool = false;
		var charIndex:Int = startIndex;
		
		while ((charIndex < script.length) && !(startCheck && (braces == 0)))
		{
			var char:String = script.charAt(charIndex);
			
			if (char == "{")
			{
				if (!startCheck)
				{
					startIndex = charIndex;
					startCheck = true;
				}
				
				braces++;
			}
			
			if (char == "}")
			{			
				braces--;
			}
			
			charIndex++;
		}
		
		var ret:String = script.substring(startIndex, charIndex);
		
		var types:EReg = ~/: *[a-z0-9_<>]+/ig; //remove types from declarations
		ret = types.replace(ret, "");
		
		//add variable declarations into init
		if (func == "init")
		{
			ret = ParseVars(script) + ret;
		}
		else if (func == "reload")
		{
			ret = ParseVars(script, interp) + ret;
		}
		
		ret = ~/var /g.replace(ret, "");
		
		return ret;
	}
	
	static public function ParseImports(script:String, interp:Interp)
	{
		var imports:String;
		var endIndex = script.indexOf("function");
		
		imports = script.substring(0, endIndex);
		
		var lines:Array<String> = imports.split(";");
		
		for (l in lines)
		{
			l = l.trim();
			
			if (l == "")
			{
				continue;
			}
			
			var sections:Array<String> = ~/ +/.split(l);
			
			if (sections[0] == "import")
			{
				var className:String = sections[1];
				var name = className.split(".").pop();
				var c:Dynamic = GetClass(className);
				interp.variables.set(name, c);
			}
			else if (sections[0] == "request")
			{
				l = sections[1];
				interp.variables.set(l, GetModule(l));
			}
		}
	}
	
	static private function ParseVars(script:String, ?interp:Interp):String
	{
		var startIndex:Int = script.indexOf("class ");
		
		if (startIndex < 0)
		{
			startIndex = script.lastIndexOf("import ");
			startIndex = script.indexOf("\n", startIndex);
		}
		else
		{
			startIndex = script.indexOf("{", startIndex) + 1;
		}
		
		var endIndex = script.indexOf("function ", startIndex);
		
		var vars:String = script.substring(startIndex, endIndex);		
		vars = vars.substring(0, vars.lastIndexOf("\n")); //cut vars to end of last line
		
		var startNonCompile:Int = vars.indexOf("//#");
		var endNonCompile:Int = vars.indexOf("//#", startNonCompile + 3);
		vars = vars.substring(0, startNonCompile) + vars.substring(endNonCompile); //remove the non-compile section
		
		var redundant:EReg = ~/[a-z]* *[a-z]* *var +[a-z0-9_<>]+ *: *[a-z0-9_<>]+ *; *(\n)?/ig; //remove declarations that do not assign a value
		vars = redundant.replace(vars, "");
		
		var types:EReg = ~/: *[a-z0-9_<>]+/ig; //remove types from variable declarations
		vars = types.replace(vars, "");
		
		var modifiers:EReg = ~/(static)? *(private|public) *(static)?/g; //remove modifiers from variable declarations
		vars = modifiers.replace(vars, "");
		
		if (interp != null)
		{
			var reloadVars:String = "";
			
			var varDecl:EReg = ~/var +([a-z0-9_]+)/ig; //find variable names
			while (varDecl.match(vars))
			{
				if (!interp.variables.exists(varDecl.matched(1)))
				{
					reloadVars += vars.substring(varDecl.matchedPos().pos, vars.indexOf(";",varDecl.matchedPos().pos) + 1);
				}
				vars = varDecl.matchedRight();
			}
			vars = reloadVars;
		}
		
		var helperStart:Int = script.indexOf("//@");
		var helperEnd:Int = script.indexOf("//@", helperStart + 3);
		if (helperStart >= 0)
		{
			vars += script.substring(helperStart, helperEnd);
		}
		
		return vars;
	}
	
	static public function Update()
	{
		#if ICE_LIVE_RELOAD
		timer += FlxG.elapsed;
		if (timer > reloadDelay)
		{
			ReloadAll();
			timer = 0;
		}
		#end
		scripts.Update();
	}
}