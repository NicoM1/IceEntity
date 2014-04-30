IceEntity
=========

A simple framework for managing gameobjects and components in haxeflixel

Changes:
  
  [NEW]
  all classes have replaced the word "gameobject" with entity, I know its annoying, but in the end its shorter to type...
  
  [NEW]
  added a simple message broadcasting system

  packages have been renamed to: ice.entity.[class].
  
  code has been surrounded in a template haxeflixel project, with EntityManager already added.
  
  [Due note, you are not required to use this project, and copying out the (ice) folder will work just fine in your own project]

Usage:

  call ```add(EntityManager.getInstance());``` in the create function of your playstate.
  
  use ```EntityManager.getInstance().AddEntity();``` to add objects or groups to the manager.
  
  use ```AddComponent();``` on a class extending gameobject to add a new component.
  
  ```init()``` will run on the first update cycle, useful for getting and stashing references to other gameobjects.
  
Message System:

  IceEntity now includes a simple message broadcasting system. It is a useful way of quickly sending information or data between objects, without needing to store a reference. Simply call ```SendMessage()``` on an entity, with any info you need to send (explained in the method details). To recieve messages, simply override the ```RecieveMessage()``` function on an entity, and use that as a simple way to do whatever you want with the messages data, no need to manage a complicated event listener setup:)
  
  it should be fairly self explanatory, but if not, you can get in touch with me on twitter: [nico_m__](https://twitter.com/nico_m__).
  
  please note, I've had issues with code completion in flashdevelop, possibly due to the singleton pattern, so it may be easier to just read the source if you need function names + parameters. (if anyone knows how to fix this let me know)
  
  [Big Warning!!!]: There is currently no clean way to remove an entity (or clear the manager) I'm working on it:) (not like anyone actually uses this yet anyway);)
  
