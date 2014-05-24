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
	
	public function new(script:String) 
	{		
		this.script = script;
		
		interp = new Interp();
		
		updateScript = ScriptHandler.Parse("update",script);
		destroyScript = ScriptHandler.Parse("destroy", script);
	}
	
	function Init() 
	{		
		interp.execute(ScriptHandler.Parse("init", script));
		
		script = null;
	}
	
	public function Update() 
	{	
		if (!init)
		{
			Init();
			init = true;
		}
		interp.execute(updateScript);
	}
	
	public function Destroy() 
	{
		interp.execute(destroyScript);
		interp = null;
		updateScript = null;
		destroyScript = null;
	}
	
}