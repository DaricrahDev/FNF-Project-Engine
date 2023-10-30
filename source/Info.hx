package;

import states.MainMenuState;
/**
 * mostly used for random shit
 */
class Info {
	public static var updateName:String = "Spooky Event Update - The JSON update";
	public static var updateVersion:String = "0.5";
	public static var updateVersionAlt:String = "v" + updateVersion;
	public static var gamebananaLink:String = "https://gamebanana.com/mods/462080";
	public static var discordLink:String = "https://discord.gg/PNcTpUTcKS";
	public static var engineNameWversion:String = "Project Engine " + updateVersionAlt;
	public static var engineNameNoversion:String = "Project Engine";
	//public static var defaultBGColor:FlxColor = 0xff7e0097;
	public static var defaultFont:String = "VCR OSD Mono";

	public function new() {	
		if (updateName != null && updateName.length > 0 && updateName != "none") {
			updateName = "No update name specified.";
		}
	}
} 