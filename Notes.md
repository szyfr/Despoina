

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


## Instruction Set
  
| Encoding | Mnemonic | cycles | Description |
|--|--|--|--|
| 00 | nop | 1 | Nothing |
| 10 | ld a,b | 1 | a = b |
| 11 | ld a,c | 1 | a = c |
| 20 | ld a,[xy] | 2 | a = [xy] |
| 21 | ld [xy],a | 2 | [xy] = a |
| 22 | ld nnnn,a | 4 | [nnnn] = a |
| 23 nn | ld a,nn | 2 | a = nn |
| 24 nn nn | ld xy,nnnn | 3 | xy = nnnn |
| 34 | inc xy | 2 | xy += 1 |
| 40 nn nn | jp nnnn | 4 | Jump to nnnn, pc = nnnn |