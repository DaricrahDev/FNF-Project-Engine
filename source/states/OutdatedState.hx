package states;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var warnText:FlxText;
	var hue:Float = 0;
	var bg:FlxSprite;

	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33000000, 0x0));
		grid.velocity.set(30, 30);
		grid.scale.set(1.3, 1.3);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		warnText = new FlxText(0, 0, 956,
			"Looks like Project Engine is outdated!\n\n
			The version that you are using (" + Info.updateVersionAlt + ") is outdated! Please update to " + TitleState.updateVersion + " (the most recent one)\n\n
			Press ENTER to go to github
			Press ESCAPE to proceed anyway\n
			\n
			Thank you for using Project Engine!",
			37);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		warnText.borderSize = 2;
		warnText.antialiasing = true;
		warnText.screenCenter();
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		hue += elapsed * 10;
		if (hue > 360)
			hue -= 360;

		var color = FlxColor.fromHSB(Std.int(hue), 1, 1);
		bg.color = color;

		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/DaricrahDev/FNF-Project-Engine/releases");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
