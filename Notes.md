

## Memory Map


| Start | End | Description |
|--|--|--|
| $0000 | $3FFF | ROM Bank 0 |
| $4000 | $7FFF | Switching ROM Bank |
| $8000 | $9FFF | Switching SRAM Bank |
| $A000 | $BFFF | Switching RAM Bank |
| $C000 | $DFFF | Switching VRAM Bank |
| $E000 | $FDFF | ??? |
| $FE00 | $FEFF | I/O |
| $FF00 | $FFFF | HRAM |

## I/O

| Address | Name | Description | R/W |
|--|--|--|--|
| $FE00 | LROMB | Lower byte of ROM Bank | R/W |
| $FE01 | HROMB | Higher byte of ROM Bank | R/W |
| $FE02 | LSRAMB | Lower byte of Save RAM Bank | R/W |
| $FE03 | HSRAMB | Higher byte of Save RAM Bank | R/W |
| $FE04 | RAMB | Work RAM Bank | R/W |
| $FE05 | VRAMB | Video RAM Bank | R/W |
|  |  |  |  |


## Instruction Set
  
| Encoding | Mnemonic | cycles | Description |
|--|--|--|--|
| 00 | nop | 1 | Nothing |
| 10 | ld a,b | 1 | a = b |
| 11 | ld a,c | 1 | a = c |
| 20 | ld a,[xy] | 2 | a = [xy] |
| 21 | ld [xy],a | 2 | [xy] = a |
| 22 nn | ld a,nn | 2 | a = nn |
| 23 | ld nnnn,a | 4 | [nnnn] = a |
| 24 nn nn | ld xy,nnnn | 3 | xy = nnnn |
| 40 nn nn | jp nnnn | 4 | Jump to nnnn, pc = nnnn |