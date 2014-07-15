package ice.entity;

import flash.geom.Point;
import flixel.FlxBasic;
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
import flixel.group.FlxTypedGroup;
import tjson.TJSON;

import flixel.FlxG;

class EntityManager extends FlxGroup
{
	///a singleton instance of this class
	public static var instance(get, null) : EntityManager;
	private static var _instance : EntityManager;
	
	///Int corresponds to GID of entity, for faster access
	public var entities(default, null) : Array<Entity>;
	private var groups : Map<String, FlxTypedGroup<Entity>>;
	
	///simple var for storing a single map
	public static var map(default, null) : FlxTilemap;
	
	///highest current GID of any entity, used for autoasigning GIDs
	public var highestGID(default, default) : Int = 0;
	
	//{ Constructor and Instance
	private function new()
	{
		super();
		entities = new Array<Entity>();
		groups = new Map<String, FlxTypedGroup<Entity>>();
		highestGID = 0;
		map = null;
		
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
		
		ScriptHandler.SetReloadDelay(Std.parseFloat(Root.get("reloaddelay")));
		
		for (entity in Root.elementsNamed("entity"))
		{
			//Get entity's tag
			var tag:String = entity.get("tag");

			//Get entity's position
			var pos:Point = new Point();
			pos.x = Std.parseInt(entity.get("x"));
			pos.y = Std.parseInt(entity.get("y"));
			
			//build entity
			var ent:Entity = new Entity(-1, tag, pos);
			
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
						
						var framesSA:Array<String>;
						framesSA = framesS.split(",");
						
						var framesIA:Array<Int>;
						framesIA = new Array<Int>();
						
						for (frame in framesSA)
						{
							var frameList:Array<String> = frame.split("-");
							if (frameList.length == 2)
							{
								var start:Int = Std.parseInt(frameList[0]);
								var end:Int = Std.parseInt(frameList[1]);
								var index:Int;
								
								if (start < end)
								{
									index = start;
									while (index <= end)
									{
										framesIA.push(index++);
									}
								}
								else if (start > end)
								{
									index = start;
									while (index >= end)
									{
										framesIA.push(index--);
									}
								}
							}
							else
							{
								framesIA.push(Std.parseInt(frame));
							}
						}
						
						ent.animation.add(name, framesIA, framerate, looped);
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
		}
		
		for (script in Root.elementsNamed("script"))
		{
			ParseScript(script, null);
		}
	}
	
	//{ Entity Parser
	/**
	 * Builds entities from an xml file Important: any components needed MUST be imported somewhere in your code
	 * @param	path		path to the xml
	 * @param	useAssets	whether to use openfl.assets, required for flash
	 */
	public function BuildFromJSON(path:String, ?useAssets:Bool = true)
	{
		//var Root:Xml = Xml.parse(IceUtil.LoadString(path, useAssets));
		var Root:Dynamic = TJSON.parse(IceUtil.LoadString(path, useAssets));
		//Root = Root.firstElement();
		
		//ScriptHandler.SetReloadDelay(Std.parseFloat(Root.get("reloaddelay")));
		ScriptHandler.SetReloadDelay(Root.reloaddelay);
		
		//for (entity in Root.elementsNamed("entity"))
		var arrEntity:Array<Dynamic> = cast Root.entity;
		for (entity in arrEntity)
		{
			//Get entity's tag
			//var tag:String = entity.get("tag");
			var tag:String = entity.tag;

			//Get entity's position
			var pos:Point = new Point();
			//pos.x = Std.parseInt(entity.get("x"));
			pos.x = entity.x;
			//pos.y = Std.parseInt(entity.get("y"));
			pos.y = entity.y;
			
			//build entity
			var ent:Entity = new Entity(-1, tag, pos);
			
			//load in art/animation
			//for (art in entity.elementsNamed("art"))
			var arrArt:Array<Dynamic> = cast entity.art;
			if (arrArt != null)
			{
				for (art in arrArt)
				{
					var width:Int; 
					//width = Std.parseInt(art.get("width"));
					width = art.width;
					
					var height:Int;
					//height = Std.parseInt(art.get("height"));
					height = art.height;
					
					var path:String;
					//path = art.get("path");
					path = art.path;
					
					ent.loadGraphic(path, true, width, height);
					
					//if (art.firstChild() != null)
					var arrAnimation:Array<Dynamic> = cast art.animation;
					if (arrAnimation != null)
					{
						//for (animation in art.elementsNamed("animation"))
						for (animation in arrAnimation)
						{
							var name:String;
							//name = animation.get("name");
							name = animation.name;
							
							var framerate:Int;
							//framerate = Std.parseInt(animation.get("framerate"));
							framerate = animation.framerate;
							
							//var looped:Bool;
							//if (animation.get("looped") == "true")
							//{
								//looped = true;
							//}
							//else
							//{
								//looped = false;
							//}
							var looped:Bool = animation.looped;
							
							var framesS:String;
							//framesS = animation.get("frames");
							framesS = animation.frames;
							
							var framesSA:Array<String>;
							framesSA = framesS.split(",");
							
							var framesIA:Array<Int>;
							framesIA = new Array<Int>();
							
							for (frame in framesSA)
							{
								var frameList:Array<String> = frame.split("-");
								if (frameList.length == 2)
								{
									var start:Int = Std.parseInt(frameList[0]);
									var end:Int = Std.parseInt(frameList[1]);
									var index:Int;
									
									if (start < end)
									{
										index = start;
										while (index <= end)
										{
											framesIA.push(index++);
										}
									}
									else if (start > end)
									{
										index = start;
										while (index >= end)
										{
											framesIA.push(index--);
										}
									}
								}
								else
								{
									framesIA.push(Std.parseInt(frame));
								}
							}
							
							ent.animation.add(name, framesIA, framerate, looped);
							
							//if (animation.exists("autorun"))
							if (Reflect.hasField(animation, "autorun"))
							{
								if (animation.autorun)
								{
									ent.animation.play(animation.name);
								}
							}
						}
					}
				}
			}
			
			//for (component in entity.elementsNamed("component"))
			var arrComponent:Array<Dynamic> = cast entity.component;
			if (arrComponent != null)
			{
				for (component in arrComponent)
				{		
					var params:Array<Dynamic>;
					params = new Array<Dynamic>();
					params.push(ent.GID);
					
					//if (component.firstChild() != null)
					//{
					//for (param in component.elementsNamed("param"))
					var arrParam:Array<Dynamic> = cast component.param;
					if (arrParam != null)
					{
						for (param in arrParam)
						{
							var type:String;
							type = param.type.toLowerCase();
							
							var value:String;
							value = param.value;
							
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
					//}
					
					try 
					{
						var classType = Type.resolveClass(component.type);
						var newComponent = Type.createInstance(classType, params);
						ent.AddComponent(newComponent);
					}
					catch (msg:Dynamic)
					{
						throw ("Unable to resolve class from xml: " + msg);
					}
				}
			}
				
				//for (script in entity.elementsNamed("script"))
				var arrScript:Array<Dynamic> = cast entity.script;
				if (arrScript != null)
				{
					for (script in arrScript)
					{
						//ParseScript(script, ent);
						ParseScriptJSON(script, ent);
					}
				}
				
				
				AddEntity(ent);
		}
		
		//for (script in Root.elementsNamed("script"))
		var arrScript:Array<Dynamic> = cast Root.script;
		if (arrScript != null)
		{
			for (script in arrScript)
			{
				//ParseScript(script, null);
				ParseScriptJSON(script, null);
			}
		}
	}
	
	private function ParseScript(script:Xml, ?owner:Entity)
	{
		var file:String = "";
		
		var path:String = "";
		path = script.get("path");
		if (path == null)
		{
			path = "";
		}
		
		if (path != "")
		{
			file = IceUtil.LoadString(path, true);
		}
		else
		{
			for (text in script.elementsNamed("text"))
			{
				file = text.firstChild().nodeValue;
			}
		}
		
		var ParsedScript:Script = new Script(file, path);
		
		for (request in script.elementsNamed("request"))
		{
			var module = ScriptHandler.GetModule(request.get("name"));
			
			ParsedScript.interp.variables.set(request.get("name"), module);
		}
		
		for (expose in script.elementsNamed("expose"))
		{
			if (ScriptHandler.allowExpose)
			{
				var path = expose.get("path");
				if (ScriptHandler.blacklist.exists(path))
				{
					throw "access to this class is blacklisted: " + path;
				}
				else
				{
					var module = ScriptHandler.GetClass(path);

					ParsedScript.interp.variables.set(expose.get("name"), module);
				}
			}
			else
			{
				throw "access to expose is restricted";
			}
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
		
		if (owner != null)
		{
			ParsedScript.interp.variables.set("owner", owner);
			owner.scripts.Add(ParsedScript, Std.parseInt(script.get("id")));
		}
		else
		{
			ScriptHandler.scripts.Add(ParsedScript, Std.parseInt(script.get("id")));
		}
	}
	
	private function ParseScriptJSON(script:Dynamic, ?owner:Entity)
	{
		var file:String = "";
		
		var path:String = "";
		//path = script.get("path");
		path = script.path;
		if (path == null)
		{
			path = "";
		}
		
		if (path != "")
		{
			file = IceUtil.LoadString(path, true);
		}
		else
		{
			//for (text in script.elementsNamed("text"))
			var arrText:Array<Dynamic> = cast script.text;
			if (arrText != null)
			{
				for (text in arrText)
				{
					file = text;
				}
			}
		}
		
		var ParsedScript:Script = new Script(file, path);
		
		//for (request in script.elementsNamed("request"))
		var arrRequest:Array<Dynamic> = cast script.request;
		if (arrRequest != null)
		{
			for (request in arrRequest)
			{
				var module = ScriptHandler.GetModule(request.name);
				
				ParsedScript.interp.variables.set(request.name, module);
			}
		}
		
		//for (expose in script.elementsNamed("expose"))
		var arrExpose:Array<Dynamic> = cast script.expose;
		if (arrExpose != null)
		{
			for (expose in arrExpose)
			{
				if (ScriptHandler.allowExpose)
				{
					//var path = expose.get("path");
					var path = expose.path;
					if (ScriptHandler.blacklist.exists(path))
					{
						throw "access to this class is blacklisted: " + path;
					}
					else
					{
						var module = ScriptHandler.GetClass(path);

						ParsedScript.interp.variables.set(expose.name, module);
					}
				}
				else
				{
					throw "access to expose is restricted";
				}
			}
		}
		
		//if (script.exists("noreload"))
		if (Reflect.hasField(script, "noreload"))
		{
			if (script.noreload)
			{
				ParsedScript.noReload = true;
			}
		}
		
		//if (script.exists("noclean"))
		if (Reflect.hasField(script, "noclean"))
		{
			if (script.noclean)
			{
				ParsedScript.noClean = true;
			}
		}
		
		if (owner != null)
		{
			ParsedScript.interp.variables.set("owner", owner);
			owner.scripts.Add(ParsedScript, script.id);
		}
		else
		{
			ScriptHandler.scripts.Add(ParsedScript, script.id);
		}
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
		for (e in group.members)
		{
			AddEntity(e);
		}
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
		for (e in entities)
		{
			e.destroy();
		}
		entities = null;
		groups = null;
		instance = null;
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
			if (g.Tag == tag)
			{
				return g;
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
	override public function update():Void 
	{
		ScriptHandler.Update();
		super.update();
	}
	//}
}
