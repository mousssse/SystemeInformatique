.main:
0x00: store sp lr
0x04: afc r0 #2 (1)
0x08: store sp r0
0x0C: load r0 sp
0x10: sub sp sp #1
0x14: store bp%1 r0 (a)
0x18: afc r0 #10 (2)
0x1C: store sp r0
0x20: load r0 sp
0x24: sub sp sp #1
0x28: store bp%2 r0 (b)
0x2C: load r0 bp%1 (a)
0x30: store sp r0
0x34: load r0 sp
0x38: sub sp sp #1
0x3C: store bp%3 r0 (d)
0x40: load r0 bp%2 (b)
0x44: store sp r0
0x48: load r0 bp%3 (d)
0x4C: store sp r0
0x50: load r1 sp
0x54: load r0 sp
0x58: mul r0 r0 r1
0x5C: store sp r0
0x60: load r0 sp
0x64: store bp%1 r0 (a)
0x68: afc r0 #0 (4)
0x6C: store sp r0
0x70: load r0 sp
0x74: sub sp sp #1
0x78: store bp%4 r0 (e)
0x7C: load r0 bp%2 (b)
0x80: store sp r0
0x84: load r0 bp%3 (d)
0x88: store sp r0
0x8C: load r1 sp
0x90: load r0 sp
0x94: sub r0 r0 r1
0x98: afc r1 #0
0x9C: bne 0xA4
0xA0: afc r1 #1
0xA4: store sp r1
0xA8: load r0 sp
0xAC: add r0 #0 r0
0xB0: beq 0xC4
0xB4: afc r0 #1 (6)
0xB8: store sp r0
0xBC: load r0 sp
0xC0: store bp%4 r0 (e)

0xC4: load r0 bp%4 (e)
0xC8: store sp r0
0xCC: load r0 sp
0xD0: add sp #4 sp
0xD4: load pc sp

