# Ponteiro dentro de fluxo com INDENT/DEDENT
x = 0
p = &x
while x < 3:
    *p = x + 1
    if *p > 2:
        x = 100
print("x=" + str(x))