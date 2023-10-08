package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.*;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
#if sys
import sys.FileSystem;
#end
import flixel.addons.ui.FlxInputText;

class BiosMenuState extends MusicBeatState {
	
	var bg:FlxSprite;
	var background:FlxSprite;
    var imageSprite:FlxSprite;
	
    var imagePath:Array<String>;
    var charDesc:Array<String>;
    var charName:Array<String>;
	var linkOpen:Array<String>;
	var badgeimg:Array<String>;
	var badgeText:Array<String>;
	var peopleLinks:Array<String>;

	var curSelected:Int = -1;
	var currentIndex:Int = 0;
	var hue:Float = 0;

    var descriptionText:FlxText;
    var characterName:FlxText;

	var intendedColor:Int;
	var colorTween:Array<FlxColor>;

	var discord:FlxText;
	var gradient:FlxSprite;

	// stealing code from titlestate yeeesssssss
	var characterNames:Array<String> = []; // dis one for character names
	var descriptionThing:Array<String> = []; // dis one for description
	var badgeImageStuff:Array<String> = []; // dis one for badge images
	var badgeTextStuff:Array<String> = []; // and dis one for badge text
	var customBGc:Array<String> = []; // bg color
	var funnilinks:Array<String> = [];

	var badgeImg:FlxSprite;
	var badgetextx:FlxText;

	var arrowUp:FlxSprite;
	var arrowDown:FlxSprite;

	override function create() {
		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.mouse.visible = true;

		// let bro cook
		characterNames = FlxG.random.getObject(characterNamesShit());
		descriptionThing = FlxG.random.getObject(descNamesShit());
		badgeImageStuff = FlxG.random.getObject(badgeImages());
		badgeTextStuff = FlxG.random.getObject(badgeTextShit());
		customBGc = FlxG.random.getObject(getbgc());
		funnilinks = FlxG.random.getObject(getTxtLinks());

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Bios Menu", null);
		#end
	
		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        background.setGraphicSize(Std.int(background.width * 1.2));
		background.color = CoolUtil.colorFromString(customBGc[0]);
        background.screenCenter();
        add(background);

		gradient = new FlxSprite().loadGraphic(Paths.image('gradient_white'));
		gradient.screenCenter();
		gradient.color = CoolUtil.colorFromString(customBGc[1]);
		gradient.scale.set(1.1, 1.1);
		gradient.x += 20;
		add(gradient);

		// i took this from psych's engine code lol
		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33000000, 0x0));
		grid.velocity.set(30, 30);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		// EDIT YOU IMAGES HERE / DONT FORGET TO CREATE A FOLDER IN images CALLED bios IT SHOULD LOOK LIKE THIS 'images/bios'
		// REMINDER!!! THE IMAGES MUST BE 518x544, IF NOT, THEY WONT FIT ON THE SCREEN!!
		imagePath = ["bios/1", "bios/2", "bios/3", "bios/4", "bios/5"];

		//funni links
		peopleLinks = [funnilinks[0], funnilinks[1], funnilinks[2], funnilinks[3], funnilinks[4]];

		// badge text
		badgeText = [badgeTextStuff[0], badgeTextStuff[1], badgeTextStuff[2], badgeTextStuff[3], badgeTextStuff[4]];

		// badge img
		badgeimg = [badgeImageStuff[0], badgeImageStuff[1], badgeImageStuff[2], badgeImageStuff[3], badgeImageStuff[4]];

		// DESCRIPTION HERE
        charDesc = [descriptionThing[0], descriptionThing[1], descriptionThing[2], descriptionThing[3], descriptionThing[4]];

		// NAME HERE
        charName = [characterNames[0], characterNames[1], characterNames[2], characterNames[3], characterNames[4]];


		// SET UP THE FIRST IMAGE YOU WANT TO SEE WHEN ENTERING THE MENU
		imageSprite = new FlxSprite(55, 99).loadGraphic(Paths.image("bios/1"));
        add(imageSprite);

		badgeImg = new FlxSprite(1086, 451).loadGraphic(Paths.image('badge4'));
		add(badgeImg);

		badgetextx = new FlxText(1069, 628, 197, 'Main Programmer');
		badgetextx.setFormat('VCR OSD Mono', 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(badgetextx);

		characterName = new FlxText(630, 94, 622, charName[currentIndex]);
        characterName.setFormat(Paths.font("vcr.ttf"), 96, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterName.antialiasing = true;
		characterName.borderSize = 4;
        add(characterName);

		descriptionText = new FlxText(630, 247, 601, charDesc[currentIndex]);
        descriptionText.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.antialiasing = true;
		descriptionText.borderSize = 2.5;
        add(descriptionText);

		var arrows = new FlxSprite(218, 30).loadGraphic(Paths.image('bios/assets/biosThing'));
		add(arrows);

		/*var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		discord = new FlxText(textBG.x, textBG.y + 4, FlxG.width, 'Press ENTER to join our discord server', 18);
		discord.setFormat('VCR OSD Mono', 18, FlxColor.WHITE, RIGHT);
		discord.borderSize = 2.5;
		add(discord);*/

		super.create();
	}

	function getbgc():Array<Array<String>>
		{
			#if MODS_ALLOWED
			var firstArray:Array<String> = Mods.mergeAllTextsNamed('customBios/customBGColors.txt', Paths.getPreloadPath());
			#else
			var fullText:String = Assets.getText(Paths.customBiosTxt('customBGColors'));
			var firstArray:Array<String> = fullText.split('\n');
			#end
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('--'));
			}
	
			return swagGoodArray;
		}

		function getTxtLinks():Array<Array<String>>
			{
				#if MODS_ALLOWED
				var firstArray:Array<String> = Mods.mergeAllTextsNamed('customBios/links.txt', Paths.getPreloadPath());
				#else
				var fullText:String = Assets.getText(Paths.customBiosTxt('links'));
				var firstArray:Array<String> = fullText.split('\n');
				#end
				var swagGoodArray:Array<Array<String>> = [];
		
				for (i in firstArray)
				{
					swagGoodArray.push(i.split('--'));
				}
		
				return swagGoodArray;
			}

	// insert functions
	function characterNamesShit():Array<Array<String>>
		{
			var fullText:String = Assets.getText(Paths.customBiosTxt('characters'));
	
			var firstArray:Array<String> = fullText.split('\n');
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('::'));
			}
	
			return swagGoodArray;
		}

	function descNamesShit():Array<Array<String>>
		{
			var fullText:String = Assets.getText(Paths.customBiosTxt('descriptions'));
		
			var firstArray:Array<String> = fullText.split('\n');
			var swagGoodArray:Array<Array<String>> = [];
		
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('::'));
			}
		
			return swagGoodArray;
		}

		function badgeImages():Array<Array<String>>
			{
				var fullText:String = Assets.getText(Paths.customBiosTxt('badgeImages'));
			
				var firstArray:Array<String> = fullText.split('\n');
				var swagGoodArray:Array<Array<String>> = [];
			
				for (i in firstArray)
				{
					swagGoodArray.push(i.split('::'));
				}
			
				return swagGoodArray;
			}


			function badgeTextShit():Array<Array<String>>
				{
					var fullText:String = Assets.getText(Paths.customBiosTxt('badgeText'));
				
					var firstArray:Array<String> = fullText.split('\n');
					var swagGoodArray:Array<Array<String>> = [];
				
					for (i in firstArray)
					{
						swagGoodArray.push(i.split('::'));
					}
				
					return swagGoodArray;
				}

	override function update(elapsed:Float) {
		
		/*hue += elapsed * 10;
		if (hue > 360)
			hue -= 360;

		var color = FlxColor.fromHSB(Std.int(hue), 1, 1);
		gradient.color = color;
		background.color = color;*/

		/*if (controls.ACCEPT) {
			CoolUtil.browserLoad('https://discord.gg/PNcTpUTcKS');
		}*/



		if (ClientPrefs.data.autoResizeImg) {
			imageSprite.setGraphicSize(518, 544);
		}

		if (controls.ACCEPT) {
			CoolUtil.browserLoad(peopleLinks[currentIndex]);
		}

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) 
			{
				currentIndex--;
				if (currentIndex < 0)
				{
					currentIndex = imagePath.length - 1;
				}
				remove(imageSprite);
				imageSprite = new FlxSprite(55, 99).loadGraphic(Paths.image(imagePath[currentIndex]));
				add(imageSprite);
				FlxTween.tween(imageSprite, {x: 55, y: 101}, 0.1, {ease: FlxEase.quadInOut});
				remove(badgeImg);
				badgeImg = new FlxSprite(1086, 451).loadGraphic(Paths.image(badgeimg[currentIndex]));
				add(badgeImg);
				descriptionText.text = charDesc[currentIndex];
				characterName.text = charName[currentIndex];
				badgetextx.text = badgeText[currentIndex];
				FlxG.sound.play(Paths.sound('scrollMenu'));  
	
			}
			else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				currentIndex++;
				if (currentIndex >= imagePath.length)
				{
					currentIndex = 0;
				}
				remove(imageSprite);
				imageSprite = new FlxSprite(55, 99).loadGraphic(Paths.image(imagePath[currentIndex]));
				add(imageSprite);
				FlxTween.tween(imageSprite, {x: 55, y: 101}, 0.1, {ease: FlxEase.quadInOut});
				remove(badgeImg);
				badgeImg = new FlxSprite(1086, 451).loadGraphic(Paths.image(badgeimg[currentIndex]));
				add(badgeImg);
				descriptionText.text = charDesc[currentIndex];
				characterName.text = charName[currentIndex];  
				badgetextx.text = badgeText[currentIndex];
				FlxG.sound.play(Paths.sound('scrollMenu'));		
			}
			if (controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					if (ClientPrefs.data.menuType == 'Project Engine') {
						MusicBeatState.switchState(new MainMenuState());
					}
					else if (ClientPrefs.data.menuType == 'FNF') {
						MusicBeatState.switchState(new FNFMainMenu());
					}
					else if (ClientPrefs.data.menuType == 'PE (Mouse)') {
						MusicBeatState.switchState(new ProjectEngineMouse());
					}
				}
		
		super.update(elapsed);
	}
}