package ice.entity;

import haxe.io.Eof;
import openfl.Assets;
#if !flash 
#if !js
import sys.io.File;
import sys.io.FileInput;
#end
#end

/**
 * ...
 * @author 
 */
class IceUtil
{
	/**
	 * Loads a text file from disk
	 * @param	path		relative path to the text file
	 * @param	useAssets	whether to use Openfl.Assets (required on flash)
	 */
	static public function LoadString(path:String, useAssets:Bool):String
	{
		var string:String = "";
		#if (flash || js)
		if (!useAssets)
		{
			throw "run time file loading is not supported on web";
		}
		#end
		if (useAssets)
		{
			var ret = Assets.getText(path);
			if (ret != null)
			{
				return ret;
			}
			else 
			{
				throw "unable to load: " + path;
			}
		}
		else
		{
			#if !(flash || js)
			try
			{
				var fileIn = File.read(path, false);
				while (true)
				{
					string += fileIn.readLine() + "\n";
				}
				fileIn.close();
			}
			catch (ex:Eof)
			{
				return string;
			}
			catch (e:Dynamic)
			{
				throw "unable to load file from: " + path;
			}
			#end
		}

		return string;
	}
}