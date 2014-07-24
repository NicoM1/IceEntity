package ice.entity;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxObject;
import ice.parser.ScriptHolder;
import ice.fsm.FSM;

class Entity extends FlxSprite
{
	
	///A specific identifier, unique to this object, Ex: "01" GID = entity ID, only named that so it does not interfere with flixel
	public var GID(default, null):Int;
	
	///A general identifier, for grouping objects, Ex: "Enemy"
	public var Tag:String;
	
	public var scripts(default,null):ScriptHolder;
	
	public var Parent(default, null):Int;
	
	private var FSMs:Array<FSM>;
	public var FSM(get, null):FSM;
	
	inline function get_FSM():FSM
	{
		if (FSMs[0] == null)
		{
			FSMs[0] = new FSM();
		}
		return FSMs[0];
	}
	
	///The key is a unique identifer, used to acces individual components
	private var components:Array<Component>; //used to be a map, but individual access is not needed, and this saves on garbage. Just don't try to add multiples of a type of component
	
	private var children:Array<Int>;
	
	private var initialized = false;
	
	///GID Can't Be 0, 0 will switch to -1, if left -1, GID will be auto asigned
	public function new(?Tag:String, ?Positon:Point, ?GID:Int = -1, ?Parent:Int = -1) 
	{
		if (Positon == null)
		{
			Positon = new Point();
		}
		
		super(Positon.x, Positon.y);
		
		if (GID == -1 || GID == 0)
		{
			this.GID = (EntityManager.getInstance().highestGID++);
		}
		else
		{
			this.GID = GID;
		}
		
		this.Tag = Tag;
		
		this.Parent = Parent;
		
		components = new Array<Component>();
		children = new Array<Int>();	
		scripts = new ScriptHolder();
		FSMs = new Array<FSM>();
	}
	
	public function AddChild(childGID:Int)
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
	
	public function GetChildren() : Array<Entity>
	{
		var childG : Array<Entity> = new Array<Entity>();
		for (c in children)
		{
			childG.push(EntityManager.getInstance().GetEntity(c));
		}
		return childG;
	}
	
	public function GetChildrenWithTag(tag:String) : Array<Entity>
	{
		var childG : Array<Entity> = new Array<Entity>();
		var child : Entity;
		for (c in children)
		{
			child = EntityManager.getInstance().GetEntity(c);
			if (child.Tag == tag)
			{
				childG.push(child);
			}
		}
		return childG;
	}	
		
	public function GetChildWithTag(tag:String) : Entity
	{
		var child : Entity;
		for (c in children)
		{
			child = EntityManager.getInstance().GetEntity(c);
			if (child.Tag == tag)
			{
				return child;
			}
		}
		
		return null;
	}
	
	//gets a component on this entity, this call is fairly heavy, you should cash the result
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
	
	//adds a component to this entity
	public function AddComponent<T:Component>(component:T)
	{
		var type = Type.getClass(component);
		var name = Type.getClassName(type);
		component.type = name;
		components.push(component);
	}
	
	public function GetParent() : Entity
	{
		return EntityManager.getInstance().GetEntity(Parent);
	}
	
	override public function update():Void 
	{
		if (!initialized)
		{
			init();
			initialized = true;
		}

		for (c in components)
		{
			c.Update();
		}
		
		scripts.Update();
		
		for (fsm in FSMs)
		{
			fsm.Update();
		}
		
		super.update();
	}
	
	public function IsAgainst(surface:FlxBasic, direction:Int) : Bool
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
	
	/**
	 * Gets the distance between two FlxObjects
	 * @param	a	First object
	 * @param	?b	Second object, defaults to this entity
	 * @return
	 */
	public function GetDistance(a:FlxObject, ?b:FlxObject = null):Float
	{
		if (b == null)
		{
			b = this;
		}
		var XX = b.getMidpoint().x - a.getMidpoint().x;
		var YY = b.getMidpoint().y - a.getMidpoint().y;
		return Math.sqrt(XX * XX + YY * YY);
	}
	
	/**
	 * Simple function for sending messages between entities
	 * @param	messageCode		An int ID, for determining message type
	 * @param	target			An optional specific GID for this message to be sent to
	 * @param	?value			An optional value, for sending larger or more specific data
	 * @param	?receiveOwn		Whether to allow this object to receive its own sent messages
	 */
	public function SendMessage(messageCode:Int, ?target:Int, ?value:Dynamic, ?receiveOwn:Bool = false) 
	{
		EntityManager.getInstance().SendMessage(GID, messageCode, target, value, receiveOwn);
	}
	
	/**
	 * Override this to handle messages, [no need to call super(etc.)]
	 * @param	sender			Entity that originally sent the message
	 * @param	messageCode		An int ID, for determining message type
	 * @param	?value			An optional value, possibly carrying larger or more specific data
	 */
	public function ReceiveMessage(sender:Int, messageCode:Int, ?value:Dynamic)
	{
		
	}
			
	private function init()
	{
		
	}
	
	override public function destroy()
	{
		if (components != null)
		{
			for (c in components)
			{
				c.destroy();
			}
		}
		scripts.Destroy();
		scripts = null;
		components = null;
		children = null;
		super.destroy();
	}
}
