package engine


//= Imports
import "core:fmt"

import "../debug"


//= Constants
DEBUG :: false


//= Structures / Enums
CPU :: struct {
	pc, sp	: u16,

	a		: u8,
	bc, xy	: u16,

	tempReg : u16,

	curCyc	: u8,
	curOp	: Instruction,
}
Instruction :: enum u8 {
	nop			= 0x00,

	ld_a_b		= 0x10,
	ld_a_c		= 0x11,

	ld_a_xy		= 0x20,
	ld_xy_a		= 0x21,
	ld_a_imm	= 0x22,
	ld_a_ptr	= 0x23,
	ld_ptr_a	= 0x24,
	ld_xy_imm	= 0x25,

	inc_xy		= 0x34,

	jp			= 0x40,
}


//= Procedures
cycle :: proc() {
	//* Check if current op is done
	//* +Run op
	//* -Grab next op
	if DEBUG do fmt.printf("%X: %v\n",cpu.pc,cpu.curCyc)

	#partial switch cpu.curOp {
		case .nop:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: nop\n",cpu.pc)
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .jp:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 4:
					if DEBUG do fmt.printf("%X: jp %2X\n",cpu.pc,cpu.tempReg)
					cpu.pc = cpu.tempReg
					cpu.curCyc = 0
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_a_b:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: ld a,b\n",cpu.pc)
				cpu.a = u8(cpu.bc >> 8)
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_a_c:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: ld a,c\n",cpu.pc)
				cpu.a = u8(cpu.bc)
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_a_xy:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: ld a,[xy]\n",cpu.pc)
				cpu.a = memoryMap[cpu.xy]
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_xy_a:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: ld [xy],a (%4X<-%2X)\n",cpu.pc,cpu.xy,cpu.a)
				save_mem( cpu.a, cpu.xy )
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_a_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+1])
				case 2:
					if DEBUG do fmt.printf("%X: ld a,%2X\n",cpu.pc,memoryMap[cpu.pc+1])
					cpu.a = u8(cpu.tempReg)
					cpu.curCyc = 0
					cpu.pc += 2
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_a_ptr:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 4:
					if DEBUG do fmt.printf("%X: ld a,[%4X] (%2X)\n",cpu.pc,cpu.tempReg,memoryMap[cpu.tempReg])
					cpu.a = memoryMap[cpu.tempReg]
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_ptr_a:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 4:
					if DEBUG do fmt.printf("%X: ld [%4X],a\n",cpu.pc,cpu.tempReg)
					save_mem( cpu.a, cpu.tempReg )
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_xy_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if DEBUG do fmt.printf("%X: ld xy,%4X\n",cpu.pc,cpu.tempReg)
					cpu.xy = cpu.tempReg
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .inc_xy:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: inc xy (%4X)\n",cpu.pc,cpu.xy+1)
				cpu.xy += 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
	}
	cpu.curCyc += 1
}

read_next :: proc() {
	cpu.curCyc = 0
	cpu.pc += 1
	cpu.curOp = Instruction(memoryMap[cpu.pc])
}

save_mem :: proc( value : u8, location : u16 ) {
	memoryMap[location] = value

	//* Copy data to SRAM array
	if location >= 0x8000 && location < 0x9FFF {
		sram[(location - 0x8000) + (u16(memoryMap[0xFE03]) * 0x200)] = value
	}
	//* Copy data to WRAM array
	if location >= 0xA000 && location < 0xBFFF {
		wram[(location - 0xA000) + (u16(memoryMap[0xFE04]) * 0x200)] = value
	}
	//* copy data to VRAM array
	if location >= 0xC000 && location < 0xDFFF {
		vram[(location - 0xC000) + (u16(memoryMap[0xFE05]) * 0x200)] = value
	}

	//* Swapping ROM bank
	if location == 0xFE00 || location == 0xFE01 || location == 0xFE02 {
		bank : u32 = (u32(memoryMap[0xFE02]) << 16) + (u32(memoryMap[0xFE01]) << 8) + u32(memoryMap[0xFE00])
		if (u32(len(rom)) / 0x4000)-1 < bank do debug.logf("[ERROR] - Attempted to access Bank %v and it doesn't exist.",bank)
		for i in 0..<0x4000 {
			memoryMap[i+0x4000] = rom[u32(i) + (bank * 0x4000)]
		}
	}
	//* Swapping SRAM array
	if location == 0xFE03 {
		for i in 0..<0x2000 {
			memoryMap[i+0x8000] = sram[u32(i) + (u32(memoryMap[0xFE03]) * 0x2000)]
		}
	}
	//* Swapping WRAM array
	if location == 0xFE04 {
		for i in 0..<0x2000 {
			memoryMap[i+0xA000] = sram[u32(i) + (u32(memoryMap[0xFE04]) * 0x2000)]
		}
	}
	//* Swapping VRAM array
	if location == 0xFE05 {
		for i in 0..<0x2000 {
			memoryMap[i+0xC000] = sram[u32(i) + (u32(memoryMap[0xFE05]) * 0x2000)]
		}
	}
}