package ice.parser;

import hscript.Expr;
import hscript.Interp;

class Script
{
	public var interp:Interp;
	var updateScript:Expr;
	var destroyScript:Expr;
	var script:String;
	var init:Bool = false;
	var hasUpdate:Bool = false;
	
	public function new(script:String) 
	{		
		this.script = script;
		
		if (script.indexOf("@update") >= 0)
		{
			hasUpdate = true;
		}
		
		interp = new Interp();
		interp.variables.set("init", false);
		
		updateScript = ScriptHandler.Parse("update",script);
		destroyScript = ScriptHandler.Parse("destroy", script);
	}
	
	function Init() 
	{		
		var initS = ScriptHandler.Parse("init", script);
		interp.execute(initS);
		interp.variables.set("init", true);
		
		script = null;
	}
	
	public function Update() 
	{	
		if (!init)
		{
			Init();
			init = true;
		}
		if (hasUpdate)
		{
			interp.execute(updateScript);
		}
	}
	
	public function Destroy() 
	{
		interp.execute(destroyScript);
		interp = null;
		updateScript = null;
		destroyScript = null;
	}
	
}