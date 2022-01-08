const std = @import("std");
const Allocator = std.mem.Allocator;

const ArrayList = std.ArrayList;

const tuples = @import("./tuples.zig");
const Color = tuples.Color;



pub const Canvas = struct {
    width: u32,
    height: u32,  
    items: []Color,
    allocator: Allocator,

    pub fn getPixel(self: Canvas, x: u32, y: u32) Color {
        return self.items[y * x];
    }

    fn clamp(color: f32) f32 {
        if (color > 1.0) {
            return 255;
        } else if (color < 0.0) {
            return 0;
        } else {
            return std.math.round(color * 255);
        }
    }

    fn len(value: f32) u8 {
        if (value < 10) {
            return 1;
        } else if (value < 100) {
            return 2;
        } else {
            return 3;
        }
    }

    pub fn writePixel(self: Canvas, x: u32, y: u32, color: Color) void {
        self.items[y * self.width + x] = color;
    }

    pub fn toPpm(self: Canvas) ![]u8 {
        var buffer = ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        const writer = buffer.writer();

        // header
        try writer.print("P3\n{} {}\n255\n", .{self.width, self.height});


        // write pixel data
        var i: u32 = 0;
        var indent: usize = 0;
        while (i < self.items.len): (i += 1) {
            // each pixel is represented as three integers: red, green, and blue.
            const color = self.items[i];
            const redComponent = clamp(color.red);
            const redLen = len(redComponent);

            if (i > 0) {
                if (indent + 1 + redLen >= 70) {
                    try writer.writeByte('\n');
                    indent = 0;
                } else {
                    try writer.writeByte(' ');
                    indent += 1;
                }
            }

            try writer.print("{d}", .{redComponent});
            indent += redLen;

            const greenComponent = clamp(color.green);
            const greenLen = len(greenComponent);
            if (indent + 1 + greenLen >= 70) {
                try writer.writeByte('\n');
                indent = 0;
            } else {
                try writer.writeByte(' ');
                indent += 1;
            }

            try writer.print("{d}", .{greenComponent});
            indent += greenLen;

            const blueComponent = clamp(color.blue);
            const blueLen = len(blueComponent);
             if (indent + 1 + blueLen >= 70) {
                try writer.writeByte('\n');
                indent = 0;
            } else {
                try writer.writeByte(' ');
                indent += 1;
            }

            try writer.print("{d}", .{blueComponent});
            indent += blueLen;
        }

        try writer.writeByte('\n');

        return buffer.toOwnedSlice();
    }
};

const Ppm = []const u8;

pub fn make(allocator: Allocator, width: u32, height: u32) !Canvas {
    const slice: []Color = try allocator.alloc(Color, width * height);

    var i: u32 = 0;

    while (i < width * height) : (i += 1) {
        slice[i] = Color{.red = 0.0, .green = 0.0, .blue = 0.0};
    }

    return Canvas{
        .width = width,
        .height = height,
        .allocator = allocator,
        .items = slice,
    };
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "creating a canvas initializes everything with Color(0, 0, 0)" {
    const canvas = try make(std.testing.allocator, 40, 40);
    defer std.testing.allocator.free(canvas.items);

    var y: u32 = 0;
    var x: u32 = 0;

    while (y < canvas.height) : (y += 1) {
        while (x < canvas.width) : (x += 1) {
            try expectEqual(
                canvas.getPixel(x, y),
                Color{.red = 0.0, .green = 0.0, .blue = 0.0}
            );
        }
        x = 0;
    }
}

test "creating a canvas" {
    const canvas = try make(std.testing.allocator, 10, 2);
    defer std.testing.allocator.free(canvas.items[0..canvas.items.len]);

    var y: u8 = 0;
    var x: u8 = 0;

    while (y < canvas.height) : (y += 1) {
        while (x < canvas.width) : (x += 1) {
            canvas.writePixel(x, y, Color{.red = 50, .green = 50, .blue =  50});
        }
        x = 0;
    }

    try expectEqual(canvas.width, 10);
    try expectEqual(canvas.height, 2);
    try expectEqual(canvas.getPixel(7, 1).equals(Color{.red = 50, .green = 50, .blue = 50}), true);

    y = 0;
    x = 0;

    while (y < canvas.height) : (y += 1) {
        while (x < canvas.width) : (x += 1) {
            try expectEqual(
                canvas.getPixel(x, y),
                Color{.red = 50, .green = 50, .blue =  50}
            );
        }
        x = 0;
    }
}

// test "constructing PPM header" {
//     const canvas = try make(std.testing.allocator, 80, 40);
//     defer std.testing.allocator.free(canvas.items);

//     const renderedBytes = try canvas.toPpm();
//     defer std.testing.allocator.free(renderedBytes);

//     var it = std.mem.split(renderedBytes, "\n");

//     try expect(std.mem.eql(u8, it.next().?, "P3"));
//     try expect(std.mem.eql(u8, it.next().?, "80 40"));
//     try expect(std.mem.eql(u8, it.next().?, "255"));
// }

// test "constructing the PPM pixel data" {
//     const canvas = try make(std.testing.allocator, 5, 3);
//     defer std.testing.allocator.free(canvas.items);

//     const c1 = Color{.red = 1.5, .green = 0.0, .blue = 0.0};
//     const c2 = Color{.red = 0.0, .green = 0.5, .blue = 0.0};
//     const c3 = Color{.red = -0.5, .green = 0.0, .blue = 1.0};

//     canvas.writePixel(0, 0, c1);
//     canvas.writePixel(2, 1, c2);
//     canvas.writePixel(4, 2, c3);

//     const renderedBytes = try canvas.toPpm();
//     defer std.testing.allocator.free(renderedBytes);

//     var it = std.mem.split(renderedBytes, "\n");

//     try expect(std.mem.eql(u8, it.next().?, "P3"));
//     try expect(std.mem.eql(u8, it.next().?, "5 3"));
//     try expect(std.mem.eql(u8, it.next().?, "255"));

//     // std.debug.print("\n\nPixel data: |{s}|\n", .{it.next().?});
//     // try expect(std.mem.eql(u8, it.next().?, "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0"));
// }

test "Splitting long lines in PPM files" {
    const canvas = try make(std.testing.allocator, 10, 2);
    defer std.testing.allocator.free(canvas.items);

    const c = Color{.red = 1.0, .green = 0.8, .blue = 0.6};

    var y: u32 = 0;
    var x: u32 = 0;

     while (y < canvas.height) : (y += 1) {
        while (x < canvas.width) : (x += 1) {
            canvas.writePixel(x, y, c);
        }
        x = 0;
    }

    const renderedBytes = try canvas.toPpm();
    defer std.testing.allocator.free(renderedBytes);

    var it = std.mem.split(u8, renderedBytes, "\n");

    try expect(std.mem.eql(u8, it.next().?, "P3"));
    try expect(std.mem.eql(u8, it.next().?, "10 2"));
    try expect(std.mem.eql(u8, it.next().?, "255"));

    try expect(std.mem.eql(u8, it.next().?, "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204"));
    try expect(std.mem.eql(u8, it.next().? , "153 255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255"));
    try expect(std.mem.eql(u8, it.next().? , "204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204 153"));
    try expect(std.mem.eql(u8, it.next().? , "255 204 153 255 204 153 255 204 153"));
}

test "PPM files are terminated by a newline character" {
    const canvas = try make(std.testing.allocator, 5, 3);
    defer std.testing.allocator.free(canvas.items);

    const ppm = try canvas.toPpm();
    defer std.testing.allocator.free(ppm);

    try expectEqual(ppm[ppm.len - 1], '\n');
}

