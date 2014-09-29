package ice.wrappers;

import flixel.FlxCamera.FlxCameraFollowStyle;

/**
 * ...
 * @author 
 */
class FlxCameraFollowStyleWrap
{
	/**
	 * Camera has no deadzone, just tracks the focus object directly.
	 */
	static var LOCKON:FlxCameraFollowStyle = FlxCameraFollowStyle.LOCKON;
	/**
	 * Camera's deadzone is narrow but tall.
	 */
	static var PLATFORMER:FlxCameraFollowStyle = FlxCameraFollowStyle.PLATFORMER;
	/**
	 * Camera's deadzone is a medium-size square around the focus object.
	 */
	static var TOPDOWN:FlxCameraFollowStyle = FlxCameraFollowStyle.TOPDOWN;
	/**
	 * Camera's deadzone is a small square around the focus object.
	 */
	static var TOPDOWN_TIGHT:FlxCameraFollowStyle = FlxCameraFollowStyle.TOPDOWN_TIGHT;
	/**
	 * Camera will move screenwise.
	 */
	static var SCREEN_BY_SCREEN:FlxCameraFollowStyle = FlxCameraFollowStyle.SCREEN_BY_SCREEN;
	/**
	 * Camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	static var NO_DEAD_ZONE:FlxCameraFollowStyle = FlxCameraFollowStyle.NO_DEAD_ZONE;
}