IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

Usage:

  call ```add(GameObjectManager.getInstance());``` in the create function of your playstate.
  
  use ```GameObjectManager.getInstance().AddGameObject();``` to add objects or groups to the manager.
  
  use ```AddComponent();``` on a class extending gameobject to add a new component.
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other gameobjects.
  
  it should be fairly self explanatory, but if not, you can get in touch with me on twitter: [nico_m__](https://twitter.com/nico_m__).
  
  please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)
  
