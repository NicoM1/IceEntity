package ice.parser;

class ScriptHolder
{
	public var scripts(default,null):Array<Script>;
	
	public function new() 
	{
		scripts = new Array<Script>();
	}
	
	/**
	 * Adds a script to this holder
	 * @param	script	the script to add
	 * @param	id		an identifier for this script, if left -1, it will be pushed to the top
	 */
	public function Add(script:Script, ?id:Int = -1)
	{
		if (id != -1)
		{
			scripts.insert(id, script);
		}
		else
		{
			scripts.insert(scripts.length, script);
		}
	}
	
	/**
	 * Removes a script by id
	 * @param	id
	 */
	public function Remove(id:Int)
	{
		scripts[id].Destroy();
		scripts.remove(scripts[id]);
	}
	
	public function Update()
	{
		for (s in scripts)
		{
			if (s.doClean)
			{
				s = null;
			}
			else if (s != null)
			{
				s.Update();
			}
		}
	}
	
	public function Destroy()
	{
		for (s in scripts)
		{
			s.Destroy();
		}
		scripts = new Array<Script>();
	}
	
	public function ReloadScripts()
	{
		for (s in scripts)
		{
			s.ReloadScript();
		}
	}
}