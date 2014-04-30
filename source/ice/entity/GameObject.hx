package ice.entity;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxObject;

class GameObject extends FlxSprite
{
	
	///A specific identifier, unique to this object, Ex: "01" GID = gameobject ID, only named that so it does not interfere with flixel
	public var GID(default, null) : Int;
	
	///A general identifier, for grouping objects, Ex: "Enemy"
	public var Tag : String;
	
	public var Parent(default, null) : Int;
	
	///The key is a unique identifer, used to acces individual components
	private var components : Array<Component>; //used to be a map, but individual access is not needed, and this saves on garbage. Just don't try to add multiples of a type of component
	
	private var children : Array<Int>;
	
	private var initialized = false;
	
	///GID Can't Be 0, 0 will switch to -1, if left -1, GID will be auto asigned
	public function new(?GID : Int = -1, ?Tag : String, ?Positon : Point, ?Parent : Int = -1) 
	{
		if (Positon == null)
		{
			Positon = new Point();
		}
		
		super(Positon.x, Positon.y);
		
		if (GID == -1 || GID == 0)
		{
			this.GID = (GameObjectManager.getInstance().highestGID++);
		}
		else
		{
			this.GID = GID;
		}
		
		this.Tag = Tag;
		
		this.Parent = Parent;
		
		components = new Array<Component>();
		children = new Array<Int>();	
	}
	
	public function AddChild(childGID : Int)
	{
		for (c in children)
		{
			if (c == childGID)
			{
				return;
			}
		}
		children.push(childGID);
	}
	
	public function GetChildren() : Array<GameObject>
	{
		var childG : Array<GameObject> = new Array<GameObject>();
		for (c in children)
		{
			childG.push(GameObjectManager.getInstance().GetGameObject(c));
		}
		return childG;
	}
	
	public function GetChildrenWithTag(tag : String) : Array<GameObject>
	{
		var childG : Array<GameObject> = new Array<GameObject>();
		var child : GameObject;
		for (c in children)
		{
			child = GameObjectManager.getInstance().GetGameObject(c);
			if (child.Tag == tag)
			{
				childG.push(child);
			}
		}
		return childG;
	}	
		
	public function GetChildWithTag(tag : String) : GameObject
	{
		var child : GameObject;
		for (c in children)
		{
			child = GameObjectManager.getInstance().GetGameObject(c);
			if (child.Tag == tag)
			{
				return child;
			}
		}
		
		return null;
	}
	
	/*
	public function GetComponentByID<T:Component>(ID : String, type : Class<T>) : T
	{
		var c = components.get(ID);
		if (c != null)
		{
			if (Std.is(c, type))
			{
				return cast c;
			}
		}
		return null;
	}*/
	
	//gets a component on this gameobject, this call is fairly heavy, you should cash the result
	public function GetComponent<T:Component>(type:Class<T>):T
	{
		var name = Type.getClassName(type);
		
		for (c in components)
		{
			if (c.type == name)
			{
				return cast c;
			}
		}
		return null;
	}
	
	//adds a component to this gameobject
	public function AddComponent<T:Component>(component:T)
	{
		var type = Type.getClass(component);
		var name = Type.getClassName(type);
		component.type = name;
		components.push(component);
	}
	
	/*///Adds a component at a specified ID, note: can be overwritted by a call to AddComponent if the ID is also the type
	public function AddComponentWithID(component : Component, ID : String)
	{
		components.set(ID, component);
	}*/
	
	public function GetParent() : GameObject
	{
		return GameObjectManager.getInstance().GetGameObject(Parent);
	}
	
	override public function update():Void 
	{
		if (!initialized)
		{
			init();
			initialized = true;
		}
		super.update();
		
		for (c in components)
		{
			c.Update();
		}
	}
	
	public function IsAgainst(surface : FlxBasic, direction : Int) : Bool
	{
		switch (direction)
		{
			case FlxObject.LEFT:
				{
					return overlapsAt(x - 1, y, surface);
				}
			case FlxObject.RIGHT:
				{
					return overlapsAt(x + 1, y, surface);
				}
			case FlxObject.UP:
				{
					return overlapsAt(x, y - 1, surface);
				}
			case FlxObject.DOWN:
				{
					return overlapsAt(x, y + 1, surface);
				}
			case FlxObject.WALL:
				{
					return overlapsAt(x + 1, y, surface) || overlapsAt(x - 1, y, surface);
				}
			case FlxObject.ANY:
				{
					return overlapsAt(x + 1, y, surface) || overlapsAt(x - 1, y, surface) || overlapsAt(x, y - 1, surface) || overlapsAt(x, y + 1, surface);
				}
		}
		
		return false;
	}
	
	public function GetDistance(?obj1 : FlxObject = null, obj2 : FlxObject):Float
	{
		if (obj1 == null)
		{
			obj1 = this;
		}
		var XX = obj2.getMidpoint().x - obj1.getMidpoint().x;
		var YY = obj2.getMidpoint().y - obj1.getMidpoint().y;
		return Math.sqrt(XX * XX + YY * YY);
	}
			
	private function init()
	{
		
	}
}