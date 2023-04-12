# zunion

pointer-chasing union-find in zig

## Purpose

Union-Find is a critical subcomponent of many algorithms (like EGG). This is a reasonably efficient implementation under the assumption that pointer chasing is satisfactory and you don't need more constrained data types.

## Installation

Copy-paste or [git-subrepo](https://github.com/ingydotnet/git-subrepo) or whatever. Also, ZIG HAS A PACKAGE MANAGER NOW!!! Use it with something like the following.

```zig
// build.zig.zon
.{
    .name = "foo",
    .version = "0.0.0",
    .dependencies = .{
        .zunion = .{
            .url = "https://github.com/hmusgrave/zunion/archive/refs/tags/0.0.2.tar.gz",
	    .hash = "122051622dceebaaff2627787de165f329f2e3dae4696150a225170cce10128e704e",
        },
    },

}
```

```zig
// build.zig
const zunion_pkg = b.dependency("zunion", .{
    .target = target,
    .optimize = optimize,
});
const zunion_mod = zunion_pkg.module("zunion");
lib.addModule("zunion", zunion_mod);
main_tests.addModule("zunion", zunion_mod);
```

## Examples

```zig
test "it all works" {
    var allocator = std.testing.allocator;
    const U = DisjointSet(u32);

    // turn the value we want to store (42) into
    // a pointer to a set tracking that variable
    // and anything it might be connected to
    var a = try U.make(allocator, 42);
    defer allocator.destroy(a);

    // same for (314)
    var b = try U.make(allocator, 314);
    defer allocator.destroy(b);

    // those disjoint sets haven't been joined, so if we
    // examine the root nodes holding each of them we'll
    // find they're different
    try expectEqual(@as(u32, 42), a.find().value);
    try expectEqual(@as(u32, 314), b.find().value);

    // modify a and b (and any ancestors between them
    // and their roots) to have the same root
    a.join(b)

    // since those nodes have been joined, they have the
    // same parent value (it's deterministically 42 at this
    // point, but that's an implementation detail, and the
    // salient detail is that they're equal).
    try expectEqual(a.find().value, b.find().value);
}
```
