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
	private var groups : Map<String, Array<Int>>; 
	
	///simple var for storing a single map
	static public var map(default, null) : FlxTilemap;
	
	///highest current GID of any entity, used for autoasigning GIDs
	public var highestGID(default, default) : Int = 0;
	
	private function new()
	{
		super();
		entitys = new Map<Int, Entity>();
		groups = new Map<String, Array<Int>>();
		highestGID = 0;
		map = null;
	} 
	
	///clears the entire manager, really just calls getInstance().destroy();
	public static function empty()
	{
		getInstance().destroy();
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
	
	public function BuildFromXML(xml:String)
	{
		var Root:Xml = Xml.parse(xml);
		Root = Root.firstChild;
		
		for (entity in Root.elementsNamed("entity"))
		{
			//Get entity's tag
			var tag:String = entity.get("tag");

			//Get entity's position
			var pos:Point = new Point();
			pos.x = entity.get("x");
			pos.y = entity.get("y");
			
			//build entity
			var ent:Entity = new Entity( -1, tag, pos);
			
			for (art in entity.elementsNamed("art"))
			{
				var width:Int; 
				width = Std.parseInt(art.get("width"));
				
				var height:Int;
				height = Std.parseInt(art.get("height"));
				
				var path:String;
				path = art.get("path");
				
				ent.loadGraphic(path, true, width, height);
				
				for (animation in art.elementsNamed("animation"))
				{
					var name:String;
					name = animation.get("name");
					
					var framerate:Int;
					framerate = Std.parseInt(animation.get("framerate"));
					
					var looped:Bool;
					if (animation.get("looped") == "true")
					{
						looped = true;
					}
					else
					{
						looped = false;
					}
					
					var framesS:String;
					framesS = animation.get("frames");
					
					var framesSA:Array<String>;
					framesSA = framesS.split(",");
					
					var framesIA:Array<Int>;
					framesIA = new Array<Int>();
					
					for (frame in framesSA)
					{
						framesIA.push(Std.parseInt(frame));
					}
					
					ent.animation.add(name, framesIA, framerate, looped);
				}
			}
			
			AddEntity(ent);
		}
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
				AddGroup(group, groupName, groupIsEntities);
			}
			else
			{
				throw "No group name provided";
			}
		}
	}
	
	function AddGroup(group:FlxGroup, name:String, entities:Bool):Void 
	{
		if (!entities)
		{
			add(group);
		}
		else
		{
			var groupArray:Array<Int> = new Array<Int>();
			for (e in group.members)
			{
				var entity = cast(e, Entity);
				AddEntity(entity);
				groupArray.push(entity.GID);
			}
			groups.set(name, groupArray);
		}
	}
	
	/**
	 * Gets a group by its identifier NOTE: this currently does not update when new objects are added, due to groups not being internally stored as FlxGroups
	 * @param	name	idenifier to access group
	 * 
	 */
	public function GetGroup(name : String) : FlxGroup
	{
		var groupArray = groups.get(name);
		var returnGroup:FlxGroup = new FlxGroup();
		for (e in groupArray)
		{
			returnGroup.add(GetEntity(e));
		}
		return returnGroup;
	}
	
	/**
	 * removes a entity from the manager
	 * @param	GID	the identifier of the object to be removed
	* @param	group	if object was in a group, specify here
	 */
	public function RemoveEntity(entity : Entity, ?GID : Int, ?group : String)
	{
		if (GID != 0)
		{
			if (group != null)
			{
				groups.get(group).remove(GID);
			}
			GetEntity(GID).destroy();
			remove(GetEntity(GID), true);
			entitys.remove(GID);
		}
		else
		{
			if (group != null)
			{
				groups.get(group).remove(entity.GID);
			}
			entity.destroy();
			remove(entity, true);
			entitys.remove(entity.GID);
		}
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
		super.destroy();
		for (e in entitys)
		{
			e.destroy();
		}
		entitys = null;
		groups = null;
		instance = null;
	}
}