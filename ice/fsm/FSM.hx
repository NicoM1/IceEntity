package ice.fsm;

class FSM
{
	private var stack:Array<Void->Void>;
	
	public function new() 
	{
		stack = new Array<Void->Void>();
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
	public function PushState(state:Void->Void)
	{
		stack[stack.length] = state;
	}
	
	/**
	 * Removes and returns the current state
	 */
	public function PopState():Void->Void
	{
		return stack.pop();
	}
	
	/**
	 * Replaces the current state, and returns it
	 * @param	state	the new state to be added
	 */
	public function ReplaceState(state:Void->Void):Void->Void
	{
		var returnState = PopState();
		PushState(state);
		return returnState;
	}
	
	public function destroy()
	{
		stack = null;
	}
}