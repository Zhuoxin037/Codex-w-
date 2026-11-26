"""Paint the approved room glyphs onto the existing scale-1 vanilla maps."""

from itertools import groupby
from pathlib import Path

from architecture import Build
from floor_upgrade import write
from map_icon_preview import GLYPHS, PIXELS


# The first block is the room interior, followed by the approved sprite's inks.
# These shades come from the flat-surface palette in Java 1.21.5.
STYLES = (
    ("entry", "gray_terracotta dark_oak_planks jungle_planks raw_iron_block birch_planks oak_planks"),
    ("combat", "brown_terracotta cyan_terracotta clay pale_oak_planks white_concrete yellow_terracotta raw_iron_block spruce_planks"),
    ("elite", "red_terracotta pale_oak_planks clay cyan_terracotta gold_block yellow_terracotta acacia_planks white_concrete"),
    ("boss", "crimson_planks pale_oak_planks birch_planks raw_iron_block light_gray_terracotta black_concrete pink_terracotta"),
    ("safe", "brown_terracotta dark_oak_planks jungle_planks acacia_planks gold_block birch_planks raw_iron_block pale_oak_planks"),
    ("forge", "cyan_terracotta deepslate light_gray_concrete iron_block pale_oak_planks stone raw_iron_block"),
    ("merchant", "dark_oak_planks spruce_planks orange_terracotta yellow_terracotta gold_block birch_planks"),
    ("blackmarket", "blue_terracotta gray_concrete purple_concrete magenta_concrete pink_concrete raw_iron_block jungle_planks deepslate"),
    ("astrology", "blue_concrete light_blue_terracotta light_blue_concrete clay pale_oak_planks birch_planks"),
    ("gamble", "cyan_terracotta dark_oak_planks light_gray_terracotta raw_iron_block pale_oak_planks white_concrete mangrove_planks jungle_planks"),
    ("rental", "green_terracotta cyan_terracotta warped_planks light_blue_concrete diamond_block pale_oak_planks"),
    ("event", "gray_concrete light_gray_terracotta raw_iron_block birch_planks pale_oak_planks white_concrete"),
)

# A mirror attaches to an existing room. The side of the frame has five map
# pixels available before the next room, and its bottom edge meets the path.
MIRROR_OFFSET = (7, -6)
MIRROR_BLOCKS = "blue_terracotta cyan_concrete light_blue_concrete diamond_block pale_oak_planks"
MIRROR = ("0330", "3223", "3243", "3423", "0330")


def paint(builder, pattern, blocks, x, z):
    for dz, row in enumerate(pattern):
        dx = 0
        for ink, run in groupby(row):
            width = len(tuple(run))
            if ink != ".":
                x1, z1 = 2 * (x + dx), 2 * (z + dz)
                builder.box((x1, 0, z1), (x1 + width * 2 - 1, 0, z1 + 1), blocks[int(ink)])
            dx += width


def stage(world):
    data = Path(world) / "datapacks/zz_sweetdream_floor/data"
    canvas = data / "fallendream/function/rogue/canvas"
    half = PIXELS // 2
    for (kind, style), (label, colors, pattern) in zip(STYLES, GLYPHS[:-1], strict=True):
        blocks = style.split()
        assert len(blocks) == 1 + len(colors.split()), label
        assert len(pattern) == PIXELS and all(len(row) == PIXELS for row in pattern), label
        builder = Build(relative=True)
        # The two rings outside the glyph belong to the room and visit state.
        builder.box((-2 * half, 0, -2 * half), (2 * half + 1, 0, 2 * half + 1), blocks[0])
        paint(builder, pattern, blocks, -half, -half)
        write(canvas / f"icon_{kind}.mcfunction", "\n".join(builder.lines))

    builder = Build(relative=True)
    paint(builder, MIRROR, MIRROR_BLOCKS.split(), *MIRROR_OFFSET)
    write(canvas / "mirror_marker.mcfunction", "\n".join(builder.lines))
    write(data / "sweetdream_floor/function/junction/paint_mirror.mcfunction",
          "$execute positioned $(x) 319 $(z) run function fallendream:rogue/canvas/mirror_marker")
