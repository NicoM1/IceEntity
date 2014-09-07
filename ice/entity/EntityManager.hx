package ice.entity;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.zip.Entry.ExtraField;
import hscript.Expr;
import ice.parser.Script;
import ice.parser.ScriptHandler;
import openfl.Assets;
import openfl.events.Event;

class EntityManager extends FlxGroup
{
	///a singleton instance of this class
	public static var instance(get, null):EntityManager;
	private static var _instance:EntityManager;
	
	///Int corresponds to GID of entity, for faster access
	public var entities(default, null):Array<Entity>;
	private var groups:Map<String, FlxTypedGroup<Entity>>;
	
	private var templates:Map<String,Xml>;
	
	///highest current GID of any entity, used for autoasigning GIDs
	public var highestGID(default, default):Int = 0;
	
	//{ Constructor and Instance
	private function new()
	{
		super();
		entities = new Array<Entity>();
		groups = new Map<String, FlxTypedGroup<Entity>>();
		templates = new Map<String, Xml>();
		highestGID = 0;		
	} 
	
	///gets the static instance of the manager
	public static function getInstance() : EntityManager
	{
		if (_instance == null)
		{
			_instance = new EntityManager();
		}
		
		return _instance;
	}
	public static inline function get_instance() : EntityManager
	{
		return getInstance();
	}
	//}

	//{ Entity Parser
	/**
	 * Builds entities from an xml file Important: any components needed MUST be imported somewhere in your code
	 * @param	path		path to the xml
	 * @param	useAssets	whether to use openfl.assets, required for flash
	 */
	public function BuildFromXML(path:String, ?useAssets:Bool = true)
	{
		var Root:Xml = Xml.parse(IceUtil.LoadString(path, useAssets));
		Root = Root.firstElement();
		
		if (Root.exists("reloaddelay"))
		{
			ScriptHandler.SetReloadDelay(Std.parseFloat(Root.get("reloaddelay")));
		}
		
		for (entity in Root.elementsNamed("entity"))
		{
			ParseEntity(entity);
		}
		
		for (instance in Root.elementsNamed("instance"))
		{
			ParseInstance(instance);
		}
		
		for (script in Root.elementsNamed("script"))
		{
			ParseScript(script, null);
		}
	}
	
	private function ParseInstance(instance:Xml)
	{
		if (!instance.exists("template"))
		{
			throw "template not specified";
		}
		if (!templates.exists(instance.get("template")))
		{
			throw "template not found";
		}
		
		var template:String = instance.get("template");
		var entityXML:Xml = templates.get(template);
		
		var entity:Entity = ParseEntity(entityXML);
		
		if (instance.exists("tag"))
		{
			entity.Tag = instance.get("tag");
		}
		if (instance.exists("x"))
		{
			entity.x = getPixel(instance.get("x"), true);
		}
		if (instance.exists("y"))
		{
			entity.y = getPixel(instance.get("y"), false);
		}
	}
	
	private function ParseEntity(entity:Xml):Entity
	{
		//Get entity's tag
		var tag:String = entity.get("tag");

		//Get entity's position
		var pos:Point = new Point();
		pos.x = getPixel(entity.get("x"), true);
		pos.y = getPixel(entity.get("y"), false);
		
		//build entity
		var ent:Entity = new Entity(tag, pos);
		
		if (entity.exists("template"))
		{
			if (!templates.exists(entity.get("template")))
			{
				templates.set(entity.get("template"), entity);
				
				if (entity.get("instance") != "true" && entity.get("instance") != "True")
				{
					return null;
				}
			}
		}
		
		//load in art/animation
		for (art in entity.elementsNamed("art"))
		{
			var width:Int; 
			width = Std.parseInt(art.get("width"));
			
			var height:Int;
			height = Std.parseInt(art.get("height"));
			
			var path:String;
			path = art.get("path");
			
			ent.loadGraphic(path, true, width, height);
			
			if (art.firstChild() != null)
			{
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
					
					ent.loadAnimation(name, framesS, framerate, looped);
					
					if (animation.exists("autorun"))
					{
						if (animation.get("autorun") == "true" || animation.get("autorun") == "True")
						{
							ent.animation.play(animation.get("name"));
						}
					}
				}
			}
		}
		
		for (component in entity.elementsNamed("component"))
		{		
			var params:Array<Dynamic>;
			params = new Array<Dynamic>();
			params.push(ent.GID);
			
			if (component.firstChild() != null)
			{
				for (param in component.elementsNamed("param"))
				{
					var type:String;
					type = param.get("type").toLowerCase();
					
					var value:String;
					value = param.get("value");
					
					switch(type)
					{
						case ("int"):
						{
							params.push(Std.parseInt(value));
						}
						case ("float"):
						{
							params.push(Std.parseFloat(value));
						}
						case ("bool"):
						{
							if (value == "true" || value == "True")
							{
								params.push(true);
							}
							else
							{
								params.push(false);
							}
						}
						default:
						{
							params.push(value);
						}
					}
				}
			}
			
			try 
			{
				var classType = Type.resolveClass(component.get("type"));
				var newComponent = Type.createInstance(classType, params);
				ent.AddComponent(newComponent);
			}
			catch (msg:Dynamic)
			{
				throw ("Unable to resolve class from xml: " + msg);
			}
		}
		
		for (script in entity.elementsNamed("script"))
		{
			ParseScript(script, ent);
		}
		
		AddEntity(ent);
		return ent;
	}
	
	public function ParseScript(?script:Xml, ?owner:Entity, ?scriptPath:String)
	{
		var file:String = "";
		
		var path:String = "";
		
		if (script != null)
		{
			path = script.get("path");
			if (path == null)
			{
				path = "";
			}
		}
		else
		{
			path = scriptPath;
		}
		
		if (path != "")
		{
			#if !ICE_LIVE_RELOAD
			file = IceUtil.LoadString(path, true);
			#else
			file = IceUtil.LoadString(path, false);
			#end
		}
		else if (script != null)
		{
			for (text in script.elementsNamed("text"))
			{
				file = text.firstChild().nodeValue;
			}
		}
		
		var ParsedScript:Script = new Script(file, path);
		
		if (script != null)
		{
			for (request in script.elementsNamed("request"))
			{
				var module = ScriptHandler.GetModule(request.get("name"));
				
				ParsedScript.interp.variables.set(request.get("name"), module);
			}
			
			for (expose in script.elementsNamed("expose"))
			{
				var path = expose.get("path");

				var module = ScriptHandler.GetClass(path);

				ParsedScript.interp.variables.set(expose.get("name"), module);
			}
			
			if (script.exists("noreload"))
			{
				if (script.get("noreload") == "true")
				{
					ParsedScript.noReload = true;
				}
			}
			
			if (script.exists("noclean"))
			{
				if (script.get("noclean") == "true")
				{
					ParsedScript.noClean = true;
				}
			}
		}
		
		if (owner != null)
		{
			ParsedScript.interp.variables.set("owner", owner);
			if (script != null)
			{
				owner.scripts.Add(ParsedScript, Std.parseInt(script.get("id")));
			}
			else
			{
				owner.scripts.Add(ParsedScript);
			}
		}
		else
		{
			if (script != null)
			{
				ScriptHandler.scripts.Add(ParsedScript, Std.parseInt(script.get("id")));
			}
			else
			{
				ScriptHandler.scripts.Add(ParsedScript);
			}
		}
	}
	
	private function getPixel(input:String, x:Bool):Int
	{
		if (input == null)
		{
			return 0;
		}
		
		var percent:Int = input.indexOf("%");
		if (percent < 0)
		{
			return Std.parseInt(input);
		}
		
		input = input.substring(0, percent);
		
		var of:Int = x? FlxG.width : FlxG.height;
		
		return Std.int(Std.parseInt(input) / 100 * of);
	}
	//}
	
	//{ Add Items
	/**
	 * Adds an entity to the manager
	 * @param	entity		entity to be added.
	 */
	public function AddEntity(entity : Entity)
	{ 
		entities[entity.GID] = entity;
		add(entity);
	}
	
	/**
	 * Adds a flixel object to the scene, just for easy rendering, no fancy referencing
	 * @param	basic	whatever type of flixel object you want to add
	 */
	public function AddFlxBasic(basic:FlxBasic)
	{
		add(basic);
	}
	
	/**
	 * Adds a group to the manager
	 * @param	group	group of entities to add
	 * @param	name	name to reference this group
	 */
	public function AddGroup(group:FlxTypedGroup<Entity>, name:String):Void 
	{
		add(group);
		groups.set(name, group);
	}
	//}
	
	//{ Removal and Destruction
	
	/**
	 * removes a entity from the manager
	 * @param 	?entity 	a specific entity to remove
	 * @param	?GID		the identifier of the object to be removed
	 */
	public function RemoveEntity(?entity:Entity, ?GID:Int)
	{
		if (GID != 0)
		{
			GetEntity(GID).destroy();
			remove(GetEntity(GID), true);
			entities[GID] = null;
		}
		else
		{
			entity.destroy();
			remove(entity, true);
			entities[entity.GID] = null;
		}
	}
	
	/**
	 * Removes an entity that was in a group, THIS REMOVES ENTITY COMPLETELY, if you wish to keep the entity in the manager, just use GetGroup().remove()
	 * @param	?entity		a specific entity to remove
	 * @param	?GID		the identifier of the object to be removed
	 * @param	group		the group the entity belonged to
	 */
	public function RemoveFromGroup(?entity:Entity, ?GID:Int = 0, group:String)
	{
		if (entity == null)
		{
			if (GID == 0)
			{
				throw "either a specific entity or a valid GID must be specified";
			}
			entity = GetEntity(GID);
		}
		GetGroup(group).remove(entity, true);
		RemoveEntity(entity);
	}
	
	///clears the entire manager, really just calls getInstance().destroy();
	public static function empty()
	{
		getInstance().destroy();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		ScriptHandler.scripts.Destroy();
		entities = null;
		for (g in groups)
		{
			g.destroy();
		}
		groups = null;
		_instance = null;
	}
	//}
	
	//{ Get Items
	///Returns the entity with the specified GID
    	public function GetEntity(GID : Int) : Entity
	{
		return entities[GID];
	}
	
	///Returns all entities with a specific tag
	public function GetEntitiesWithTag(tag : String) : Array<Entity>
	{
		var gObjects = new Array<Entity>();
		
		for (g in entities)
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
		for (g in entities)
		{
			if (g != null)
			{
				if (g.Tag == tag)
				{
					return g;
				}
			}
		}
		
		return null;
	}
	
	/**
	 * Gets a group by its identifier
	 * @param	name	idenifier to access group
	 * 
	 */
	public function GetGroup(name : String) : FlxTypedGroup<Entity>
	{
		return groups.get(name);
	}
	//}
	
	//{ Messages
	public function SendMessage(sender:Int, messageCode:Int, ?target:Int, ?value:Dynamic, ?receiveOwn:Bool = false)
	{
		if (target == null)
		{
			for (e in entities)
			{
				if (receiveOwn || e.GID != sender)
				{
					e.ReceiveMessage(sender, messageCode, value);
				}
			}
		}
		else
		{
			entities[target].ReceiveMessage(sender, messageCode, value);
		}
	}
	//}
	
	//{ Update
	override public function update(elapsed:Float):Void 
	{
		ScriptHandler.Update();
		super.update(elapsed);
	}
	//}
}
