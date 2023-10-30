package states;

import flixel.FlxState;
import states.TitleState;
import backend.Song;
import backend.Highscore;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import lime.utils.Assets;
import tjson.TJSON as Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import openfl.Assets;

typedef MenuData =
{
	backgroundSprite:String,
	bgColor:String,
	gradientSprite:String,
	gradientColor:String,
	oneshotSongName:String,
	checkersEnabled:Bool,
	randomTexts:Array<String>
}
class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = Info.updateVersionAlt; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var gradient:FlxSprite;
	var bg:FlxSprite;
	var testText:FlxText;
	var menuItem:FlxSprite;
	
	var featureText:FlxText;
	var darkBG:FlxSprite;

	var mods:FlxSprite;
	var credits:FlxSprite;

	var intendedColor:Int;
	var colorTween:FlxTween;

	var decorations:FlxSprite;

	var menuJSON:MenuData;

	//var featureIsClickable:Bool = false;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'), FlxG.sound.volume);

		menuJSON = Json.parse(Paths.getTextFromFile('moddingTools/customMenus/customMenus.json'));

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.mouse.visible = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		add(bg);
		
		gradient = new FlxSprite();
		gradient.color = CoolUtil.colorFromString(menuJSON.gradientColor);
		gradient.screenCenter();
		gradient.x += 20;
		add(gradient);

		// lot of important shit
		if (menuJSON.backgroundSprite != null && menuJSON.backgroundSprite.length > 0 && menuJSON.backgroundSprite != "none") {
			bg.loadGraphic(Paths.image(menuJSON.backgroundSprite));
			bg.screenCenter();
		}
		else
		{
			bg.loadGraphic(Paths.image('placeholders/noMenuImg'));
			bg.screenCenter();
		}

		if (menuJSON.gradientSprite != null && menuJSON.gradientSprite.length > 0 && menuJSON.gradientSprite != "none") {
			gradient.loadGraphic(Paths.image(menuJSON.gradientSprite));
			gradient.screenCenter();
		}
		else
		{
			gradient.loadGraphic(Paths.image('placeholders/invisibleImg'));
			gradient.screenCenter();
		}

		if (menuJSON.bgColor != null && menuJSON.bgColor.length > 0 && menuJSON.bgColor != "none") {
			bg.color = CoolUtil.colorFromString(menuJSON.bgColor);
		}
		else
		{
			bg.color = FlxColor.TRANSPARENT;
		}

		if (menuJSON.bgColor != "white") {
			bg.color = 0xfffffff;
		}

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33000000, 0x0));
		grid.velocity.set(30, 30);
		grid.scale.set(1.3, 1.3);
		grid.alpha = 0;
		grid.visible = menuJSON.checkersEnabled;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		var mainSide = new FlxSprite(0, 0).loadGraphic(Paths.image('mic-d-up/Main_Side'));
		add(mainSide);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		/*magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, 0);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);*/
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 207)  + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		camGame.zoom = 3;
		FlxTween.tween(camGame, {zoom: 1}, 1.1, {ease: FlxEase.expoInOut});

		if (ClientPrefs.data.goreEnabled) {
			decorations = new FlxSprite(0, 0).loadGraphic(Paths.image('halloween_gore'));
		}
		else
		{
			decorations = new FlxSprite(0, 0).loadGraphic(Paths.image('halloween'));
		}
			
		decorations.screenCenter(XY);
		decorations.scale.set(1.1, 1.1);
		decorations.visible = false;
		add(decorations);

		mods = new FlxSprite(935, -121).loadGraphic(Paths.image('mic-d-up/mods'));
		add(mods);

		credits = new FlxSprite(935, 553).loadGraphic(Paths.image('mic-d-up/credits'));
		add(credits);

		darkBG = new FlxSprite(-8, -4).makeGraphic(1504, 48, FlxColor.BLACK);
		darkBG.visible = ClientPrefs.data.randomMessage;
		darkBG.alpha = 0.5;
		add(darkBG);

		featureText = new FlxText(0, 0, 1244, "", 35);
		featureText.setFormat('VCR OSD Mono', 35, FlxColor.WHITE, CENTER);
		featureText.screenCenter();
		featureText.y -= 339;
		featureText.visible = ClientPrefs.data.randomMessage;
		add(featureText);

		FlxG.camera.follow(camFollow, null, 0);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, Info.engineNameWversion, 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = true;
		versionShit.setFormat(Info.defaultFont, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, Info.updateName, 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = true;
		versionShit.setFormat(Info.defaultFont, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//featureIsClickable = false;

		switch (FlxG.random.int(0, 5)) {

			case 0:
				featureText.text = menuJSON.randomTexts[0];
			case 1:
				featureText.text = menuJSON.randomTexts[1];
			case 2:
				featureText.text = menuJSON.randomTexts[2];
			case 3:
				featureText.text = menuJSON.randomTexts[3];
			case 4:
				featureText.text = menuJSON.randomTexts[4];
			case 5:	
				featureText.text = menuJSON.randomTexts[5];
		}

		/*if (ClientPrefs.data.isOneshotMod) {
			featureText.text = "ONESHOT MODE ENABLED - CLICK HERE TO DISABLE";
			featureText.color = FlxColor.CYAN;
			featureIsClickable = true;
		}*/

		// NG.core.calls.event.logEvent('swag').send();

		if (ClientPrefs.data.spookymonth) {
			decorations.visible = true;
			featureText.text = "It's spooky month!";
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{		
		if (ClientPrefs.data.spookymonth) {
			bg.color = 0xff292649;
			gradient.visible = false;
		}
		else
		{
			bg.color = CoolUtil.colorFromString(menuJSON.bgColor);
			gradient.visible = true;
		}

		/*if (featureIsClickable) {
			if (FlxG.mouse.overlaps(featureText)) {
				featureText.color = FlxColor.YELLOW;
				if (FlxG.mouse.justPressed) {
					MusicBeatState.switchState(new OptionsState());
				}
			}
			else {
				featureText.color = FlxColor.CYAN;
			}
		}
		else {
			featureText.color = FlxColor.WHITE;
		}*/

		/* bye bye shitty options
		if (ClientPrefs.data.bgcolor == 'Purple (Default)')
		{
			bg.color = 0xff7e0097;
			gradient.loadGraphic(Paths.image('gradient'));
		}
		else if (ClientPrefs.data.bgcolor == 'Red')
		{
			bg.color = 0xffdf2222;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xffdf2222;
		}
		else if (ClientPrefs.data.bgcolor == 'Green')
		{
			bg.color = 0xff6cfd18;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xff6cfd18;
		}
		else if (ClientPrefs.data.bgcolor == 'Blue')
		{
			bg.color = 0xff00c3ff;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xff00c3ff;
		}
		else if (ClientPrefs.data.bgcolor == 'White')
		{
			bg.color = 0xffffffff;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xffffffff;
		}
		else if (ClientPrefs.data.bgcolor == 'Orange')
		{
			bg.color = 0xffff5e00;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xffff5e00;
		}
		else if (ClientPrefs.data.bgcolor == 'Pink')
		{
			bg.color = 0xfff737dd;
			gradient.loadGraphic(Paths.image('gradient_white'));
			gradient.color = 0xfff737dd;
		}
		else if (ClientPrefs.data.bgcolor == 'RGB') {
			hue += elapsed * 10;
			if (hue > 360)
			hue -= 360;

			var color = FlxColor.fromHSB(Std.int(hue), 1, 1);
			bg.color = color;
			gradient.visible = false;
		}
		else if (ClientPrefs.data.bgcolor == 'OG') {
			bg.loadGraphic(Paths.image('menuBG'));
			gradient.visible = false;
		}*/

		if (FlxG.mouse.overlaps(mods))
			{
				FlxTween.tween(mods, {x: 935, y: -91}, 0.1, {ease: FlxEase.quadInOut});
	
				if (FlxG.mouse.justPressed)
				{
					MusicBeatState.switchState(new ModsMenuState());
				}
			}
			else
			{
				FlxTween.tween(mods, {x: 935, y: -121}, 0.1, {ease: FlxEase.quadInOut});
			}
	
			if (FlxG.mouse.overlaps(credits))
			{
				FlxTween.tween(credits, {x: 935, y: 522}, 0.1, {ease: FlxEase.quadInOut});
	
				if (FlxG.mouse.justPressed)
				{
						if (ClientPrefs.data.creditsType == 'Bios Menu') {
							MusicBeatState.switchState(new BiosMenuState());
						}
						else if (ClientPrefs.data.creditsType == 'Credits Menu') {
							MusicBeatState.switchState(new CreditsState());
						}
					//FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			}
			else
			{
				FlxTween.tween(credits, {x: 935, y: 553}, 0.1, {ease: FlxEase.quadInOut});
			}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}

				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad(Info.gamebananaLink);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(FlxG.camera, {zoom: 10, angle: 0, alpha: 0}, 0.5, {ease: FlxEase.expoIn});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										if (ClientPrefs.data.isOneshotMod) {
											var songLowercase:String = Paths.formatToSongPath(menuJSON.oneshotSongName);
											var poop:String = Highscore.formatSongButBetter(songLowercase, 'hard');

										PlayState.SONG = Song.loadFromJson(poop, songLowercase);
										PlayState.isStoryMode = false;
										PlayState.storyDifficulty = 1;

										LoadingState.loadAndSwitchState(new PlayState());
										}
										else {
											MusicBeatState.switchState(new StoryMenuState());
										}
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										//MusicBeatState.switchState(new CreditsState());
										
									case 'options':
										MusicBeatState.switchState(new OptionsState());
										OptionsState.onPlayState = false;
										if (PlayState.SONG != null)
										{
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
										}
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x += -200;
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}