package lib.gameobjects;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class GameObjectManager extends FlxGroup
{
	static var instance : GameObjectManager;
	
	///Int corresponds to GID of gameobject, for faster access
	private var gameObjects : Map<Int, GameObject>;
	private var groups : Map<String, FlxGroup>; 
	
	static public var map(default, null) : FlxTilemap;
	
	public var highestGID(default, default) : Int = 0;
	
	private function new()
	{
		super();
		gameObjects = new Map<Int, GameObject>();
		groups = new Map<String, FlxGroup>();
	} 
	
	public static function getInstance() : GameObjectManager
	{
		if (instance == null)
		{
			instance = new GameObjectManager();
		}
		
		return instance;
	}
	
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
	
	public function GetGroup(name : String) : FlxGroup
	{
		return groups.get(name);
	}
	
	public function RemoveGameObject(GID : Int)
	{
		gameObjects.remove(GID);
	}
	
	///Replaces a specified gameobject [WILL BREAK ALL REFERENCES]
	public function ReplaceGameObject(GID : Int, newObj : GameObject)
	{
		remove(gameObjects.get(GID), false);
		gameObjects.set(GID, newObj);
		add(newObj);
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