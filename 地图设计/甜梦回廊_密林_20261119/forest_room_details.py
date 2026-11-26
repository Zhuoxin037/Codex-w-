"""Clear the deer arena's movement envelope and furnish the service rooms."""

from architecture import Build
from floor_upgrade import text, write
from forest_economy import FN


def stage(data, mc, before):
    arena = Build(relative=True)
    arena.box((-13, 0, -13), (13, 4, 13), "air")
    arena.disk(0, -1, 0, 13, 13, "mossy_stone_bricks")
    arena.disk(0, -1, 0, 11, 11, "packed_mud")
    arena.disk(0, -1, 0, 9, 9, "coarse_dirt")
    arena.disk(0, -1, 0, 4, 4, "tuff_bricks")
    for x in (-11, -5, 0, 5, 11):
        for z in (-11, -5, 0, 5, 11):
            arena.set(x, 2, z, "light[level=15]")
    mc("combat/deer_glade", *arena.lines)
    before("combat/boss", f"execute positioned ~ ~ ~-4 run function {FN}stag/spawn",
           f"function {FN}combat/deer_glade")

    for kind, furnish in (("safe", safe), ("forge", forge), ("astrology", astrology),
                          ("gamble", gamble), ("rental", rental)):
        b = Build(relative=True)
        furnish(b)
        mc(f"room/details/{kind}", *b.lines)
        for variant in range(3):
            path = data / f"fallendream/function/rogue/detail/{kind}_{variant}.mcfunction"
            if not path.is_file():
                continue
            body = text(path)
            hook = f"function {FN}room/details/{kind}"
            if hook not in body.splitlines():
                write(path, body + hook)


def safe(b):
    b.box((5, 0, 5), (10, 0, 10), "spruce_planks")
    b.box((5, 1, 10), (10, 1, 10), "spruce_stairs[facing=south]")
    b.box((10, 1, 6), (10, 1, 9), "spruce_stairs[facing=east]")
    for x, z in ((5, 5), (10, 5), (5, 10), (10, 10)):
        b.box((x, 1, z), (x, 3, z), "stripped_spruce_log")
    for x in range(5, 11):
        b.box((x, 4, 5), (x, 4, 10), "spruce_slab[type=top]" if x in (5, 10) else "spruce_slab[type=bottom]")
    b.set(6, 3, 5, "lantern[hanging=true]")
    b.set(9, 3, 9, "lantern[hanging=true]")
    b.box((7, 1, 7), (8, 1, 8), "brown_carpet")
    b.set(7, 1, 6, "flower_pot")


def forge(b):
    b.box((5, 0, 5), (10, 0, 10), "tuff_bricks")
    b.box((8, 1, 9), (10, 3, 10), "deepslate_bricks")
    b.box((9, 4, 10), (9, 6, 10), "polished_blackstone_brick_wall")
    b.set(9, 1, 9, "campfire[lit=true]")
    b.set(9, 2, 9, "iron_bars")
    b.set(7, 1, 8, "anvil[facing=west]")
    b.box((8, 1, 6), (10, 1, 6), "stripped_dark_oak_log[axis=x]")
    b.set(10, 2, 6, "lantern")
    b.set(8, 2, 6, "flower_pot")
    b.set(6, 1, 9, "barrel[facing=up]")


def astrology(b):
    b.disk(8, 0, 8, 3, 3, "polished_tuff")
    b.disk(8, 0, 8, 2, 2, "waxed_oxidized_cut_copper")
    b.box((8, 1, 8), (8, 2, 8), "chiseled_tuff_bricks")
    b.set(8, 3, 8, "amethyst_block")
    for x, z in ((6, 8), (10, 8), (8, 6), (8, 10)):
        b.set(x, 1, z, "polished_tuff_wall")
        b.set(x, 2, z, "soul_lantern")
    b.set(7, 1, 9, "small_amethyst_bud[facing=up]")
    b.set(9, 1, 7, "small_amethyst_bud[facing=up]")


def gamble(b):
    b.box((5, 0, 5), (10, 0, 10), "dark_oak_planks")
    b.box((6, 1, 8), (9, 1, 8), "dark_oak_slab[type=top]")
    for x in (6, 9):
        for z in (7, 9):
            b.set(x, 1, z, "spruce_stairs[facing=north]" if z == 7 else "spruce_stairs[facing=south]")
    b.set(7, 2, 8, "red_candle[candles=2,lit=true]")
    b.set(8, 2, 8, "white_candle[candles=1,lit=true]")
    b.box((6, 1, 10), (10, 1, 10), "dark_oak_slab[type=top]")
    b.set(10, 2, 10, "lantern")


def rental(b):
    b.box((5, 0, 5), (10, 0, 10), "spruce_planks")
    b.box((6, 1, 9), (10, 1, 9), "stripped_dark_oak_log[axis=x]")
    for x in (6, 10):
        b.box((x, 1, 10), (x, 4, 10), "stripped_spruce_log")
    b.box((6, 4, 10), (10, 4, 10), "stripped_spruce_log[axis=x]")
    b.set(7, 3, 10, "lantern[hanging=true]")
    b.set(9, 3, 10, "lantern[hanging=true]")
    b.set(8, 2, 9, "chain[axis=x]")
    b.set(10, 1, 7, "barrel[facing=up]")
