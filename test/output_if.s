.main:
0x0000: push lr
0x0004: sub sp sp #1
0x0008: push #4 (2)
0x000C: push #3 (3)
0x0010: push #2 (4)
0x0014: pop r1
0x0018: pop r0
0x001C: sub r0 r0 r1
0x0020: mov r1 #0
0x0024: cmp r0 #0
0x0028: ble 0x0030
0x002C: mov r1 #1
0x0030: push r1
0x0034: pop r1
0x0038: pop r0
0x003C: add r0 r0 r1
0x0040: push r0
0x0044: pop r0
0x0048: str r0 bp%1 (b)
0x004C: push #0 (2)
0x0050: push #2 (3)
0x0054: ldr r0 bp%1 (b)
0x0058: push r0
0x005C: pop r1
0x0060: pop r0
0x0064: add r0 r0 r1
0x0068: push r0
0x006C: pop r1
0x0070: pop r0
0x0074: add r0 r0 r1
0x0078: push r0
0x007C: pop r0
0x0080: sub sp sp #1
0x0084: str r0 bp%2 (a)
0x0088: ldr r0 bp%1 (b)
0x008C: push r0
0x0090: ldr r0 bp%2 (a)
0x0094: push r0
0x0098: pop r1
0x009C: pop r0
0x00A0: sub r0 r0 r1
0x00A4: mov r1 #0
0x00A8: cmp r0 #0
0x00AC: bne 0x00B4
0x00B0: mov r1 #1
0x00B4: push r1
0x00B8: pop r0
0x00BC: sub r0 #1 r0
0x00C0: push r0
0x00C4: pop r0
0x00C8: cmp r0 #0
0x00CC: beq 0x017C
0x00D0: push #2 (4)
0x00D4: pop r0
0x00D8: sub sp sp #1
0x00DC: str r0 bp%4 (a)
0x00E0: ldr r0 bp%4 (a)
0x00E4: push r0
0x00E8: push #2 (6)
0x00EC: pop r1
0x00F0: pop r0
0x00F4: sub r0 r0 r1
0x00F8: mov r1 #0
0x00FC: cmp r0 #0
0x0100: ble 0x0108
0x0104: mov r1 #1
0x0108: push r1
0x010C: push #2 (6)
0x0110: pop r0
0x0114: mov r1 #0
0x0118: cmp r0 #0
0x011C: beq 0x0124
0x0120: mov r1 #1
0x0124: push r1
0x0128: pop r1
0x012C: pop r0
0x0130: add r0 r0 r1
0x0134: mov r1 #0
0x0138: cmp r0 #0
0x013C: beq 0x0144
0x0140: mov r1 #1
0x0144: push r1
0x0148: pop r0
0x014C: cmp r0 #0
0x0150: beq 0x0168
0x0154: push #3 (7)
0x0158: pop r0
0x015C: sub sp sp #1
0x0160: str r0 bp%7 (d)
0x0164: add sp sp #1

0x0168: push #8 (7)
0x016C: pop r0
0x0170: str r0 bp%1 (b)
0x0174: add sp sp #1
0x0178: b 0x0188

0x017C: push #3 (4)
0x0180: pop r0
0x0184: str r0 bp%2 (a)

0x0188: push #5 (4)
0x018C: pop r0
0x0190: sub sp sp #1
0x0194: str r0 bp%4 (e)
0x0198: ldr r0 bp%2 (a)
0x019C: push r0
0x01A0: pop r0
0x01A4: add sp sp #3
0x01A8: pop pc

.res:
0x01AC: push lr
0x01B0: push #0 (2)
0x01B4: pop r0
0x01B8: sub sp sp #1
0x01BC: str r0 bp%2 (a)
0x01C0: sub bp bp #3
0x01C4: mov lr 0x01CC
0x01C8: b 0x0000
0x01CC: add bp bp #3
0x01D0: push #1 (3)
0x01D4: pop r1
0x01D8: pop r0
0x01DC: add r0 r0 r1
0x01E0: push r0
0x01E4: pop r0
0x01E8: sub sp sp #1
0x01EC: str r0 bp%2 (b)
0x01F0: push #2 (3)
0x01F4: pop r0
0x01F8: sub sp sp #1
0x01FC: str r0 bp%3 (c)
0x0200: add sp sp #2
0x0204: pop pc

