int main() {
    int a = 10;
    int b = 3;
    int c;
    
    c = a / b;
    c = a % b;
    
    a--;
    --b;
    
    if ((a > b) && (b != c) || (a >= c)) {
        return 1;
    }
    
    return 0;
}