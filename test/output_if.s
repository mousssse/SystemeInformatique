.main:
0x0000: push lr
0x0003: sub sp sp #1
0x0007: push #4 (2)
0x000A: pop r0
0x000C: str r0 bp%1 (b)
0x000F: push #0 (2)
0x0012: push #2 (3)
0x0015: ldr r0 bp%1 (b)
0x0018: push r0
0x001B: pop r1
0x001D: pop r0
0x001F: add r0 r0 r1
0x0023: push r0
0x0026: pop r1
0x0028: pop r0
0x002A: add r0 r0 r1
0x002E: push r0
0x0031: pop r0
0x0033: sub sp sp #1
0x0037: str r0 bp%2 (a)
0x003A: ldr r0 bp%1 (b)
0x003D: push r0
0x0040: ldr r0 bp%2 (a)
0x0043: push r0
0x0046: pop r1
0x0048: pop r0
0x004A: sub r0 r0 r1
0x004E: push r0
0x0051: pop r0
0x0053: cmp r0 #0
0x0056: bne 0x00AE
0x0059: push #2 (4)
0x005C: pop r0
0x005E: sub sp sp #1
0x0062: str r0 bp%4 (a)
0x0065: ldr r0 bp%4 (a)
0x0068: push r0
0x006B: push #2 (6)
0x006E: pop r1
0x0070: pop r0
0x0072: sub r0 r0 r1
0x0076: push r0
0x0079: push #2 (6)
0x007C: pop r1
0x007E: pop r0
0x0080: add r0 r0 r1
0x0084: push r0
0x0087: pop r0
0x0089: cmp r0 #0
0x008C: beq 0x009F
0x008F: push #3 (7)
0x0092: pop r0
0x0094: sub sp sp #1
0x0098: str r0 bp%7 (d)
0x009B: add sp sp #1

0x009F: push #8 (7)
0x00A2: pop r0
0x00A4: str r0 bp%1 (b)
0x00A7: add sp sp #1
0x00AB: b 0x00B6

0x00AE: push #3 (4)
0x00B1: pop r0
0x00B3: str r0 bp%2 (a)

0x00B6: push #5 (4)
0x00B9: pop r0
0x00BB: sub sp sp #1
0x00BF: str r0 bp%4 (e)
0x00C2: ldr r0 bp%2 (a)
0x00C5: push r0
0x00C8: pop r0
0x00CA: add sp sp #3
0x00CE: pop pc

.res:
0x00D0: push lr
0x00D3: push #0 (2)
0x00D6: pop r0
0x00D8: sub sp sp #1
0x00DC: str r0 bp%2 (a)
0x00DF: sub bp bp #3
0x00E3: mov lr 0x00EA
0x00E7: b 0x0000
0x00EA: add bp bp #3
0x00EE: push #1 (3)
0x00F1: pop r1
0x00F3: pop r0
0x00F5: add r0 r0 r1
0x00F9: push r0
0x00FC: pop r0
0x00FE: sub sp sp #1
0x0102: str r0 bp%2 (b)
0x0105: push #2 (3)
0x0108: pop r0
0x010A: sub sp sp #1
0x010E: str r0 bp%3 (c)
0x0111: add sp sp #2
0x0115: pop pc

