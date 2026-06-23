int main() {
    int s;
    s = 0;
    for (int i = 0; i < 5; ++i) {
        s = s + i;
    }
    for (int j = 5; j > 0; --j) {
        s = s + j;
    }
    return s;
}