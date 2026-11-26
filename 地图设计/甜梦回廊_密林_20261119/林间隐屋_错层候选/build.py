"""Woodland lobby built around three offset rooms and an upper terrace."""

from pathlib import Path
import random
import runpy

HERE = Path(__file__).resolve().parent
forest = runpy.run_path(str(HERE.parent/"林间隐屋_林木候选"/"build.py"))
site = forest["terrain"]
trail_x = site["trail_x"]
Build, write, course, window, trestle, rug = (
    site[name] for name in ("Build", "write", "line", "glazed", "trestle", "rug")
)
UPPER_FLOOR = 83
LOWER_ENTRY = (-5, 5)
PADS = ((-10, 1), (10, 2))
DOORS = ((-5, "left"), (-4, "right"))
DOOR_Z = 6
STONE = "tuff_bricks"
OAK = "stripped_spruce_log"
BARK = "spruce_wood"
WOOD = "spruce_planks"
AMBER = ("brown_stained_glass", "orange_stained_glass", "brown_stained_glass")
MAIN_ROOF = {-8:88, -7:88, -6:89, -5:89, -4:90, -3:90, -2:91, -1:92, 0:92,
             1:93, 2:92, 3:91, 4:91, 5:90, 6:89, 7:89, 8:88}
SIDE_FRONT = 9


def base(b, x0, x1, z0, z1, wall_top):
    b.box((x0, 75, z0), (x1, 76, z1), "mossy_cobblestone")
    course(b, 77, x0, x1, z0, z1, WOOD)
    b.shell(x0, x1, 78, 79, z0, z1, STONE)
    b.shell(x0, x1, 80, wall_top, z0, z1, WOOD)
    for x, z in ((x0,z0), (x0,z1), (x1,z0), (x1,z1)):
        b.set(x, 78, z, "mossy_stone_bricks")
        b.box((x, 79, z), (x, wall_top, z), BARK)


def aged_footing(b):
    # Damp courses follow the ground along the exposed faces of the three wings.
    for x, z in ((-11,4), (-10,4), (-8,4), (-7,7), (-6,7), (0,7), (6,7),
                 (8,SIDE_FRONT), (12,SIDE_FRONT), (13,3)):
        b.set(x, 78, z, "mossy_stone_bricks")
    for x, z in ((-11,4), (-8,4), (-6,7), (0,7), (8,SIDE_FRONT), (13,3)):
        b.set(x, 79, z, "cracked_stone_bricks")
    for x, z in ((-12,5), (-11,5), (-9,5), (-7,8), (8,10), (10,10), (11,10), (12,10)):
        b.set(x, 77, z, "moss_block")
    for x, z in ((-12,5), (-11,5), (-9,5), (8,10), (12,10)):
        b.set(x, 78, z, "fern")


def forecourt(b):
    # A shoulder of the bank recedes at the turn to the front step.
    height=site["height"]
    for x in range(-2,11):
        for z in range(11,22):
            y=height(x,z)
            floor=77+max(0,x-2)//2+abs(z-16)//4
            if y<=floor or site["on_trail"](x,z):
                continue
            b.box((x,floor+1,z),(x,y+2,z),"air")
            b.set(x,floor,z,"moss_block" if (x+z)%3 else "podzol")
            if (x*7+z)%4==0:
                b.set(x,floor+1,z,"fern")


def walls(b):
    # The short side rooms stop at different points along the path.
    base(b, -6, 6, -8, 7, 82)
    base(b, -12, -6, -6, 4, 82)
    base(b, 6, 13, -3, SIDE_FRONT, 81)
    b.box((-6,78,-2), (-6,81,2), "air")
    b.box((6,78,0), (6,80,3), "air")
    for x,z in ((-6,-3),(-6,3),(6,-1),(6,4)):
        b.box((x,79,z), (x,81,z), OAK)
    course(b, 82, -6,-6,-3,3, OAK+"[axis=z]")
    course(b, 81, 6,6,-1,4, OAK+"[axis=z]")
    for z in (-8,7):
        course(b, 82, -6,6,z,z, OAK+"[axis=x]")
    course(b, 82, -12,-6,4,4, OAK+"[axis=x]")
    aged_footing(b)
    for z, center, at in ((7,2,"south"),(-8,-2,"north")):
        window(b,at,z,center,79,AMBER)
    window(b,"south",4,-9,79,AMBER)
    window(b,"west",-12,0,79,AMBER)
    window(b,"south",SIDE_FRONT,10,79,AMBER)
    window(b,"east",13,1,79,AMBER)


def entrance(b):
    # The closed door sits behind the bay on level two. The steps stay open to the path.
    b.box((-5,78,7),(-4,81,7),"air")
    b.box((-5,78,6),(-4,79,6),"air")
    course(b,82,-7,-2,8,8,"spruce_slab[type=top]")
    for x,hinge in DOORS:
        for y,half in ((78,"lower"),(79,"upper")):
            b.set(x,y,DOOR_Z,"spruce_door[facing=south,half="+half+",hinge="+hinge+",open=false]")
    for x in (-6,-3):
        b.set(x,78,7,"mossy_cobblestone")
        b.box((x,79,7),(x,82,7),BARK)
        b.set(x,82,8,"spruce_stairs[facing=north,half=top]")
        b.set(x,81,8,"spruce_fence")
    course(b,80,-5,-4,6,6,OAK+"[axis=x]")
    course(b,81,-5,-4,7,7,"dark_oak_slab[type=top]")
    for x,z in ((-6,8),(-3,8)):
        b.set(x,80,z,"lantern[hanging=true]")
    course(b,77,-6,-3,8,10,"stone_bricks")
    course(b,77,-6,-4,11,11,"stone_brick_stairs[facing=north]")
    for x,z in ((-6,10),(-5,8),(-3,9)):
        b.set(x,77,z,"mossy_stone_bricks")
    for x,z in ((-8,6),(-7,6),(-8,7),(-7,7)):
        b.set(x,77,z,"moss_block")
    for x,z in ((-8,6),(-7,7)):
        b.set(x,78,z,"mossy_cobblestone_wall")
    b.set(-8,78,7,"fern")
    b.set(-7,78,8,"flower_pot")


def upper_and_terrace(b):
    # The upper room steps back at the terrace, and comes forward again above the entrance.
    course(b,83,-6,6,-8,7,WOOD)
    course(b,83,-7,-3,8,8,WOOD)
    b.shell(-6,6,84,88,-8,7,WOOD)
    b.shell(-6,-2,84,87,7,8,WOOD)
    b.box((-5,84,7),(-3,86,7),"air")
    course(b,88,-6,-2,8,8,WOOD)
    for z, xx in ((-8,(-6,-3,3,6)),(7,(-6,-2,0,4,6)),(8,(-6,-2))):
        for x in xx:
            b.box((x,83,z),(x,88 if z!=8 else 87,z),BARK)
        course(b,83,min(xx),max(xx),z,z,"dark_oak_slab[type=top]")
    course(b,87,-6,-2,8,8,OAK+"[axis=x]")
    for x in (-6,6):
        for z in (-8,-4,1,5):
            b.box((x,83,z),(x,88,z),BARK)
    for x,z in ((-1,7),(5,7),(1,-8),(2,-8)):
        b.set(x,86,z,"stripped_spruce_wood")
    window(b,"south",8,-4,85,AMBER)
    window(b,"south",7,2,85,AMBER)
    window(b,"north",-8,0,85,AMBER)
    window(b,"east",6,-4,85,AMBER)
    # A thin bracketed flower trough sits below the front bay.
    for x in (1,2,3):
        b.set(x,84,8,"dark_oak_slab[type=top]")
        b.set(x,84,10,"spruce_trapdoor[facing=south,open=true]")
    b.set(1,85,9,"potted_cornflower")
    b.set(3,85,9,"potted_fern")
    course(b,84,1,3,9,9,"spruce_slab[type=top]")
    for x in (1,3):
        b.set(x,83,8,"spruce_stairs[half=top,facing=north]")
    # The terrace projects over the short sitting room by one block.
    course(b,83,-12,-7,-6,5,WOOD)
    course(b,83,-12,-6,-6,-6,"dark_oak_planks")
    course(b,83,-12,-7,5,5,"dark_oak_planks")
    b.box((-6,84,-2),(-6,85,-1),"air")
    b.box((-6,86,-2),(-6,86,-1),OAK+"[axis=z]")
    course(b,84,-12,-12,-6,5,"spruce_fence")
    course(b,84,-11,-7,5,5,"spruce_fence")
    course(b,84,-11,-7,-6,-6,"spruce_fence")
    for x,z in ((-12,5),(-12,-6),(-7,5),(-7,-6)):
        b.set(x,84,z,BARK)
        b.set(x,85,z,"spruce_slab[type=bottom]")
    for x in (-12,-7):
        b.set(x,82,5,"spruce_stairs[half=top,facing=north]")
    for x,z in ((-11,3),(-8,-5)):
        b.set(x,84,z,"barrel[facing=up]")
        b.set(x,85,z,"potted_fern")
    b.set(-11,84,-4,"dark_oak_stairs[facing=west]")
    b.set(-11,84,-3,"dark_oak_stairs[facing=west]")
    b.set(-10,84,3,"lantern")
    trestle(b,84,-10,-8,2,2)
    b.set(-9,85,2,"flower_pot")
    b.set(-11,84,1,"spruce_stairs[facing=west]")
    b.box((-12,80,5),(-12,82,5),"vine[north=true]")


def roofs(b, include_chimney=True):
    # An off-centre ridge stretches slightly farther toward the open terrace.
    for x,y in MAIN_ROOF.items():
        face="east" if x<1 else "west"
        rising=x!=1 and MAIN_ROOF[x+(1 if x<1 else -1)]>y
        shape="_stairs[facing="+face+"]" if rising else "_slab[type=bottom]"
        front=8 if x<-6 else 9
        course(b,y,x,x,-10,front,"dark_oak"+shape)
        course(b,y-1,x,x,-9,front-1,"dark_oak_planks")
        b.set(x,y,front,"spruce"+shape)
        if -6<=x<=6:
            for wall in (-8,7):
                if y>90:
                    b.box((x,89,wall),(x,y-2,wall),WOOD)
                b.set(x,y-1,wall,OAK+"[axis=x]")
        if x in (-7,-4,-1,2,5,8):
            b.set(x,y-1,front,"dark_oak_slab[type=top]")
    for z in (-8,7):
        b.box((1,88,z),(1,91,z),OAK)
        for x,y in ((-4,89),(-3,90),(-2,91),(3,91),(4,90),(5,89)):
            b.set(x,min(y,MAIN_ROOF[x]-2),z,OAK)
    for x,z in ((-7,1),(-7,2),(-6,2),(-6,3),(7,-6),(6,-6),(6,-7)):
        b.set(x,MAIN_ROOF[x],z,"spruce_stairs[facing="+("east" if x<1 else "west")+"]")
    for x,z in ((-7,2),(-7,3),(-8,2),(7,-6),(7,-5),(8,-5)):
        b.set(x,MAIN_ROOF[x]+1,z,"moss_carpet")
    # The tutorial room has its own compact gable, offset below the main ridge.
    side_roof={7:84,8:85,9:86,10:87,11:87,12:86,13:85,14:84}
    for x,y in side_roof.items():
        face="east" if x<11 else "west"
        tile="spruce_slab[type=bottom]" if x in (10,11) else "spruce_stairs[facing="+face+"]"
        course(b,y,x,x,-4,SIDE_FRONT+1,tile)
        course(b,y-1,x,x,-3,SIDE_FRONT,"dark_oak_planks")
        if x<14:
            for z in (-3,SIDE_FRONT):
                b.box((x,82,z),(x,y-1,z),WOOD)
                b.set(x,y-1,z,OAK+"[axis=x]")
        if x==13:
            b.box((x,82,-3),(x,y-1,SIDE_FRONT),WOOD)
        if x in (8,11,13):
            b.set(x,y-1,SIDE_FRONT+1,"dark_oak_slab[type=top]")
    b.box((6,82,8),(6,83,SIDE_FRONT),WOOD)
    b.box((11,82,SIDE_FRONT),(11,85,SIDE_FRONT),OAK)
    for x,z in ((12,1),(12,2),(13,2),(13,3)):
        b.set(x,side_roof[x]+1,z,"moss_carpet")

    if include_chimney:
        chimney(b)


def chimney(b):
    for x,z in ((-6,-6),(-6,-5),(-5,-6),(-5,-5)):
        b.box((x,84,z),(x,90,z),"mossy_stone_bricks")
    b.box((-7,90,-7),(-5,92,-5),"bricks")
    b.set(-6,91,-6,"campfire[lit=true]")
    b.set(-6,92,-6,"air")
    course(b,93,-7,-5,-7,-7,"stone_brick_slab[type=bottom]")
    course(b,93,-7,-5,-5,-5,"stone_brick_slab[type=bottom]")
    for x in (-7,-5):
        b.set(x,93,-6,"stone_brick_slab[type=bottom]")


def stairs(b):
    b.box((1,83,-3),(2,83,0),"air")
    for step in range(6):
        y,z=78+step,2-step
        course(b,y,1,2,z,z,"spruce_stairs[facing=north]")
        if step:
            course(b,y-1,1,2,z,z,OAK+"[axis=z]")
    course(b,83,0,3,-4,-4,OAK+"[axis=x]")
    for x in (0,3):
        b.box((x,84,-3),(x,84,1),"spruce_fence")
    course(b,84,1,2,1,1,"spruce_fence")
    for z in (-5,4):
        course(b,82,-5,5,z,z,OAK+"[axis=x]")
    for x,z in ((-3,4),(4,-5)):
        b.set(x,81,z,"chain")
        b.set(x,80,z,"lantern[hanging=true]")


def hearth_and_tutorial(b):
    course(b,77,-11,-10,0,1,"waxed_oxidized_cut_copper")
    b.set(-11,79,2,"lantern")
    b.label((-10.5,80,1),"入梦","gold")
    b.box((-12,78,-5),(-10,81,-3),"mossy_stone_bricks")
    b.box((-11,82,-6),(-6,82,-5),"mossy_stone_bricks")
    course(b,78,-11,-11,-3,-3,"campfire[lit=true]")
    course(b,79,-11,-11,-3,-3,"air")
    course(b,80,-12,-10,-3,-3,"stripped_dark_oak_log[axis=x]")
    b.set(-12,81,-3,"potted_fern")
    rug(b,78,-11,-7,-2,3,"brown","green")
    b.set(-11,78,2,"barrel[facing=up]")
    b.set(-10,78,2,"spruce_stairs[facing=south]")
    trestle(b,78,-9,-7,-2,-1)
    b.set(-8,79,-2,"brown_candle[candles=2,lit=true]")
    rug(b,78,-5,-1,0,4,"brown","gray")
    b.box((-3,78,-7),(2,79,-7),"bookshelf")
    b.set(3,78,-7,"barrel[facing=south]")
    b.set(-4,78,-6,"spruce_stairs[facing=north]")
    b.set(-3,78,-6,"spruce_stairs[facing=north]")
    trestle(b,78,-4,-2,-3,-3)
    b.set(-3,79,-3,"potted_fern")
    b.set(-4,79,-3,"brown_candle[candles=2,lit=true]")
    course(b,77,9,10,1,2,"amethyst_block")
    b.set(10,78,-1,"lectern[facing=south]")
    b.label((10,80,1.5),"教程","light_purple")
    b.box((9,78,-2),(12,80,-2),"bookshelf")
    b.set(9,79,-2,"chiseled_bookshelf[facing=south,slot_0_occupied=true,slot_3_occupied=true]")
    b.set(12,78,3,"cartography_table")
    b.set(12,79,3,"potted_fern")
    b.set(12,78,4,"spruce_stairs[facing=east]")
    course(b,82,7,12,-1,-1,OAK+"[axis=x]")
    b.set(9,81,-1,"chain")
    b.set(9,80,-1,"lantern[hanging=true]")
    trestle(b,78,9,11,6,6)
    b.set(10,79,6,"potted_fern")
    course(b,78,9,11,8,8,"spruce_stairs[facing=south]")


def upstairs(b):
    b.box((5,84,-6),(5,86,-3),"bookshelf")
    b.set(5,84,-4,"barrel[facing=west]")
    b.set(5,85,-4,"cartography_table")
    b.set(5,86,-4,"potted_fern")
    rug(b,84,-4,2,2,6,"brown","gray")
    trestle(b,84,-4,-2,3,3)
    b.set(-3,85,3,"brown_candle[candles=2,lit=true]")
    course(b,84,-5,-3,6,6,"spruce_stairs[facing=south]")
    b.set(4,84,5,"barrel[facing=up]")
    b.set(4,85,5,"lantern")
    course(b,84,1,3,6,6,"spruce_stairs[facing=south]")
    for z in (-5,4):
        course(b,89,-4,4,z,z,OAK+"[axis=x]")
        for x in (-4,4):
            b.set(x,88,z,"spruce_stairs[half=top,facing="+("east" if x<0 else "west")+"]")
    b.set(-1,88,4,"chain")
    b.set(-1,87,4,"lantern[hanging=true]")


def build():
    b = Build()
    rng = random.Random(19406)
    site["terrain"](b,rng)
    forest["woodland"](b,rng,entrance_trees=((-17,16,True,1),(14,15,False,-1)))
    forecourt(b)
    walls(b)
    upper_and_terrace(b)
    roofs(b)
    entrance(b)
    stairs(b)
    hearth_and_tutorial(b)
    upstairs(b)
    return b.lines


if __name__ == "__main__":
    write(HERE/"小屋建造.mcfunction",build())
