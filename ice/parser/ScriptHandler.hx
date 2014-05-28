package ice.parser;
import flixel.FlxBasic;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

class ScriptHandler extends FlxBasic
{
	static var parser:Parser;
	
	static var modules:Map<String,Dynamic>;
	
	static public var scripts:ScriptHolder;
	
	///If scripts can use <expose> elements to get acess to game code
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
	}
	
	/**
	 * Adds a static class, or class instace to the global pool, so <request> tags can get them
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
		return modules.get(name);
	}
	
	/**
	 * Disallows access to a specific class in scripts
	 * @param	path	path to disallowed class. example: "flixel.FlxG"
	 */
	static public function Blacklist(path:String)
	{
		blacklist.set(path, false);
	}
	
	static public function Parse(func:String, script:String):Expr
	{		
		var returnScript = ParseString(func, script);
		if (returnScript != null)
		{
			return parser.parseString(returnScript);
		}
		return null;
	}
	
	static public function ParseString(func:String, script:String):String
	{		
		var startIndex:Int = script.indexOf("@" + func);
		if (startIndex < 0)
		{
			return null;
		}
		startIndex = script.indexOf("{", startIndex) + 1;		
		var endIndex:Int = script.indexOf("}|", startIndex);
		
		var finalScript:String = ""; 
		/*if (func == "init")
		{
			finalScript += "if(!init)\n{";
		}*/
		finalScript += script.substring(startIndex, endIndex);
		/*if (func == "init")
		{
			finalScript += "}";
		}*/
		
		return finalScript;
	}
	
	static public function Update()
	{
		scripts.Update();
	}
}