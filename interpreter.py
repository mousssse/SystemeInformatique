import sys

instructions = {}

#asmFilename = sys.argv[1]
asmFilename = './test/output_if.s'
with open(asmFilename, 'r') as file:
    inMain = False
    for line in file.readlines():
        line = line.strip()
        if line.startswith('.main'): inMain = True
        elif line and not line.startswith('.'):
            addr, instr = line.split(':', 1)
            addr = int(addr, 16)
            instr = instr.split('(')
            instructions[addr] = instr[0].strip()
            if inMain:
                startAddress = addr
                inMain = False

# chaque cellule de pile fait la taille d'une adresse, sinon c'est compliqué
# attention à mettre la même valeur que définie dans branching.h
address_size = 2
stack_size = 32
registers = {"r0":0, "r1": 0, "sp": stack_size - 1, "bp": stack_size - 1, "pc": startAddress, "lr": 0}
flags = {'C': 0, 'N': 0, 'Z': 0}
stack = [0]*stack_size

def print_stack(stack):
    count = 0
    print('[\t', end='')
    for i in range(len(stack)):
        if (count == 7):
            count = 0
            if (i != len(stack) - 1):
                print("0x{:02x}".format(stack[i]), end=',\n\t')
            else:
                print("0x{:02x}".format(stack[i]), end='\n')
        else:
            print("0x{:02x}".format(stack[i]), end=', ')
            count += 1
    print(']')

def resolve_value(param):
    if param.startswith("#"):
        return int(param[1:])
    elif param.startswith("0x"):
        return int(param, 16)
    elif param.startswith("bp%"):
        return stack[registers["bp"] - int(param[3:])]
    else:
        return registers[param]

def update_flags(x):
    if (x == 0): flags['Z'] = 1
    else: flags['Z'] = 0
    if (x < 0): flags['N'] = 1
    else: flags['N'] = 0
    if (x > 255): flags['C'] = 1
    else: flags['C'] = 0

def execute_instruction(instr):
    print(instr)
    op, params = instr.split(' ', 1)
    nextAddress = registers['pc'] + 4
    if op == 'store':
        ptr, val = params.split()
        if '%' in ptr: stack[registers[ptr.split('%')[0]] - int(ptr[3:])] = resolve_value(val)
        else: stack[registers[ptr]] = resolve_value(val)
        if ptr == 'sp': registers['sp'] -= 1
    elif op == 'load':
        res, ptr = params.split()
        if 'bp' in ptr: registers[res] = resolve_value(ptr)
        else: 
            registers['sp'] += 1
            if res == 'pc': nextAddress = stack[registers['sp']]
            else: registers[res] = stack[registers['sp']]
    elif op == 'add':
        res, x, y = params.split()
        val = resolve_value(x) + resolve_value(y)
        registers[res] = val
        update_flags(val)
    elif op == 'sub':
        res, x, y = params.split()
        val = resolve_value(x) - resolve_value(y)
        registers[res] = val
        update_flags(val)
    elif op == 'mul':
        res, x, y = params.split()
        val = resolve_value(x) * resolve_value(y)
        registers[res] = val
        update_flags(val)
    elif op == 'afc':
        reg, val = params.split()
        registers[reg] = resolve_value(val)
    elif op.startswith('b'):
        if op == 'b': nextAddress = resolve_value(params)
        elif op == 'beq' and flags['Z'] == 1: nextAddress = resolve_value(params)
        elif op == 'bne' and flags['Z'] != 1: nextAddress = resolve_value(params)
        elif op == 'blt' and flags['N'] == 1: nextAddress = resolve_value(params)
        elif op == 'bge' and flags['N'] != 1: nextAddress = resolve_value(params)
        elif op == 'bgt' and flags['C'] == 1: nextAddress = resolve_value(params)
        elif op == 'ble' and flags['C'] != 1: nextAddress = resolve_value(params)
    else:
        print(f"Unknown instruction: '{op}'")
        return True

    registers['pc'] = nextAddress
    print('{' + ', '.join([f'{reg}: {hex(int(x))}' for reg, x in registers.items()]) + '}')
    print_stack(stack)
    print(flags)
    return False

def execute():
    while True:
        error = execute_instruction(instructions[registers['pc']])
        if error: break

# don't forget to remove the last pop pc before running
execute()