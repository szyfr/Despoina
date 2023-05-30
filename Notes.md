

## Memory Map


| Start | End | Description |
|--|--|--|
| 0x0000 | 0x3FFF | ROM Bank 0 |
| 0x4000 | 0x7FFF | Switching ROM Bank |
| 0x8000 | 0x9FFF | Switching SRAM Bank |
| 0xA000 | 0xBFFF | Switching RAM Bank |
| 0xC000 | 0xDFFF | Switching VRAM Bank |
| 0xE000 | 0xFDFF | ??? |
| 0xFE00 | 0xFEFF | I/O |
| 0xFF00 | 0xFFFF | HRAM |

## I/O

| Address | Name | Description | R/W |
|--|--|--|--|
| 0xFE00 | LROMB | Lower byte of ROM Bank | R/W |
| 0xFE01 | MROMB | Middle byte of ROM Bank | R/W |
| 0xFE02 | HROMB | Higher byte of ROM Bank | R/W |
| 0xFE03 | SRAMB | Save RAM Bank | R/W |
| 0xFE04 | WRAMB | Work RAM Bank | R/W |
| 0xFE05 | VRAMB | Video RAM Bank | R/W |
|  |  |  |  |


## CPU Registers and Flags

### Registers

| 16-bit | Hi | Lo | Name / Function |
|--|--|--|--|
| AF | A | - | Accumulator & Flags |
| BC | B | C | BC |
| DE | D | E | DE |
| XY | - | - | XY |
| SP | - | - | Stack Pointer |
| PC | - | - | Program Counter |

### Flags

| Bit | Name | Description |
|--|--|--|
| 7 | z | Zero flag |
| 6 | c | Carry flag |

## Instruction Set
  
| Encoding | Mnemonic | Cycles | Description |
|--|--|--|--|
|  |
| 00 | nop | 1 | Nothing |
| 01 | halt | 1 | Stops CPU operation until interrupt |
| 10 | ld a,b | 1 | a = b |
| 20 | ld b,a | 1 | b = a |
| 11 | ld a,c | 1 | a = c |
| 21 | ld c,a | 1 | c = a |
| 12 | ld a,[bc] | 2 | a = [bc] |
| 22 | ld [bc],a | 2 | [bc] = a |
| 13 | ld a,[xy] | 2 | a = [xy] |
| 23 | ld [xy],a | 2 | [xy] = a |
| 14 nn | ld a,nn | 2 | a = nn |
| 15 nn nn | ld [nnnn],a | 4 | [nnnn] = a |
| 25 nn nn | ld a,[nnnn] | 4 | a = [nnnn] |
| 16 nn nn | ld bc,nnnn | 3 | bc = nnnn |
| 26 nn nn | ld xy,nnnn | 3 | xy = nnnn |
| 30 | inc a | 1 | a += 1 |
| 40 | dec a | 1 | a -= 1 |
| 33 | inc xy | 2 | xy += 1 |
| 43 | dec xy | 2 | xy -= 1 |
| 34 | push af | 4 | Puts af onto stack |
| 44 | pop af | 3 | Takes off the stack and puts into af |
| 50 nn nn | jp nnnn | 4 | Jump to nnnn, pc = nnnn |
| 51 nn nn | jp nz,nnnn | 4/3 | Jump to nnnn if zero flag is not set |
| 56 nn nn | cmp bc,nn | 3 | bc - nn and sets flags but preserves bc |
| 66 nn nn | cmp xy,nn | 3 | xy - nn and sets flags but preserves xy |
|  |  |  |  |
| 84 nn nn | add xy,nn | 3 | xy += nn |
|  |  |  |  |
|  |  |  |  |

|  |  |  |  |