import sys
import json

asmFilename = sys.argv[1]
with open(asmFilename, 'r') as file:
    lines = file.readlines()

pyFile = open("pythonDict.py", 'r')
addrDict = json.loads(pyFile.readline())

if addrDict:
    print("\nChanging labels...")
    for index, line in enumerate(lines):
        words = line.split()
        if words:
            if words[0][:-1] in addrDict:
                print(lines[index][:-1] + ' -> ', end='')
                line = line.replace(words[2], addrDict[words[0][:-1]])
                lines[index] = line
                print(lines[index][:-1])

    with open(asmFilename, 'w') as file:
        file.writelines(lines)

    print("Labels changed.\n")

else: print("No labels to change\n")