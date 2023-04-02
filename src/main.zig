const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const Allocator = std.mem.Allocator;

fn DisjointSet(comptime T: type) type {
    return struct {
        parent: *@This(),
        rank: usize,
        value: T,

        pub fn make(allocator: Allocator, x: T) !*@This() {
            var rtn = try allocator.create(@This());
            errdefer allocator.destroy(rtn);
            rtn.* = .{
                .parent = rtn,
                .rank = 0,
                .value = x,
            };
            return rtn;
        }

        pub fn find(self: *@This()) *@This() {
            // Coded this way to preserve a constant
            // stack size. Looks like it should roughly
            // double the iteration cost, but that cost
            // is small (ackermann function amortized),
            // and the second go-around all the data
            // should mostly be cached.

            // find the root ancestor
            var root = self.parent;
            while (root.parent != root)
                root = root.parent;

            // walk up the tree and store that root
            // in each descendant
            var node = self;
            while (node.parent != root) {
                var next = node.parent;
                node.parent = root;
                node = next;
            }
            return self.parent;
        }

        pub fn join(self: *@This(), other: *@This()) void {
            var rootX = self.find();
            var rootY = other.find();
            if (rootX != rootY) {
                if (rootX.rank < rootY.rank) {
                    rootX.parent = rootY;
                } else if (rootX.rank > rootY.rank) {
                    rootY.parent = rootX;
                } else {
                    rootY.parent = rootX;
                    rootX.rank += 1;
                }
            }
        }
    };
}

test "disjoint set" {
    var allocator = std.testing.allocator;
    const U = DisjointSet(u32);

    var a = try U.make(allocator, 5);
    defer allocator.destroy(a);

    var b = try U.make(allocator, 7);
    defer allocator.destroy(b);

    var c = try U.make(allocator, 8);
    defer allocator.destroy(c);

    try expectEqual(@as(u32, 5), a.find().value);
    try expectEqual(@as(u32, 7), b.find().value);
    try expectEqual(@as(u32, 8), c.find().value);

    a.join(b);
    try expectEqual(@as(u32, 5), a.find().value);
    try expectEqual(@as(u32, 5), b.find().value);
    try expectEqual(@as(u32, 8), c.find().value);

    b.join(c);
    try expectEqual(@as(u32, 5), a.find().value);
    try expectEqual(@as(u32, 5), b.find().value);
    try expectEqual(@as(u32, 5), c.find().value);
}
