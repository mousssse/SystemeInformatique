import sys

asmFilename = sys.argv[1]
nbOpPerInstr = 4

op_codes = {'add': 1, 'mul': 2, 'sub': 3, 'div': 4,
            'cop': 5, 'afc': 6, 'load': 7, 'store': 8,
            'b': 9, 'beq': 10, 'bne': 11, 'blt': 12,
            'bge': 13, 'bgt': 14, 'ble': 15}

registers = {'r0': 0, 'r1': 1, 'r2': 2, 'r3': 3,
             'r4': 4, 'r5': 5, 'r6': 6, 'r7': 7,
             'r8': 8, 'r9': 9, 'r10': 10, 'r11': 11,
             'sp': 12, 'bp': 13, 'pc': 14, 'lr': 15}

binaryFileName = asmFilename.rsplit('.', 1)[0]

print(binaryFileName)
binaryFile = open(binaryFileName, "w")

binaryInstructions = []

with open(asmFilename, 'r') as file:
    for line in file.readlines():
        line = line.strip()
        if line and not line.startswith('.'):
            addr, instr = line.split(':', 1)
            instr = instr.split('(')[0]
            instr_size = 0
            for oct in instr.split():
                if oct in op_codes:
                    binaryFile.write('{0:08b}'.format(op_codes[oct]))
                    instr_size += 1
                elif oct in registers:
                    binaryFile.write('{0:08b}'.format(registers[oct]))
                    instr_size += 1
                elif oct.startswith('bp%'):
                    binaryFile.write('{0:08b}'.format(registers['bp'] + int(oct[3:])))
                    instr_size += 1
                elif oct.startswith('#'):
                    binaryFile.write('{0:08b}'.format(int(oct[1:])))
                    instr_size += 1
                elif oct.startswith('0x'):
                    binaryFile.write('{0:08b}'.format(int(oct, 16) // nbOpPerInstr))
                    instr_size += 1
                else: print("unexistent: ", oct)
            if instr_size > nbOpPerInstr: raise ValueError("Instructions shouldn't be longer than 4 bytes.")
            for i in range(instr_size, nbOpPerInstr):
                binaryFile.write('{0:08b}'.format(0))

binaryFile.close()