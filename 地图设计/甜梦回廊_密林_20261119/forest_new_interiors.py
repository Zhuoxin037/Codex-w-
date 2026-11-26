"""Purpose-built rooms. All positions are relative to the floor at Y=80."""

from architecture import Build, LEAVES, WORN


def lantern(b, x, y, z):
    b.set(x,y,z,"lantern[hanging=true]")


def blade_clear_arena():
    b=Build(relative=True)
    b.box((-17,1,-17),(17,11,17),"air")
    b.box((-17,-1,-17),(17,0,17),"rooted_dirt")
    b.box((-17,0,-17),(17,0,17),"moss_block")
    b.disk(0,0,0,16,16,WORN)
    b.disk(0,0,0,14,14,"packed_mud")
    b.disk(0,0,0,12,12,"coarse_dirt")
    b.disk(0,0,0,4,4,"polished_tuff")
    b.shell(-17,17,1,4,-17,17,"mossy_cobblestone")
    b.shell(-17,17,5,11,-17,17,LEAVES)
    b.shell(-16,16,10,11,-16,16,"azalea_leaves[persistent=true]")
    b.shell(-15,15,11,11,-15,15,LEAVES)
    for side in (-1,1):
        edge=side*16
        for z in (-12,-7,7,12):
            b.box((edge,1,z),(edge,4,z),"tuff_bricks")
            b.set(edge,3,z,"chiseled_tuff_bricks")
            b.set(side*15,7,z,"dark_oak_log[axis=x]")
            lantern(b,side*15,6,z)
        for x in (-11,-7,7,11):
            b.box((x,1,side*16),(x,3,side*16),"mossy_stone_bricks")
            b.set(x,4,side*16,"flowering_azalea_leaves[persistent=true]")
        for z in (-16,16):
            b.box((side*16,1,z),(side*17,9,z),"dark_oak_log")
    b.box((-5,6,-16),(5,6,-16),"dark_oak_log[axis=x]")
    for x in (-4,0,4):
        lantern(b,x,5,-16)
    for x in (-10,-5,0,5,10):
        for z in (-10,-5,0,5,10):
            b.set(x,3,z,"light[level=15]")
    return b.lines


def base(b, stone="tuff_bricks", floor="spruce_planks"):
    b.box((-10,0,-10),(10,0,-3),floor)
    b.box((-10,1,-11),(10,5,-11),stone)
    b.box((-9,3,-11),(9,3,-11),"stripped_spruce_log[axis=x]")
    for x in (-10,10):
        b.box((x,1,-10),(x,5,-3),stone)
        b.box((x,1,-3),(x,6,-3),"stripped_spruce_log")
    b.box((-10,6,-10),(10,6,-3),"dark_oak_planks")
    b.box((-10,6,-2),(10,6,-2),"dark_oak_slab[type=top]")
    for x in (-9,0,9):
        lantern(b,x,5,-4)
    for x in (-8,-4,0,4,8):
        b.set(x,3,-7,"light[level=14]")


def forge(b):
    base(b,"deepslate_bricks","tuff_bricks")
    b.box((1,1,-10),(7,2,-8),"polished_blackstone_bricks")
    b.box((1,3,-10),(7,3,-9),"polished_blackstone_brick_slab[type=top]")
    b.box((3,4,-10),(5,6,-10),"deepslate_bricks")
    for x in (3,4,5):
        b.set(x,1,-8,"campfire[lit=true]")
    b.set(0,1,-5,"anvil[facing=east]")
    b.set(2,1,-5,"smithing_table")
    b.box((-8,1,-9),(-7,1,-6),"barrel[facing=south]")
    b.box((-8,2,-9),(-7,2,-6),"dark_oak_slab[type=bottom]")
    b.set(8,1,-8,"water_cauldron[level=3]")


def astrology(b):
    base(b,"polished_tuff","polished_tuff")
    b.disk(0,0,-7,6,3,"waxed_oxidized_cut_copper")
    b.disk(0,0,-7,4,2,"polished_blackstone")
    for x,z in ((-5,-6),(5,-6),(-4,-9),(4,-9)):
        b.set(x,0,z,"chiseled_tuff_bricks")
        b.set(x,3,z,"light[level=12]")
    b.set(0,1,-8,"chiseled_tuff_bricks")
    b.set(0,2,-8,"amethyst_block")
    b.set(0,3,-8,"amethyst_cluster[facing=up]")
    b.set(0,1,-5,"lectern[facing=south]")
    b.box((-5,5,-9),(5,5,-9),"waxed_cut_copper_slab[type=top]")
    for x in (-4,4):
        b.set(x,4,-9,"chain")
        b.set(x,3,-9,"soul_lantern[hanging=true]")


def safe(b):
    base(b,"mossy_stone_bricks")
    b.box((-8,1,-9),(-3,1,-9),"spruce_stairs[facing=south]")
    b.box((3,1,-9),(8,1,-9),"spruce_stairs[facing=south]")
    b.box((-2,1,-10),(2,3,-10),"bricks")
    b.set(0,1,-10,"campfire")
    b.box((-2,3,-9),(2,3,-9),"brick_slab[type=top]")
    b.box((-5,1,-6),(5,1,-4),"brown_carpet")
    for x in (-7,7):
        b.set(x,1,-6,"barrel[facing=up]")
        b.set(x,2,-6,"potted_fern")


def gamble(b):
    base(b,"polished_blackstone_bricks","dark_oak_planks")
    b.box((-4,1,-7),(4,1,-6),"dark_oak_planks")
    for x,block in ((-2,"light_blue_stained_glass"),(0,"yellow_stained_glass"),(2,"orange_stained_glass")):
        b.set(x,2,-7,block)
        b.set(x,2,-8,"ochre_froglight")
        b.set(x,3,-7,"waxed_copper_grate")
    b.box((-5,4,-8),(5,4,-7),"crimson_slab[type=top]")
    b.box((-7,1,-5),(-2,1,-5),"red_carpet")
    b.box((2,1,-5),(7,1,-5),"red_carpet")
    for x in (-3,3):
        b.set(x,1,-4,"dark_oak_stairs[facing=north]")


def rental(b):
    base(b,"mossy_stone_bricks")
    b.box((-8,1,-9),(8,1,-9),"stripped_spruce_log[axis=x]")
    b.box((-8,2,-10),(8,5,-10),"spruce_planks")
    for x in (-7,-4,0,4,7):
        b.box((x,2,-9),(x,4,-9),"dark_oak_fence")
        b.set(x,5,-9,"barrel[facing=south]")
    b.box((1,1,-6),(6,1,-6),"spruce_slab[type=top]")
    b.set(4,2,-6,"potted_spruce_sapling")
    b.set(8,1,-5,"fletching_table")


def merchant(b, dark=False):
    base(b,"deepslate_bricks" if dark else "mossy_stone_bricks","dark_oak_planks" if dark else "spruce_planks")
    fabric=("purple_wool","gray_wool") if dark else ("orange_wool","white_wool")
    for x in range(-9,10):
        b.set(x,5,-4,fabric[x%2])
    for x in (-9,0,9):
        lantern(b,x,5,-6)
    for x in (-7,-3,1,5,8):
        b.set(x,1,-10,"barrel[facing=south]")
        b.set(x,2,-10,"dark_oak_slab[type=top]")
    for x in (-8,8):
        b.box((x,1,-5),(x,4,-5),"stripped_dark_oak_log")
        b.set(x,1,-6,"decorated_pot")
    if dark:
        for x in (-6,6):
            b.set(x,2,-8,"soul_lantern")
            b.set(x,1,-8,"chiseled_polished_blackstone")


def interiors():
    room_types={"safe":safe,"forge":forge,"astrology":astrology,"gamble":gamble,"rental":rental,
                "merchant":merchant,"blackmarket":lambda b:merchant(b,True)}
    for key,build in room_types.items():
        b=Build(relative=True)
        build(b)
        yield key,b.lines
