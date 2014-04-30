IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

Changes:

  packages have been renamed to: ice.entity.[class].
  
  code has been surrounded in a template haxeflixel project, with GameObjectManager already added.
  
  [Due note, you are not required to use this project, and copying out the (ice) folder will work just fine in your own project]

Usage:

  call ```add(GameObjectManager.getInstance());``` in the create function of your playstate.
  
  use ```GameObjectManager.getInstance().AddGameObject();``` to add objects or groups to the manager.
  
  use ```AddComponent();``` on a class extending gameobject to add a new component.
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other gameobjects.
  
  it should be fairly self explanatory, but if not, you can get in touch with me on twitter: [nico_m__](https://twitter.com/nico_m__).
  
  please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)
  
