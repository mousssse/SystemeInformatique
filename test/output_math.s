.main:
0x0000: push lr
0x0003: push #0 (1)
0x0006: pop r0
0x0008: sub sp sp #1
0x000C: str r0 bp%1 (a)
0x000F: sub sp sp #1
0x0013: sub sp sp #1
0x0017: push #1 (4)
0x001A: push #2 (5)
0x001D: push #3 (6)
0x0020: pop r1
0x0022: pop r0
0x0024: add r0 r0 r1
0x0028: push r0
0x002B: push #4 (6)
0x002E: pop r1
0x0030: pop r0
0x0032: div r0 r0 r1
0x0036: push r0
0x0039: pop r1
0x003B: pop r0
0x003D: mul r0 r0 r1
0x0041: push r0
0x0044: push #5 (5)
0x0047: push #6 (6)
0x004A: pop r1
0x004C: pop r0
0x004E: mul r0 r0 r1
0x0052: push r0
0x0055: push #7 (6)
0x0058: pop r1
0x005A: pop r0
0x005C: add r0 r0 r1
0x0060: push r0
0x0063: pop r1
0x0065: pop r0
0x0067: sub r0 r0 r1
0x006B: push r0
0x006E: pop r0
0x0070: str r0 bp%2 (b)
0x0073: push #0 (4)
0x0076: pop r0
0x0078: add sp sp #3
0x007C: pop pc

