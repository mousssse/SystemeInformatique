.main:
0x0000: push lr
0x0003: sub sp sp #1
0x0007: push #0 (2)
0x000A: push #2 (3)
0x000D: ldr r0 bp%1 (b)
0x0010: push r0
0x0013: pop r1
0x0015: pop r0
0x0017: add r0 r0 r1
0x001B: push r0
0x001E: pop r1
0x0020: pop r0
0x0022: add r0 r0 r1
0x0026: push r0
0x0029: pop r0
0x002B: sub sp sp #1
0x002F: str r0 bp%2 (a)

0x0032: ldr r0 bp%2 (a)
0x0035: push r0
0x0038: ldr r0 bp%1 (b)
0x003B: push r0
0x003E: pop r1
0x0040: pop r0
0x0042: sub r0 r0 r1
0x0046: push r0
0x0049: pop r0
0x004B: cmp r0 #0
0x004E: beq 0x009E

0x0051: push #0 (4)
0x0054: pop r0
0x0056: str r0 bp%2 (a)

0x0059: push #1 (4)
0x005C: pop r0
0x005E: cmp r0 #0
0x0061: beq 0x006F

0x0064: push #2 (5)
0x0067: pop r0
0x0069: str r0 bp%1 (b)
0x006C: b 0x59

0x006F: ldr r0 bp%2 (a)
0x0072: push r0
0x0075: push #5 (6)
0x0078: pop r1
0x007A: pop r0
0x007C: sub r0 r0 r1
0x0080: push r0
0x0083: pop r0
0x0085: cmp r0 #0
0x0088: ble 0x009B
0x008B: push #7 (6)
0x008E: pop r0
0x0090: sub sp sp #1
0x0094: str r0 bp%6 (d)
0x0097: add sp sp #1

0x009B: b 0x32

0x009E: ldr r0 bp%2 (a)
0x00A1: push r0
0x00A4: pop r0
0x00A6: add sp sp #2
0x00AA: pop pc

