package ice.group;

import flixel.group.FlxGroup;
import ice.entity.Entity;

class EntityGroup extends FlxTypedGroup<Entity>
{

	public function new(MaxSize:Int) 
	{
		super(MaxSize);
	}
	
}