package ice.entity;

class Component
{
	 ///GID of owner
	public var GID : Int;
	 ///Actual owner entity, null until init()
	public var owner : Entity;
	
	private var initialized = false;
	
	public var type : String;
	
	public function new(Owner : Int) 
	{
		this.GID = Owner;
	}
	
	public function GetOwner() : Entity
	{
		return EntityManager.getInstance().GetEntity(GID);
	}
	
	public function GetComponentOnOwner<T:Component>(type:Class<T>):T
	{
		return GetOwner().GetComponent(type);
	}
	
	public function Update()
	{
		if (!initialized)
		{
			init();
			initialized = true;
		}
	}	
			
	private function init()
	{
		owner = GetOwner();
	}
	
	public function destroy()
	{
		owner = null;
	}
}