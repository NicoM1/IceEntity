package ice.fsm;

class FSM
{
	private var stack:Array<Void->Void>;
	
	public var info(get, null):Dynamic;
	private var infos:Array<Dynamic>;
	
	public inline function get_info():Dynamic
	{
		return infos[infos.length -1];
	}
	
	public function new() 
	{
		stack = new Array < Void->Void > ();
		infos = new Array<Dynamic>();
	}
	
	/**
	 * Updates the current state
	 */
	public function Update()
	{
		stack[stack.length - 1]();
	}
	
	/**
	 * Adds a state to the top of the stack
	 * @param	state	The state to be added
	 */
	public function PushState(state:Void->Void, ?info:Dynamic)
	{
		stack[stack.length] = state;
		infos.push(info);
	}
	
	/**
	 * Removes and returns the current state
	 */
	public function PopState():Void->Void
	{
		infos.pop();
		return stack.pop();
	}
	
	/**
	 * Replaces the current state, and returns it
	 * @param	state	the new state to be added
	 */
	public function ReplaceState(state:Void->Void, ?info:Dynamic):Void->Void
	{
		var returnState = PopState();
		PushState(state,info);
		return returnState;
	}
	
	public function destroy()
	{
		stack = null;
	}
}