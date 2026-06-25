int classify(int x) {
    if (x > 0) {
        if (x > 100) {
            return 2;
        } else {
            return 1;
        }
    }
    return 0;
}