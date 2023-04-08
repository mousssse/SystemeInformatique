PUSH #0 (0)
POP sp%0 (a)
PUSH #4 (3)
PUSH #3 (4)
PUSH [sp%0 (a)] (5)
MUL sp%4 sp%4 sp%5
ADD sp%3 sp%3 sp%4
POP sp%1 (b)
PUSH [sp%2 (c)] (3)
PUSH #1 (4)
ADD sp%3 sp%3 sp%4
POP sp%1 (b)
PUSH #0 (3)
