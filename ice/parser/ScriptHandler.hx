package ice.parser;
import flixel.FlxBasic;
import flixel.FlxG;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import ice.entity.EntityManager;
import openfl.Assets;
import openfl.events.Event;

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
		
		return script.substring(startIndex, endIndex);
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