PUSH #0 (1)
PUSH #2 (2)
PUSH [sp%0 (b)] (3)
POP R1
POP R0
ADD R0, R0, R1
PUSH R0
POP R1
POP R0
ADD R0, R0, R1
PUSH R0
POP sp%1 (a)
PUSH [sp%1 (a)] (2)
PUSH [sp%0 (b)] (3)
POP R1
POP R0
SUB R0 R0 R1
CMP R0, #0
JEQ .else

PUSH #2 (3)
POP sp%1 (a)
JMP .both

.else:
PUSH #3 (3)
POP sp%1 (a)

.both:
PUSH [sp%1 (a)] (3)
POP {PC}
