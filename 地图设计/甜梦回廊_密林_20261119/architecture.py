"""Author the lobby and every room and corridor used by the Forest floor."""
import json
import math
import random
from pathlib import Path

HERE = Path(__file__).resolve().parent
PACK = HERE / "floor_pack/data"
FLOOR = PACK / "sweetdream_floor/function"
ROGUE = PACK / "sweetdream/function/rogue"

STONE = "tuff_bricks"
WORN = "mossy_stone_bricks"
BARK = "dark_oak_log"
LEAVES = "dark_oak_leaves[persistent=true]"
PALE_LEAVES = "azalea_leaves[persistent=true]"
MOSS = "moss_block"
PATH = "coarse_dirt"
PITCH = 36
RADII = (13, 14, 17)
DOOR_HALF = 3
ENTRY_Z = 2 * PITCH


def radius(kind):
    return {"boss": RADII[2], "elite": RADII[1]}.get(kind, RADII[0])


def write(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(rows) + "\n", encoding="utf-8")


class Build:
    def __init__(self, relative=False):
        self.lines = []
        self.relative = relative

    def pos(self, *coords):
        if self.relative:
            return " ".join(f"~{value or ''}" for value in coords)
        return " ".join(map(str, coords))

    def box(self, a, b, material):
        self.lines.append(f"fill {self.pos(*a)} {self.pos(*b)} minecraft:{material}")

    def set(self, x, y, z, material):
        self.lines.append(f"setblock {self.pos(x, y, z)} minecraft:{material}")

    def disk(self, x, y, z, rx, rz, material):
        for offset in range(-rz, rz + 1):
            half = int(rx * math.sqrt(max(0, 1 - (offset / rz) ** 2)))
            self.box((x-half, y, z+offset), (x+half, y, z+offset), material)

    def shell(self, x0, x1, y0, y1, z0, z1, material):
        self.box((x0, y0, z0), (x1, y1, z0), material)
        self.box((x0, y0, z1), (x1, y1, z1), material)
        self.box((x0, y0, z0), (x0, y1, z1), material)
        self.box((x1, y0, z0), (x1, y1, z1), material)

    def oak(self, x, y, z, h, canopy=3, leaves=LEAVES, thick=False):
        # Flat-sided leaves taper across three elevations, with the branch visible from below.
        if thick:
            self.box((x, y, z), (x+1, y+h-1, z+1), BARK)
        else:
            self.box((x, y, z), (x, y+h, z), BARK)
        self.box((x-canopy+1, y+h-3, z-1), (x+canopy-1, y+h-3, z-1), BARK + "[axis=x]")
        self.box((x-canopy, y+h-2, z-canopy+1), (x+canopy, y+h-1, z+canopy-1), leaves)
        self.box((x-canopy+1, y+h-2, z-canopy), (x+canopy-1, y+h-1, z+canopy), leaves)
        self.box((x-canopy+1, y+h, z-canopy+1), (x+canopy-1, y+h+1, z+canopy-1), leaves)
        self.box((x-1, y+h+2, z-1), (x+1, y+h+2, z+1), leaves)

    def label(self, position, text, color, scale=1):
        component = json.dumps({"text": text, "color": color, "bold": True}, ensure_ascii=False, separators=(",", ":"))
        self.lines.append(
            f'summon minecraft:text_display {self.pos(*position)} '
            f'{{Tags:["sd.floor_lobby_display"],billboard:"center",background:0,text:{component},'
            f'transformation:{{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],'
            f'scale:[{scale}f,{scale}f,{scale}f],right_rotation:[0f,0f,0f,1f]}}}}'
        )


def lamp(b, x, z, base="mossy_cobblestone_wall"):
    b.set(x, 1, z, base)
    b.set(x, 2, z, "ochre_froglight[axis=y]")
    b.set(x, 3, z, "dark_oak_slab[type=bottom]")


def waystone(b, x, z, height=3, stem=STONE, top="chiseled_tuff_bricks"):
    b.set(x, 1, z, WORN)
    b.box((x, 2, z), (x, height, z), stem)
    b.set(x, height+1, z, top)


def room_feature(b, kind, variant):
    if kind == "entry":
        # Opaque rear ruin with a traversable aisle through its opening.
        for z in (-5, 5):
            waystone(b, -6, z, 5, "chiseled_tuff", "ochre_froglight[axis=y]")
        b.box((-6, 6, -5), (-6, 6, 5), WORN)
        b.box((-6, 7, -3), (-6, 7, 3), STONE)
        for x in (-3, -1, 1, 3):
            b.set(x, 0, 0, WORN)
    elif kind == "combat":
        if variant == 0:
            for x, z in ((-6, -5),(5, -6),(-6, 5),(6, 6)):
                b.box((x, 1, z), (x+1, 2, z+1), "stripped_spruce_log")
                b.set(x, 3, z, MOSS)
        elif variant == 1:
            for x, z in ((-6,-5),(6,-6),(-6,6),(5,6)):
                waystone(b, x, z, 2, "mossy_cobblestone", STONE)
                b.set(x+1, 1, z, "mossy_cobblestone_slab")
        else:
            for x, z in ((-6,-6),(5,-6),(-6,6),(6,6)):
                b.box((x, 1, z), (x+1, 2, z+1), "brown_mushroom_block")
                b.set(x, 3, z, "red_mushroom")
    elif kind == "elite":
        b.disk(0, 0, 0, 6, 6, "packed_mud")
        b.disk(0, 0, 0, 4, 4, "mud_bricks")
        for x in (-7,7):
            for z in (-6,6):
                waystone(b, x, z, 5, "tuff_bricks", "shroomlight")
                b.set(x, 6, z+1, "rooted_dirt")
    elif kind == "boss":
        b.disk(0, 0, 0, 9, 9, WORN)
        b.disk(0, 0, 0, 8, 8, "deepslate_tiles")
        b.disk(0, 0, 0, 5, 5, "polished_tuff")
        for d in range(-4,5):
            b.set(d, 0, d, "oxidized_cut_copper")
            b.set(d, 0, -d, "oxidized_cut_copper")
        for x, z in ((-8,-7),(8,-7),(-8,7),(8,7)):
            b.box((x-1, 1, z-1), (x+1, 2, z+1), STONE)
            for off in (-1,1):
                waystone(b, x+off, z, 6, "cracked_deepslate_bricks", "shroomlight")
            b.box((x-1, 8, z), (x+1, 9, z), "deepslate_tiles")
        for x in (-7,7):
            b.box((x, 1, -4), (x, 1, 4), "mossy_stone_brick_slab")
            b.set(x, 1, 0, "verdant_froglight[axis=y]")
        # The Knight faces the player in front of a broken, root-covered shrine gate.
        for x in (-5,5):
            b.box((x-1, 1, -9), (x+1, 2, -7), WORN)
            b.box((x, 3, -8), (x, 7, -8), "cracked_deepslate_bricks")
            b.set(x, 6, -7, "chiseled_deepslate")
            b.set(x, 7, -7, "verdant_froglight[axis=y]")
        b.box((-5, 8, -8), (-2, 8, -8), "deepslate_tiles")
        b.box((-3, 9, -8), (1, 9, -8), "deepslate_tiles")
        b.box((2, 8, -8), (5, 8, -8), "cracked_deepslate_bricks")
        b.box((-6, 10, -9), (-2, 10, -8), "dark_oak_log[axis=x]")
        b.box((-6, 11, -10), (-3, 11, -7), LEAVES)
        b.set(-3, 10, -7, "hanging_roots")
    elif kind == "safe":
        # A quiet shelter and a shallow spring away from the through-paths.
        b.box((-6, 0, -6), (-2, 0, -2), "mud_bricks")
        b.box((-5, 0, -5), (-3, 0, -3), "water")
        for x,z in ((-6,-6),(-6,-2),(-2,-6),(-2,-2)):
            b.box((x, 1, z), (x, 4, z), "spruce_fence")
        b.box((-7, 5, -7), (-1, 5, -1), "spruce_slab[type=top]")
        b.set(-4, 4, -4, "shroomlight")
        b.set(-4, 1, 3, "campfire[lit=true,signal_fire=false]")
        b.box((-6, 1, 3), (-6, 1, 5), "spruce_stairs[facing=east]")
    elif kind in ("merchant", "rental", "blackmarket"):
        palette = {
            "merchant": ("orange_wool","barrel[facing=south]"),
            "rental": ("light_blue_wool","loom"),
            "blackmarket": ("purple_wool","chiseled_bookshelf[facing=south]"),
        }
        canvas, stock = palette[kind]
        b.box((-5, 1, -6), (-5, 1, -2), "stripped_spruce_log[axis=z]")
        for z in (-6,-2):
            b.box((-5, 2, z), (-5, 5, z), "spruce_fence")
        for z in range(-7, 0):
            b.box((-7, 5, z), (-3, 5, z), canvas if z % 2 else "brown_wool")
        b.box((-6, 1, -5), (-6, 1, -3), stock)
        b.set(-5, 2, -5, "shroomlight")
        b.set(-5, 2, -3, "verdant_froglight" if kind == "blackmarket" else "shroomlight")
        for z in (5,6):
            b.set(-5, 1, z, "spruce_trapdoor[half=top]")
    elif kind == "forge":
        b.box((-6, 0, -7), (6, 0, -3), "polished_blackstone")
        b.box((-4, 1, -6), (4, 1, -6), "deepslate_bricks")
        b.set(-4, 2, -6, "blast_furnace[facing=south,lit=true]")
        b.set(0, 1, -5, "smithing_table")
        b.set(3, 2, -6, "anvil[facing=east]")
        b.box((-4, 3, -7), (-4, 8, -7), "deepslate_brick_wall")
        b.box((4, 2, -6), (4, 5, -6), "polished_blackstone_bricks")
        b.set(-6, 1, -4, "campfire")
    elif kind == "astrology":
        b.disk(0, 0, -2, 5, 5, "blue_terracotta")
        for x,z in ((-4,-6),(4,-6),(-4,4),(4,5)):
            waystone(b, x, z, 3, "polished_tuff", "amethyst_block")
            b.set(x, 5, z, "end_rod")
        for x,z in ((-2,-1),(0,-3),(2,1),(3,-4),(-3,2),(0,0)):
            b.set(x, 0, z, "pearlescent_froglight[axis=y]")
    elif kind == "gamble":
        b.box((-6, 0, 3), (-1, 0, 7), "purple_terracotta")
        b.box((-5, 1, 4), (-2, 1, 6), "dark_oak_planks")
        b.box((-4, 2, 5), (-3, 2, 5), "purple_carpet")
        b.set(-5, 2, 4, "candle[candles=3,lit=true]")
        b.set(-2, 2, 6, "yellow_candle[candles=2,lit=true]")
        b.box((-7, 1, 5), (-7, 1, 6), "dark_oak_stairs[facing=east]")
    elif kind == "event":
        # Keep every approach and the whole room center open. Build the scene in an inset.
        if variant == 0:
            b.disk(-6, 0, -5, 4, 4, WORN)
            b.box((-8, 1, -7), (-5, 1, -5), "stripped_dark_oak_log[axis=x]")
            b.set(-7, 2, -6, "decorated_pot")
            b.set(-6, 2, -6, "barrel[facing=up]")
            b.set(-5, 2, -5, "moss_carpet")
            b.box((-9, 1, -8), (-9, 4, -7), "mossy_cobblestone")
            b.set(-9, 5, -8, "shroomlight")
        elif variant == 1:
            b.disk(-6, 0, -6, 4, 4, STONE)
            b.shell(-8,-4,1,1,-8,-4,"mossy_stone_brick_wall")
            b.box((-7, 0, -7), (-5, 0, -5), "water")
            b.set(-6, -1, -6, "sea_lantern")
            b.box((-8, 2, -8), (-8, 4, -8), "spruce_fence")
            b.box((-4, 2, -8), (-4, 4, -8), "spruce_fence")
            b.box((-9, 5, -9), (-3, 5, -7), "spruce_slab[type=bottom]")
        elif variant == 2:
            b.disk(-6, 0, -5, 4, 4, "oxidized_cut_copper")
            b.box((-9, 1, -7), (-9, 5, -7), "polished_tuff")
            b.box((-3, 1, -7), (-3, 5, -7), "polished_tuff")
            b.box((-9, 6, -7), (-3, 6, -7), WORN)
            b.set(-6, 5, -7, "bell[attachment=ceiling,facing=south]")
            b.set(-6, 6, -7, "shroomlight")
        elif variant == 3:
            b.disk(-6, 0, -6, 4, 4, "moss_block")
            b.box((-7, 1, -7), (-5, 1, -7), "mossy_cobblestone")
            b.box((-6, 2, -7), (-6, 6, -7), "stripped_dark_oak_log[axis=y]")
            b.box((-8, 5, -7), (-4, 5, -7), "stripped_dark_oak_log[axis=x]")
            b.box((-6, 2, -6), (-6, 5, -6), "vine[north=true]")
            b.set(-7, 5, -6, "vine[north=true]")
            b.set(-8, 1, -5, "moss_carpet")
            lamp(b, -9, -8)
        elif variant == 4:
            b.disk(-6, 0, -6, 4, 4, "podzol")
            for x,z in ((-8,-7),(-7,-5),(-5,-8),(-4,-6)):
                b.set(x, 1, z, "fern")
            b.box((-8, 1, -8), (-5, 1, -8), "dark_oak_leaves[persistent=true]")
            b.set(-7, 2, -8, "lantern")
        elif variant == 5:
            b.box((-10, 0, -9), (-4, 0, -4), "spruce_planks")
            for x in (-10,-4):
                for z in (-9,-4):
                    b.box((x,1,z),(x,3,z), "stripped_spruce_log")
            b.box((-10,1,-9),(-4,3,-9),"spruce_planks")
            b.box((-11,4,-10),(-3,4,-4),"dark_oak_slab[type=top]")
            b.set(-8,1,-7,"barrel[facing=up]")
            b.set(-7,1,-7,"crafting_table")
            b.set(-7,2,-7,"lantern")
        elif variant == 6:
            b.disk(-6, 0, -6, 3, 3, "coarse_dirt")
            b.set(-7,1,-7,"barrel[facing=up]")
            b.set(-6,1,-7,"mossy_cobblestone")
            b.set(-6,2,-7,"flower_pot")
            b.set(-7,1,-6,"white_carpet")
            b.set(-8,1,-6,"blue_carpet")
            lamp(b,-9,-8)
        elif variant == 7:
            b.disk(-6, 0, -6, 3, 3, "gravel")
            b.box((-7,1,-7),(-7,3,-7),"dark_oak_fence")
            b.set(-7,3,-6,"spruce_wall_sign[facing=south]")
            b.set(-6,1,-6,"spruce_trapdoor[open=false,half=bottom]")
            b.set(-8,1,-7,"lantern")
        elif variant == 8:
            b.disk(-6, 0, -6, 3, 3, "polished_tuff")
            b.set(-7,1,-7,"chiseled_tuff_bricks")
            b.set(-7,2,-7,"heavy_weighted_pressure_plate")
            b.set(-6,1,-7,"barrel[facing=south]")
            b.set(-7,1,-6,"polished_tuff_slab")
            b.set(-8,1,-7,"lantern")


def forest_canopy(b, r, variant):
    # Overlapping crowns rise toward the clearing. The lower edge meets roots and
    # trunks, while the four door lintels can still be carved by corridor().
    def height(x, z):
        return 11 + round(1.2 * math.cos((x + variant * 2) / 3.6)
                          + 1.2 * math.sin((z - variant * 3) / 4.7)
                          + 1.2 * (1 - max(abs(x), abs(z)) / r))

    for x in range(-r, r+1, 2):
        for z in range(-r, r+1, 2):
            y = height(x, z)
            xx, zz = min(r, x+1), min(r, z+1)
            leaves = PALE_LEAVES if math.sin((x+z+variant*4)/5) > 0.7 else LEAVES
            b.box((x, y, z), (xx, y+2, zz), leaves)
            # Double depth at the rim avoids a skyline slit above the enclosure.
            if min(x+r, r-xx, z+r, r-zz) <= 1:
                b.box((x, 6, z), (xx, y-1, zz), leaves)

    for side in (-1, 1):
        for offset in (-r+3, -r+7, r-7, r-3):
            for x, z in ((offset, side*(r-1)), (side*(r-1), offset)):
                top = height(x-(x+r)%2, z-(z+r)%2) + 1
                b.box((x, 1, z), (x, top, z), BARK)
                dx, dz = (0, -side) if abs(z) > abs(x) else (-side, 0)
                b.set(x+dx, 1, z+dz, "mangrove_roots")
                branch_y = 9 if offset < 0 else 10
                axis = "x" if dx else "z"
                b.box((x, branch_y, z), (x+3*dx, branch_y, z+3*dz), f"{BARK}[axis={axis}]")
                b.box((x+2*dx, branch_y+1, z+2*dz),
                      (x+3*dx, max(branch_y+1, top), z+3*dz), LEAVES)
                if (offset + variant) % 3 == 0:
                    b.set(x+3*dx, branch_y-1, z+3*dz, "hanging_roots")


def room_parts(kind, variant):
    b = Build(relative=True)
    rng = random.Random(f"floor-forest:{kind}:{variant}")
    r = radius(kind)
    b.box((-r, -1, -r), (r, -1, r), "rooted_dirt")
    b.box((-r, 0, -r), (r, 0, r), MOSS)
    # Scattered patches are clipped to keep the perimeter threshold detector exact.
    for _ in range(r*8):
        x, z = rng.randint(1-r,r-1), rng.randint(1-r,r-1)
        b.set(x, 0, z, rng.choice(("podzol",PATH,"mossy_cobblestone","rooted_dirt")))
    b.box((1-r, 0, -1), (r-1, 0, 1), PATH)
    b.box((-1, 0, 1-r), (1, 0, r-1), PATH)
    b.shell(-r,r,1,1,-r,r,"mossy_cobblestone")
    b.shell(-r,r,2,2,-r,r,MOSS)
    b.shell(-r,r,3,5,-r,r,LEAVES)
    forest_canopy(b, r, variant)
    # Root banks and lights belong to the forest, including in unentered rooms.
    for side in (-1,1):
        for offset in (-r+2,-r+4,r-4,r-2):
            for x,z in ((offset,side*(r-1)),(side*(r-1),offset)):
                b.set(x, 1, z, rng.choice((MOSS,"mossy_cobblestone","rooted_dirt")))
                b.set(x, 2, z, rng.choice(("fern","short_grass","air","brown_mushroom")))
                wall_x,wall_z = (side*r,z) if abs(x)>abs(z) else (x,side*r)
                b.set(wall_x, 1, wall_z, rng.choice((MOSS,"rooted_dirt","mossy_cobblestone")))
    for x,z in ((-r+3,-3),(r-3,3),(-3,r-3),(3,-r+3)):
        lamp(b,x,z)
    for px in range(-r+2,r-1,5):
        for pz in range(-r+2,r-1,5):
            b.lines.append(f"setblock {b.pos(px,3,pz)} minecraft:light[level=15] keep")
    shell=b.lines
    b=Build(relative=True)
    for x,z in ((-8,-4),(8,4),(-4,8),(4,-8)):
        if kind in ("combat", "elite"):
            b.box((x,1,z),(x+1,1,z+1),"mossy_cobblestone_slab")
            b.set(x+1,2,z+1,"fern")
    room_feature(b,kind,variant)
    return shell,b.lines


def room(kind, variant):
    shell,detail=room_parts(kind,variant)
    return shell+detail


def corridor(axis, first, second):
    b = Build(relative=True)
    end = PITCH-second
    width = DOOR_HALF

    def corner(along, y, across):
        return (along,y,across) if axis=="east" else (across,y,along)

    def box(a, y0, width0, end_pos, y1, width1, mat):
        b.box(corner(a,y0,width0),corner(end_pos,y1,width1),mat)

    box(first,-1,-width-1,end,0,width+1,"rooted_dirt")
    box(first,0,-width,end,0,width,WORN)
    box(first,1,-width,end,5,width,"air")
    if first+1 <= end-1:
        for side in (-width-1,width+1):
            box(first+1,1,side,end-1,2,side,"mossy_cobblestone")
            box(first+1,3,side,end-1,6,side,LEAVES)
        box(first+1,6,-width-1,end-1,6,width+1,LEAVES)
        box(first+1,0,-1,end-1,0,1,"spruce_planks")
    for position in sorted({first,end}):
        box(position,1,-width-1,position,5,-width-1,"stripped_dark_oak_log")
        box(position,1,width+1,position,5,width+1,"stripped_dark_oak_log")
        box(position,6,-width-1,position,6,width+1,"dark_oak_log[axis=" + ("z" if axis=="east" else "x") + "]")
        # The light sits above the aperture, leaving the whole door clear.
        b.set(*corner(position,6,0),"shroomlight")
        for side in (-1,1):
            b.set(*corner(position,7,side*(width-1)), "moss_block")
            b.set(*corner(position,7,side*width),"mangrove_roots")
            b.set(*corner(position,6,side*(width+1)),"mossy_cobblestone")
        box(position,8,-width,position,8,width,PALE_LEAVES)
    return b.lines


def landscape():
    b = Build()
    rng = random.Random("Forest panorama")
    for x in range(-24, 172, 2):
        near = -24 + round(1 + math.sin(x/6))
        far = 170 + round(math.sin(x/9))
        shoulder = 5 if x < -18 or x > 158 else 2
        b.box((x,70,near+5),(x+1,73,far-5),"tuff")
        b.box((x,74,near+shoulder),(x+1,75,far-shoulder),"tuff")
        b.box((x,76,near),(x+1,77,far),"rooted_dirt")
        b.box((x,78,near),(x+1,78,far),MOSS)
    # Outer grove. Lower terrain stays below the original room cleanup range.
    for x,z in [(x,z) for x in range(-19,170,8) for z in (-21,162,168)] + [
        (x,z) for x in (-21,163,168) for z in range(-9,157,8)
    ]:
        b.oak(x,79,z,rng.randint(12,17),canopy=rng.choice((2,3)),thick=x not in (-21,168) and z < 168,
              leaves=rng.choice((LEAVES,LEAVES,PALE_LEAVES)))
        b.set(x-1,79,z+2,rng.choice(("fern","short_grass","brown_mushroom")))
    write(FLOOR / "forest/landscape.mcfunction", b.lines)
    write(FLOOR / "forest/biome.mcfunction", [
        *(f"fillbiome {x} 76 -24 {x+3} 103 171 minecraft:dark_forest" for x in range(-24,172,4)),
        "data modify storage sweetdream_floor:run forest_biome set value 1b",
    ])


def understory():
    # Fill unselected cells with scenery. All blocks that can affect a future layout
    # are under the existing cleanup ceiling, and stay inside the unused cell.
    dispatch = []
    for index in range(25):
        x,z = index%5*PITCH,index//5*PITCH
        variant = index % 4
        dispatch.append(
            f'execute if data storage zx:rogue floor.cells[{{cell:{index},present:0b}}] '
            f'positioned {x} 79 {z} run function sweetdream_floor:forest/understory_{variant}'
        )
    write(FLOOR / "forest/understory.mcfunction",dispatch)
    for variant in range(4):
        b = Build(relative=True)
        rng = random.Random(207+variant)
        b.disk(-2,0,0,12,12,"rooted_dirt")
        b.disk(-3,1,1,8,8,MOSS)
        b.disk(-2,2,1,6,6,MOSS)
        b.disk(4,0,2,8,8,MOSS)
        for x,y,z in ((-5,1,-4),(3,0,-5),(-3,3,2),(5,1,4),(-5,1,5)):
            b.oak(x,y,z,rng.choice((8,9,10)),canopy=rng.choice((2,3)),thick=variant%2==0,
                  leaves=rng.choice((LEAVES,LEAVES,PALE_LEAVES)))
        for x,z in ((-4,-1),(2,1),(5,-2),(-6,3),(4,6)):
            b.box((x,0,z),(x,2,z),"mossy_cobblestone")
            b.set(x,3,z,rng.choice(("azalea","fern","brown_mushroom")))
        write(FLOOR / f"forest/understory_{variant}.mcfunction",b.lines)


def main():
    landscape()
    understory()
    for kind in ("entry","combat","elite","boss","safe","merchant","rental","blackmarket","forge","astrology","gamble","event"):
        for variant in range(3):
            write(ROGUE / f"rooms/{kind}_{variant}.mcfunction", room(kind,variant))
    for axis in ("east","south"):
        for first in RADII:
            for second in RADII:
                write(ROGUE / f"corridors/{axis}_{first}_{second}.mcfunction",corridor(axis,first,second))


if __name__ == "__main__":
    main()
