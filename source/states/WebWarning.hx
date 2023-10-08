package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class WebWarning extends MusicBeatState {
	
	var warningText:FlxText;

	override function create() {
		
		warningText = new FlxText(0, 0, 1124, "Uh Oh!\nYou are being scammed! This is not an official build, thats because we wont let you play this HTML5 fake build. You wont be able to play this build because some sites reupload mods and some may contain a virus, download the official version on GameBanana!");
		warningText.setFormat('VCR OSD Mono', 58, FlxColor.WHITE, CENTER);
		warningText.screenCenter();
		add(warningText);

		super.create();
	}

	override function update(elapsed:Float) {
		
		super.update(elapsed);
	}
}
