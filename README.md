IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

Usage:\n
  call ```add(GameObjectManager.getInstance());``` in the create function of your playstate.\n
  use ```GameObjectManager.getInstance().AddGameObject();``` to add objects or groups to the manager.\n
  use ```AddComponent();``` on a class extending gameobject to add a new component.\n
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other gameobjects.\n
  
