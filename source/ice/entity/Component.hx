package ice.entity;

class Component
{
	 ///GID of owner
	public var Owner : Int;
	 ///Actual owner gameobject, null untill init()
	public var owner : GameObject;
	
	private var initialized = false;
	
	public var type : String;
	
	public function new(Owner : Int) 
	{
		this.Owner = Owner;
	}
	
	public function GetOwner() : GameObject
	{
		return GameObjectManager.getInstance().GetGameObject(Owner);
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
}