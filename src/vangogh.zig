const std = @import("std");

const tuples = @import("./tuples.zig");

const Tuple = tuples.tuple;
const Color = tuples.color;

const canvas = @import("./canvas.zig");

// const Projectile = struct {
//     pos: Tuple,
//     velocity: Tuple,
// };

// const Env = struct {
//     gravity: Tuple,
//     wind: Tuple,
// };

// fn tick(env: Env, proj: Projectile) Env {
//     const position = proj.pos.add(proj.velocity);
//     const velocity = proj.velocity.add(env.gravity).add(env.wind);

//     return Env{.pos = position, .velocity = velocity};
// }


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const c = try canvas.make(allocator, 900, 550);
    defer allocator.free(c.items);

    var i: u32 = 0;

    while (i < 400): (i += 1) {
        c.writePixel(i, 20, .{.red = 1.0, .green = 0.0, .blue = 0.0});
        i += 1;
    }


    // const start = tuples.point(0.0, 1.0, 0.0);
    // const velocity = tuples.vector(1.0, 1.8, 0.0).normalize() * 11.25;
    // const p = Projectile{.pos = start, .velocity = .velocity};

    // const gravity = tuples.vector(0.0, -0.1, 0.0);
    // const wind = tuples.vector(-0.01, 0.0, 0.0);
    // const env = Env{.gravity = gravity, .wind = wind};
    



    const file = try std.fs.cwd().createFile("painting.ppm", .{.read = true});
    defer file.close();


    const painting = try c.toPpm();
    defer allocator.free(painting);

    try file.writeAll(painting);
}