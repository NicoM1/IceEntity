package ice.entity;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class EntityManager extends FlxGroup
{
	///a singleton instance of this class
	static var instance : EntityManager;
	
	///Int corresponds to GID of entity, for faster access
	private var entitys : Map<Int, Entity>;
	private var groups : Map<String, FlxGroup>; 
	
	///simple var for storing a single map
	static public var map(default, null) : FlxTilemap;
	
	///highest current GID of any entity, used for autoasigning GIDs
	public var highestGID(default, default) : Int = 0;
	
	private function new()
	{
		super();
		entitys = new Map<Int, Entity>();
		groups = new Map<String, FlxGroup>();
		highestGID = 0;
		map = null;
	} 
	
	///clears the entire manager
	public static function empty()
	{
		instance = null;
		getInstance();
	}
	
	///gets the static instance of the manager
	public static function getInstance() : EntityManager
	{
		if (instance == null)
		{
			instance = new EntityManager();
		}
		
		return instance;
	}
	
	/**
	 * Adds a entity, group, or map to the manager
	 * @param	?entity				entity to be added.
	 * @param	?sprite					sprite to be added, there will be no way to reference this sprite, it is just an easy way to add one for testing
	 * @param	?group					a group of sprites or entitys to be added
	 * @param	?groupName				must be suppled when a group is added, used to reference the group
	 * @param	?groupIsEntitys		whether the group consists of entities or sprites, adds any entitys to the global array, components require this to function
	 * @param	?tileMap				easy way to hold a single tilemap, mainly for testing
	 */
	public function AddEntity(?entity : Entity, ?sprite : FlxSprite, ?group : FlxGroup, ?groupName : String, ?groupIsEntities : Bool = true, ?tileMap : FlxTilemap)
	{
		if (entity != null)
		{
			entitys.set(entity.GID, entity);
			add(entity);
		}
		if (sprite != null)
		{
			add(sprite);
		}
		if (tileMap != null)
		{
			map = tileMap;
			add(tileMap);
		}
		if (group != null)
		{
			if (groupName != null)
			{
				groups.set(groupName, group);
				add(group);
				if (groupIsEntities)
				{
					for (g in group.members)
					{
						AddEntity(cast(g, Entity));
					}
				}
			}
			else
			{
				throw "No group name provided";
			}
		}
	}
	
	/**
	 * Gets a group by its identifier
	 * @param	name	idenifier to access group
	 * 
	 */
	public function GetGroup(name : String) : FlxGroup
	{
		return groups.get(name);
	}
	
	/**
	 * removes a entity from the manager
	 * @param	GID	the identifier of the object to be removed
	 */
	public function RemoveEntity(GID : Int)
	{
		entitys.remove(GID);
	}
	
	///Returns the entity with the specified GID
    public function GetEntity(GID : Int) : Entity
	{
		return entitys.get(GID);
	}
	
	///Returns all entitys with a specific tag
	public function GetEntitiesWithTag(tag : String) : Array<Entity>
	{
		var gObjects = new Array<Entity>();
		
		for (g in entitys)
		{
			if (g.Tag == tag)
			{
				gObjects.push(g);
			}
		}
		
		return gObjects;
	}
	
	///Returns the first entity found with a specific tag
	public function GetEntityByTag(tag : String) : Entity
	{		
		for (g in entitys)
		{
			if (g.Tag == tag)
			{
				return g;
			}
		}
		
		return null;
	}
	
	public function SendMessage(sender:Int, messageCode:Int, ?target:Int, ?value:Dynamic, ?recieveOwn:Bool = false)
	{
		if (target == null)
		{
			for (e in entitys)
			{
				if (recieveOwn || e.GID != sender)
				{
					e.RecieveMessage(sender, messageCode, value);
				}
			}
		}
		else
		{
			entitys.get(target).RecieveMessage(sender, messageCode, value);
		}
	}
	
	override public function destroy():Void 
	{
		//super.destroy(); never gets destroyed between scenes
	}
}