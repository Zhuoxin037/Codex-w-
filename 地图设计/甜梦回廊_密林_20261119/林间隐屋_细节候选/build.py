"""Joinery, weathering and furnishings for the approved stepped cabin."""

from pathlib import Path
import math
import runpy

HERE = Path(__file__).resolve().parent
house = runpy.run_path(str(HERE.parent / "林间隐屋_错层候选" / "build.py"))
Build, course, rug, trestle, write = (house[key] for key in ("Build", "course", "rug", "trestle", "write"))
UPPER_FLOOR = house["UPPER_FLOOR"]
LOWER_ENTRY = house["LOWER_ENTRY"]
PADS = ((1, 16), house["PADS"][1])
DOORS = house["DOORS"]
DOOR_Z = house["DOOR_Z"]
SIDE_FRONT = house["SIDE_FRONT"]
trail_x = house["trail_x"]
WINDOWS = (
    ("south", 7, 2, 79), ("north", -8, -2, 79),
    ("south", 4, -9, 79), ("west", -12, 0, 79),
    ("south", SIDE_FRONT, 10, 79), ("east", 13, 1, 79),
    ("south", 8, -4, 85), ("south", 7, 2, 85),
    ("north", -8, 0, 85), ("east", 6, -4, 85),
)


def tent_panels():
    rise, run = 2.9, 2.6
    angle = math.atan2(rise, run)
    length = math.hypot(run, rise)
    sides = ((3.9, 78.35, angle), (6.5, 81.25, -angle))
    strips = ((13.35, .18, "brown_wool"),
              (13.53, 5.02, "light_gray_wool"),
              (18.55, .18, "brown_wool"))
    canvas = tuple(((x, y, z), (length, .11, depth), yaw, material)
                   for x, y, yaw in sides for z, depth, material in strips)
    seam = ((6.41, 81.295, 13.35), (.18, .065, 5.38), 0, "brown_wool")
    return canvas + (seam,)


TENT_PANELS = tent_panels()


def recessed_windows(b):
    for face, wall, center, bottom in WINDOWS:
        front = face in ("south", "north")
        outward = 1 if face in ("south", "east") else -1
        connections = "east=true,west=true" if front else "north=true,south=true"

        def place(u, y, depth, material):
            v = wall + outward * depth
            pos = (u, y, v) if front else (v, y, u)
            b.set(*pos, material)

        for i, u in enumerate(range(center - 1, center + 2)):
            for row in range(2):
                tint = "orange" if (i + row) % 3 == 1 else "brown"
                place(u, bottom + row, 0, tint + "_stained_glass_pane[" + connections + "]")
            cap = "dark_oak_slab[type=top]" if i == 1 else "spruce_stairs[half=top,facing=" + face + "]"
            place(u, bottom + 2, 1, cap)
        for u in (center - 2, center + 2):
            for y in (bottom, bottom + 1):
                place(u, y, 1, "spruce_trapdoor[open=true,facing=" + face + "]")
        place(center, bottom - 1, 1, "spruce_slab[type=top]")


def door_and_gable(b):
    for x, direction in ((-5, "west"), (-4, "east")):
        b.set(x, 81, 7, "spruce_stairs[half=top,facing=" + direction + "]")
        b.set(x, 81, 6, "dark_oak_planks")
    for x in (-6, -3):
        b.set(x, 79, 8, "dark_oak_button[face=wall,facing=south]")
        b.set(x, 80, 7, "stripped_dark_oak_log")
    for x, direction in ((-7, "east"), (-2, "west")):
        b.set(x, 82, 8, "dark_oak_stairs[half=top,facing=" + direction + "]")
    # Thin trim around the vent and exposed joints between the posts and wall boards.
    b.set(1, 90, 8, "dark_oak_trapdoor[open=true,facing=south]")
    b.set(1, 89, 8, "spruce_slab[type=top]")
    b.set(1, 91, 8, "spruce_slab[type=bottom]")
    for x, y in ((-2, 89), (4, 89)):
        b.set(x, y, 8, "spruce_trapdoor[open=true,facing=south]")
    for x, y, z in ((0, 82, 8), (4, 82, 8), (13, 81, SIDE_FRONT + 1)):
        b.set(x, y, z, "dark_oak_button[face=wall,facing=south]")
    for x in (1, 2, 3):
        b.set(x, 84, 10, "dark_oak_trapdoor[open=true,facing=south]")
    b.set(2, 85, 9, "potted_azure_bluet")


def roof_repairs(b):
    # Keep each tile at its approved height and pitch. Moss stays at the damp footings.
    heights = house["MAIN_ROOF"]
    for x, z in ((-7,2), (-7,3), (-8,2), (7,-6), (7,-5), (8,-5)):
        b.set(x, heights[x] + 1, z, "air")
    for x, y, z in ((12,87,1), (12,87,2), (13,86,2), (13,86,3)):
        b.set(x, y, z, "air")
    for x, z in ((-6,-3), (-6,-2), (-5,-2), (5,3), (5,4), (6,4)):
        y = heights[x]
        toward_ridge = x + (1 if x < 1 else -1)
        face = "east" if x < 1 else "west"
        material = ("spruce_stairs[facing=" + face + "]" if heights[toward_ridge] > y
                    else "spruce_slab[type=bottom]")
        b.set(x, y, z, material)


def weathered_footing(b):
    for x, y, z, material in (
        (-11, 78, 4, "mossy_cobblestone"), (-12, 78, 4, "cracked_stone_bricks"),
        (-6, 78, 7, "mossy_stone_bricks"), (-3, 78, 7, "cobblestone"),
        (0, 78, 7, "mossy_cobblestone"), (4, 78, 7, "cobbled_deepslate"),
        (5, 78, 7, "mossy_stone_bricks"), (8, 78, SIDE_FRONT, "mossy_cobblestone"),
        (9, 78, SIDE_FRONT, "cracked_stone_bricks"), (12, 79, SIDE_FRONT, "andesite"),
        (13, 78, SIDE_FRONT, "mossy_stone_bricks"),
    ):
        b.set(x, y, z, material)
    for x in (-6, -4):
        b.set(x, 77, 11, "mossy_stone_brick_stairs[facing=north]")
    b.set(-6, 77, 8, "cracked_stone_bricks")
    b.set(-6, 78, 10, "moss_carpet")
    b.set(-3, 78, 8, "moss_carpet")
    for x, low, high, z in ((-12, 78, 81, 5), (5, 79, 82, 8), (12, 78, 80, SIDE_FRONT + 1)):
        b.box((x, low, z), (x, high, z), "vine[north=true]")
    b.set(-10, 77, 6, "moss_block")
    b.set(-10, 78, 6, "flowering_azalea_leaves[persistent=true]")
    b.set(-9, 77, 6, "moss_block")
    b.set(-9, 78, 6, "fern")
    course(b, 77, -10, -9, 7, 7, "spruce_trapdoor[open=true,facing=south]")


def terrace(b):
    for x in (-11, -10, -8):
        b.set(x, 83, 6, "spruce_trapdoor[open=true,facing=south]")
    for x, z in ((-12, 5), (-7, 5), (-12, -6), (-7, -6)):
        b.set(x, 85, z, "dark_oak_slab[type=bottom]")
    b.set(-11, 85, 3, "potted_cornflower")
    b.set(-8, 85, -5, "potted_azure_bluet")
    # Low furniture keeps the walk-out from the main room open.
    b.set(-8, 84, 2, "air")
    for x in (-10, -9):
        b.set(x, 84, 2, "spruce_fence")
        b.set(x, 85, 2, "spruce_pressure_plate")
    b.set(-11, 84, 2, "spruce_stairs[facing=west]")
    b.set(-11, 84, 0, "spruce_trapdoor[open=true,facing=north]")
    course(b, 85, -7, -7, 1, 2, "dark_oak_slab[type=top]")
    b.set(-7, 86, 1, "potted_fern")
    b.set(-7, 86, 2, "flower_pot")


def hearth(b):
    b.box((-12, 78, -5), (-9, 81, -3), "tuff_bricks")
    b.box((-11, 78, -4), (-10, 79, -4), "bricks")
    course(b, 79, -11, -10, -3, -3, "air")
    course(b, 78, -11, -10, -3, -3, "campfire[lit=true,facing=south]")
    b.set(-12, 78, -3, "mossy_stone_bricks")
    b.set(-9, 79, -3, "cracked_stone_bricks")
    course(b, 80, -12, -9, -2, -2, "dark_oak_slab[type=top]")
    course(b, 82, -11, -6, -5, -5, "tuff_bricks")
    b.set(-12, 81, -2, "potted_azure_bluet")
    b.set(-9, 81, -2, "brown_candle[candles=2,lit=true]")
    course(b, 78, -12, -9, -2, -2, "polished_andesite_slab[type=bottom]")
    b.set(-12, 79, -2, "spruce_stairs[half=top,facing=south]")
    b.set(-9, 79, -2, "spruce_stairs[half=top,facing=south]")
    course(b, 78, -9, -7, -1, 2, "brown_carpet")
    course(b, 78, -9, -7, 0, 1, "gray_carpet")
    b.set(-8, 79, -2, "air")
    trestle(b, 78, -9, -7, 0, 0)
    b.set(-8, 79, 0, "brown_candle[candles=2,lit=true]")
    course(b, 78, -7, -7, -4, -3, "spruce_stairs[facing=east]")
    b.set(-7, 78, -5, "dark_oak_trapdoor[open=true,facing=north]")
    course(b, 78, -8, -7, 2, 2, "spruce_stairs[facing=south]")
    b.set(-9, 78, 2, "dark_oak_trapdoor[open=true,facing=east]")
    b.set(-11, 79, 3, "potted_fern")
    b.set(-11, 78, 3, "barrel[facing=up]")
    course(b, 77, -11, -10, 0, 1, "spruce_planks")
    course(b, 78, -11, -10, 0, 1, "air")


def shelves_and_textiles(b):
    b.set(-3, 78, -7, "barrel[facing=south]")
    b.set(-2, 79, -7, "chiseled_bookshelf[facing=south,slot_0_occupied=true,slot_4_occupied=true]")
    b.set(1, 79, -7, "chiseled_bookshelf[facing=south,slot_1_occupied=true,slot_2_occupied=true,slot_5_occupied=true]")
    course(b, 80, -3, 2, -7, -7, "spruce_slab[type=bottom]")
    b.set(3, 79, -7, "potted_fern")
    b.set(9, 79, -2, "chiseled_bookshelf[facing=south,slot_0_occupied=true,slot_3_occupied=true]")
    b.set(11, 78, -2, "barrel[facing=south]")
    b.set(11, 80, -2, "chiseled_bookshelf[facing=south,slot_1_occupied=true,slot_3_occupied=true,slot_5_occupied=true]")
    course(b, 81, 9, 12, -2, -2, "dark_oak_slab[type=bottom]")
    b.set(5, 85, -3, "chiseled_bookshelf[facing=west,slot_1_occupied=true,slot_5_occupied=true]")
    b.set(5, 84, -6, "barrel[facing=west]")
    for x, z in ((-4, 1), (-2, 1), (-4, 3), (-2, 3)):
        b.set(x, 78, z, "light_gray_carpet")
    b.set(-3, 78, 2, "brown_carpet")
    for x, z in ((-3, 4), (-1, 3), (-1, 5), (1, 4)):
        b.set(x, 84, z, "light_gray_carpet")
    b.set(-1, 84, 4, "brown_carpet")


def stair_storage(b):
    # Drawers fit beneath the risers and face the main hall.
    b.set(2, 78, -1, "barrel[facing=east]")
    b.set(2, 78, -2, "chiseled_bookshelf[facing=east,slot_0_occupied=true,slot_2_occupied=true]")
    b.set(2, 79, -2, "barrel[facing=east]")
    b.set(2, 78, -3, "barrel[facing=east]")
    b.set(3, 78, 2, "spruce_fence")
    b.set(3, 79, 2, "spruce_slab[type=bottom]")
    b.set(5, 78, -5, "barrel[facing=west]")
    b.set(5, 79, -5, "potted_fern")
    b.set(4, 78, -6, "chiseled_bookshelf[facing=south,slot_0_occupied=true,slot_5_occupied=true]")


def reading_room(b):
    # A fitted writing desk sits against the bookshelves on the east wall.
    b.set(5, 84, -2, "barrel[facing=west]")
    b.set(5, 85, -2, "lantern")
    b.set(5, 84, -1, "cartography_table")
    b.set(5, 84, 0, "spruce_stairs[half=top,facing=east]")
    b.set(5, 85, 0, "brown_candle[candles=2,lit=true]")
    b.set(4, 84, -1, "dark_oak_stairs[facing=west]")
    course(b, 87, 5, 5, -6, -3, "dark_oak_slab[type=bottom]")
    # The front bay has a bench with arms and a small table at the sill.
    b.set(-5, 84, 6, "spruce_stairs[facing=south]")
    b.set(-6, 84, 6, "spruce_wood")
    b.set(-2, 84, 6, "dark_oak_trapdoor[facing=west,open=true]")
    b.set(-5, 84, 5, "spruce_fence")
    b.set(-5, 85, 5, "spruce_pressure_plate")
    b.set(-1, 84, 6, "barrel[facing=up]")
    b.set(-1, 85, 6, "potted_azure_bluet")
    b.set(4, 85, 5, "potted_fern")
    b.set(4, 84, 5, "barrel[facing=up]")
    b.set(-5, 84, 1, "barrel[facing=up]")
    b.set(-5, 85, 1, "lantern")


def tutorial_corner(b):
    b.set(8, 78, -2, "barrel[facing=south]")
    b.set(8, 79, -2, "potted_azure_bluet")
    b.set(12, 79, 3, "brown_candle[candles=2,lit=true]")
    rug(b, 78, 8, 12, 4, 8, "brown", "gray")
    b.set(12, 78, 4, "spruce_stairs[facing=east]")
    b.set(12, 78, 7, "barrel[facing=up]")
    b.set(12, 79, 7, "potted_fern")
    b.set(8, 78, 7, "barrel[facing=up]")
    b.set(8, 79, 7, "lantern")
    course(b, 78, 9, 11, 8, 8, "spruce_stairs[facing=south]")
    trestle(b, 78, 9, 11, 6, 6)
    b.set(10, 79, 6, "flower_pot")


def campsite(b):
    site = house["site"]
    for x in range(-3, 11):
        for z in range(12, 22):
            edge = ((x - 3) / 7.4) ** 2 + ((z - 16.5) / 5.8) ** 2
            if edge > 1 or site["on_trail"](x, z):
                continue
            b.box((x, 78, z), (x, max(83, site["height"](x, z) + 2), z), "air")
            b.set(x, 76, z, "dirt")
            if edge > .78:
                top = "moss_block"
            elif x <= 1 and (x + z) % 3 == 0:
                top = "gravel"
            else:
                top = "podzol" if (x * 17 + z) % 7 == 0 else "rooted_dirt"
            b.set(x, 77, z, top)
    for z in (14, 15, 17, 18, 19):
        rim = min(site["height"](11, z), 81)
        for y in range(78, rim):
            b.set(11, y, z, "mossy_cobblestone" if (y + z) % 3 == 0 else "tuff")
    for z in (15, 18):
        b.set(11, site["height"](11, z) + 1, z, "fern")
    course(b, 77, -4, -4, 15, 17, "mossy_stone_brick_stairs[facing=east]")
    course(b, 77, 1, 2, 15, 16, "waxed_oxidized_cut_copper")
    b.set(-1, 77, 16, "hay_block")
    b.set(-1, 78, 16, "campfire[lit=true]")
    for x, z in ((-2,15), (0,15), (-2,17), (0,17)):
        b.set(x, 77, z, "andesite")
    for x, z in ((-1,15), (-2,16), (0,16), (-1,17)):
        stone = "mossy_cobblestone_slab" if x < 0 else "cobbled_deepslate_slab"
        b.set(x, 78, z, stone + "[type=bottom]")
    course(b, 78, -1, 0, 13, 13, "spruce_stairs[facing=north]")
    b.set(1, 78, 13, "barrel[facing=up]")
    b.set(1, 79, 13, "lantern")
    b.set(2, 78, 13, "spruce_log[axis=z]")
    b.set(2, 78, 14, "spruce_log[axis=z]")
    b.set(2, 79, 13, "spruce_log[axis=z]")
    course(b, 78, 5, 7, 14, 17, "light_gray_carpet")
    course(b, 78, 5, 5, 14, 16, "gray_wool")
    course(b, 79, 5, 5, 14, 16, "brown_carpet")
    for z in (13, 18):
        b.box((6, 78, z), (6, 81, z), "spruce_fence")
    for x, z in ((3, 13), (9, 13), (3, 18), (9, 18)):
        b.set(x, 78, z, "mossy_cobblestone_slab[type=bottom]")
    b.set(8, 78, 14, "barrel[facing=south]")
    b.set(7, 78, 13, "barrel[facing=up]")
    b.set(7, 79, 13, "lantern")
    for (x, y, z), (width, thickness, depth), angle, material in TENT_PANELS:
        sine, cosine = math.sin(angle / 2), math.cos(angle / 2)
        b.lines.append(
            f'summon minecraft:block_display {x} {y} {z} '
            f'{{Tags:["sd.floor_lobby_display"],block_state:{{Name:"minecraft:{material}"}},'
            f'transformation:{{translation:[0f,0f,0f],left_rotation:[0f,0f,{sine:.8f}f,{cosine:.8f}f],'
            f'scale:[{width:.8f}f,{thickness:.8f}f,{depth:.8f}f],right_rotation:[0f,0f,0f,1f]}}}}'
        )


def build():
    b = Build()
    b.lines.extend(line for line in house["build"]() if not line.startswith("summon minecraft:text_display "))
    recessed_windows(b)
    door_and_gable(b)
    roof_repairs(b)
    weathered_footing(b)
    terrace(b)
    hearth(b)
    shelves_and_textiles(b)
    stair_storage(b)
    reading_room(b)
    tutorial_corner(b)
    campsite(b)
    return b.lines


if __name__ == "__main__":
    write(HERE / "小屋建造.mcfunction", build())
