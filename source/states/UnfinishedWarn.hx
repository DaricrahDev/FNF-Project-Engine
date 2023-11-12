package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class UnfinishedWarning extends MusicBeatState {

	public static var shitState:FlxState;
	var text:FlxText;

	override function create() {
		
		text = new FlxText(0, 0, 1134, "WARNING!\n\nTHIS STAGE IS NOT FINISHED!\nEXPECT BUGS AND GAME CRASHES WHILE YOU ARE USING THIS STATE, IF YOU FIND A BUG, PLEASE REPORT IT IN THE DISCORD SERVER.");
		text.setFormat(Info.defaultFont, 38, 0xFFFFFFF, CENTER);
		text.screenCenter();
		add(text);

		if (ClientPrefs.data.languages == 'Español')
			text.text = "AVISO!\n\nESTA PARTE DEL JUEGO NO ESTÁ TERMINADA!\nENCONTRAR ERRORES MIENTRAS USA ESTE NIVEL ES MUY COMÚN, SI ENCUENTRAS UN ERROR, POR FAVOR, REPÓRTALO AL SERVIDOR DE DISCORD";

		super.create();
	}

	override function update(elapsed:Float) {
		
		if (controls.BACK) {
			MusicBeatState.switchState(new ProjectEngineMouse());
		}

		super.update(elapsed);
	}
}