int check(int x, int y) {
    if (x != y) {
        return 1;
    }
    if (x > 0 && y >= 1) {
        return 2;
    }
    if (x < 0 || y > 10) {
        return 3;
    }
    return 0;
}