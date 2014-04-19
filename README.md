IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

Usage:
  call add(GameObjectManager.getInstance()); in the create function of your playstate
  use GameObjectManager.getInstance().AddGameObject(); to add objects or groups to the manager
  use AddComponent(); on a class extending gameobject to add a new component
  init() will run on the first update cycle, useful for getting and stashing references to other gameobjects
  
