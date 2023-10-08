package;

/**
 * mostly used for discord rpc
 */
 
typedef Variables =
{
	var fps:Int;
}
class Info {
	public static var updateName:String = "Spooky Event Update";
	public static var updateVersion:String = "0.5";
	public static var pressTabThing:String = "Press TAB to enable spooky mode";
	public static var updateVersionAlt:String = "v" + updateVersion;
	public static var gamebananaLink:String = "https://gamebanana.com/mods/462080";
	public static var discordLink:String = "https://discord.gg/PNcTpUTcKS";
	public static var engineNameWversion:String = "Project Engine " + updateVersionAlt;
	public static var engineNameNoversion:String = "Project Engine";
	public static var defaultBGColor:FlxColor = 0xff7e0097;

	public function new() {	
		if (updateName == null) {
			updateName = "No update name specified.";
		}

		if (ClientPrefs.data.spookymonth) {
			defaultBGColor = 0xff303030;
		}
	}


} 