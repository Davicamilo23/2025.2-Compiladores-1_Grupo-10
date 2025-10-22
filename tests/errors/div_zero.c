int main(void) {
    int x = 10 / 0; // division by zero (compile-time error on some compilers or UB)
    return x;
}
