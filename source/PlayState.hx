package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIDropDownMenu;

class PlayState extends FlxState
{
	var c8:Chip8;

	var displayPixels = new Array<FlxSprite>();
	var width:Int = 64;
	var height:Int = 32;
	var scale:Int = 10;
	var cycleSpeed:Int = 12;
	var romloaded:Bool = false;

	var inputRom:FlxInputText;
	var inputCycle:FlxInputText;
	var button:FlxButton;
	var colorPicker:FlxUIDropDownMenu;
	var colorList:Array<String>;
	var colorPixel:Int;
	var colorBg:Int;
	var textTitle:FlxText;
	var textInst:FlxText;
	var menu:Bool = false;
	var once:Bool = false;

	override public function create()
	{
		super.create();

		colorPixel = 0xFFFFFFFF;
		colorBg = 0xFF000000;

		FlxG.cameras.bgColor = colorBg;
		pixelLoader();

		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		inputRom = new FlxInputText(250, 263, 100, "IBMLogo.ch8");
		inputCycle = new FlxInputText(355, 263, 30, Std.string(cycleSpeed));
		button = new FlxButton(280, 280, "Enter", onClick);
		textTitle = new FlxText(174, 120, 0, "Hello Flixel-8!", 32);
		textInst = new FlxText(174, 200, 0, "Left Box Text: Enter ROM name (must be in assets/data)\nRight Text Box: Instructions per cycle (adjust if needed)\nPress [SPACE] to toggle this menu", 8);
		textInst.alignment = FlxTextAlign.CENTER;
		add(inputRom);
		add(inputCycle);
		add(button);
		add(textTitle);
		add(textInst);

		
		colorList = ["Dark", "Light", "Techno Blue", "Love <3", "Terminal", "GB Retro"];
		colorPicker = new FlxUIDropDownMenu(10, 280, FlxUIDropDownMenu.makeStrIdLabelArray(colorList, true), onColorChange);
		colorPicker.header.text.text = "Pick Theme";
		add(colorPicker);

		//c8.loadFontIntoMem();
		//c8.loadRomIntoMem();
		//c8.debug();

		//c8.emuCycle();

		//renderDisplay(c8.frameBuffer);

		trace("Create done");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (romloaded == true) 
		{
			inputHandle(c8.keys);

			for (i in 0 ... cycleSpeed) 
			{
				c8.emuCycle();
			}

			renderDisplay(c8.frameBuffer);

			emuMenu();
		}
	}

	public function renderDisplay(frameBuffer:Array<Int>)
	{
		for (i in 0 ... width) 
		{
			for (j in 0 ... height) 
			{
				var index:Int = j * width + i;
				var pixelSpriteIndex:Int = j * width + i;

				displayPixels[pixelSpriteIndex].visible = (frameBuffer[index] == 1);
			}
		}
	}

	public function pixelLoader() 
	{
		for (j in 0 ... height) 
		{
			for (i in 0 ... width) 
			{
				var pixel:FlxSprite = new FlxSprite(i * scale, j * scale);
				pixel.makeGraphic(scale, scale, colorPixel);
				pixel.visible = false;
				displayPixels.push(pixel);
				add(pixel);
			}
		}
	}

	public function updatePixelColor()
	{
		for (i in 0 ... displayPixels.length) 
		{
			displayPixels[i].color = colorPixel;
		}
	}

	public function inputHandle(keys:Array<Int>) 
	{
		if (FlxG.keys.pressed.X) 
		{
			keys[0] = 1;
		}
		else
		{
			keys[0] = 0;
		}
		if (FlxG.keys.pressed.ONE) 
		{
			keys[1] = 1;
		}
		else
		{
			keys[1] = 0;
		}
		if (FlxG.keys.pressed.TWO) 
		{
			keys[2] = 1;
		}
		else
		{
			keys[2] = 0;
		}
		if (FlxG.keys.pressed.THREE) 
		{
			keys[3] = 1;
		}
		else
		{
			keys[3] = 0;
		}
		if (FlxG.keys.pressed.Q) 
		{
			keys[4] = 1;
		}
		else
		{
			keys[4] = 0;
		}
		if (FlxG.keys.pressed.W) 
		{
			keys[5] = 1;
		}
		else
		{
			keys[5] = 0;
		}
		if (FlxG.keys.pressed.E) 
		{
			keys[6] = 1;
		}
		else
		{
			keys[6] = 0;
		}
		if (FlxG.keys.pressed.A) 
		{
			keys[7] = 1;
		}
		else
		{
			keys[7] = 0;
		}
		if (FlxG.keys.pressed.S) 
		{
			keys[8] = 1;
		}
		else
		{
			keys[8] = 0;
		}
		if (FlxG.keys.pressed.D) 
		{
			keys[9] = 1;
		}
		else
		{
			keys[9] = 0;
		}
		if (FlxG.keys.pressed.Z) 
		{
			keys[10] = 1;
		}
		else
		{
			keys[10] = 0;
		}
		if (FlxG.keys.pressed.C) 
		{
			keys[11] = 1;
		}
		else
		{
			keys[11] = 0;
		}
		if (FlxG.keys.pressed.FOUR) 
		{
			keys[12] = 1;
		}
		else
		{
			keys[12] = 0;
		}
		if (FlxG.keys.pressed.R) 
		{
			keys[13] = 1;
		}
		else
		{
			keys[13] = 0;
		}
		if (FlxG.keys.pressed.F) 
		{
			keys[14] = 1;
		}
		else
		{
			keys[14] = 0;
		}
		if (FlxG.keys.pressed.V) 
		{
			keys[15] = 1;
		}
		else
		{
			keys[15] = 0;
		}
	}

	public function emuMenu()
	{
			if (menu == true) 
			{
				add(inputRom);
				add(inputCycle);
				add(button);
				add(colorPicker);
			}
			else 
			{
				remove(inputRom);
				remove(inputCycle);
				remove(button);
				remove(colorPicker);
			}
			
			if(FlxG.keys.pressed.SPACE) 
			{
				if (once == false) 
				{
					menu = !menu;
				}

				once = true;
			}
			else 
			{
				once = false;
			}
	}

	public function onClick() 
	{
		//trace(inputRom.text);
		c8 = new Chip8("assets/data/" + inputRom.text);
		cycleSpeed = Std.parseInt(inputCycle.text);
		c8.loadFontIntoMem();
		c8.loadRomIntoMem();
		remove(inputRom);
		remove(inputCycle);
		remove(button);
		remove(colorPicker);
		remove(textTitle);
		remove(textInst);
		menu = false;

		romloaded = true;
	}

	public function onColorChange(ID:String)
	{
		//trace(ID);

		if (ID == "0") 
		{
			colorPixel = 0xFFFFFFFF;
			colorBg = 0xFF000000;
		}
		else if (ID == "1") 
		{
			colorPixel = 0xFF000000;
			colorBg = 0xFFFFFFFF;
		}
		else if (ID == "2") 
		{
			colorPixel = 0xFF3299B4;
			colorBg = 0xFF02313D;
		}
		else if (ID == "3") 
		{
			//colorBg = 0xFFFFB3CB;
			//colorPixel = 0xFFFF69D7;

			colorBg = 0xFFFF709D;
			colorPixel = 0xFFFFB0C9;
		}
		else if (ID == "4") 
		{
			colorBg = 0xFF000000;
			colorPixel = 0xFF41FF00;
		}
		else if (ID == "5") 
		{
			colorBg = 0xFF8BAC0F;
			//colorPixel = 0xFFC4EC13;
			colorPixel = 0xFF306230;
		}

		if (ID == "1") 
		{
			textTitle.color = 0xFF000000;
			textInst.color = 0xFF000000;
		}
		else 
		{
			textTitle.color = 0xFFFFFFFF;
			textInst.color = 0xFFFFFFFF;
		}


		FlxG.cameras.bgColor = colorBg;

		updatePixelColor();
	}
}
