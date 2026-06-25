int add(int a, int b, int c) {
    int result;
    result = a + b;
    {
        result = result + c;
    }
    return result;
}