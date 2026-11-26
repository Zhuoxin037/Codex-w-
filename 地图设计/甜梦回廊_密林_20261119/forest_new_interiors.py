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


def pier(b,x,z,height,stone="tuff_bricks"):
    b.set(x,1,z,"chiseled_tuff_bricks")
    b.box((x,2,z),(x,height-1,z),stone)
    b.set(x,height,z,"polished_tuff_stairs[facing=north,half=top]")


def bracket(b,x,y,z,material="spruce"):
    b.set(x,y,z,material+"_log[axis=z]")
    b.set(x,y-1,z,"chain")
    lantern(b,x,y-2,z)


def forge(b):
    b.disk(5,0,-7,6,5,"cobbled_deepslate")
    b.disk(5,0,-7,5,4,"tuff_bricks")
    b.box((4,1,-10),(8,3,-9),"deepslate_bricks")
    b.box((4,1,-8),(8,1,-8),"polished_blackstone_bricks")
    b.box((4,2,-8),(4,3,-8),"chiseled_polished_blackstone")
    b.box((8,2,-8),(8,3,-8),"chiseled_polished_blackstone")
    b.box((5,2,-8),(7,2,-8),"campfire[lit=true]")
    b.box((4,4,-9),(8,4,-8),"polished_blackstone_brick_stairs[facing=south,half=top]")
    b.box((5,5,-10),(7,6,-9),"deepslate_bricks")
    b.box((6,7,-10),(6,8,-9),"deepslate_bricks")
    b.set(5,1,-5,"anvil[facing=east]")
    b.set(7,1,-5,"smithing_table")
    b.set(9,1,-6,"water_cauldron[level=3]")
    for x,z in ((5,-4),(9,-8)):
        b.set(x,1,z,"polished_blackstone_brick_wall")
        b.set(x,2,z,"lantern")
    b.box((-8,1,-9),(-5,1,-8),"spruce_planks")
    b.box((-8,2,-9),(-5,2,-9),"spruce_slab[type=bottom]")
    b.set(-8,2,-8,"grindstone[face=floor,facing=south]")
    b.set(-5,2,-8,"barrel[facing=south]")
    b.set(-7,3,-9,"potted_dead_bush")


def astrology(b):
    b.disk(-5,0,-7,6,5,"polished_tuff")
    b.disk(-5,0,-7,5,4,"waxed_oxidized_cut_copper")
    b.disk(-5,0,-7,4,3,"polished_blackstone")
    b.disk(-5,0,-7,2,2,"waxed_cut_copper")
    b.set(-5,1,-8,"chiseled_tuff")
    b.set(-5,2,-8,"amethyst_block")
    b.set(-5,3,-8,"amethyst_cluster[facing=up]")
    for x,z,h in ((-9,-9,5),(-2,-10,5),(-9,-4,4),(-2,-4,4)):
        pier(b,x,z,h,"polished_tuff")
        b.set(x,h+1,z,"waxed_oxidized_cut_copper_slab[type=bottom]")
        b.set(x,0,z,"pearlescent_froglight[axis=y]")
    b.box((-8,5,-9),(-6,5,-9),"waxed_oxidized_cut_copper_slab[type=top]")
    b.box((-4,5,-10),(-3,5,-10),"waxed_oxidized_cut_copper_slab[type=top]")
    for x,z in ((-8,-6),(-4,-10),(-3,-6),(-7,-8)):
        b.set(x,0,z,"chiseled_tuff")
        b.set(x,3,z,"light[level=15]")


def safe(b):
    b.disk(-5,0,-6,6,5,"spruce_planks")
    b.box((-10,1,-10),(-7,3,-10),"mossy_stone_bricks")
    b.box((-10,1,-9),(-7,1,-8),"stone_brick_slab[type=bottom]")
    b.set(-9,2,-9,"campfire")
    b.set(-10,2,-9,"mossy_stone_brick_wall")
    b.set(-8,2,-9,"mossy_stone_brick_wall")
    b.box((-10,3,-9),(-8,3,-9),"stone_brick_stairs[facing=south,half=top]")
    b.box((-9,4,-10),(-9,6,-9),"mossy_stone_bricks")
    for x in (-7,-5):
        b.set(x,1,-8,"brown_bed[facing=north,part=foot]")
        b.set(x,1,-9,"brown_bed[facing=north,part=head]")
    b.box((-8,1,-6),(-5,1,-4),"brown_carpet")
    b.box((-7,1,-6),(-6,1,-4),"gray_carpet")
    b.set(-4,1,-9,"barrel[facing=up]")
    b.set(-4,2,-9,"lantern")
    b.box((-10,1,-6),(-10,2,-5),"bookshelf")
    b.box((-10,3,-6),(-10,3,-5),"spruce_slab[type=bottom]")
    b.set(-9,1,-5,"spruce_stairs[facing=east]")
    b.set(-7,1,-4,"spruce_stairs[facing=north]")
    b.set(-5,1,-4,"potted_fern")


def gamble(b):
    b.disk(5,0,-7,6,5,"polished_blackstone")
    b.disk(5,0,-7,5,4,"dark_oak_planks")
    b.box((2,1,-9),(8,1,-7),"polished_blackstone_bricks")
    b.box((2,2,-9),(8,3,-9),"stripped_dark_oak_log[axis=x]")
    for x,glass in ((3,"lime_stained_glass"),(5,"yellow_stained_glass"),(7,"light_blue_stained_glass")):
        b.set(x,2,-8,glass)
        b.set(x,2,-9,"ochre_froglight")
        b.set(x,3,-8,"waxed_exposed_cut_copper_stairs[facing=south,half=top]")
    for x in (2,4,6,8):
        b.set(x,2,-8,"stripped_dark_oak_log")
    b.box((2,4,-9),(8,4,-8),"dark_oak_slab[type=bottom]")
    b.set(8,2,-7,"lever[face=floor,facing=east,powered=false]")
    b.box((3,1,-6),(7,1,-4),"red_carpet")
    for x in (3,7):
        b.set(x,1,-5,"dark_oak_stairs[facing=north]")
    b.set(9,1,-8,"barrel[facing=up]")
    b.set(9,2,-8,"lantern")


def rental(b):
    b.box((3,0,4),(10,0,10),"stripped_spruce_log[axis=x]")
    for x in (3,10):
        b.box((x,1,9),(x,5,9),"dark_oak_log")
        b.box((x,1,5),(x,5,5),"stripped_spruce_log")
    for z,y,kind in ((4,5,"spruce_stairs[facing=south]"),(5,5,"spruce_planks"),
                     (6,6,"spruce_stairs[facing=south]"),(7,7,"spruce_slab[type=bottom]"),
                     (8,6,"spruce_stairs[facing=north]"),(9,5,"spruce_planks"),
                     (10,5,"spruce_stairs[facing=north]")):
        b.box((2,y,z),(11,y,z),kind)
    for x in (5,7,9):
        b.set(x,1,9,"barrel[facing=north]")
        b.set(x,2,9,"spruce_trapdoor[facing=north,open=true,half=bottom]")
    b.box((4,3,9),(9,3,9),"spruce_slab[type=top]")
    b.set(6,4,9,"potted_spruce_sapling")
    b.set(9,4,9,"lantern")
    b.set(4,1,7,"fletching_table")
    b.set(8,1,7,"cartography_table")
    lantern(b,6,4,5)


def merchant(b, dark=False):
    if dark:
        b.box((-9,0,-10),(9,0,-5),"polished_blackstone_bricks")
        b.box((-9,1,-11),(-2,4,-11),"deepslate_tiles")
        b.box((2,1,-11),(9,4,-11),"deepslate_tiles")
        for x in (-9,-1,1,9):
            if abs(x)==1:
                b.set(x,0,-9,"chiseled_polished_blackstone")
                continue
            pier(b,x,-8,5,"polished_blackstone_bricks")
            b.set(x,6,-8,"polished_blackstone_brick_slab[type=bottom]")
        for x in (-8,8):
            b.set(x,1,-6,"polished_blackstone_brick_wall")
            b.set(x,2,-6,"soul_lantern")
            b.set(x,1,-9,"decorated_pot")
        for x in (-6,-4,-2,2,4):
            b.set(x,0,-7,"waxed_cut_copper")
            b.set(x,0,-6,"chiseled_polished_blackstone")
        for x in (-7,7):
            b.set(x,4,-11,"crying_obsidian")
            b.set(x,3,-10,"light[level=14]")
        b.box((-8,5,-10),(-3,5,-10),"polished_blackstone_brick_slab[type=bottom]")
        b.box((3,5,-10),(8,5,-10),"polished_blackstone_brick_slab[type=bottom]")
        return
    for lo,hi in ((-8,-2),(2,7)):
        b.box((lo,0,-10),(hi,0,-5),"spruce_planks")
        b.box((lo,1,-10),(hi,1,-10),"barrel[facing=south]")
        b.box((lo,2,-10),(hi,2,-10),"spruce_slab[type=bottom]")
        for x in (lo,hi):
            b.box((x,1,-9),(x,4,-9),"stripped_spruce_log")
        for x in range(lo,hi+1):
            tint="orange" if x%3==0 else "yellow"
            for z,y in ((-10,5),(-9,5),(-8,5),(-7,4),(-6,4)):
                b.set(x,y,z,f"{tint}_wool")
            b.set(x,4,-5,"spruce_slab[type=top]")
        b.set(lo,3,-10,"potted_fern")
        b.set(hi,3,-10,"lantern")
    for x in (-4,-2,2):
        b.set(x,0,-7,"smooth_sandstone")
        b.set(x,0,-6,"polished_tuff")
    b.set(-7,1,-6,"decorated_pot")
    b.set(6,1,-6,"decorated_pot")

def interiors():
    room_types={"safe":safe,"forge":forge,"astrology":astrology,"gamble":gamble,"rental":rental,
                "merchant":merchant,"blackmarket":lambda b:merchant(b,True)}
    for key,build in room_types.items():
        b=Build(relative=True)
        build(b)
        yield key,b.lines
