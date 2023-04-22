import sys
import pythonDict
print(pythonDict.addrDict)

asmFilename = sys.argv[1]
with open(asmFilename, 'r') as file:
    lines = file.readlines()

for index, line in enumerate(lines):
    words = line.split()
    if words:
        if words[0][:-1] in pythonDict.addrDict:
            print(lines[index])
            line = line.replace(words[2], pythonDict.addrDict[words[0][:-1]])
            lines[index] = line
            print(lines[index])

with open(asmFilename, 'w') as file:
    file.writelines(lines)