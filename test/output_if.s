0x0000: push #4 (1)
0x0002: pop sp%0 (b)
0x0004: push #0 (1)
0x0006: push #2 (2)
0x0008: push [sp%0 (b)] (3)
0x000A: pop r1
0x000C: pop r0
0x000E: add r0, r0, r1
0x0012: push r0
0x0018: pop r1
0x001A: pop r0
0x001C: add r0, r0, r1
0x0020: push r0
0x0026: pop sp%1 (a)
0x0028: push [sp%0 (b)] (2)
0x002A: push [sp%1 (a)] (3)
0x002C: pop r1
0x002E: pop r0
0x0030: sub r0 r0 r1
0x0034: push r0
0x0036: pop r0
0x0038: cmp r0, #0
0x003B: bne 0x006F
0x003E: push #2 (3)
0x0040: pop sp%3 (a)
0x0042: push [sp%3 (a)] (4)
0x0044: push #2 (5)
0x0046: pop r1
0x0048: pop r0
0x004A: sub r0 r0 r1
0x004E: push r0
0x0050: push #2 (5)
0x0052: pop r1
0x0054: pop r0
0x0056: add r0 r0 r1
0x005A: push r0
0x005C: pop r0
0x005E: cmp r0, #0
0x0061: beq 0x0068
0x0064: push #3 (6)
0x0066: pop sp%6 (d)

0x0068: push #8 (6)
0x006A: pop sp%0 (b)
0x006C: b 0x0073

0x006F: push #3 (3)
0x0071: pop sp%1 (a)

0x0073: push #5 (3)
0x0075: pop sp%3 (e)
0x0077: push [sp%1 (a)] (4)
0x0079: pop {pc}
