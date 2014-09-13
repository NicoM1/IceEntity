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
	private var prefabs:Map<String,Xml>;
	
	///highest current GID of any entity, used for autoasigning GIDs
	public var highestGID(default, default):Int = 0;
	
	var sceneSwitch:Bool = false;
	
	//{ Constructor and Instance
	private function new()
	{
		super();
		entities = new Array<Entity>();
		groups = new Map<String, FlxTypedGroup<Entity>>();
		templates = new Map<String, Xml>();
		prefabs = new Map<String, Xml>();
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
	 * Empties the manager and then loads one or more xml scene files
	 * @param	XMLs	array of paths to xml scenes
	 */
	public static function switchScene(XMLs:Array<String>)
	{
		EntityManager.empty();

		for (s in XMLs)
		{
			EntityManager.instance.BuildFromXML(s, true);
		}
		EntityManager.instance.sceneSwitch = true;
	}
	
	/**
	 * Builds entities from an xml file Important: any components needed MUST be imported somewhere in your code
	 * @param	path		path to the xml
	 * @param	useAssets	whether to use openfl.assets, required for flash
	 */
	public function BuildFromXML(path:String, ?useAssets:Bool = true)
	{
		var Root:Xml;
		Root = Xml.parse(IceUtil.LoadString(path, useAssets));
		Root = Root.firstElement();
		
		if (Root.exists("reloaddelay"))
		{
			ScriptHandler.SetReloadDelay(Std.parseFloat(Root.get("reloaddelay")));
		}
		
		for (e in Root.elements())
		{
			switch(e.nodeName)
			{
				case "entity":
					var ent = ParseEntity(e);
					if (ent != null)
					{
						AddEntity(ent);
					}
					
				case "instance":
					ParseInstance(e);
					
				case "script":
					ParseScript(e, null);
					
				case "load":
					BuildFromXML(e.get("path"));
				case "prefab":
					prefabs.set(e.get("name"), e);
				default:
					throw "unrecognized element: " + e.nodeName;
			}
		}
	}
	
	private function ParseInstance(instance:Xml):Entity
	{
		if (!instance.exists("template") && !instance.exists("prefab"))
		{
			throw "template or prefab not specified";
		}
		
		var template:String = instance.get("template");
		var prefab:String = null;
		
		if (template == null)
		{
			prefab = instance.get("prefab");
		}
		
		var newTag:String = null;
		var newX:String = null;
		var newY:String = null;
		
		if (instance.exists("tag"))
		{
			newTag = instance.get("tag");
		}
		if (instance.exists("x"))
		{
			newX = instance.get("x");
		}
		if (instance.exists("y"))
		{
			newY = instance.get("y");
		}
		var e:Entity;
		if (template != null)
		{
			e = instantiate(template, newTag, newX, newY);
		}
		else
		{
			instantiatePrefab(prefab, newX, newY);
			return null;
		}
		AddEntity(e);
		return e;
	}
	
	/**
	 * Creates an instance of a "prefab" as specified by a <prefab> declaration and adds it to the manager
	 * @param	name	name of prefab to instantiate	
	 * @param	offsetX x-offset to add to any entities contained in prefab (string to allow %'s of width/height: 90%)
	 * @param	offsetY y-offset to add to any entities contained in prefab (string to allow %'s of width/height: 90%)
	 */
	public function instantiatePrefab(name:String, offsetX:String, offsetY:String)
	{
		if (!prefabs.exists(name))
		{
			throw "specified prefab not found: " + name;
		}
		for (e in prefabs.get(name).elements())
		{
			switch(e.nodeName)
			{
				case "entity":
					var ent = ParseEntity(e);
					if (ent != null)
					{
						ent.x += getPixel(offsetX, true);
						ent.y += getPixel(offsetY, false);
						AddEntity(ent);
					}
					
				case "instance":
					var ent = ParseInstance(e);
					if (ent != null)
					{
						ent.x += getPixel(offsetX, true);
						ent.y += getPixel(offsetY, false);
					}
					
				case "script":
					ParseScript(e, null);
					
				case "load":
					throw "load element is not allowed in prefab declarations";
				case "prefab":
					throw "prefab element is not allowed in prefab declarations";
				default:
					throw "unrecognized element: " + e.nodeName;
			}
		}
	}
	
	/**
	 * Create an instance of a "template" as specified by a <template> declaration, NOT AUTOMATICALLY ADDED TO MANAGER
	 * @param	template	name of template to instantiate
	 * @param	newTag		tag to override original with
	 * @param	newX		x-position to override original with (string to allow %'s of width/height: 90%)
	 * @param	newY		y-position to override original with (string to allow %'s of width/height: 90%)
	 * @return				use EntityManager.instance.AddEntity(result) to add this entity to the scene
	 */
	public function instantiate(template:String, ?newTag:String, ?newX:String, ?newY:String):Entity
	{
		if (!templates.exists(template))
		{
			throw "specified template not found: " + template;
		}
		
		var entityXML:Xml = templates.get(template);
		
		var entity:Entity = ParseEntity(entityXML);
		
		if (newTag != null)
		{
			entity.Tag = newTag;
		}
		if (newX != null)
		{
			entity.x = getPixel(newX, true);
		}
		if (newY != null)
		{
			entity.y = getPixel(newY, false);
		}
		
		return entity;
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
		//super.destroy();
		
		if (members != null)
		{
			var i:Int = 0;
			var basic:FlxBasic = null;
			
			while (i < length)
			{
				basic = members[i++];
				
				if (basic != null)
					basic.destroy();
			}
		}
		
		ScriptHandler.scripts.Destroy();
		for (e in entities)
		{
			if (e != null)
			{
				e.destroy();
			}
		}
		
		entities = null;
		for (g in groups)
		{
			g.destroy();
		}
		groups = null;
		templates = null;
		//_instance = null;
		reset();
	}
	
	private function reset()
	{
		members = [];
		entities = new Array<Entity>();
		groups = new Map<String, FlxTypedGroup<Entity>>();
		templates = new Map<String, Xml>();
		highestGID = 0;	
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
		do {
			if (sceneSwitch = true)
			{
				sceneSwitch = false;
			}
			
			ScriptHandler.Update();

			if (sceneSwitch)
			{
				continue;
			}
			
			var i:Int = 0;
			var basic:FlxBasic = null;
			
			while (i < length)
			{
				basic = members[i++];
				
				if (basic != null && basic.exists && basic.active)
				{
					basic.update(elapsed);
				}
				if (sceneSwitch)
				{
					break;
				}
			}
		}while (sceneSwitch == true);
	}
	
	/*(override public function draw():Void 
	{
		if (!sceneSwitch)
		{
			super.draw();
		}
		else
		{
			sceneSwitch = false;
		}
	}*/
	//}
}
