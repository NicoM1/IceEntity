IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

**Changes:**
----------

  **[NEW v0.5.0]**
  Added hscript integration
   
  **[v0.4.0]**
  
  Changed group storage and behavior
  
  Split AddEntity() into separate methods

  **[v0.3.1]**
  Allowed hyphens when parsing animations
  
  **[v0.3.0]**
  Added an xml parser for building entities
  
  **Earlier:**
  
  [See Changelog](https://github.com/NicoM1/IceEntity/blob/master/CHANGELOG.md)
  
**Installation**
----------

  **[1]** Run ```haxelib git iceentity https://github.com/NicoM1/IceEntity``` in a terminal with access to git
  
  **[2]** Add ```<haxelib name="iceentity"/>``` to your ```Project.xml``` file, directly under ```<haxelib name="flixel"/>```
  
  **[3]** Get annoyed with missing features, give up;)

**Usage:**
----------

  Call ```add(EntityManager.getInstance());``` in the create function of your playstate.
  
  Use ```EntityManager.getInstance().AddEntity();``` to add objects or groups to the manager.
  
  Use ```AddComponent();``` on a class extending entity to add a new component.
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other entities.
  
 **Entity Parser:**
----------
As of v0.3.0, IceEntity includes an xml parser, which can build entities from simple xml files. Do note, this is a new feature, and may have bugs (not like the rest of IceEntity doesn't;)). In order to use this system, you must:

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
    </data>
	
**Important information:** 

Parameters for components **must** be in the same order as specified in their constructor, **passing the entity's GID is not required**, it will be auto set. 

Param "name" attributes are not required, but are strongly recommended for organization.

Allowed types for parameters are: **"int" "float" and "bool" anything else will be treated as a plain string, including a lack of the "type" attribute**. Capitalization on param types does not matter. 

**MOST IMPORTANTLY: any component you wish to add in a xml file MUST be referenced somewhere in your basecode, even adding an ```import com.me.MyComponent;``` to your playstate will work. xml parsing will not work without this, as the component will not be compiled.**

**[2]** Call ```EntityManager.getInstance().BuildFromXML("assets/data/MyEntities.xml");``` in your playstates create function (or wherever really).

**HScript Integration:**
----------

As of v0.5.0, IceEntity has integrated the hscript scripting engine into its entity parser, and entity classes. Note this is a brand new feature, relativly untested, and may not be as efficient as standard components. If you find an issue, or are confused, tweet to me at: [@nico_m__](https://twitter.com/nico_m__), or email me: nico(dot)may99(at)gmail(dot)com. This allows you, the developer, to program without recompiling, or do many other cool things. I'll let you think of the possibilities:). It also means, that with little or no work, modding can be inegrated into your game! Here are the steps to getting this to work in you game:

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
			@init
			{
				i = 10;
			}| <!--close these "functions" with }|-->
			@update
			{
				trace(Player.x); 
				trace(owner.x); <!--if this script was inside an entity declaration, you can reference that entity with "owner"-->
				trace(FlxG.camera.x);
				trace(i);
			}|
			@destroy
			{
				Player = null;
			}|
		</text>
	</script>
	
As you can see, the "expose" tag allows the script to gain access to a static class, and reference it as whatever is in the "name" attribute. The "request" tag allows the script to get access to a class instance (or, truthfully, a static class will also work), from the ```ScriptHandler```s global pool. You can add to the pool in your code with ```ScriptHandler.AddModule(name, value);``` Note that this must be done BEFORE you parse the entity file, or you will get a nasty error message.

**[3]** You can think of the lines with "@" as functions, although their variables are **global scope**. Currently, the above 3 are the only possible "functions", you can think of them as: "at(@) (function) do whatever is in these brackets." **Do not add comments between the function name and first curly-bracket**, elsewhere, comments are great. Close these "functions" with the "}" chararacter followed immediatly by the "|" character, like so: "}|".

**[4]** The scripting system relies on hscript, which is basically interpreted haxe. Unfortunatly, I do not know enough about hscript yet to explain what you can and can't do, but two things to note are: do not use the "var" keyword, just pretend the variables already exist, and do not specify variable types. If you are more experienced in hscript, please submit a pull request with a fuller description:)

**[5]** As a developer, you may not want scripts, specificly mods, to have access to sensitive areas of your game. There are two ways to achieve this. The broad stroke way is to completely disallow access to the expose tag, ensuring scripts have no access to anything unless you specificly add it to the ```ScriptHandler```s modules list. This can be done with: ```ScriptHandler.allowExpose = false;```. The second, more specific way is to "blacklist" classes with ```ScriptHandler.Blacklist("path.to.Class");```, this will warn the user they can not access this package.
  
**Message System:**
----------

IceEntity now includes a simple message broadcasting system. It is a useful way of quickly sending information or data between objects, without needing to store a reference. Simply call ```SendMessage()``` on an entity, with any info you need to send (explained in the method details). To receive messages, simply override the ```ReceiveMessage()``` function on an entity, and use that as a simple way to do whatever you want with the messages data, no need to manage a complicated event listener setup:)
  
  **Contact/Extra Info:**
  ----------
  
  It should be fairly self explanatory, but if not, you can get in touch with me on twitter: [@nico_m__](https://twitter.com/nico_m__).
  
  **Please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)**
