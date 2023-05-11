import sys

instructions = {}

#asmFilename = sys.argv[1]
asmFilename = './test/output_if.S'
with open(asmFilename, 'r') as file:
    for line in file.readlines():
        line = line.strip()
        if line and not line.startswith('.'):
            addr, instr = line.split(':', 1)
            instructions[addr] = instr.strip()

registers = {"r0":None, "r1": None, "sp":1000, "bp":1000, "pc":None, "lr":0}
stack = []

for addr, instr in instructions.items():
    op, params = instr.split(' ', 1)
    if op == "push": 
        if params.startswith("#"): stack.append(int(params[1:].split()[0]))
        else: stack.append(registers[params])
    elif op == 'pop': registers[params] = stack.pop()
    elif op == 'add':
        res, x, y = params.split(', ')

        if x.startswith("#"): x = x[1:].split()[0]
        else: x = registers[x]
        if y.startswith("#"): y = y[1:].split()[0]
        else: y = registers[y]

        registers[res] = int(x) + int(y)
    elif op == 'sub':
        res, x, y = params.split(', ')
        if x.startswith("#"): x = x[1:].split()[0]
        else: x = registers[x]
        if y.startswith("#"): y = y[1:].split()[0]
        else: y = registers[y]

        registers[res] = int(x) - int(y)
    print(addr, registers)
    print(stack)