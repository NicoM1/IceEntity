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
		if (modules.exists(path))
		{
			return modules.get(path);
		}
		else
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
		var startindex:Int = script.indexOf("public function " + func) + 16 + func.length;
		
		var braces:Int = 0;
		var startcheck:Bool = false;
		var char_index:Int = startindex;
		
		while ((char_index < script.length) && !(startcheck && (braces == 0)))
		{
			var char:String = script.charAt(char_index);
			
			if (char == "{")
			{
				if (!startcheck)
				{
					startindex = char_index;
				}
				
				startcheck = true;
				
				braces++;
			}
			
			if (char == "}")
			{
				startcheck = true;
				
				braces--;
			}
			
			char_index++;
		}
		
		var ret:String = script.substring(startindex, char_index);
		
		return ret;
	}
	
	static public function ParseImports(script:String, interp:Interp)
	{
		var lines:Array<String> = script.split(";");
		
		for (l in lines)
		{
			l = StringTools.trim(l);
			
			if (l.substr(0, 6) == "import")
			{
				var className:String = l.substring(7, l.length);
				var name = className.split(".").pop();
				var c:Dynamic = GetClass(className);
				interp.variables.set(name, c);
			}
			
			if (l.substr(0, 9) == "//request")
			{
				l = l.split(" ").pop();
				interp.variables.set(l, GetModule(l));
			}
		}
	}
	
	static public function Update()
	{
		if (!init)
		{
			Assets.addEventListener(Event.CHANGE, ReloadAll);
			init = true;
		}
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