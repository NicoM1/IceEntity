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
