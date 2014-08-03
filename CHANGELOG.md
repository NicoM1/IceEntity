1.0.2
------------------------------
* allow animation addition using entity.loadAnimation() (lets you use fancy frame declarations)

1.0.1
------------------------------
* allow adding scripts to an entity via entity.scripts.ParseScript(path)
* fix new entities in groups not being drawn
* allow type declarations in callable functions

1.0.0
------------------------------
* rewrite scripting system, allow for real haxe files
* remove map property on EntityManager
* add instance and template creation for entity xml files

0.10.1
------------------------------
* extend interp to allow property access on objects

0.10.0
------------------------------
* add syntax for exposing and requesting classes inside of scripts

0.9.0
------------------------------
* add simple fsm system

0.8.2
------------------------------
* fix parsing mistake causing scripts to only load if the entity had an art element

0.8.1
------------------------------
* make sure to check that entities aren't null

0.8.0
------------------------------
* add noreload option
* make scripts delete if they only have init logic (unless noclean is specified)

0.7.0
------------------------------
* allow access to instance via a property

0.6.3
------------------------------
* fix backward conditionals that broke string loading

0.6.2
------------------------------
* only call @reload if script changed

0.6.1
------------------------------
* add option for true live-reloading

0.6.0
------------------------------
* integrate live-reloading of external scripts
* add @reload function for scripts
* change Owner to GID

0.5.6
------------------------------
* fix spelling of receive

0.5.5
------------------------------
* check destroyScript for null

0.5.4
------------------------------
* fix underlying mistake that caused the need for the if(!init) check

0.5.3
------------------------------
* hard-code the if(!init) check

0.5.2
------------------------------
* fix parsing of entity scripts

0.5.1
------------------------------
* fix for new handling of flxgroups
* add init variable to (sort of) fix recurring init

0.5.0
------------------------------
* added hscript integration

0.4.0
------------------------------
* changed group storage and behaviour
* split AddEntity() into separate methods 

0.3.1
------------------------------
* added ability to use hyphens in animation parsing

0.3.0
------------------------------
* added entity xml parser

0.2.1
------------------------------
* added destruction of entities
* removed template
* added haxelib setup

0.2.0
------------------------------
* marked version numbers (not coded anywhere in project, just for reference)
* all classes have replaced the word "gameobject" with entity, I know its annoying, but in the end its shorter to type...
* added a simple message broadcasting system
* added distance measuring between entities
* added IsAgainst() for determining if an entity is directly touching something in a given direction

0.1.1
------------------------------
* packages have been renamed to: ice.entity.[class].
* code has been surrounded in a template haxeflixel project, with EntityManager already added.

0.1.0
------------------------------
* code ported from IceEntity
