package states;

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
import openfl.Assets;

class ProjectEngineMouse extends MusicBeatState
{
	//public static var psychEngineVersion:String = '0.4'; //This is also used for Discord RPC
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

	var storymode:FlxSprite;
	var freeplay:FlxSprite;
	var options:FlxSprite;

	var randomShit:Array<String> = [];
	var customBGColor:Array<String> = [];
	var playSongName:Array<String> = [];

	var hue:Float = 0;

	var decorations:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		randomShit = FlxG.random.getObject(getRandomShit());
		customBGColor = FlxG.random.getObject(getBackgroundColor());

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
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.color = CoolUtil.colorFromString(customBGColor[0]); 
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		gradient = new FlxSprite().loadGraphic(Paths.image('gradient_white'));
		gradient.color = CoolUtil.colorFromString(customBGColor[1]);
		gradient.screenCenter();
		gradient.x += 20;
		add(gradient);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33000000, 0x0));
		grid.velocity.set(30, 30);
		grid.scale.set(1.3, 1.3);
		grid.alpha = 0;
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

		/*for (i in 0...optionShit.length)
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
		}*/

		if (ClientPrefs.data.goreEnabled) {
			decorations = new FlxSprite(0, 0).loadGraphic(Paths.image('halloween_gore'));
		}
		else
		{
			decorations = new FlxSprite(0, 0).loadGraphic(Paths.image('halloween'));
		}

		
		camGame.zoom = 3;
		FlxTween.tween(camGame, {zoom: 1}, 1.1, {ease: FlxEase.expoInOut});

		mods = new FlxSprite(935, -121).loadGraphic(Paths.image('mic-d-up/mods'));
		add(mods);

		credits = new FlxSprite(935, 553).loadGraphic(Paths.image('mic-d-up/credits'));
		add(credits);

		FlxG.camera.follow(camFollow, null, 0);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, Info.engineNameWversion, 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = true;
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0,  Info.updateName, 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = true;
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		
		storymode = new FlxSprite(142, 123); 
		storymode.frames = Paths.getSparrowAtlas('mainmenu/menu_story_mode');
		storymode.animation.addByPrefix('idle', 'story_mode basic', 24);
		storymode.animation.addByPrefix('selected', 'story_mode white', 24);
		storymode.animation.play('idle');
		add(storymode);

		freeplay = new FlxSprite(156, 310); 
		freeplay.frames = Paths.getSparrowAtlas('mainmenu/menu_freeplay');
		freeplay.animation.addByPrefix('idle', 'freeplay basic', 24);
		freeplay.animation.addByPrefix('selected', 'freeplay white', 24);
		freeplay.animation.play('idle');
		add(freeplay);
		
		options = new FlxSprite(192, 524); 
		options.frames = Paths.getSparrowAtlas('mainmenu/menu_options');
		options.animation.addByPrefix('idle', 'options basic', 24);
		options.animation.addByPrefix('selected', 'options white', 24);
		options.animation.play('idle');
		add(options);

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

		switch (FlxG.random.int(0, 5)) {

			case 0:
				featureText.text = randomShit[0];
			case 1:
				featureText.text = randomShit[1];
			case 2:
				featureText.text = randomShit[2];
			case 3:
				featureText.text = randomShit[3];
			case 4:
				featureText.text = randomShit[4];
		}

		if (ClientPrefs.data.spookymonth) {
			mods.loadGraphic(Paths.image('mic-d-up/spookyEvent'));
			decorations.visible = true;

			featureText.text = "It's spooky month!";
		}

		if (ClientPrefs.data.spookymonth) {
			bg.color = 0xff414141;
			gradient.visible = false;
		}
		else
		{
			bg.color = CoolUtil.colorFromString(customBGColor[0]);
			gradient.visible = true;
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	function getSongName():Array<Array<String>> // ADD ONLY ONE SONG!!!!
		{
			#if MODS_ALLOWED
			var firstArray:Array<String> = Mods.mergeAllTextsNamed('customMenus/oneshotSongName.txt', Paths.getPreloadPath());
			#else
			var fullText:String = Assets.getText(Paths.customMenusTxt('oneshotSongName'));
			var firstArray:Array<String> = fullText.split('\n');
			#end
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('--'));
			}
	
			return swagGoodArray;
		}

		function getBackgroundColor():Array<Array<String>> // ADD ONLY ONE SONG!!!! //getBackgroundColor
			{
				#if MODS_ALLOWED
				var firstArray:Array<String> = Mods.mergeAllTextsNamed('customMenus/customBGColors.txt', Paths.getPreloadPath());
				#else
				var fullText:String = Assets.getText(Paths.customMenusTxt('customBGColors'));
				var firstArray:Array<String> = fullText.split('\n');
				#end
				var swagGoodArray:Array<Array<String>> = [];
		
				for (i in firstArray)
				{
					swagGoodArray.push(i.split('--'));
				}
		
				return swagGoodArray;
			}

	function getRandomShit():Array<Array<String>>
		{
			#if MODS_ALLOWED
			var firstArray:Array<String> = Mods.mergeAllTextsNamed('customMenus/randomMenuText.txt', Paths.getPreloadPath());
			#else
			var fullText:String = Assets.getText(Paths.customMenusTxt('randomMenuText'));
			var firstArray:Array<String> = fullText.split('\n');
			#end
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('--'));
			}
	
			return swagGoodArray;
		}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(storymode)) {
			storymode.animation.play('selected');
			storymode.setPosition(142, 109); 

			if (FlxG.mouse.justPressed) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (ClientPrefs.data.isOneshotMod) {
					var songLowercase:String = Paths.formatToSongPath(playSongName[0]);
					var poop:String = Highscore.formatSongButBetter(songLowercase, 'hard');

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;

				LoadingState.loadAndSwitchState(new PlayState());
				}
				else {
					MusicBeatState.switchState(new StoryMenuState());
				}
			}
		}
		else {
			storymode.animation.play('idle');
			storymode.setPosition(142, 123);
		}

		if (FlxG.mouse.overlaps(freeplay)) {
			freeplay.animation.play('selected');
			freeplay.setPosition(156, 310);

			if (FlxG.mouse.justPressed) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				MusicBeatState.switchState(new FreeplayState());
			}
		}
		else {
			freeplay.animation.play('idle');
			freeplay.setPosition(156, 324);
		}

		if (FlxG.mouse.overlaps(options)) {
			options.animation.play('selected');
			options.setPosition(192, 510);

			if (FlxG.mouse.justPressed) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				MusicBeatState.switchState(new options.OptionsState());
			}
		}
		else {
			options.animation.play('idle');
			options.setPosition(192, 524);
	}

		if (FlxG.mouse.overlaps(mods))
			{
				FlxTween.tween(mods, {x: 935, y: -91}, 0.1, {ease: FlxEase.quadInOut});
	
				if (FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
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
					FlxG.sound.play(Paths.sound('confirmMenu'));
					if (ClientPrefs.data.creditsType == 'Bios Menu') {
						MusicBeatState.switchState(new BiosMenuState());
					}
					else if (ClientPrefs.data.creditsType == 'Credits Menu') {
						MusicBeatState.switchState(new CreditsState());
					}
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
			/*if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}*/

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			/*if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
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
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new OptionsState());
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
			}*/
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
