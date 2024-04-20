import haxe.io.Bytes;

class Chip8 
{
	var memory:Array<Int> = new Array(); //4Kb Memory
	var registers:Array<Int> = new Array(); //V[0] to V[F] General Purpose
	var index:Int; //store memory address
	var pc:Int; //program counter, hold next memory address of instrution to excute
	var sp:Int; //stack pointer, postion in stack
	var dt:Int; //delay timmer
	var st:Int; //sound timmer
	var stack:Array<Int> = new Array(); //stack memory
	public var frameBuffer:Array<Int> = new Array(); //stores graphics per frame
	public var keys:Array<Int> = new Array(); //for input tracking
	var opcode:Int; //holds the instruction

	var font:Array<Int> = new Array(); //bulit in fonts

	var romPath:String; //path to rom (assets/data/...)

	public function new(romPath:String) 
	{
		//ram to 4kb
		for (i in 0 ... 4096) 
		{
			memory[i] = 0;
		}

		//regs, stack, keys, all set to 0 to begin with
		for (i in 0 ... 16) 
		{
			registers[i] = 0;
			stack[i] = 0;
			keys[i] = 0;
		}

		//pixels are "off"
		for (i in 0 ... (64*32)) 
		{
			frameBuffer[i] = 0;
		}

		index = 0;
		pc = 0x200; //rom starts at 0x200 in memory fool
		sp = 0;
		opcode = 0;

		//bulit in fonts sprite data
		font = [ 
				0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
				0x20, 0x60, 0x20, 0x20, 0x70, // 1
				0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
				0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
				0x90, 0x90, 0xF0, 0x10, 0x10, // 4
				0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
				0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
				0xF0, 0x10, 0x20, 0x40, 0x40, // 7
				0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
				0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
				0xF0, 0x90, 0xF0, 0x90, 0x90, // A
				0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
				0xF0, 0x80, 0x80, 0x80, 0xF0, // C
				0xE0, 0x90, 0x90, 0x90, 0xE0, // D
				0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
				0xF0, 0x80, 0xF0, 0x80, 0x80  // F
			   ];

		this.romPath = romPath;

		trace("Chip8 Init");
	}

	public function loadFontIntoMem() 
	{
		for (i in 0 ... font.length) 
		{
			memory[i] = font[i];

			//trace(memory[i]);
		}
	}

	public function loadRomIntoMem()
	{
		var romData:Bytes = sys.io.File.getBytes(romPath);

		for (i in 0 ... romData.length) 
		{
			memory[0x200 + i] = romData.get(i);

			//trace(memory[0x200 + i]);
		}
	}

	public function updateTimers() 
	{
		if (dt > 0) 
		{
			dt -= 1;
		}

		if (st > 0) 
		{
			st -= 1;
		}
	}

	public function debug() 
	{
		//check memory content (it's in int, hopfully that's fine)
		for (i in 0 ... memory.length) 
		{
			//trace("MemAddress: 0x" + StringTools.hex(i, 4) + ", Byte: 0x" + StringTools.hex(memory[i], 2));
			Sys.println("MemAddress: 0x" + StringTools.hex(i, 4) + ", Byte: 0x" + StringTools.hex(memory[i], 2));
		}
	}

	public function emuCycle() 
	{
		opcode = memory[pc] << 8 | memory[pc + 1];

		var x:Int = (opcode & 0x0F00) >> 8;
		var y:Int = (opcode & 0x00F0) >> 4;
		var n:Int = opcode & 0x000F;
		var nn:Int = opcode & 0x00FF;
		var nnn:Int = opcode & 0x0FFF;

		//Debug outputs
		/*
		Sys.println("Opcode: 0x" + StringTools.hex(opcode, 4));
		Sys.println("x: 0x" + StringTools.hex(x, 4));
		Sys.println("y: 0x" + StringTools.hex(y, 4));
		Sys.println("n: 0x" + StringTools.hex(n, 4));
		Sys.println("nn: 0x" + StringTools.hex(nn, 4));
		Sys.println("nnn: 0x" + StringTools.hex(nnn, 4));
		*/

		//How to read debug out (general)
		//NOTE: clicking on the console or off of the main window will pause emualtion, making it possible to scroll through the debug statements
		//opcode: 0xAAAA, Description...V[x] (x value)(V[x] value) at other nibble/value (0xZZZZ)

		switch(opcode & 0xF000) 
		{
			case 0x0000:
				if (opcode == 0x00E0) 
				{
					Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Clear Display");

					for (i in 0 ... (64*32)) 
					{
						frameBuffer[i] = 0;
					}

					pc += 2;
				}
				else if (opcode == 0x00EE) 
				{
					Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Pops stack, returns from subroutine");

					//sp -= 1;
					//pc = stack[sp];
					pc = stack.pop();

					pc += 2;
				}
			case 0x1000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Jump to address NNN (0x" + StringTools.hex(nnn, 4) + ")");

				pc = nnn;

				//pc += 2;
			case 0x2000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Call the subroutine at NNN (0x" + StringTools.hex(nnn, 4) + ")");

				//stack[sp] = pc;
				//sp += 1;
				//pc = nnn;
				stack.push(pc);
				pc = nnn;

				//pc += 2;
			case 0x3000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skips if V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") is equal to NN (0x" + StringTools.hex(nn, 4) + ")");

				if (registers[x] == nn) 
				{
					pc += 2;
				}

				pc += 2;
			case 0x4000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skips if V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") is NOT equal to NN (0x" + StringTools.hex(nn, 4) + ")");

				if (registers[x] != nn) 
				{
					pc += 2;
				}

				pc += 2;
			case 0x5000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skips if V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") is equal to V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ")");

				if (registers[x] == registers[y]) 
				{
					pc += 2;
				}

				pc += 2;
			case 0x6000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Load NNN (0x" + StringTools.hex(nnn, 4) + ") to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

				registers[x] = nn;

				pc +=2;
			case 0x7000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Add NN (0x" + StringTools.hex(nn, 4) + ") to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

				registers[x] = registers[x] + nn;

				if (registers[x] > 255) 
				{
					registers[x] = registers[x] & 0xFF;
				}

				pc += 2;
			case 0x8000:
				switch (opcode & 0x000F) 
				{
					case 0x0000:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Sets V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") to V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ")");

						registers[x] = registers[y];

						pc += 2;
					case 0x0001:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Logical OR V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") to V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ")");

						registers[0xF] = 0;
						registers[x] = registers[x] | registers[y];

						pc += 2;
					case 0x0002:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Logical AND V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") to V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ")");

						registers[0xF] = 0;
						registers[x] = registers[x] & registers[y];

						pc += 2;
					case 0x0003:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Logical XOR V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") to V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[x]) + ")");

						registers[0xF] = 0;
						registers[x] = registers[x] ^ registers[y];

						pc += 2;
					case 0x0004:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Add V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") and V[y] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[y]) + "), carry bit in V[F] (" + StringTools.hex(registers[0xF]) + ")");

						if ((registers[x] + registers[y]) > 0xFF) 
						{
							registers[0xF] = 1;
						}
						else 
						{
							registers[0xF] = 0;
						}

						registers[x] = (registers[x] + registers[y]) & 0xFF;

						pc += 2;
					case 0x0005:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Subtract V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ") from V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + "), carry bit in V[F] (" + StringTools.hex(registers[0xF]) + ")");

						if (registers[x] > registers[y]) 
						{
							registers[0xF] = 1;
						}
						else 
						{
							registers[0xF] = 0;
						}

						registers[x] = (registers[x] - registers[y]) & 0xFF;

						pc += 2;
					case 0x0006:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Shift right V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") by 1, put LSB in V[F] (" + StringTools.hex(registers[0xF]) + ")");

						registers[0xF] = registers[x] & 0x1;
						registers[x] = registers[x] >> 1;

						pc += 2;
					case 0x0007:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Subtract V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") from V[y] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[y]) + "), borrow flag stored in V[F] (" + StringTools.hex(registers[0xF]) + ")");

						if (registers[x] > registers[y]) 
						{
							registers[0xF] = 1;
						}
						else 
						{
							registers[0xF] = 0;
						}

						registers[x] = (registers[y] - registers[x]) & 0xFF;

						pc += 2;
					case 0x000E:
						Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Shift left V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") by 1, put LSB in V[F] (" + StringTools.hex(registers[0xF]) + ")");

						registers[0xF] = registers[x] & 0x80;
						registers[x] = (registers[x] << 1) & 0xFF;

						pc += 2;
				}
			case 0x9000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skips if V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") and V[y] (" + StringTools.hex(y) + ")(" + StringTools.hex(registers[y]) + ") NOT equal");

				if(registers[x] != registers[y]) 
				{
					pc += 2;
				}

				pc += 2;
			case 0xA000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Set Index (0x" + StringTools.hex(index, 4) + ") to NNN (0x" + StringTools.hex(nnn, 4) + ")");

				index = nnn;

				pc += 2;
			case 0xB000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Jump to NNN (0x" + StringTools.hex(nnn, 4) + ") plus V[0] (" + StringTools.hex(registers[0]) + ")");

				pc = registers[0] + nnn;
			case 0xC000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Random 8Bits logical AND with NN (0x" + StringTools.hex(nn, 4) + "), store in V[x] (" + StringTools.hex(x) + ")");

				var rand = Math.floor(Math.random() * 256); //0 to 255
				registers[x] = rand & nn;

				pc += 2;
			case 0xD000:
				Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Display! x: 0x" + StringTools.hex(x) + " y: 0x" + StringTools.hex(y) + " N: 0x" + StringTools.hex(n));

				var xCoor:Int = registers[x] & 63;
                var yCoor:Int = registers[y] & 31;

                registers[0xF] = 0;

                //for each row...
                for (row in 0 ... n) 
                {
                    var nthByte:Int = memory[row + index]; //sprite data, "nth byte", row

                    //for pixel, "bit", in row...
                    for (bit in 0 ... 8) 
                    {
                        var currX:Int = (xCoor + bit) % 64;
                        var currY:Int = (yCoor + row) % 32;

                        var spritePixel:Bool = (nthByte & (0x80 >> bit)) != 0; //to see if pixel should be "on"
                        var screenPixel:Bool = frameBuffer[currY * 64 + currX] == 1; //checks if that pixel is already "on" screen

                        if (spritePixel && screenPixel) 
                        {
                            registers[0xF] = 1; //collision check
                            frameBuffer[currY * 64 + currX] ^= 1; //XOR on screen
                        }
                        else if (spritePixel && screenPixel == false) 
                        {
                            frameBuffer[currY * 64 + currX] ^= 1; //XOR on screen
                        }
                    }
                }

                pc += 2;
            case 0xE000:
            	switch (opcode & 0x00FF) 
            	{
            		case 0x009E:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skip if Keys[V[x]] (" + StringTools.hex(registers[x]) + ") is pressed");

            			if (keys[registers[x]] == 1) 
            			{
            				pc += 2;
            			}

            			pc += 2;
            		case 0x00A1:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Skips if Keys[V[x]] (" + StringTools.hex(registers[x]) + ") is NOT pressed");

            			if (keys[registers[x]] == 0) 
            			{
            				pc += 2;
            			}

            			pc += 2;
            	}
            case 0xF000:
            	switch(opcode & 0x00FF) 
            	{
            		case 0x0007:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Set V[x] (" + StringTools.hex(x) + ") to delay timer");

            			registers[x] = dt;

            			pc += 2;
            		case 0x000A:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Wait for key press, store in V[x] (" + StringTools.hex(x) + ")");
            			var keyPressed:Bool = false;

            			for (i in 0 ... 16) 
            			{
            				if (keys[i] == 1) 
            				{
            					registers[x] = i;
            					keyPressed = true;
            				}
            				else if(keyPressed == false) 
            				{
            					pc -= 2;
            				}
            			}
            		case 0x0015:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Delay timer set to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

            			dt = registers[x];

            			pc += 2;
            		case 0x0018:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Sound timer set to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

            			st = registers[x];

            			pc += 2;
            		case 0x001E:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Add and set index to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

            			index = index + registers[x];

            			if (index > 0xFFF) 
            			{
            				index = index & 0xFFF;
            			}

            			pc += 2;
            		case 0x0029:
            			Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Set index to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") sprite font location");

            			index = (registers[x] * 0x05) & 0xFFF;

            			pc += 2;
					case 0x0033:
					    Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Stores values of V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") in memory index");
					    
					    var value:Int = registers[x];

					    memory[index] = Std.int(value / 100);
					    memory[index + 1] = Std.int((value / 10) % 10);
					    memory[index + 2] = value % 10;

					    pc += 2;
					case 0x0055:
					    Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Stores V[0] (" + StringTools.hex(registers[0]) + ") to V[X] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ") in memory");

					    for (i in 0 ... x + 1) 
					    {
					        memory[(index + i) & 0xFFF] = registers[i];
					    }

					    pc += 2;
					case 0x0065:
					    Sys.println("opcode: 0x" + StringTools.hex(opcode, 4) + ", Load memory data to V[0] (" + StringTools.hex(registers[0]) + ") to V[x] (" + StringTools.hex(x) + ")(" + StringTools.hex(registers[x]) + ")");

					    for (i in 0 ... x + 1) 
					    {
					        registers[i] = memory[index + i] & 0xFFF;
					    }

					    pc += 2;
            	}
            default:
            	trace("Unknown opcode: 0x" + StringTools.hex(opcode, 4));

            	pc += 2;
		}

		updateTimers();
	}
}