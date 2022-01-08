pub fn floatEquals(a: f32, b: f32) bool {
    const epsilon = 0.00001;
    const x = a - b;
    if (x < 0) {
        return -x < epsilon;
    } else {
        return x < epsilon;
    }
}