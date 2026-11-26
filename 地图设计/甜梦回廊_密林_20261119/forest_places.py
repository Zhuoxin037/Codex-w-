"""Scene geometry and the pixel symbols for the Forest floor."""

import math
from itertools import product
from pathlib import Path
from random import Random

import architecture as forest
from floor_upgrade import text, write

# Five ink pixels across with another pixel of backing on all sides.
# A route or visited-room border remains clear around the backing.
ICONS = {
    "entry": ("white", (".###.", ".#.#.", ".#.#.", ".#.#.", "##.##")),  # Gate
    "combat": ("orange", ("#...#", ".#.#.", "..#..", ".#.#.", "#...#")),  # Blades
    "elite": ("yellow", ("..#..", ".###.", ".###.", "#####", "..#..")),  # Greatsword
    "boss": ("red", (".###.", "#####", "#.#.#", ".###.", ".#.#.")),  # Skull
    "safe": ("pink", (".#.#.", "#####", "#####", ".###.", "..#..")),  # Heart
    "forge": ("white", ("##..#", "#####", ".###.", "..#..", ".###.")),  # Anvil
    "merchant": ("yellow", ("#####", "#.#.#", "#####", "#...#", "#####")),  # Stall
    "rental": ("light_blue", (".###.", ".#.##", "..##.", "..#..", ".###.")),  # Key
    "blackmarket": ("magenta", (".###.", "#####", "#.#.#", "#####", ".###.")),  # Hood
    "astrology": ("light_blue", ("..#..", ".###.", "#####", ".###.", "..#..")),
    "gamble": ("lime", (".###.", "##..#", "#.#.#", "#..##", ".###.")),  # Die
    "event": ("white", (".###.", "#...#", "...#.", "..#..", "..#..")),
}
LEAF = forest.LEAVES
MOSS = forest.MOSS
BARK = forest.BARK
TILE = "tuff_bricks"
WORN = "mossy_stone_bricks"
MUD = "packed_mud"
SPRUCE = "spruce_planks"


def light(b, x, y, z, level=15):
    b.lines.append(f"setblock {b.pos(x,y,z)} minecraft:light[level={level}] keep")


def silhouettes(b, radius, kind, variant):
    # Pull each corner in by a different amount. Crossing axes stay open and
    # all room thresholds still sit on the same seven-wide door sockets.
    rng = Random(f"forest-rim:{kind}:{variant}")
    for sx, sz in product((-1, 1), repeat=2):
        reach = rng.choice((4, 6, 8))
        for i in range(reach):
            width = max(1, round(3 * (1 - i/reach)))
            inward = radius - 1 - i
            xs = sorted((sx*(radius-1), sx*(radius-width)))
            zs = sorted((sz*(radius-1), sz*(radius-width)))
            b.box((sx*inward, 1, zs[0]), (sx*inward, 1, zs[1]), rng.choice((MOSS, "podzol", "mossy_cobblestone")))
            b.box((xs[0], 1, sz*inward), (xs[1], 1, sz*inward), rng.choice((MOSS, "rooted_dirt", "tuff")))
            if width >= 2:
                b.set(sx*inward, 2, sz*(radius-width), "fern" if i % 2 else "azalea")
            if i in (0, 2) and width >= 2:
                b.set(sx*inward, 2, sz*(radius-1), "mossy_cobblestone")
                b.set(sx*inward, 3, sz*(radius-1), "mossy_cobblestone_slab")
        # An old trunk grows up the bank with an asymmetric crown that
        # connects to the higher canopy. Vary its projection and height by corner.
        x, z = sx*(radius-rng.choice((2, 3))), sz*(radius-2)
        bark_top = rng.choice((6, 7, 8))
        branch = -sx*rng.choice((2, 3))
        b.box((x, 1, z), (x, bark_top, z), BARK)
        b.box((x, bark_top-2, z), (x+branch, bark_top-2, z), BARK+"[axis=x]")
        b.box((x+branch-1, bark_top-1, z-1), (x+branch+1, bark_top+2, z+1), LEAF)
        b.box((x-1, bark_top+1, z-1), (x+1, 11, z+1), LEAF)
        b.set(x+branch, bark_top-3, z, "hanging_roots")

    # Erase the repeated, ruler-straight dirt cross. Turns in the visible
    # trail do not change physical door locations or combat spawn heights.
    for along in range(1-radius, radius):
        shift = round(math.sin(along * 0.28) * (1 + variant % 2))
        material = "podzol" if (along + variant) % 4 else "rooted_dirt"
        if abs(along) <= 3 or abs(along) >= radius-3:
            shift = 0
        b.box((along, 0, -1), (along, 0, 1), MOSS)
        b.box((-1, 0, along), (1, 0, along), MOSS)
        b.box((along, 0, shift-1), (along, 0, shift+1), material)
        b.box((-shift-1, 0, along), (-shift+1, 0, along), material)

    if kind == "combat":
        if variant == 0:
            for x,z in ((-7,-6),(6,7)):
                b.disk(x, 0, z, 4, 3, "mud")
                b.disk(x, 0, z, 3, 2, "packed_mud")
                b.box((x-2, 1, z), (x+2, 1, z), "stripped_dark_oak_log[axis=x]")
                b.set(x+1, 2, z, "moss_carpet")
                b.set(x-2, 2, z, "brown_mushroom")
        elif variant == 1:
            for x,z in ((-7,6),(7,-6)):
                b.disk(x, 0, z, 4, 3, "mossy_cobblestone")
                b.box((x-1, 1, z), (x+1, 1, z), "tuff_brick_slab")
                b.box((x, 2, z), (x+1, 3, z), "cracked_stone_bricks")
                b.set(x+1, 4, z, "moss_carpet")
        else:
            for x,z in ((-7,-6),(6,7)):
                b.disk(x, 0, z, 4, 3, "podzol")
                for dx, dz, size in ((-2,-1,3),(1,1,2),(2,-2,1)):
                    giant_mushroom(b, x+dx, z+dz, size)


def giant_mushroom(b, x, z, height):
    b.box((x, 1, z), (x, height, z), "mushroom_stem")
    for dx, dz in ((0,0),(1,0),(-1,0),(0,1),(0,-1)):
        b.set(x+dx, height+1, z+dz, "brown_mushroom_block")
    b.set(x, height+2, z, "brown_mushroom_block")


def room_lighting(b, radius):
    # Ceiling sources alone leave the floor and the underside of the canopy
    # in shadow. Distribute light between floor and branches.
    for x, z in product(range(-radius+2, radius-1, 4), repeat=2):
        light(b, x, 2, z)
        light(b, x, 6, z, 14)
    for offset in (-radius+2, -radius+1, radius-1, radius-2):
        for x, z in ((offset, 0), (0, offset)):
            light(b, x, 3, z)


def district(b, kind):
    if kind == "astrology":
        # Copper orrery embedded into a stone terrace. Keep the dais east of
        # the lectern's approach and all four doors open.
        b.disk(-6, 0, -6, 4, 4, TILE)
        b.disk(-6, 0, -6, 3, 3, "polished_tuff")
        for x, z in ((-8,-6),(-4,-6),(-6,-4),(-6,-8)):
            b.set(x, 1, z, "polished_tuff_slab[type=bottom]")
            b.set(x, 0, z, "waxed_weathered_cut_copper")
        b.set(-6, 1, -6, "chiseled_tuff_bricks")
        b.set(-6, 2, -6, "amethyst_block")
        for x,z in ((-9,-6),(-6,-9),(-3,-6),(-6,-3)):
            b.set(x, 1, z, "waxed_oxidized_cut_copper_slab[type=bottom]")
            light(b, x, 2, z, 14)
        b.set(-6, 1, -3, "lectern[facing=south]")
    elif kind == "blackmarket":
        b.box((-8, 0, -8), (-2, 0, -3), "dark_oak_planks")
        b.shell(-8, -2, 1, 1, -8, -3, "polished_blackstone_bricks")
        b.box((-8, 1, -7), (-8, 4, -3), "stripped_dark_oak_log")
        b.box((-7, 1, -8), (-2, 3, -8), "dark_oak_planks")
        for x,z in ((-8,-8),(-2,-8),(-2,-3),(-8,-3)):
            b.box((x, 1, z), (x, 4, z), "dark_oak_log")
        for z in range(-9,-1):
            b.box((-9, 5, z), (-4, 5, z), "dark_oak_slab[type=bottom]")
            b.box((-4, 5, z), (-1, 5, z), "dark_oak_slab[type=top]")
        b.box((-7, 1, -4), (-5, 1, -4), "dark_oak_slab[type=top]")
        b.set(-7, 1, -5, "barrel[facing=up]")
        b.set(-7, 2, -5, "lantern")
        b.set(-5, 1, -7, "chiseled_bookshelf[facing=south]")
        b.set(-6, 1, -7, "chiseled_bookshelf[facing=south]")
        b.set(-5, 2, -7, "candle[candles=3,lit=true]")
        b.set(-3, 1, -3, "spruce_slab[type=bottom]")
        for x,z in ((-3,-5),(-5,-5)):
            light(b,x,3,z)


def event_scene(b, event):
    """Distinct anchored props in the NW inset, with the doorway axes free."""
    if event == 0:  # Traveler's relic
        b.disk(-7, 0, -7, 4, 4, "podzol")
        b.box((-10,1,-9),(-9,3,-7),"mossy_cobblestone")
        b.box((-9,1,-9),(-5,1,-9),"dark_oak_log[axis=x]")
        b.set(-8,2,-9,"moss_carpet")
        b.set(-7,2,-9,"potted_brown_mushroom")
        b.set(-7,1,-7,"barrel[facing=up]")
        b.set(-6,1,-7,"decorated_pot")
        b.set(-8,1,-6,"brown_carpet")
        b.set(-7,1,-6,"brown_carpet")
        b.set(-9,4,-8,"lantern")
    elif event == 1:  # Echo well, with a real recessed water surface and a raised rim
        b.disk(-7, 0, -7, 4, 4, "cobbled_deepslate")
        b.box((-8,-1,-8),(-6,-1,-6),"prismarine_bricks")
        b.box((-8,0,-8),(-6,0,-6),"water")
        b.set(-7,-1,-7,"sea_lantern")
        b.shell(-9,-5,1,1,-9,-5,"mossy_stone_brick_slab[type=bottom]")
        for x in (-9,-5):
            b.box((x,1,-9),(x,4,-9),"stripped_spruce_log")
            b.set(x,5,-9,"dark_oak_slab[type=bottom]")
        b.box((-9,4,-9),(-5,4,-9),"spruce_log[axis=x]")
        b.set(-7,3,-9,"chain[axis=y]")
        b.set(-7,2,-9,"lantern[hanging=true]")
        b.set(-7,0,-4,"waxed_oxidized_cut_copper")
    elif event == 2:  # Bell and broken toll stone
        b.disk(-7, 0, -7, 4, 3, "polished_tuff")
        for x in (-10,-4):
            b.box((x,1,-9),(x,4,-9),TILE)
            b.set(x,5,-9,"chiseled_tuff_bricks")
            b.set(x,1,-8,"tuff_brick_stairs[facing=north]")
        b.box((-10,5,-9),(-4,5,-9),TILE)
        b.box((-9,6,-9),(-5,6,-9),"tuff_brick_slab")
        b.set(-7,4,-9,"bell[attachment=ceiling,facing=south]")
        b.set(-9,1,-7,"mossy_cobblestone_slab")
        b.set(-10,1,-7,"chiseled_tuff_bricks")
        b.set(-10,2,-7,"lantern")
    elif event == 3:  # Cross. Coordinates match the fire-event transition.
        b.disk(-6, 0, -6, 4, 4, "podzol")
        b.box((-8,1,-8),(-4,1,-7),WORN)
        b.box((-6,2,-7),(-6,6,-7),"stripped_dark_oak_log")
        b.box((-8,5,-7),(-4,5,-7),"stripped_dark_oak_log[axis=x]")
        b.box((-6,3,-6),(-6,5,-6),"vine[north=true]")
        b.set(-7,5,-6,"vine[north=true]")
        b.set(-5,5,-6,"vine[north=true]")
        b.set(-8,2,-8,"moss_carpet")
        b.set(-4,2,-8,"lantern")
    elif event == 4:  # Ambush trail through a fallen trunk
        b.disk(-7, 0, -7, 4, 4, "podzol")
        b.box((-10,1,-9),(-4,1,-9),"dark_oak_log[axis=x]")
        b.box((-10,1,-10),(-9,1,-10),LEAF)
        for x,z in ((-9,-7),(-8,-5),(-6,-8),(-5,-5),(-4,-8),(-8,-8)):
            b.set(x,1,z,"fern")
        b.set(-9,2,-9,"moss_carpet")
        b.set(-5,2,-9,"brown_mushroom")
        b.set(-7,0,-5,"rooted_dirt")
        b.set(-7,1,-5,"spruce_button[face=floor,facing=west]")
    elif event == 5:  # Empty cabin, front to the south
        cabin(b)
    elif event == 6:  # Water-damaged medicine chest
        b.disk(-7, 0, -7, 4, 3, "mud")
        b.box((-10,1,-9),(-5,1,-9),"dark_oak_log[axis=x]")
        b.set(-9,2,-9,"moss_carpet")
        b.box((-9,0,-8),(-5,0,-6),"spruce_planks")
        b.set(-7,1,-7,"barrel[facing=up]")
        b.set(-7,2,-7,"white_carpet")
        b.set(-8,1,-7,"mossy_stone_brick_slab")
        b.set(-6,1,-7,"decorated_pot")
        b.set(-9,1,-8,"spruce_fence")
        b.set(-9,2,-8,"lantern")
    elif event == 7:  # Broken trail marker with boards resting against the post
        b.disk(-7, 0, -7, 3, 3, "gravel")
        b.set(-7,1,-8,"mossy_cobblestone_wall")
        b.box((-7,2,-8),(-7,3,-8),"stripped_spruce_log")
        b.set(-7,3,-7,"spruce_wall_sign[facing=south]")
        b.set(-7,3,-9,"spruce_wall_sign[facing=north]")
        b.set(-8,1,-8,"spruce_stairs[facing=east]")
        b.set(-6,1,-8,"spruce_slab")
        b.set(-6,1,-7,"brown_mushroom")
        b.set(-8,1,-7,"polished_tuff_slab[type=bottom]")
        b.set(-8,2,-7,"air")
    elif event == 8:  # Iron casket on a split stone plinth
        b.disk(-7, 0, -7, 4, 3, "polished_tuff")
        b.box((-9,1,-9),(-5,1,-8),"cracked_deepslate_bricks")
        b.box((-8,1,-7),(-6,1,-7),"polished_blackstone_brick_slab")
        b.set(-7,2,-8,"barrel[facing=south]")
        b.set(-8,2,-8,"polished_blackstone_wall")
        b.set(-6,2,-8,"polished_blackstone_wall")
        b.set(-9,2,-9,"lantern")
        b.set(-5,2,-9,"moss_carpet")
    light(b,-8,3,-5)
    light(b,-5,3,-8,14)


def cabin(b):
    b.box((-10,0,-11),(-4,0,-4),TILE)
    b.box((-9,0,-10),(-5,0,-4),SPRUCE)
    b.shell(-10,-4,1,4,-11,-5,SPRUCE)
    for x,z in product((-10,-4),(-11,-5)):
        b.box((x,1,z),(x,4,z),"stripped_spruce_log")
        b.set(x,1,z,WORN)
    for x,z in ((-9,-5),(-5,-5),(-7,-11),(-4,-8)):
        b.set(x,2,z,"brown_stained_glass_pane")
    b.box((-7,1,-5),(-7,2,-5),"air")
    b.set(-7,3,-5,"spruce_stairs[facing=south,half=top]")
    for dep in range(4):
        for x,facing in ((-11+dep,"east"),(-3-dep,"west")):
            b.box((x,4+dep,-12),(x,4+dep,-4),f"dark_oak_stairs[facing={facing}]")
    b.box((-7,8,-12),(-7,8,-4),"dark_oak_slab[type=bottom]")
    for z in (-11,-5):
        for rise in range(3):
            b.box((-9+rise,4+rise,z),(-5-rise,4+rise,z),SPRUCE)
    b.set(-5,1,-10,"bookshelf")
    b.set(-5,2,-10,"bookshelf")
    b.set(-9,1,-10,"barrel[facing=up]")
    b.set(-9,2,-10,"lantern")
    b.set(-9,1,-8,"spruce_stairs[facing=east]")
    b.set(-8,1,-7,"brown_carpet")
    b.set(-6,1,-7,"brown_carpet")
    b.set(-3,2,-7,"spruce_trapdoor[open=true,facing=east,half=top]")
    b.set(-3,2,-9,"spruce_trapdoor[open=true,facing=east,half=top]")
    b.set(-10,1,-4,"potted_fern")
    b.set(-4,1,-4,"potted_brown_mushroom")
    b.set(-7,0,-3,"mossy_cobblestone_slab[type=top]")
    light(b,-7,3,-7)


def corridor(axis, first, last):
    b = forest.Build(relative=True)
    end = forest.PITCH-last
    def point(along, y, across):
        return (along, y, across) if axis == "east" else (across, y, along)

    for a in range(first, end+1):
        edge = a in (first,end)
        curve = round(2 * math.sin(math.pi*(a-first)/(end-first))) if end-first > 3 else 0
        if (first+last+(axis=="east"))%2:
            curve = -curve
        for cross in range(-3,4):
            if not edge:
                if abs(cross-curve) <= 1:
                    floor = "spruce_planks" if (first+last)%3==0 else "packed_mud"
                else:
                    floor = WORN if (a+cross)%3 else "mossy_cobblestone"
                b.set(*point(a,0,cross),floor)
            if cross in (-2,0,2):
                light(b,*point(a,2,cross))
        # One supported branch on alternating sides breaks the repeated
        # corridor silhouette. The seven-wide threshold remains untouched.
        if first+1 < a < end-1 and a%3 == 0:
            side = -1 if a%2 else 1
            b.set(*point(a,0,4*side),"rooted_dirt")
            b.box(point(a,1,4*side),point(a,5,4*side),BARK)
            b.set(*point(a,1,3*side),"mossy_cobblestone_slab")
            b.set(*point(a,5,3*side),BARK)
            b.set(*point(a,5,2*side),LEAF)
    return b.lines


def stage(world):
    from forest_scene import KINDS

    home = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream/function/rogue"
    for kind in KINDS:
        for variant in range(9 if kind == "event" else 3):
            b = forest.Build(relative=True)
            silhouettes(b, forest.radius(kind), kind, variant)
            room_lighting(b, forest.radius(kind))
            path = home/f"shell/{kind}_{variant}.mcfunction"
            old = text(path).replace("minecraft:ochre_froglight[axis=y]\n", "minecraft:lantern\n")
            old = "\n".join(line for line in old.splitlines() if not line.endswith("minecraft:dark_oak_slab[type=bottom]"))
            write(path, old + "\n" + "\n".join(b.lines))
            b = forest.Build(relative=True)
            path = home/f"detail/{kind}_{variant}.mcfunction"
            if kind == "event":
                event_scene(b, variant)
            elif kind in ("astrology","blackmarket"):
                district(b, kind)
            elif kind != "combat":
                b.lines.extend(text(path).splitlines())
            if b.lines:
                write(path, "\n".join(b.lines))
            else:
                # The combat relief belongs to the forest shell. Preserve
                # a valid no-op for the first-admission furnishing hook.
                write(path, "# The forest already provides combat terrain.")
    for axis, first, last in product(("east","south"),forest.RADII,forest.RADII):
        path = home/f"corridors/{axis}_{first}_{last}.mcfunction"
        old = text(path).replace("minecraft:shroomlight\n", f"minecraft:{LEAF}\n")
        write(path, old + "\n".join(corridor(axis, first, last)))
    for kind, (ink, pattern) in ICONS.items():
        b = forest.Build(relative=True)
        b.box((-6,0,-6),(7,0,7),"black_concrete")
        for z, row in enumerate(pattern, -2):
            for x, pixel in enumerate(row, -2):
                if pixel == "#":
                    b.box((2*x,0,2*z),(2*x+1,0,2*z+1),ink+"_concrete")
        write(home/f"canvas/icon_{kind}.mcfunction", "\n".join(b.lines))
