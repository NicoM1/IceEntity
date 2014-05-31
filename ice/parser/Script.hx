package ice.parser;

import hscript.Expr;
import hscript.Interp;
import ice.entity.IceUtil;
import openfl.Assets;

class Script
{
	public var interp:Interp;
	var updateScript:Expr;
	var destroyScript:Expr;
	var script:String;
	var init:Bool = false;
	var path:String = "";
	
	public function new(script:String, ?path:String = "") 
	{		
		this.script = script;
		this.path = path;
		
		interp = new Interp();
		interp.variables.set("init", false);
		
		updateScript = ScriptHandler.Parse("update",script);
		destroyScript = ScriptHandler.Parse("destroy", script);
	}
	
	function Init() 
	{		
		var initS = ScriptHandler.Parse("init", script);
		if (initS != null)
		{
			interp.execute(initS);
		}
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
		
		if (updateScript != null)
		{
			interp.execute(updateScript);
		}
	}
	
	public function Destroy() 
	{
		if (destroyScript != null)
		{
			interp.execute(destroyScript);
			interp = null;
			updateScript = null;
			destroyScript = null;
		}
	}
	
	public function ReloadScript()
	{
		if (path != "")
		{
			#if ICE_LIVE_RELOAD
			script = IceUtil.LoadString(path, false);
			#else
			script = Assets.getText(path);
			#end
			updateScript = ScriptHandler.Parse("update",script);
			destroyScript = ScriptHandler.Parse("destroy", script);
			var reloadS = ScriptHandler.Parse("reload", script);
			if (reloadS != null)
			{
				interp.execute(reloadS);
			}
		}
	}
}