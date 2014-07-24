IceEntity
=========

![IceEntity Demo](http://i.imgur.com/9tQt9rh.png)

A simple framework for managing entities and components in HaxeFlixel

**Changes:**
----------

  **[NEW v1.0.0]**
  
  Rewrote entire scripting system, allowing proper Haxe classes to be parsed as scripts

  Added templates and instance creation to XML parser
  
  **[v0.10.0]**
  
  Added syntax for exposing and requesting classes inside of scripts

  **[v0.9.0]**
  
  Added simple FSM system (sorry no write-up yet)

  **[v0.8.0]**
  
  Added "noreload" option for script elements
  
  Made scripts remove after calling init, unless they have update or destroy logic

  **[v0.7.0]**
  Allow access to instance via a property

  **[v0.6.1]**
  Made live-reloading fully automatic

  **[v0.6.0]**
  Added live-reloading of scripts

  **[v0.5.0]**
  Added hscript integration

  **Earlier:**
  
  [See Changelog](https://github.com/NicoM1/IceEntity/blob/dev/CHANGELOG.md)
  
**Installation**
----------

  **[1]** Run ```haxelib git iceentity https://github.com/NicoM1/IceEntity master``` in a terminal with access to git
  
  **Note: If you use the development version of HaxeFlixel (as I do), please replace ```master``` with ```dev```, this will make sure that IceEntity works properly with your prefered version of HaxeFlixel.**
  
  **[2]** Add ```<haxelib name="iceentity"/>``` to your ```Project.xml``` file, directly under ```<haxelib name="flixel"/>```
  
  **[3]** MAKE COOL THINGS:D


**Usage:**
----------

  Call ```add(EntityManager.instance);``` in the create function of your playstate.
  
  Use ```EntityManager.instance.AddEntity();``` to add objects or groups to the manager.
  
  Use ```AddComponent();``` on a class extending entity to add a new component.
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other entities.
  
 **Entity Parser:**
----------
IceEntity includes an xml parser, which can build entities from simple xml files. In order to use this system, you must:

**[1]** Create an xml file with this structure:

    <?xml version="1.0" encoding="utf-8" ?>
    <data>
	    <entity tag="myTag" x="0" y="0">
		    <art width="32" height="32" path="assets/images/myimage.png">
			    <animation name="idle" frames="0,1,2,3-6,6-0" framerate="10" looped="true" autorun="true"/>
				//ANIMATIONS: all parameters must be supplied, except "autorun" which mearly starts the animation as soon as it is loaded
				//FRAMES: as of v0.3.1, "frames" can now use hyphens, allowing you to do things such as: "0-10", or "10-0", note that commas are still allowed, and this is valid: "0-10,10-0,0,1,2,3,4,5,6,7,8,9,10"
		    </art>
		    <component type="com.me.MyComponent">
			    <param name="speed" type="int" value="10"/>
		    </component>
			//CHECK NEXT SECTION FOR SCRIPTING INFORMATION (yes, you can write code here!!)
	    </entity>

		<entity tag="templateTest" template="test" x="0" y="0"/> [NEW as of 1.0.0]
		/*This is a "template" it can be used to create many instances of a premade entity, 
		simply declare the entity as usual, and add an identifier: template="identifier".
		Note that by default, entities with a template attribute are not built at startup,
		however you can do so by adding instance="true" to the declaration.
		Note this is a single line for clarity, but this "template" would in practice look
		the same as the above entity declaration, with art and all*/

		<instance template="test" tag="overwrittenTag" x="10" y="15"/>
		/*This is an "instance", you can instantiate a template as many times as you wish, 
		while altering tag and position.*/

    </data>
	
**Important information:** 

Parameters for components **must** be in the same order as specified in their constructor, **passing the entity's GID is not required**, it will be auto set. 

Param "name" attributes are not required, but are strongly recommended for organization.

Allowed types for parameters are: **"int" "float" and "bool" anything else will be treated as a plain string, including a lack of the "type" attribute**. Capitalization on param types does not matter. 

**MOST IMPORTANTLY: any component you wish to add in a xml file MUST be referenced somewhere in your basecode, even adding an ```import com.me.MyComponent;``` to your playstate will work. xml parsing will not work without this, as the component will not be compiled.**

**[2]** Call ```EntityManager.instance.BuildFromXML("assets/data/MyEntities.xml");``` in your playstates create function (or wherever really).

**HScript Integration:**
----------

As of v1.0.0, IceEntity's scripting system has been completely rewritten, with work from both me and @Ohmnivore, making the act of scripting at runtime much more user friendly. Note this is a new feature, relatively untested, and may not be as efficient as standard components. If you find an issue, or are confused, tweet to me at: [@nico_m__](https://twitter.com/nico_m__), or email me: nico(dot)may99(at)gmail(dot)com. **These features allow you, the developer, to program your game in standard Haxe code, without recompiling, at runtime.** I'll let you think of the possibilities:). It also means, that with little or no work, modding can be integrated into your game! Here are the steps to getting this to work in you game:

**[1]** In you entity xml file (described above), there are two places you can put scripts. One being inside of an entity declaration, like so:

    <?xml version="1.0" encoding="utf-8" ?>
    <data>
	    <entity tag="myTag" x="0" y="0">
		    <script/>
	    </entity>
    </data>
	
The other is outside of an entity declaration, like so:
	
	<?xml version="1.0" encoding="utf-8" ?>
    <data>
		<script/>
    </data>
	
Before I describe how to actually write a script, let me make sure you know the difference between the two places. A script placed inside an entity declaration has two features that orphan (outside) scripts do not. First: a "owner" variable is automatically created, allowing you to access the entity that the script resides in, and second: they scripts "destroy" function will automatically be called in the event of its parent entity's destruction.

**[2]** In order to write your script, this is the format you must use:

	<script path="" id="-1"> 
	<!--if a path is specified, that is loaded instead of the <text> node-->
	<!--id can be left at -1, to auto-assign, but I recommend setting it to any int greater than 0, to allow referencing this script-->
		<expose name="FlxG" path="flixel.FlxG"/> <!--Gets a static class-->
		<request name="Player"/>	<!--requests a class instance from a global pool-->
		<text>
			import flixel.FlxG; //these can be used instead of the above xml tags
			request Player;
			
			var test:Entity = new Entity("test");

			function init
			{
				var i = 10; //variables declared in init are accessible from other functions
				trace(test.Tag);
			}
			function reload
			{
				<!--described in next section-->
			}
			function update
			{
				trace(Player.x); 
				trace(owner.x); <!--if this script was inside an entity declaration, you can reference that entity with "owner"-->
				trace(FlxG.camera.x);
				trace(i);
			}
			function destroy
			{
				Player = null;
			}
		</text>
	</script>
	
As you can see, the "expose" tag allows the script to gain access to a static class, and reference it as whatever is in the "name" attribute. The "request" tag allows the script to get access to a class instance (or, truthfully, a static class will also work), from the ```ScriptHandler```s global pool. You can add to the pool in your code with ```ScriptHandler.AddModule(name, value);``` Note that this must be done BEFORE you parse the entity file, or you will get a nasty error message.

**[3]** You may be (rightly) thinking: **"Hey, you said we were using real Haxe, that doesn't look like real Haxe to me?"** The reason for this: IceEntity's parser has been written to be flexible with how you want to write your scripts, if all you need is a few lines doing something really simple, the above is easier to type, **however**, if you wish to get full IDE support **(auto-completion)**, you can program your scripts like this (or pretty much anywhere in-between the two styles):

    package ;
    
    import flixel.FlxG;
    import ice.entity.Entity;
    
    class Test
    {
    	//#
    	var owner:Entity;
				/*
				This is a special syntax used in scripts.
				It allows you to create variables that are not compiled when the script is parsed.
				Why?
				This way, if you have used a request tag, or wish to have completion for the scripts owner, 
				you can create a variable of the proper type, 
				allowing full completion, without fearing issues in your scripts
				You may only use one of these blocks per script, simply open with "//#" and repeat to close.
				*/
    	//#
    	public static var testEntity = new Entity("myTag"); /*
															These variable are live-reloaded only if they
															did not previously exist, changing a value will not
															reload the variable, however if you add a new
															variable, it will be detected.
															*/
    	
    	public function init() 
    	{
    		var p:Entity = new Entity();
    	}
    
    	public function update()
    	{
    		test("hello world");
    	}
    
    	public function reload()
    	{
    
    	}

		//@
		function test(t)
		{
			trace(t);
		}
			/*
			This is another special syntax, any function placed inside of this block (one per script),
			acts how you would expect a standard haxe function to act, and is live-reloaded.
			*/
		//@
    }

**[4]** The scripting system relies on hscript, which is basically interpreted Haxe. Unfortunately, I do not know enough about hscript yet to explain everything you can and can't do, but an important item to note is to not use properties in scripts, you must instead just use methods (as far as I can tell...). If you are more experienced in hscript, please submit a pull request with a fuller description:)

**[5]** As a developer, you may not want scripts, specificity mods, to have access to sensitive areas of your game. There are two ways to achieve this. The broad stroke way is to completely disallow access to the expose tag, ensuring scripts have no access to anything unless you specificity add it to the ```ScriptHandler```s modules list. This can be done with: ```ScriptHandler.allowExpose = false;```. The second, more specific way is to "blacklist" classes with ```ScriptHandler.Blacklist("path.to.Class");```, this will warn the user they can not access this package.

**Note: this section has been converted for the changes in IceEntity's scripting system, however, it is possible some items are incorrect, if something isn't working how it says, or how you feel it should, please let me know [@nico_m__](https://twitter.com/nico_m__) ,thanks:D**

**Live Scripting**
----------

![Live-Scripting Demo](http://i.imgur.com/CkyiKeF.gif)
IceEntity allows you, with minimal effort, to literally code your game **while it is running**. This currently only works for CPP and Neko builds, and only for external script files (ie scripts created inside of your entities.xml file will not be editable at runtime). Here is what you need to do to make use of this new feature:

**[1]** Any scripts you want to be able to edit at runtime must be taken out of your xml file, placed in their own file, and then declared in your script element's "path" attribute.

**[2]** You can now import and request classes inside your scripts, similar to how imports are handled in regular haxe:

    import flixel.FlxG; //this is identical to the expose tag in xml, except you do not control the name of the class, the last section is used, in this case: "FlxG".
	request MyClass; //this is identical using a request tag in your xml
	
	function init
	{
	
	}

This also means the live-reloader will update your imports, so you can add things as you need them. This, however, may slow the reloader, if you find that to be the case, you can add:

    <haxedef name="ICE_NO_RELOAD_IMPORTS"/>

to your project.xml file.

**[3]** To help with testing, a new scripting function has been added:

    function reload
	{
		//This runs every time the script is updated, you can use it to edit variables for testing.
		//Note that it is ONLY for testing, you should not use this for any real game code, just for playing with values for speed and so on. THIS NEVER RUNS IN A FINAL BUILD
	}
	
**[4]** The files you edit while making use of live reloading **are not your main files**. The files you want to edit are in: yourProject\export\windows\ (neko or cpp)\bin\assets\data. **If you wish to use the logic you've created, copy these files back into your main folder when you are done**.

**[5]** Reloading can be costly; you may not wish to reload every script when you only want to tweak a couple. To stop certain scripts from reloading, a "noreload" attribute has been added for script elements:

    <script noreload="true">
	
Also, you may wish to do setup on an entity after the game begins, but not run any actual update logic. This means a script object is created, and updated every frame for no reason. To combat this, automatic script "cleaning" has been added, meaning that if only an "init" function is specified, the script will be deleted after running said "init" function. It is possible that during live-scripting, this behaviour may be annoying, if you wish to add other functions while running. In that case, you can specify:

    <script noclean="true">
	
Note that cleaning **only happens** if the script only had an "init" function at startup, the noclean option is only meant to be used if you really have a need for it, in normal use you should **never** specify this option.

**[6]** All you need to do to use this system is to add:
```<haxedef name="ICE_LIVE_RELOAD"/>``` to your project.xml file. Thats it!!!!
If you want control over the exact time between reloads, you can add a ```reloaddelay``` attribute to the root element of your entities.xml file.

**[6] Important Notes**: 

**This doesn't work for scripts specified in the "text" elements of your xml file**

**Make sure to remove ```<haxedef name="ICE_LIVE_RELOAD"/>``` before releasing your game, it is a performance waster, and has no use in a final build.**

For more responsive use I recommend adding ```<haxedef name="FLX_NO_FOCUS_LOST_SCREEN"/>``` to your project.xml, and setting ```FlxG.autoPause``` to ```false```. This way, you do not need to give the game focus to see your changes in action.

As a rule of thumb, any script that you wish to use the "update" function in should be contained in its own file, not in your xml file. This does two things: keeps your xml file readable, and combats the annoyance of live-reloading not working for internal scripts.
  
**Message System:**
----------

IceEntity now includes a simple message broadcasting system. It is a useful way of quickly sending information or data between objects, without needing to store a reference. Simply call ```SendMessage()``` on an entity, with any info you need to send (explained in the method details). To receive messages, simply override the ```ReceiveMessage()``` function on an entity, and use that as a simple way to do whatever you want with the messages data, no need to manage a complicated event listener setup:)
  
  **Contact/Extra Info:**
  ----------
  
  It should be fairly self explanatory, but if not, you can get in touch with me on twitter: [@nico_m__](https://twitter.com/nico_m__).
