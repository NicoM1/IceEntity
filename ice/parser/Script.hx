package ice.parser;

import hscript.Expr;
import hscript.Interp;
import ice.entity.IceUtil;
import openfl.Assets;

class Script
{
	public var interp:IceInterp;
	var updateScript:Expr;
	var destroyScript:Expr;
	var script:String;
	var newScript:String;
	var init:Bool = false;
	var path:String = "";
	public var noReload = false;
	public var doClean(default,null):Bool = false;
	public var noClean:Bool = false;
	
	public function new(script:String, ?path:String = "") 
	{		
		this.script = script;
		this.path = path;
		
		interp = new IceInterp();
		
		ScriptHandler.ParseImports(script, interp);
		updateScript = ScriptHandler.Parse("update", script);
		destroyScript = ScriptHandler.Parse("destroy", script);
	}
	
	function Init() 
	{		
		var initS = ScriptHandler.Parse("init", script);
		if (initS != null)
		{
			interp.execute(initS);
		}
		
		if (!noClean && updateScript == null && destroyScript == null)
		{
			doClean = true;
		}
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
		if (!noReload && path != "")
		{
			#if ICE_LIVE_RELOAD
			newScript = IceUtil.LoadString(path, false);
			if (newScript == null)
			{
				return;
			}
			if (newScript == script)
			{
				return;
			}
			script = newScript;
			#end
			
			#if !ICE_NO_RELOAD_IMPORTS
			ScriptHandler.ParseImports(script, interp);
			#end
			
			updateScript = ScriptHandler.Parse("update", script);
			destroyScript = ScriptHandler.Parse("destroy", script);
			var reloadS = ScriptHandler.Parse("reload", script, interp);
			if (reloadS != null)
			{
				interp.execute(reloadS);
			}
		}
	}
}