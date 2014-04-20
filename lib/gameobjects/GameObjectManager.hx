package lib.gameobjects;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class GameObjectManager extends FlxGroup
{
	///a singleton instance of this class
	static var instance : GameObjectManager;
	
	///Int corresponds to GID of gameobject, for faster access
	private var gameObjects : Map<Int, GameObject>;
	private var groups : Map<String, FlxGroup>; 
	
	///simple var for storing a single map
	static public var map(default, null) : FlxTilemap;
	
	///highest current GID of any gameobject, used for autoasigning GIDs
	public var highestGID(default, default) : Int = 0;
	
	private function new()
	{
		super();
		gameObjects = new Map<Int, GameObject>();
		groups = new Map<String, FlxGroup>();
	} 
	
	///gets the static instance of the manager
	public static function getInstance() : GameObjectManager
	{
		if (instance == null)
		{
			instance = new GameObjectManager();
		}
		
		return instance;
	}
	
	/**
	 * Adds a gameobject, group, or map to the manager
	 * @param	?gameObject				gameobject to be added.
	 * @param	?sprite					sprite to be added, there will be no way to reference this sprite, it is just an easy way to add one for testing
	 * @param	?group					a group of sprites or gameobjects to be added
	 * @param	?groupName				must be suppled when a group is added, used to reference the group
	 * @param	?groupIsGameobjects		whether the group consists of gameobjects or sprites, adds any gameobjects to the global array, components require this to function
	 * @param	?tileMap				easy way to hold a single tilemap, mainly for testing
	 */
	public function AddGameObject(?gameObject : GameObject, ?sprite : FlxSprite, ?group : FlxGroup, ?groupName : String, ?groupIsGameobjects : Bool = true, ?tileMap : FlxTilemap)
	{
		if (gameObject != null)
		{
			gameObjects.set(gameObject.GID, gameObject);
			add(gameObject);
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
				if (groupIsGameobjects)
				{
					for (g in group.members)
					{
						AddGameObject(cast(g, GameObject));
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
	 * removes a gameobject from the manager
	 * @param	GID	the identifier of the object to be removed
	 */
	public function RemoveGameObject(GID : Int)
	{
		gameObjects.remove(GID);
	}
	
	///Returns the gameobject with the specified GID
    public function GetGameObject(GID : Int) : GameObject
	{
		return gameObjects.get(GID);
	}
	
	///Returns all gameobjects with a specific tag
	public function GetGameObjectsWithTag(tag : String) : Array<GameObject>
	{
		var gObjects = new Array<GameObject>();
		
		for (g in gameObjects)
		{
			if (g.Tag == tag)
			{
				gObjects.push(g);
			}
		}
		
		return gObjects;
	}
	
	///Returns the first gameobject found with a specific tag
	public function GetGameObjectByTag(tag : String) : GameObject
	{		
		for (g in gameObjects)
		{
			if (g.Tag == tag)
			{
				return g;
			}
		}
		
		return null;
	}
}