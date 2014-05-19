IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

**Changes:**
----------
   
  **[NEW v0.4.0]**
  Changed group storage and behaviour
  
  Split AddEntity() into separate methods

  **[NEW v0.3.1]**
  Allowed hyphens when parsing animations
  
  **[NEW v0.3.0]**
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
	    </entity>
    </data>
	
**Important information:** 

Parameters for components **must** be in the same order as specified in their constructor, **passing the entity's GID is not required**, it will be auto set. 

Param "name" attributes are not required, but are strongly recommended for organization.

Allowed types for parameters are: **"int" "float" and "bool" anything else will be treated as a plain string, including a lack of the "type" attribute**. Capitalization on param types does not matter. 

**MOST IMPORTANTLY: any component you wish to add in a xml file MUST be referenced somewhere in your basecode, even adding an ```import com.me.MyComponent;``` to your playstate will work. xml parsing will not work without this, as the component will not be compiled.**

**[2]** Call ```EntityManager.getInstance().BuildFromXML("assets/data/MyEntities.xml");``` in your playstates create function (or wherever really).
  
**Message System:**
----------

IceEntity now includes a simple message broadcasting system. It is a useful way of quickly sending information or data between objects, without needing to store a reference. Simply call ```SendMessage()``` on an entity, with any info you need to send (explained in the method details). To recieve messages, simply override the ```RecieveMessage()``` function on an entity, and use that as a simple way to do whatever you want with the messages data, no need to manage a complicated event listener setup:)
  
  **Contact/Extra Info:**
  ----------
  
  It should be fairly self explanatory, but if not, you can get in touch with me on twitter: [nico_m__](https://twitter.com/nico_m__).
  
  **Please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)**
