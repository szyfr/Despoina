package engine


//= Imports
import "core:fmt"

import "../debug"


//= Constants
DEBUG :: false


//= Structures / Enums
CPU :: struct {
	pc, sp	: u16,

	a, f	: u8,
	bc, xy	: u16,

	halt	: bool,

	tempReg : u16,

	curCyc	: u8,
	curOp	: Instruction,
}
Instruction :: enum u8 {
	nop			= 0x00,
	halt		= 0x01,

	ld_a_b		= 0x10,
	ld_b_a		= 0x20,
	ld_a_c		= 0x11,
	ld_c_a		= 0x21,
	ld_a_bc		= 0x12,
	ld_bc_a		= 0x22,
	ld_a_xy		= 0x13,
	ld_xy_a		= 0x23,
	ld_a_imm	= 0x14,
	ld_a_ptr	= 0x15,
	ld_ptr_a	= 0x25,
	ld_bc_imm	= 0x16,
	ld_xy_imm	= 0x26,

	inc_a		= 0x30,
	dec_a		= 0x40,
	inc_bc		= 0x31,
	dec_bc		= 0x41,
	inc_xy		= 0x32,
	dec_xy		= 0x42,
	inc_xy_ptr	= 0x33,
	dec_xy_ptr	= 0x43,

	push_af		= 0x34,
	pop_af		= 0x44,
	push_bc		= 0x35,
	pop_bc		= 0x45,
	push_xy		= 0x36,
	pop_xy		= 0x46,

	jp			= 0x50,
	jp_xy		= 0x60,
	jp_nz		= 0x51,
	jp_z		= 0x61,
	jp_nc		= 0x51,
	jp_c		= 0x61,

	cmp_a_b		= 0x53,
	cmp_a_c		= 0x63,
	cmp_a_imm	= 0x54,
	cmp_a_ptr	= 0x64,
	cmp_a_bc	= 0x55,
	cmp_a_xy	= 0x65,
	cmp_bc_xy	= 0x56,
	cmp_xy_bc	= 0x66,
	cmp_bc_imm	= 0x57,
	cmp_xy_imm	= 0x67,

	add_a_b		= 0x70,
	add_b_a		= 0x80,
	add_a_c		= 0x71,
	add_c_a		= 0x81,
	add_a_imm	= 0x72,
	add_ptr_a	= 0x82,
	add_a_bc	= 0x73,
	add_a_xy	= 0x83,
	add_bc_imm	= 0x74,
	add_xy_imm	= 0x84,
	add_bc_xy	= 0x75,
	add_xy_bc	= 0x85,
	
}


//= Procedures
cycle :: proc() {
	//* Check if current op is done
	//* +Run op
	//* -Grab next op
	//if DEBUG do fmt.printf("%X: %v\n",cpu.pc,cpu.curCyc)
	if cpu.halt == true do return

	#partial switch cpu.curOp {
		case .nop:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: nop\n",cpu.pc)
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .halt:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: halt\n",cpu.pc)
				cpu.curCyc = 0
				cpu.halt = true
				cpu.pc += 1
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
		case .ld_a_bc:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: ld a,[bc] (%4X:%2X)\n",cpu.pc,cpu.bc,memoryMap[cpu.bc])
				cpu.a = memoryMap[cpu.bc]
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_bc_a:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: ld [bc],a (%4X<-%2X)\n",cpu.pc,cpu.bc,cpu.a)
				save_mem( cpu.a, cpu.bc )
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
					if DEBUG do fmt.printf("%X: ld [%4X],a (%2X)\n",cpu.pc,cpu.tempReg,cpu.a)
					save_mem( cpu.a, cpu.tempReg )
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .ld_bc_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if DEBUG do fmt.printf("%X: ld bc,%4X\n",cpu.pc,cpu.tempReg)
					cpu.bc = cpu.tempReg
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
		case .inc_a:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: inc a (%2X)\n",cpu.pc,cpu.a+1)
				if cpu.a == 0xFF do cpu.f = 0b01000000
				cpu.a += 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .dec_a:
			if cpu.curCyc == 1 {
				if DEBUG do fmt.printf("%X: dec a (%2X)\n",cpu.pc,cpu.a-1)
				if cpu.a == 0x01 do cpu.f = 0b10000000
				cpu.a -= 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .inc_bc:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: inc bc (%4X)\n",cpu.pc,cpu.bc+1)
				if cpu.bc == 0xFFFF do cpu.f = 0b01000000
				cpu.bc += 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .dec_bc:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: dec bc (%4X)\n",cpu.pc,cpu.bc-1)
				if cpu.bc == 0x01 do cpu.f = 0b10000000
				cpu.bc -= 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .inc_xy:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: inc xy (%4X)\n",cpu.pc,cpu.xy+1)
				if cpu.xy == 0xFFFF do cpu.f = 0b01000000
				cpu.xy += 1
				cpu.curCyc = 0
				cpu.pc += 1
				cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .dec_xy:
			if cpu.curCyc == 2 {
				if DEBUG do fmt.printf("%X: dec xy (%4X)\n",cpu.pc,cpu.xy-1)
				if cpu.xy == 0x01 do cpu.f = 0b10000000
				cpu.xy -= 1
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
					if DEBUG do fmt.printf("%X: jp %4X\n",cpu.pc,cpu.tempReg)
					cpu.pc = cpu.tempReg
					cpu.curCyc = 0
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .jp_nz:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if (cpu.f & 0b10000000) != 0 {
						if DEBUG do fmt.printf("%X: jp nz,%4X (No Jump) %8b\n",cpu.pc,cpu.tempReg,cpu.f & 0b00000000)
						cpu.pc += 3
						cpu.curCyc = 0
						cpu.curOp = Instruction(memoryMap[cpu.pc])
					}
				case 4:
					if DEBUG do fmt.printf("%X: jp nz,%4X (Jump)\n",cpu.pc,cpu.tempReg)
					cpu.pc = cpu.tempReg
					cpu.curCyc = 0
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .jp_z:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if (cpu.f & 0b10000000) != 0 {
						if DEBUG do fmt.printf("%X: jp z,%4X (No Jump)\n",cpu.pc,cpu.tempReg)
						cpu.pc += 3
						cpu.curCyc = 0
						cpu.curOp = Instruction(memoryMap[cpu.pc])
					}
				case 4:
					if DEBUG do fmt.printf("%X: jp z,%4X (Jump)\n",cpu.pc,cpu.tempReg)
					cpu.pc = cpu.tempReg
					cpu.curCyc = 0
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .cmp_bc_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if DEBUG do fmt.printf("%X: cmp bc,%4X (z:%t c:%t)\n",cpu.pc,cpu.tempReg,cpu.bc == cpu.tempReg,cpu.bc < cpu.tempReg)
					cpu.f = 0
					if cpu.bc == cpu.tempReg do cpu.f = cpu.f | 0b10000000
					if cpu.bc <  cpu.tempReg do cpu.f = cpu.f | 0b01000000
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .cmp_xy_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if DEBUG do fmt.printf("%X: cmp xy,%4X (z:%t c:%t)\n",cpu.pc,cpu.tempReg,cpu.xy == cpu.tempReg,cpu.xy < cpu.tempReg)
					cpu.f = 0
					if cpu.xy == cpu.tempReg do cpu.f = cpu.f | 0b10000000
					if cpu.xy <  cpu.tempReg do cpu.f = cpu.f | 0b01000000
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .push_af:
			switch cpu.curCyc {
				case 1:
					save_mem( cpu.a, cpu.sp )
				case 2:
					save_mem( cpu.f, cpu.sp-1 )
				case 3:
					cpu.sp -= 2
				case 4:
					if DEBUG do fmt.printf("%X: push af (%4X:%2X%2X)\n",cpu.pc,cpu.sp+2,cpu.a,cpu.f)
					cpu.curCyc = 0
					cpu.pc += 1
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .pop_af:
			switch cpu.curCyc {
				case 1:
					cpu.f = memoryMap[cpu.sp+1]
				case 2:
					cpu.a = memoryMap[cpu.sp+2]
				case 3:
					if DEBUG do fmt.printf("%X: pop af (A:%2X F:%2X)\n",cpu.pc,cpu.a,cpu.f)
					cpu.sp += 2
					cpu.curCyc = 0
					cpu.pc += 1
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case .add_xy_imm:
			switch cpu.curCyc {
				case 1:
					cpu.tempReg = u16(memoryMap[cpu.pc+2]) << 8
				case 2:
					cpu.tempReg += u16(memoryMap[cpu.pc+1])
				case 3:
					if DEBUG do fmt.printf("%X: add xy,%4X (%4X)\n",cpu.pc,cpu.tempReg,cpu.xy+cpu.tempReg)
					if u32(cpu.xy)+u32(cpu.tempReg) > 0xFFFF do cpu.f = cpu.f | 0b01000000
					cpu.xy += cpu.tempReg
					cpu.curCyc = 0
					cpu.pc += 3
					cpu.curOp = Instruction(memoryMap[cpu.pc])
			}
		case:
			if DEBUG do fmt.printf("%X: Failed to find Opcode\n",cpu.pc)
			cpu.curCyc = 0
			cpu.pc += 1
			cpu.curOp = Instruction(memoryMap[cpu.pc])
			play = false
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
	if location >= 0x8000 && location <= 0x9FFF {
		sram[(location - 0x8000) + (u16(memoryMap[0xFE03]) * 0x2000)] = value
	}
	//* Copy data to WRAM array
	if location >= 0xA000 && location <= 0xBFFF {
		wram[(location - 0xA000) + (u16(memoryMap[0xFE04]) * 0x2000)] = value
	}
	//* copy data to VRAM array
	if location >= 0xC000 && location <= 0xDFFF {
		vram[(location - 0xC000) + (u16(memoryMap[0xFE05]) * 0x2000)] = value
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
			memoryMap[i+0xA000] = wram[u32(i) + (u32(memoryMap[0xFE04]) * 0x2000)]
		}
	}
	//* Swapping VRAM array
	if location == 0xFE05 {
		for i in 0..<0x2000 {
			memoryMap[i+0xC000] = vram[u32(i) + (u32(memoryMap[0xFE05]) * 0x2000)]
		}
	}
}