const std = @import("std");

pub const Tuple = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn isPoint(self: Tuple) bool {
        return self.w == 1.0;
    }

    pub fn isVector(self: Tuple) bool {
        return self.w == 0.0;
    }

    pub fn add(self: Tuple, v: Tuple) Tuple {
        return .{
            .x = self.x + v.x,
            .y = self.y + v.y,
            .z = self.z + v.z,
            .w = self.w + v.w,
        };
    }

    pub fn minus(self: Tuple, t2: Tuple) Tuple {
        return .{
            .x = self.x - t2.x,
            .y = self.y - t2.y,
            .z = self.z - t2.z,
            .w = self.w - t2.w,
        };
    }

    pub fn multiplyScalar(self: Tuple, scalar: f32) Tuple {
        return .{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
            .w = self.w * scalar,
        };
    }

    pub fn divideScalar(self: Tuple, scalar: f32) Tuple {
        return .{
            .x = self.x / scalar,
            .y = self.y / scalar,
            .z = self.z / scalar,
            .w = self.w / scalar,
        };
    }

    pub fn dot(a: Tuple, b: Tuple) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }

    pub fn cross(a: Tuple, b: Tuple) Tuple {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
            .w = 0.0,
        };
    }

    pub fn negate(self: Tuple) Tuple {
        return .{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
            .w = -self.w,
        };
    }

    pub fn magnitude(self: Tuple) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
    }

    pub fn normalize(self: Tuple) Tuple {
        const m = magnitude(self);
        return .{
            .x = self.x / m,
            .y = self.y / m,
            .z = self.z / m,
            .w = self.w / m,
        };
    }
};

pub fn point(x: f32, y: f32, z: f32) Tuple {
    return .{ .x = x, .y = y, .z = z, .w = 1.0 };
}

pub fn vector(x: f32, y: f32, z: f32) Tuple {
    return .{ .x = x, .y = y, .z = z, .w = 0.0 };
}

fn floatEquals(a: f32, b: f32) bool {
    const epsilon = 0.00001;
    const x = a - b;
    if (x < 0) {
        return -x < epsilon;
    } else {
        return x < epsilon;
    }
}

pub const Color = struct {
    red: f32,
    blue: f32,
    green: f32,

    pub fn plus(self: Color, other: Color) Color {
        return .{
            .red = self.red + other.red,
            .green = self.green + other.green,
            .blue = self.blue + other.blue,
        };
    }

    pub fn min(self: Color, other: Color) Color {
        return .{
            .red = self.red - other.red,
            .green = self.green - other.green,
            .blue = self.blue - other.blue,
        };
    }

    pub fn multiplyScalar(self: Color, scalar: f32) Color {
        return .{
            .red = self.red * scalar,
            .blue = self.blue * scalar,
            .green = self.green * scalar,
        };
    }

    pub fn multiply(c1: Color, c2: Color) Color {
        return .{
            .red = c1.red * c2.red,
            .blue = c1.blue * c2.blue,
            .green = c1.green * c2.green,
        };
    }

    pub fn equals(self: Color, other: Color) bool {
        return floatEquals(self.red, other.red) and floatEquals(self.green, other.green) and floatEquals(self.red, other.red);
    }
};

pub fn color(red: f32, green: f32, blue: f32) Color {
    return .{ .red = red, .green = green, .blue = blue };
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "tuple with w=1.0 is a point" {
    const a: Tuple = .{ .x = 4.3, .y = -4.2, .z = 3.1, .w = 1.0 };
    try expect(a.isPoint() == true);
    try expect(a.isVector() == false);
}

test "tuple with w=0 is a vector" {
    const a: Tuple = .{ .x = 4.3, .y = -4.2, .z = 3.1, .w = 0.0 };
    try expect(a.isPoint() == false);
    try expect(a.isVector() == true);
}

test "point constructor" {
    try expectEqual(point(4.3, -4.2, 3.1), .{ .x = 4.3, .y = -4.2, .z = 3.1, .w = 1.0 });
}

test "vector constructor" {
    try expectEqual(vector(4.3, -4.2, 3.1), .{ .x = 4.3, .y = -4.2, .z = 3.1, .w = 0.0 });
}

test "addition" {
    const a: Tuple = .{ .x = 3.0, .y = -2.0, .z = 5.0, .w = 1.0 };
    const b: Tuple = .{ .x = -2.0, .y = 3.0, .z = 1.0, .w = 0.0 };

    try expectEqual(a.add(b), .{ .x = 1.0, .y = 1.0, .z = 6.0, .w = 1.0 });
}

test "subtracting two points" {
    const p1 = point(3.0, 2.0, 1.0);
    const p2 = point(5.0, 6.0, 7.0);

    try expectEqual(p1.minus(p2), vector(-2, -4, -6));
}

test "subtracting a vector from a point" {
    const p = point(3.0, 2.0, 1.0);
    const v = vector(5.0, 6.0, 7.0);

    try expectEqual(p.minus(v), point(-2, -4, -6));
}

test "subtracting two vectors" {
    const v1 = vector(3.0, 2.0, 1.0);
    const v2 = vector(5.0, 6.0, 7.0);

    try expectEqual(
        v1.minus(v2),
        vector(-2, -4, -6),
    );
}

test "dot product of two tuples" {
    const v1: Tuple = vector(1.0, 2.0, 3.0);
    const v2: Tuple = vector(2.0, 3.0, 4.0);

    try expectEqual(v1.dot(v2), 20.0);
}

test "cross product of two tuples" {
    const v1: Tuple = vector(1.0, 2.0, 3.0);
    const v2: Tuple = vector(2.0, 3.0, 4.0);

    try expectEqual(v1.cross(v2), vector(-1.0, 2.0, -1.0));
    try expectEqual(v2.cross(v1), vector(1.0, -2.0, 1.0));
}

test "negate a vector" {
    const tuple: Tuple = .{ .x = 1.0, .y = -2.0, .z = 3.0, .w = -4.0 };
    try expectEqual(tuple.negate(), .{ .x = -1.0, .y = 2.0, .z = -3.0, .w = 4.0 });
}

test "multiplying a tuple with a scalar" {
    const tuple = Tuple{ .x = 1.0, .y = -2.0, .z = 3.0, .w = -4.0 };
    try expectEqual(tuple.multiplyScalar(3.5), Tuple{ .x = 3.5, .y = -7.0, .z = 10.5, .w = -14.0 });
}

test "dividing a tuple by a scalar" {
    const t = Tuple{ .x = 1.0, .y = -2.0, .z = 3.0, .w = -4.0 };
    try expectEqual(t.divideScalar(2.0), Tuple{ .x = 0.5, .y = -1, .z = 1.5, .w = -2.0 });
}

test "computing the magnitude for a vector(1, 0, 0)" {
    try expectEqual(vector(1.0, 0.0, 0.0).magnitude(), 1.0);
}

test "compute the magnitude of a vector(0, 1, 0)" {
    try expectEqual(vector(0.0, 1.0, 0.0).magnitude(), 1.0);
}

test "compute the magnitude of a vector(0, 0, 1)" {
    try expectEqual(vector(0.0, 0.0, 1.0).magnitude(), 1.0);
}

test "compute the magnitude of a vector(1, 2, 3)" {
    try expectEqual(vector(1.0, 2.0, 3.0).magnitude(), std.math.sqrt(14.0));
}

test "compute the magnitude of a vector(-1, -2, -3)" {
    try expectEqual(vector(-1.0, -2.0, -3.0).magnitude(), std.math.sqrt(14.0));
}

test "normalizing vector(4, 0, 0) gives vector(1, 0, 0)" {
    const v = vector(4.0, 0.0, 0.0);
    try expectEqual(v.normalize(), vector(1.0, 0.0, 0.0));
}

test "normalizing vector(1, 2, 3)" {
    const v = vector(1.0, 2.0, 3.0);
    const norm = v.normalize();
    try expect(floatEquals(norm.x, 1.0 / std.math.sqrt(14.0)));
    try expect(floatEquals(norm.y, 2.0 / std.math.sqrt(14.0)));
    try expect(floatEquals(norm.z, 3.0 / std.math.sqrt(14.0)));
}

test "colors are (red, green, blue) tuples" {
    const c = color(-0.5, 0.4, 1.7);
    try expectEqual(c.red, -0.5);
    try expectEqual(c.green, 0.4);
    try expectEqual(c.blue, 1.7);
}

test "adding colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);
    try expect(c1.plus(c2).equals(color(1.6, 0.7, 1.0)));
}

test "subtracting colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);

    try expect(c1.min(c2).equals(color(0.2, 0.5, 0.5)));
}

test "multiplying a color by a scalar" {
    const c = color(0.2, 0.3, 0.4);

    try expect(c.multiplyScalar(2.0).equals(color(0.4, 0.6, 0.8)));
}

test "multiplying colors" {
    const c1 = color(1.0, 0.2, 0.4);
    const c2 = color(0.9, 1.0, 0.1);

    try expect(c1.multiply(c2).equals(color(0.9, 0.2, 0.04)));
}
