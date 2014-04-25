package ice.entity;

class Component
{
	public var Owner : Int;
	
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
	
	/*public function GetComponentOnOwnerByID<T:Component>(ID : String, type:Class<T>):T
	{
		return GetOwner().GetComponentByID(ID,type);
	}*/
	
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
		
	}
}