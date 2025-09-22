x = 1
def foo():
    x = 2
    print("inner_x=" + str(x))
foo()
print("outer_x=" + str(x))
