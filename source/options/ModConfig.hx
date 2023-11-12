package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class ModConfig extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Preferences';
		rpcTitle = 'Preferences Menu'; //for Discord Rich Presence

		if (ClientPrefs.data.languages == 'Español')
			title = 'Preferencias';
			rpcTitle = 'Menú de Preferencias';

		var option:Option = new Option('Oneshot Mod',
			'If checked, enables the oneshot mod mode.',
			'isOneshotMod',
			'bool');
		addOption(option);

	var option:Option = new Option('Show Random Message',
		"If unchecked, will hide the random message that shows at the main menu.",
		'randomMessage',
		'bool');
	addOption(option);

	var option:Option = new Option('Beat on title',
	"If unchecked, will hide the beat at the title screen.",
	'beatTitle',
	'bool');
	addOption(option);

		var option:Option = new Option('Menu Type:',
		"Select between two menu types, the OG or the one we made for this engine.",
		'menuType',
		'string',
		['Project Engine', 'FNF']);
	addOption(option);

	var option:Option = new Option('Credits Type:',
	"Select between two credits menu types, the credits menu or the bios menu.",
	'creditsType',
	'string',
	['Bios Menu', 'Credits Menu']);
	addOption(option);

	var option:Option = new Option('Enable Freeplay Characters',
	"[W.I.P]\nIf enabled, enables freeplay characters.",
	'enablefreeplayChars',
	'bool');
	addOption(option);

		super();
	            
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
	}
}
