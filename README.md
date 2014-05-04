IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

**Changes:**
----------

  **[NEW v0.2.1]**
  added destruction of entities
  
  **[NEW v0.2.1]**
  removed template
  
  **[NEW v0.2.1]**
  added haxelib setup
  
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
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other entitiess.
  
**Message System [v0.2]:**
----------

  IceEntity now includes a simple message broadcasting system. It is a useful way of quickly sending information or data between objects, without needing to store a reference. Simply call ```SendMessage()``` on an entity, with any info you need to send (explained in the method details). To recieve messages, simply override the ```RecieveMessage()``` function on an entity, and use that as a simple way to do whatever you want with the messages data, no need to manage a complicated event listener setup:)
  
  **Contact/Extra Info:**
  ----------
  
  It should be fairly self explanatory, but if not, you can get in touch with me on twitter: [nico_m__](https://twitter.com/nico_m__).
  
  **Please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)**
