"""Build-command source for the woodland cabin lobby candidate."""
from pathlib import Path
import math
import random
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from architecture import Build, write

MIN_X, MAX_X = -48, 48
MIN_Z, MAX_Z = -41, 52
FLOOR = 76
UPPER_FLOOR = 84
EAVES = 91


def square(b, x0, x1, y, z0, z1, material):
    b.box((x0,y,z0), (x1,y,z1), material)


def height(x, z):
    if -19 <= x <= 15 and -11 <= z <= 14:
        return FLOOR
    if z >= 11 and (abs(x-(z-11)*.12)<5 or abs(z-18)<4):
        return FLOOR
    taper=min(1, max(0,(max(abs(x)-13,abs(z)-10))/14))
    rolling=1.6*math.sin(.14*x-.07*z)+1.0*math.cos(.12*z+.08*x)
    if z < -10:
        rolling+=min(3.2,(-z-10)*.22)
    return FLOOR+round(rolling*taper)


def woods_floor(b, rng):
    for x in range(MIN_X,MAX_X+1):
        for z in range(MIN_Z,MAX_Z+1):
            y=height(x,z)
            b.box((x,y-4,z),(x,y-2,z),"stone")
            b.set(x,y-1,z,"dirt")
            b.set(x,y,z,"grass_block")
            trail=abs(x-(z-11)*.12) < 2.4+.45*math.sin(z*.4) and z>=10
            wings=z>=12 and abs(z-(18+.13*abs(x))) < 1.6 and -42<x<43
            near_house=-15<=x<=14 and -9<=z<=13
            if trail or wings:
                b.set(x,y,z,rng.choice(("coarse_dirt","dirt_path","dirt_path","coarse_dirt","gravel")))
            elif rng.random()<.25:
                b.set(x,y,z,rng.choice(("moss_block","podzol","moss_block","rooted_dirt")))
            elif not near_house and rng.random()<.30:
                plant=rng.choice(("fern","short_grass","fern","short_grass","brown_mushroom","white_tulip"))
                b.set(x,y+1,z,plant)
    for x,z in ((-18,13),(11,14),(17,7),(-22,-8),(16,-14),(28,3),(-29,2),(-11,23),(18,27)):
        y=height(x,z)
        b.box((x-1,y,z-1),(x+1,y+1,z+1),"mossy_cobblestone")
        b.set(x,y+1,z+1,"moss_block")
        b.set(x+1,y+2,z,"mossy_cobblestone_slab[type=bottom]")


def leaf_cluster(b, rng, x, y, z, rx, ry, rz, material):
    for dy in range(-ry,ry+1):
        for dx in range(-rx,rx+1):
            edge=(dx/rx)**2+(dy/ry)**2
            if edge>1.06:
                continue
            half=round(rz*math.sqrt(max(0,1.02-edge))+rng.uniform(-.6,.75))
            b.box((x+dx,y+dy,z-half),(x+dx,y+dy,z+half),material)


def oak(b, rng, x, z, h, width):
    y=height(x,z)+1
    thick=h>15
    bark="dark_oak_log"
    leaf="dark_oak_leaves[persistent=true]"
    b.box((x,y,z),(x+int(thick),y+h-1,z+int(thick)),bark)
    for dx,dz in ((-1,0),(1,0),(0,-1),(0,1)):
        b.set(x+dx,y,z+dz,"mangrove_roots")
        length=rng.randint(2,4)
        fork=y+h-rng.randint(4,8)
        for i in range(1,length+1):
            b.set(x+i*dx,fork+(i//2),z+i*dz,bark+("[axis=x]" if dx else "[axis=z]"))
        leaf_cluster(b,rng,x+(length+1)*dx,fork+3,z+(length+1)*dz,width-1,2,width-1,leaf)
    leaf_cluster(b,rng,x,y+h,z,width,4,width,leaf)


def pine(b, rng, x, z, h):
    y=height(x,z)+1
    b.box((x,y,z),(x,y+h-1,z),"spruce_log")
    for step in range(6):
        r=max(1,4-step//2)
        yc=y+h-12+step*2
        for dx in range(-r,r+1):
            width=r-abs(dx)//2
            lean=rng.choice((-1,0,0,1))
            b.box((x+dx,yc,z-width+lean),(x+dx,yc+1,z+width+lean),"spruce_leaves[persistent=true]")
        b.set(x,yc,z,"spruce_log")
    b.set(x,y+h,z,"spruce_leaves[persistent=true]")


def grove(b, rng):
    placed=[]
    for x,z,h,w in ((-20,7,17,5),(18,1,18,5),(-18,-13,19,6),(16,-14,19,5),
                    (-19,23,20,5),(25,18,17,5),(-7,-18,17,6),(9,-20,20,6)):
        oak(b,rng,x,z,h,w)
        placed.append((x,z))
    for _ in range(1700):
        x,z=rng.randint(-43,43),rng.randint(-36,47)
        if (-24<x<21 and -24<z<15) or (-17<x<19 and 15<=z<35) or (z>=12 and (
                abs(x-(z-11)*.12)<4 or abs(z-18-.13*abs(x))<3)):
            continue
        if any((x-px)**2+(z-pz)**2<7.2**2 for px,pz in placed):
            continue
        placed.append((x,z))
        if rng.random()<.53:
            pine(b,rng,x,z,rng.randint(14,23))
        else:
            oak(b,rng,x,z,rng.randint(12,19),rng.randint(4,5))


def window(b, wall, at, middle, bottom=80):
    # Glass is continuous across the cutout, including the central mullion's backing.
    front = wall in ("south","north")
    direction = 1 if wall in ("south","east") else -1

    def pos(across,y,depth=0):
        edge=at-direction*depth
        return (across,y,edge) if front else (edge,y,across)

    for dx in (-1,0,1):
        for y in range(bottom,bottom+3):
            b.set(*pos(middle+dx,y),"yellow_stained_glass")
        b.set(*pos(middle+dx,bottom-1,-1),"dark_oak_slab[type=top]")
        b.set(*pos(middle+dx,bottom+3),"stripped_dark_oak_log[axis="+("x" if front else "z")+"]")
        if dx==0:
            if bottom>80:
                b.set(*pos(middle,bottom+3,1),"stripped_dark_oak_log")
                b.set(*pos(middle,bottom+2,1),"lantern[hanging=true]")
            else:
                b.set(*pos(middle,bottom+1,1),"ochre_froglight")
            for y in range(bottom,bottom+3):
                b.set(*pos(middle,y,-1),"spruce_fence")
    for offset in (-2,2):
        for y in (bottom,bottom+1):
            b.set(*pos(middle+offset,y,-1),f"spruce_trapdoor[open=true,facing={wall}]")


def cabin(b):
    b.box((-12,75,-8),(11,76,7),"mossy_cobblestone")
    square(b,-11,10,77,-7,7,"spruce_planks")
    square(b,-12,11,77,7,11,"stripped_spruce_log[axis=z]")
    b.shell(-11,10,78,EAVES-1,-7,7,"spruce_planks")
    for lo,hi in ((78,79),(83,84),(90,90)):
        for z in (-7,7):
            b.box((-11,lo,z),(10,hi,z),"stripped_spruce_log[axis=x]")
        for x in (-11,10):
            b.box((x,lo,-7),(x,hi,7),"stripped_spruce_log[axis=z]")
    for x in (-11,10):
        for z in (-7,0,7):
            b.box((x,77,z),(x,EAVES,z),"dark_oak_log")
            b.set(x,77,z,"stone_bricks")
    for x in (-4,3):
        b.box((x,84,7),(x,EAVES-1,7),"stripped_dark_oak_log")
    for x in (-12,11):
        for z in range(-7,8):
            y=EAVES+7-abs(z)
            b.box((x,EAVES,z),(x,y,z),"spruce_planks")
    for x in (-12,11):
        for z in (-8,8):
            b.set(x,EAVES-1,z,"dark_oak_fence")
    for z in range(-9,10):
        y=EAVES+9-abs(z)
        shape="dark_oak_slab[type=bottom]" if z==0 else (
            "dark_oak_stairs[facing="+("north" if z>0 else "south")+"]")
        square(b,-13,12,y,z,z,shape)
        square(b,-13,12,y-1,z,z,"dark_oak_planks")
        b.set(-13,y,z,"spruce_stairs[facing="+("north" if z>0 else "south")+"]" if z else "dark_oak_slab[type=bottom]")
        b.set(12,y,z,"spruce_stairs[facing="+("north" if z>0 else "south")+"]" if z else "dark_oak_slab[type=bottom]")
    # Compact cross-gabled entrance, flanked by the warm window bays.
    for x in range(-3,4):
        top=89-abs(x)
        square(b,x,x,top-1,8,12,"dark_oak_planks")
        mat="dark_oak_slab[type=bottom]" if x==0 else "dark_oak_stairs[facing="+("west" if x>0 else "east")+"]"
        square(b,x,x,top,8,12,mat)
        if top-2>=85:
            b.box((x,85,11),(x,top-2,11),"spruce_planks")
    b.box((-3,84,11),(3,84,11),"dark_oak_log[axis=x]")
    for x in (-3,3,-9,8):
        b.box((x,78,11),(x,84 if abs(x)==3 else 82,11),"dark_oak_log")
        b.set(x,78,11,"stone_bricks")
    for z in (10,11,12):
        y=84-(z-10)//2
        for start,end in ((-12,-4),(4,11)):
            square(b,start,end,y,z,z,"dark_oak_stairs[facing=north]")
            square(b,start,end,y-1,z,z,"dark_oak_planks")
    b.box((-2,78,7),(2,81,7),"air")
    b.box((-2,78,8),(-2,81,8),"stripped_spruce_log")
    b.box((2,78,8),(2,81,8),"stripped_spruce_log")
    square(b,-2,2,82,7,8,"stripped_dark_oak_log[axis=x]")
    for x in range(-2,3):
        b.set(x,77,12,"spruce_stairs[facing=north]")
    for x in (-7,-6,-5,5,6,7):
        b.set(x,78,11,"spruce_fence")
    for x in (-7,6):
        window(b,"south",7,x)
        window(b,"south",7,x,bottom=86)
    for z in (-4,3):
        window(b,"east",10,z)
        window(b,"east",10,z,bottom=86)
        window(b,"west",-11,z,bottom=86)
    window(b,"north",-7,1,bottom=86)
    # The rear hearth doubles as the chimney's base.
    b.box((-6,78,-8),(-3,85,-6),"stone_bricks")
    b.box((-6,78,-5),(-3,79,-5),"mossy_stone_bricks")
    b.box((-5,79,-5),(-4,80,-5),"air")
    b.set(-5,79,-5,"campfire[lit=true]")
    b.box((-7,81,-5),(-2,81,-5),"stripped_dark_oak_log[axis=x]")
    b.box((-5,85,-7),(-3,98,-5),"stone_bricks")
    b.box((-5,99,-7),(-3,103,-5),"bricks")
    b.box((-6,103,-8),(-2,103,-4),"stone_brick_slab[type=bottom]")
    b.box((-5,104,-7),(-3,104,-5),"bricks")
    b.set(-4,104,-6,"campfire[lit=true]")
    # Shallow woodshed, woodpile and front flower boxes are kept out of the walkway.
    square(b,-17,-12,77,0,6,"cobblestone")
    for x in (-17,-12):
        b.box((x,78,6),(x,82,6),"spruce_fence")
    for x in range(-18,-11):
        y=82+(x+18)//2
        square(b,x,x,y,-1,7,"dark_oak_stairs[facing=east]")
        square(b,x,x,y-1,-1,7,"dark_oak_planks")
    b.box((-17,78,1),(-13,79,3),"spruce_log[axis=z]")
    b.box((-16,80,2),(-14,80,3),"spruce_log[axis=z]")
    b.set(-14,78,5,"barrel[facing=up]")
    for x in (-7,6):
        square(b,x-1,x+1,77,9,9,"moss_block")
        b.set(x-1,78,9,"fern")
        b.set(x,78,9,"poppy")
        b.set(x+1,78,9,"azure_bluet")
    for loc in ((-3,83,11),(3,83,11),(-10,83,0),(9,83,0)):
        x,y,z=loc
        b.set(x,y+1,z,"dark_oak_planks")
        b.set(x,y,z,"lantern[hanging=true]")


def interior(b):
    # Only the 2×2 pads are reserved for the two existing interactions.
    square(b,-8,-7,77,1,2,"waxed_oxidized_cut_copper")
    square(b,6,7,77,1,2,"amethyst_block")
    b.box((-10,78,-1),(-7,78,-1),"stripped_spruce_log[axis=x]")
    b.set(-9,79,-1,"lantern")
    b.set(-8,79,-1,"decorated_pot")
    b.box((7,78,-1),(9,80,-1),"bookshelf")
    b.set(7,78,0,"lectern[facing=south]")
    b.set(8,81,-1,"soul_lantern")
    b.box((4,78,-6),(8,79,-6),"bookshelf")
    b.set(4,80,-6,"flower_pot")
    b.set(7,80,-6,"lantern")
    # A small common table and shelf, with clear aisles toward both stations.
    for x in (-1,2):
        for z in (-4,-2):
            b.set(x,78,z,"spruce_fence")
    square(b,-1,2,79,-4,-2,"spruce_slab[type=bottom]")
    b.set(0,80,-3,"lantern")
    b.set(1,80,-3,"flower_pot")
    for x in (-2,3):
        b.set(x,78,-3,"spruce_stairs[facing="+("west" if x<0 else "east")+"]")
    b.box((-1,81,-6),(3,81,-6),"spruce_slab[type=bottom]")
    b.set(0,82,-6,"flower_pot")
    b.set(2,82,-6,"lantern")
    for x in (-8,4):
        b.box((x,78,-7),(x,84,-7),"stripped_spruce_log")
    square(b,-3,3,77,0,5,"stripped_spruce_log[axis=z]")
    square(b,-2,2,78,0,4,"green_carpet")
    for x in (-9,8):
        for z in (-3,4):
            b.set(x,78,z,"spruce_stairs[facing="+("east" if x<0 else "west")+"]")
    b.label((-7.5,80,1.5),"入梦","gold")
    b.label((6.5,80,1.5),"教程","light_purple")


def upstairs(b):
    y=UPPER_FLOOR
    # A full deck with a two-block stair, continuous rails, and an open north landing.
    square(b,-10,9,y,-6,6,"spruce_planks")
    for x in (-8,-1,7):
        square(b,x,x,y,-6,6,"stripped_spruce_log[axis=z]")
    b.box((3,y,-3),(4,y,1),"air")
    for index in range(7):
        rise=78+index
        z=3-index
        if rise>78:
            b.box((3,78,z),(4,rise-1,z),"dark_oak_planks")
        square(b,3,4,rise,z,z,"spruce_stairs[facing=north]")
        if rise<83:
            b.set(5,rise,z,"stripped_dark_oak_log")
            b.set(5,rise+1,z,"spruce_fence")
    for rail in (2,5):
        b.box((rail,y+1,-3),(rail,y+1,2),"spruce_fence")
    square(b,3,4,y+1,2,2,"spruce_fence")
    square(b,2,5,y,-5,-4,"stripped_spruce_log[axis=x]")
    # Furnish the edges of the loft so the middle and landing stay available.
    for x in (-8,-7,-6):
        b.set(x,y+1,6,"spruce_stairs[facing=south]")
    for z in (-4,-3,-2):
        b.set(-10,y+1,z,"spruce_stairs[facing=west]")
    b.box((-10,y+1,3),(-10,y+2,5),"bookshelf")
    b.set(-10,y+3,4,"lantern")
    b.box((8,y+1,-6),(9,y+1,-6),"barrel[facing=south]")
    b.set(9,y+2,-6,"flower_pot")
    square(b,-6,-1,y+1,1,4,"brown_carpet")
    for x in (-7,7):
        b.set(x,91,-1,"stripped_dark_oak_log")
        b.set(x,90,-1,"chain[axis=y]")
        b.set(x,89,-1,"lantern[hanging=true]")
    for x in (-9,8):
        b.box((x,85,-6),(x,90,-6),"stripped_spruce_log")
    # Keep the chimney stack visible through the floor.
    square(b,-5,-3,y,-6,-5,"stone_bricks")


def build():
    b=Build()
    rng=random.Random(1119)
    woods_floor(b,rng)
    grove(b,rng)
    cabin(b)
    interior(b)
    upstairs(b)
    return b.lines


if __name__=="__main__":
    write(HERE/"小屋建造.mcfunction",build())
