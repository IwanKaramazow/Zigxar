const std = @import("std");
const tuples = @import("./tuples.zig");

const Allocator = std.mem.Allocator;
const Tuple = tuples.Tuple;

const floatEquals = @import("./float.zig").floatEquals;

pub const Matrix2d = struct {
    items: [4]f32,

    fn get(self: Matrix2d, x: u8, y: u8) f32 {
        return self.items[x * 2 + y];
    }

    fn equals(self: Matrix2d, other: Matrix2d) bool {
        return std.mem.eql(f32, &self.items, &other.items);
    }

    fn determinant(self: Matrix2d) f32 {
        return self.items[0] * self.items[3] - self.items[1] * self.items[2];
    }
};

pub const Matrix3d = struct {
    items: [9]f32,

    fn get(self: Matrix3d, x: u8, y: u8) f32 {
        return self.items[x * 3 + y];
    }

    fn equals(self: Matrix3d, other: Matrix3d) bool {
        return std.mem.eql(f32, &self.items, &other.items);
    }

    fn submatrix(self: Matrix3d, row: u8, column: u8) Matrix2d {
        var m: [4]f32 = undefined;

        var currentIndex: u8 = 0;

        var i: u8 = 0;

        while (i < 3) : (i += 1) {
            var j: u8 = 0;

            while (j < 3) : (j += 1) {
                if(i != row and j != column) {
                    m[currentIndex] = self.get(i, j);
                    currentIndex += 1;
                }
            }
        }

        return Matrix2d {.items = m};
    }

    fn minor(self: Matrix3d, row: u8, column: u8) f32 {
        return self.submatrix(row, column).determinant();
    }

    fn cofactor(self: Matrix3d, row: u8, column: u8) f32 {
        const m = self.minor(row, column);

        if (row + column % 2 == 0) {
            return m;
        } else {
            return -m;
        }
    }

    fn determinant(self: Matrix3d) f32 {
        var det: f32 = 0;

        comptime var column = 0;

        inline while (column < 3): (column += 1) {
            det += self.get(0, column) * self.cofactor(0, column);
        }

        return det;
    }
};

pub const Matrix4d = struct {
    items: [16]f32,

    const identity: Matrix4d = .{. items = .{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}};

    fn get(self: Matrix4d, x: u8, y: u8) f32 {
        return self.items[x * 4 + y];
    }

    fn equals(self: Matrix4d, other: Matrix4d) bool {
        var row: u8 = 0;

        while (row < 4): (row += 1) {
            var col: u8 = 0;

            while (col < 4): (col += 1) {
                if(!floatEquals(self.items[row * 4 + col], other.items[row * 4 + col])) {
                    return false;
                }
            }
        }

        return true;

        // return std.mem.eql(f32, &self.items, &other.items);
    }

    fn multiply(self: Matrix4d, other: Matrix4d) Matrix4d {
        var m: [16]f32 = undefined;

        comptime var row: u8 = 0;
        inline while (row < 4) : (row += 1)  {
            comptime var col: u8 = 0;

            inline while (col < 4) : (col += 1) {
                m[row * 4 + col] =
                        self.get(row, 0) * other.get(0, col) 
                    +   self.get(row, 1) * other.get(1, col) 
                    +   self.get(row, 2) * other.get(2, col)
                    +   self.get(row, 3) * other.get(3, col);
            }
        }

        return .{.items = m}; 
    }

    fn multiplyTuple(self: Matrix4d, tuple: Tuple) Tuple {
        return .{
            .x = self.get(0, 0) * tuple.x + self.get(0, 1) * tuple.y + self.get(0, 2) * tuple.z + self.get(0, 3) * tuple.w,
            .y = self.get(1, 0) * tuple.x + self.get(1, 1) * tuple.y + self.get(1, 2) * tuple.z + self.get(1, 3) * tuple.w,
            .z = self.get(2, 0) * tuple.x + self.get(2, 1) * tuple.y + self.get(2, 2) * tuple.z + self.get(2, 3) * tuple.w,
            .w = self.get(3, 0) * tuple.x + self.get(3, 1) * tuple.y + self.get(3, 2) * tuple.z + self.get(3, 3) * tuple.w,
        };
    }

    fn transpose(self: Matrix4d) Matrix4d {
        var m: [16]f32 = undefined;

        comptime var row = 0;

        inline while (row < 4) : (row += 1) {
            comptime var col = 0;

            inline while (col < 4) : (col += 1) {
                m[row * 4 + col] = self.get(col, row);
            }
        }

        return .{.items = m};
    }

    fn submatrix(self: Matrix4d, row: u8, column: u8) Matrix3d {
        var m: [9]f32 = undefined;

        var currentIndex: u8 = 0;

        var i: u8 = 0;

        while (i < 4) : (i += 1) {
            var j: u8 = 0;

            while (j < 4) : (j += 1) {
                if(i != row and j != column) {
                    m[currentIndex] = self.get(i, j);
                    currentIndex += 1;
                }
            }
        }

        return Matrix3d {.items = m};
    }

    fn minor(self: Matrix4d, row: u8, column: u8) f32 {
        return self.submatrix(row, column).determinant();
    }

    fn cofactor(self: Matrix4d, row: u8, column: u8) f32 {
        const m = self.minor(row, column);

        if ((row + column) % 2 == 0) {
            return m;
        } else {
            return -m;
        }
    }

    fn determinant(self: Matrix4d) f32 {
        var det: f32 = 0;

        comptime var column = 0;

        inline while (column < 4): (column += 1) {
            det += self.get(0, column) * self.cofactor(0, column);
        }

        return det;
    }

    fn invertible(self: Matrix4d) bool {
        return self.determinant() != 0;
    }

    fn inverse(self: Matrix4d) Matrix4d {
        std.debug.assert(self.invertible());

        const det = self.determinant();

        var m2: [16]f32 = undefined;

        var row: u8 = 0;

        while (row < 4): (row += 1) {
            var column: u8 = 0;

            while (column < 4): (column += 1) {
                const c = self.cofactor(row, column);

                m2[column * 4 + row] = c / det;
            }
        }

        return Matrix4d {.items = m2};
    }
 };

const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

test "A 2x2 matrix ought to be representable" {
    const matrix = Matrix2d {.items = .{-3.0, 5.0, 1.0, -2.0}};

    try expectEqual(matrix.get(0,0), -3.0);
    try expectEqual(matrix.get(0,1), 5);
    try expectEqual(matrix.get(1,0), 1);
    try expectEqual(matrix.get(1,1), -2.0);
}

test "2D Matrix equality with identical matrices" {
    const matrix = Matrix2d {.items = .{-3.0, 5.0, 1.0, -2.0}};

    try expect(matrix.equals(.{.items = .{-3.0, 5.0, 1.0, -2.0}}));
}

test "A 3x3 matrix ought to be representable" {
    const matrix = Matrix3d {.items = .{-3.0, 5.0, 0.0, 1.0, -2.0, -7.0, 0.0, 1.0, 1.0}};

    try expectEqual(matrix.get(0,0), -3.0);
    try expectEqual(matrix.get(1,1), -2.0);
    try expectEqual(matrix.get(2,2), 1.0);
}

test "3D Matrix equality with identical matrices" {
    const matrix = Matrix3d {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9}};

    try expect(matrix.equals(. {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9}}));
}


test "Constructing and inspecting a 4x4 matrix" {
    const m: Matrix4d = .{ .items = .{1.0, 2.0, 3.0, 4.0, 5.5, 6.5, 7.5, 8.5, 9.0, 10.0, 11.0, 12.0, 13.5, 14.5, 15.5, 16.5}};

    try expectEqual(m.get(0, 0), 1.0);
    try expectEqual(m.get(0, 3), 4.0);
    try expectEqual(m.get(1, 0), 5.5);
    try expectEqual(m.get(1, 2), 7.5);
    try expectEqual(m.get(2, 2), 11.0);
    try expectEqual(m.get(3, 0), 13.5);
    try expectEqual(m.get(3, 2), 15.5);
}

test "4D Matrix equality with identical matrices" {
    const matrix = Matrix4d {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2}};

    try expect(matrix.equals(. {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2}}));
}

test "4D Matrix equality with different matrices" {
    const matrix = Matrix4d {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2}};

    try expect(!matrix.equals(.{.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7}}));
}

test "Multiplying two matrices" {
    const a = Matrix4d {.items = .{1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2}};

    const b = Matrix4d {.items = .{-2, 1, 2, 3, 3, 2, 1, -1, 4, 3, 6, 5, 1 ,2, 7, 8}};

    try expect(a.multiply(b).equals(. {.items = .{20, 22, 50, 48, 44, 54, 114, 108, 40, 58, 110, 102, 16, 26, 46, 42}}));
}

test "A matrix multiplied by a tuple" {
    const m = Matrix4d {.items = .{1, 2, 3, 4, 2, 4, 4, 2, 8, 6, 4, 1, 0, 0, 0, 1}};
    const tuple = Tuple {.x = 1, .y = 2, .z = 3, .w = 1};

    try expectEqual(
        m.multiplyTuple(tuple),
        .{.x = 18, .y = 24, .z = 33, .w = 1}
    );
}

test "Multiplying a matrix by the identity matrix" {
    const m = Matrix4d { .items = .{0, 1, 2, 4, 1, 2, 4, 8, 2, 4, 8, 16, 4, 8, 16, 32}};

    try expect(m.multiply(Matrix4d.identity).equals(m));
}

test "Multiplying the identity matrix by a tuple" {
    const tuple = Tuple {.x = 1, .y = 2, .z = 3, .w = 4};

    try expectEqual(Matrix4d.identity.multiplyTuple(tuple), tuple);
}

test "Transposing a matrix" {
    const m = Matrix4d {.items = .{0, 9, 3, 0, 9, 8, 0, 8, 1, 8, 5, 3, 0, 0, 5, 8}};

    const transposed = Matrix4d {.items = .{0, 9, 1, 0, 9, 8, 8, 0, 3, 0, 5, 5, 0, 8 , 3, 8}};

    try expect(m.transpose().equals(transposed));
}

test "Transposing the identity matrix" {
    try expect(Matrix4d.identity.transpose().equals(Matrix4d.identity));
}

test "Calculating the determinant of a 2x2 matrix" {
    const m = Matrix2d { .items = .{1, 5, -3, 2}};

    try expectEqual(m.determinant(), 17);
}

test "A submatrix of a 3x3 matrix is a 2x2 matrix" {
    const m = Matrix3d {.items = .{1, 5, 0, -3, 2, 7, 0, 6, -3}};

    try expect(m.submatrix(0, 2).equals(.{.items = .{-3, 2, 0, 6}}));
}

test "A submatrix of a 4x4 matrix is a 3x3 matrix" {
    const m = Matrix4d {.items = .{-6, 1, 1, 6, -8, 5, 8, 6, -1, 0, 8, 2, -7, 1, -1, 1}};

    try expect(m.submatrix(2, 1).equals(.{.items = .{-6, 1, 6, -8, 8, 6, -7, -1, 1}}));
}

test "Calculating a minor of a 3x3 matrix" {
    const m = Matrix3d {.items = .{3, 5, 0, 2, -1, -7, 6, -1, 5}};

    try expectEqual(m.minor(1, 0), 25);
}

test "Calculating a cofactor of a 3x3 matrix" {
    const m = Matrix3d {.items = .{3, 5, 0, 2, -1, -7, 6, -1, 5}};

    try expectEqual(m.minor(0, 0), -12);
    try expectEqual(m.cofactor(0, 0), -12);
    try expectEqual(m.minor(1, 0), 25);
    try expectEqual(m.cofactor(1, 0), -25);
}

test "Calculating the determinant of a 3x3 matrix" {
    const m = Matrix3d {.items = .{1, 2, 6, -5, 8, -4, 2, 6, 4}};

    try expectEqual(m.cofactor(0, 0), 56);
    try expectEqual(m.cofactor(0, 1), 12);
    try expectEqual(m.cofactor(0, 2), -46);
    try expectEqual(m.determinant(), -196);
}

test "Calculating the determinant of a 4x4 matrix" {
    const m = Matrix4d {.items = .{-2, -8, 3, 5, -3, 1, 7, 3, 1, 2, -9, 6, -6, 7, 7, -9}};

    try expectEqual(m.cofactor(0, 0), 690);
    try expectEqual(m.cofactor(0, 1), 447);
    try expectEqual(m.cofactor(0, 2), 210);
    try expectEqual(m.cofactor(0, 3), 51);
    try expectEqual(m.determinant(), -4071);
}

test "Testing an invertible matrix for invertibility" {
    const m = Matrix4d {.items = .{6, 4, 4, 4, 5, 5, 7, 6, 4, -9, 3, -7, 9, 1, 7, -6}};

    try expectEqual(m.determinant(), -2120);
    try expect(m.invertible());
}

test "Testing a noninvertible matrix for invertibility" {
    const m = Matrix4d {.items = .{-4, 2, -2, -3, 9, 6, 2, 6, 0, -5, 1, -5, 0, 0, 0, 0}};

    try expectEqual(m.determinant(), 0);
    try expect(!m.invertible());
}

test "Calculating the inverse of a matrix" {
    const m = Matrix4d {.items = .{-5, 2, 6, -8, 1, -5, 1, 8, 7, 7, -6, -7, 1, -3, 7, 4}};

    const inverted = m.inverse();



    try expectEqual(m.determinant(), 532);
    try expectEqual(m.cofactor(2, 3), -160);
    try expect(floatEquals(inverted.get(3, 2), -160.0 / 532.0));
    try expectEqual(m.cofactor(3, 2), 105);
    try expect(floatEquals(inverted.get(2, 3), 105.0 / 532.0));

    try expectEqual(m.cofactor(0, 2), -42);
    try expectEqual(m.cofactor(2, 0), 128);
    try expect(floatEquals(inverted.get(0, 2), 0.24060));

    const expected = Matrix4d { .items = .{
        0.21805, 0.45113, 0.24060, -0.04511,
        -0.80827, -1.45677, -0.44361, 0.52068,
        -0.07895, -0.22368, -0.05263, 0.19737,
        -0.52256, -0.81391, -0.30075, 0.30639
    }};

    try expect(inverted.equals(expected));
}

test "Calculating the inverse of another matrix" {
    const m = Matrix4d {.items = .{8, -5, 9, 2, 7, 5, 6, 1, -6, 0, 9, 6, -3, 0, -9, -4}};


    const inverted = m.inverse();

    const expected = Matrix4d { .items = .{
        -0.15385, -0.15385, -0.28205, -0.53846,
        -0.07692, 0.12308, 0.02564, 0.03077,
        0.35897, 0.35897, 0.43590, 0.92308,
        -0.69231, -0.69231, -0.76923, -1.92308
    }};

    try expect(inverted.equals(expected));
}

test "Calculating the inverse of a 3th matrix" {
    const m = Matrix4d {.items = .{9, 3, 0, 9, -5, -2, -6, -3, -4, 9, 6, 4, -7, 6, 6, 2}};

    const inverted = m.inverse();

    const expected = Matrix4d { .items = .{
        -0.04074, -0.07778, 0.14444, -0.22222,
        -0.07778, 0.03333, 0.36667, -0.33333,
        -0.02901, -0.14630, -0.10926, 0.12963,
        0.17778, 0.06667, -0.26667, 0.33333
    }};

    try expect(inverted.equals(expected));
}

test "Multiplying a product by its inverse" {
    const a = Matrix4d {.items = .{3, -9, 7, 3, 3, -8, 2, -9, -4, 4, 4, 1, -6, 5, -1, 1}};
    const b = Matrix4d {.items = .{8, 2, 2, 2, 3, -1, 7, 0, 7, 0, 5, 4, 6, -2, 0, 5}};

    const c = a.multiply(b);

    try expect(a.equals(c.multiply(b.inverse())));
}

