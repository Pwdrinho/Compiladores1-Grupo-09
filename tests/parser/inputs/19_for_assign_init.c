int main() {
    int i;
    i = 0;
    for (i = 1; i < 5; i++) {
        i = i + 1;
    }
    for (i = 10; i > 0; i += 1) {
        i = i - 1;
    }
    for (i = 10; i > 0; i -= 1) {
        i = i + 1;
    }
    return i;
}