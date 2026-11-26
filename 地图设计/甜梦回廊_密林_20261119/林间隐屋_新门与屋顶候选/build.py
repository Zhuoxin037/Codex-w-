"""A recessed brick doorway under the timber roof of the woodland hideout."""

from pathlib import Path
import random
import runpy

HERE=Path(__file__).resolve().parent
hideout=runpy.run_path(str(HERE.parent/"林间隐屋候选"/"build.py"))
Build,write,line,glazed=(hideout[key] for key in ("Build","write","line","glazed"))
UPPER_FLOOR=hideout["UPPER_FLOOR"]
LOWER_ENTRY=hideout["LOWER_ENTRY"]
PADS=hideout["PADS"]
trail_x=hideout["trail_x"]
TIMBER="stripped_dark_oak_log"
STONE="tuff_bricks"
AMBER=("brown_stained_glass","orange_stained_glass","brown_stained_glass")
RIDGE=((-10,84),(-9,85),(-8,85),(-7,86),(-6,87),(-5,88),(-4,89),(-3,89),(-2,90),(-1,90),
       (0,91),(1,90),(2,90),(3,89),(4,89),(5,88),(6,87),(7,86),(8,86))


def walls(b):
    b.box((-11,75,-8),(11,76,8),"mossy_cobblestone")
    line(b,77,-10,10,-7,7,"spruce_planks")
    b.shell(-10,10,78,82,-7,7,STONE)
    b.shell(-10,10,83,85,-7,7,"spruce_planks")
    for z in (-7,7):
        line(b,83,-10,10,z,z,TIMBER+"[axis=x]")
        for x in (-10,-7,-2,2,7,10):
            b.box((x,81,z),(x,85,z),TIMBER)
    for x in (-10,10):
        line(b,83,x,x,-7,7,TIMBER+"[axis=z]")
        for z in (-4,3):
            b.box((x,81,z),(x,85,z),TIMBER)
    for z in (-7,7):
        for x in (-10,-9,-8,-2,-1,0,7,8,9,10):
            b.set(x,78,z,"mossy_stone_bricks")
    for x in (-10,-9,-8,-2,7,8,9):
        b.set(x,79,7,"tuff")
    for x in (-9,-8,0,1,8,9):
        b.set(x,81,7,"packed_mud")
        b.set(x,82,7,"mud_bricks")
    glazed(b,"south",7,4,79,AMBER)
    glazed(b,"north",-7,-5,80,AMBER)
    for x in range(4,7):
        for y in (84,85):
            b.set(x,y,7,AMBER[(x+y)%3])
        b.set(x,83,8,"dark_oak_slab[type=top]")
    b.set(5,84,8,"dark_oak_fence")
    for x in (3,7):
        b.set(x,84,8,"spruce_trapdoor[facing=south,open=true]")
    for x,z,short,tall in ((-9,8,78,82),(-8,8,80,84),(1,8,78,81),(9,8,79,84)):
        b.box((x,short,z),(x,tall,z),"vine[north=true]")


def entry(b):
    line(b,77,-7,-3,8,10,"stone_bricks")
    line(b,77,-6,-4,11,11,"mossy_stone_brick_stairs[facing=north]")
    b.set(-7,77,10,"mossy_stone_bricks")
    b.set(-3,77,10,"mossy_cobblestone_slab[type=top]")
    for x,z in ((-7,8),(-6,10),(-4,9),(-3,9)):
        b.set(x,77,z,"cracked_stone_bricks")
    # The doors are one block behind the face of the stone arch.
    b.box((-6,78,7),(-4,79,7),"air")
    b.box((-7,78,8),(-3,81,8),STONE)
    b.box((-5,78,8),(-4,79,8),"air")
    for x in (-6,-3):
        b.set(x,78,8,"mossy_stone_bricks")
        b.set(x,80,8,"stone_bricks")
    for x in (-5,-4):
        outside="west" if x==-5 else "east"
        b.set(x,80,8,"stone_brick_stairs[half=top,facing="+outside+"]")
    line(b,81,-6,-3,8,8,"stone_brick_slab[type=bottom]")
    b.set(-7,80,8,"air")
    b.set(-7,81,8,"air")
    b.set(-7,78,8,"mossy_cobblestone")
    b.set(-7,79,8,"moss_carpet")
    for x,hinge in ((-5,"left"),(-4,"right")):
        for y,half in ((78,"lower"),(79,"upper")):
            b.set(x,y,7,"spruce_door[facing=south,half="+half+",hinge="+hinge+",open=false]")
    line(b,80,-5,-4,7,7,"stripped_spruce_log[axis=x]")
    b.set(-6,78,7,STONE)
    b.set(-6,79,7,STONE)
    b.set(-7,82,8,"dark_oak_fence")
    b.set(-7,81,8,"lantern[hanging=true]")
    b.set(-8,77,9,"moss_block")
    b.set(-8,78,9,"fern")
    b.set(-2,77,9,"moss_block")
    b.set(-2,78,9,"brown_mushroom")


def timber_roof(b):
    heights=dict(RIDGE)
    for z,y in RIDGE:
        facing="south" if z<0 else "north"
        climb=z!=0 and heights[z+(1 if z<0 else -1)]>y
        kind="_stairs[facing="+facing+"]" if climb else "_slab[type=bottom]"
        line(b,y,-11,11,z,z,"dark_oak"+kind)
        if z not in (-10,8):
            line(b,y-1,-11,11,z,z,"dark_oak_planks")
        if z in (-10,-9,8):
            line(b,y,-10,10,z,z,"spruce"+kind)
        if -7<=z<=7:
            for x in (-10,10):
                if y>=87:
                    b.box((x,86,z),(x,y-1,z),"spruce_planks")
                if z in (-3,0,3):
                    b.box((x,85,z),(x,y-1,z),TIMBER)
    # One lower eave above the left-hand doorway follows the main roof pitch.
    line(b,85,-8,-3,9,9,"dark_oak_stairs[facing=north]")
    line(b,84,-7,-4,10,10,"spruce_stairs[facing=north]")
    for x in (-7,-4):
        b.set(x,84,9,"dark_oak_stairs[half=top,facing=north]")
        b.set(x,83,8,"dark_oak_stairs[half=top,facing=north]")
    line(b,85,-8,-3,8,8,TIMBER+"[axis=x]")
    for x,z in ((-8,6),(-7,7),(-8,8),(-9,8),(-8,9),(-7,9),(6,-8),(7,-7),(8,-7)):
        y=85 if z==9 else heights[z]
        b.set(x,y+1,z,"moss_carpet")
    # Replacement shakes occur in short runs where a section was patched.
    for x,z in ((-9,5),(-8,5),(-9,6),(-8,6),(-3,4),(-2,4),(6,3),(7,3),(7,2),(8,2),(8,3)):
        y=heights[z]
        tile="spruce_stairs[facing=north]" if heights[z-1]>y else "spruce_slab[type=bottom]"
        b.set(x,y,z,tile)
    line(b,91,-9,-8,0,0,"waxed_weathered_cut_copper_slab[type=bottom]")
    line(b,91,7,10,0,0,"waxed_weathered_cut_copper_slab[type=bottom]")
    for x in range(4,7):
        b.set(x,85,7,AMBER[(x+85)%3])
    glazed(b,"east",10,-1,85,AMBER)
    glazed(b,"west",-10,-2,85,AMBER)
    b.box((-10,84,0),(-9,90,1),"cracked_stone_bricks")
    b.box((-11,90,-1),(-9,92,1),"bricks")
    b.set(-10,91,0,"campfire[lit=true]")
    b.set(-10,92,0,"air")
    line(b,93,-11,-9,-1,-1,"stone_brick_slab[type=bottom]")
    line(b,93,-11,-9,1,1,"stone_brick_slab[type=bottom]")
    for x in (-11,-9):
        b.set(x,93,0,"stone_brick_slab[type=bottom]")


def annex(b):
    b.box((10,75,-5),(16,76,4),"mossy_cobblestone")
    line(b,77,10,16,-5,4,"spruce_planks")
    b.shell(10,16,78,81,-5,4,STONE)
    b.box((10,78,0),(10,80,3),"air")
    for x in range(11,18):
        y=85-(x-11)//2
        tile="dark_oak_stairs[facing=west]" if x%2 else "dark_oak_slab[type=bottom]"
        line(b,y,x,x,-6,5,tile)
        if x<17:
            line(b,y-1,x,x,-6,5,"dark_oak_planks")
        for z in (-5,4):
            if y>83:
                b.box((x,82,z),(x,y-1,z),"spruce_planks")
    line(b,82,17,17,-6,5,"spruce_stairs[facing=west]")
    for x,z in ((11,4),(16,4),(16,-5),(11,-5)):
        b.box((x,79,z),(x,82,z),TIMBER)
        b.set(x,78,z,"mossy_stone_bricks")
    glazed(b,"south",4,13,79,AMBER)
    glazed(b,"east",16,0,79,AMBER)
    line(b,77,12,14,5,5,"moss_block")
    b.set(12,78,5,"fern")
    b.set(14,78,5,"brown_mushroom")
    hideout["annex_interior"](b)


def build(plant_woods=None):
    b=Build()
    rng=random.Random(19406)
    hideout["terrain"](b,rng)
    if plant_woods is None:
        hideout["woods"](b,rng,open_front=True)
    else:
        plant_woods(b,rng)
    walls(b)
    timber_roof(b)
    entry(b)
    annex(b)
    hideout["stair_and_floors"](b)
    hideout["ground_interior"](b)
    hideout["study"](b,window_seat_z=6,roof_heights=dict(RIDGE))
    return b.lines


if __name__=="__main__":
    write(HERE/"小屋建造.mcfunction",build())
