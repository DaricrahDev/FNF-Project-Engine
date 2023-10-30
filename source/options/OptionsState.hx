package options;

import states.UnfinishedWarn.UnfinishedWarning;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import states.MainMenuState;
import backend.StageData;
import states.FNFMainMenu;
import states.ProjectEngineMouse;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mod Preferences'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	var gradient:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Mod Preferences':
				openSubState(new options.ModConfig());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var bg:FlxSprite; 

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		FlxG.sound.playMusic(Paths.music('optionsMenu'), 1);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
		add(bg);

		gradient = new FlxSprite().loadGraphic(Paths.image('gradient_options'));
		gradient.screenCenter();
		gradient.scale.set(1.1, 1.1);
		gradient.x += 20;
		add(gradient);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33000000, 0x0));
		grid.velocity.set(30, 30);
		grid.scale.set(1.3, 1.3);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (ClientPrefs.data.spookymonth) {
			bg.color = 0xffe07902;
			gradient.visible = false;
		}
		else
		{
			bg.color = 0xff0c77b6;
			gradient.visible = true;
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else if (ClientPrefs.data.menuType == 'Project Engine') {
				MusicBeatState.switchState(new MainMenuState());
			}
			else if (ClientPrefs.data.menuType == 'FNF') {
				MusicBeatState.switchState(new FNFMainMenu());
			}
			else if (ClientPrefs.data.menuType == 'PE (Mouse)') {
				MusicBeatState.switchState(new UnfinishedWarning());
			}
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}