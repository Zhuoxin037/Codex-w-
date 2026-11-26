"""Woodland lobby with a stone ground floor and a usable timber-framed upper storey."""
from pathlib import Path
import math
import random
import runpy
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from architecture import Build, write

woodland = runpy.run_path(str(HERE.parent/"林间小屋候选"/"build.py"))
height = woodland["height"]
UPPER_FLOOR = 83
LOWER_ENTRY = (-3,5)
PADS = ((-5,2),(9,2))
STONE = "tuff_bricks"
BEAM = "stripped_dark_oak_log"
PLASTER = "white_terracotta"
ROOF = "deepslate_tile"


def rectangle(b,x0,x1,y,z0,z1,material):
    b.box((x0,y,z0),(x1,y,z1),material)


def approach(z):
    return -3+5*math.sin((z-10)*.072)


def grounds(b,rng):
    for x in range(-48,49):
        for z in range(-41,53):
            y=height(x,z)
            b.box((x,y-4,z),(x,y-2,z),"stone")
            b.set(x,y-1,z,"dirt")
            b.set(x,y,z,"grass_block")
            on_path=z>=9 and abs(x-approach(z))<(1.7+.48*math.cos(z*.33))
            on_branch=-39<x<39 and abs(z-(19+abs(x)*.11))<1.3
            if on_path or on_branch:
                material=rng.choices(("dirt_path","coarse_dirt","mossy_cobblestone","gravel"),(8,4,1,1))[0]
                b.set(x,y,z,material)
            elif rng.random()<.23:
                b.set(x,y,z,rng.choice(("moss_block","podzol","rooted_dirt")))
            elif rng.random()<.40 and (abs(x)>14 or abs(z)>12):
                b.set(x,y+1,z,rng.choice(("short_grass","fern","short_grass","fern","brown_mushroom")))
    for x,z in ((-13,12),(-13,15),(12,12),(15,10),(11,-9),(-16,-4),(-19,22),(15,24)):
        y=height(x,z)
        b.box((x-1,y,z-1),(x+1,y+1,z+1),"mossy_cobblestone")
        b.set(x,y+1,z,"moss_block")
        b.set(x-1,y+2,z,"mossy_cobblestone_slab[type=bottom]")
    for x,z in ((-9,11),(-10,13),(-8,12),(-6,14),(2,11),(3,13),(4,12),(12,9),(11,10),
                (-6,21),(-5,20),(-7,22),(10,19),(11,18)):
        y=height(x,z)
        b.set(x,y,z,"moss_block")
        b.set(x,y+1,z,rng.choice(("poppy","azure_bluet","fern","white_tulip")))
    for z in (14,24,32):
        x=round(approach(z))+(3 if z!=24 else -3)
        y=height(x,z)
        b.set(x,y+1,z,"mossy_cobblestone")
        b.set(x,y+2,z,"spruce_fence")
        b.set(x,y+3,z,"lantern")


def mixed_stone(b,rng):
    b.box((-8,75,-10),(7,76,7),"mossy_cobblestone")
    rectangle(b,-7,6,77,-9,6,"spruce_planks")
    b.shell(-7,6,78,82,-9,6,STONE)
    stone_options=(STONE,STONE,STONE,"stone_bricks","andesite","mossy_stone_bricks")
    for x in range(-7,7):
        for z in (-9,6):
            for y in range(78,83):
                b.set(x,y,z,rng.choice(stone_options if y<81 else (STONE,STONE,"stone_bricks")))
    for z in range(-8,6):
        for x in (-7,6):
            for y in range(78,83):
                b.set(x,y,z,rng.choice(stone_options if y<81 else (STONE,STONE,"stone_bricks")))
    for x,z in ((-7,-9),(-7,6),(6,-9),(6,6)):
        b.box((x,78,z),(x,82,z),"stone_bricks")


def framing(b):
    b.shell(-7,6,83,88,-9,6,PLASTER)
    for y in (83,88):
        for z in (-9,6):
            b.box((-7,y,z),(6,y,z),BEAM+"[axis=x]")
        for x in (-7,6):
            b.box((x,y,-9),(x,y,6),BEAM+"[axis=z]")
    for x in (-7,-2,1,6):
        for z in (-9,6):
            b.box((x,84,z),(x,87,z),BEAM)
    for z in (-5,0,3):
        for x in (-7,6):
            b.box((x,84,z),(x,87,z),BEAM)
    for x,z in ((-7,-9),(-7,6),(6,-9),(6,6)):
        dx,dz=(-1 if x<0 else 1),(-1 if z<0 else 1)
        for p in ((x+dx,z),(x,z+dz)):
            b.box((p[0],83,p[1]),(p[0],87,p[1]),BEAM)
            b.set(p[0],82,p[1],"stone_brick_stairs[facing="+("west" if dx<0 else "east")+",half=top]")
    for x,z in ((-6,6),(5,6),(-7,-7),(6,4),(-6,-9),(5,-9)):
        b.set(x,85,z,"calcite")
        b.set(x,84,z,"calcite")


def main_roof(b):
    # The steep gable presents its narrow end to the forest path.
    profiles=(8,7,6,5,4,3,2,1,0)
    for x in range(-9,8):
        peak=89+profiles[abs(x+1)]
        facing="east" if x<-1 else "west"
        roof=ROOF+"_slab[type=bottom]" if x==-1 else (
            ROOF+"_stairs[facing="+facing+"]")
        rectangle(b,x,x,peak,-11,8,roof)
        rectangle(b,x,x,peak-1,-11,8,"deepslate_tiles")
        if -7<=x<=6:
            for z in (-9,6):
                if peak>=91:
                    b.box((x,89,z),(x,peak-2,z),PLASTER)
                b.set(x,peak-1,z,BEAM+"[axis=x]")
        for z in (-11,8):
            fascia="polished_deepslate" if x==-1 else (
                "polished_deepslate_stairs[facing="+facing+",half=top]")
            b.set(x,peak-1,z,fascia)
    for z in (-9,6):
        b.box((-1,89,z),(-1,94,z),BEAM)
        for dx in (-1,1):
            for h in range(3):
                b.set(-1+dx*(h+2),92-h,z,BEAM)
    b.box((-6,78,-7),(-4,97,-5),"stone_bricks")
    b.box((-6,98,-7),(-4,100,-5),"bricks")
    rectangle(b,-7,-3,100,-8,-4,"stone_brick_slab[type=top]")
    rectangle(b,-6,-4,101,-7,-5,"bricks")
    b.set(-5,101,-6,"campfire[lit=true]")


def recess_window(b,wall,at,center,bottom):
    forward=wall in ("south","north")
    outward=1 if wall in ("south","east") else -1

    def point(u,y,depth=0):
        edge=at+outward*depth
        return (u,y,edge) if forward else (edge,y,u)

    for u in (center-1,center,center+1):
        for y in range(bottom,bottom+3):
            b.set(*point(u,y),"orange_stained_glass")
        b.set(*point(u,bottom-1,1),"spruce_slab[type=top]")
        b.set(*point(u,bottom+3,1),BEAM+"[axis="+("x" if forward else "z")+"]")
    for u in (center-2,center+2):
        for y in range(bottom,bottom+3):
            b.set(*point(u,y,1),"spruce_trapdoor[open=true,facing="+wall+"]")
    for y in range(bottom,bottom+3):
        b.set(*point(center,y,1),"dark_oak_fence")
    b.set(*point(center,bottom+3,-1),BEAM)
    b.set(*point(center,bottom+2,-1),"lantern[hanging=true]")


def entrance(b):
    rectangle(b,-6,0,77,6,10,"spruce_planks")
    for x in (-4,-3,-2):
        b.set(x,77,11,"spruce_stairs[facing=north]")
    b.box((-4,78,6),(-2,80,6),"air")
    for x in (-5,-1):
        b.box((x,78,6),(x,81,6),BEAM)
        b.set(x,78,6,"mossy_stone_bricks")
    b.box((-5,81,6),(-1,81,6),BEAM+"[axis=x]")
    for x in (-6,0):
        b.box((x,78,10),(x,82,10),BEAM)
        b.set(x,78,10,"stone_bricks")
    for z in range(7,12):
        h=85-(z-7)//2
        rectangle(b,-7,1,h,z,z,ROOF+"_stairs[facing=north]")
        rectangle(b,-7,1,h-1,z,z,"deepslate_tiles")
    for x in (-5,-1):
        b.set(x,82,9,BEAM)
        b.set(x,81,9,"lantern[hanging=true]")
    b.set(-7,77,10,"mossy_cobblestone")
    b.set(1,77,9,"mossy_cobblestone")


def reading_bay(b):
    # The offset single-storey bay has its own low cross roof.
    b.box((6,75,-2),(12,76,6),"mossy_cobblestone")
    rectangle(b,6,12,77,-2,6,"spruce_planks")
    b.shell(6,12,78,82,-2,6,STONE)
    b.box((6,78,-1),(6,81,5),"air")
    for x,z in ((12,-2),(12,6),(6,-2),(6,6)):
        b.box((x,79,z),(x,82,z),BEAM)
    for z in range(-3,8):
        y=84+5-abs(z-2)
        slope=ROOF+"_slab[type=bottom]" if z==2 else (
            ROOF+"_stairs[facing="+("north" if z>2 else "south")+"]")
        rectangle(b,7,13,y, z,z,slope)
        rectangle(b,7,13,y-1,z,z,"deepslate_tiles")
        if -2<=z<=6:
            b.box((12,83,z),(12,max(83,y-2),z),PLASTER)
            if z in (0,2,4):
                b.box((12,83,z),(12,max(83,y-2),z),BEAM)
    recess_window(b,"south",6,10,79)
    recess_window(b,"east",12,3,79)
    for x in (9,10,11):
        b.set(x,77,8,"moss_block")
        b.set(x,77,9,"spruce_trapdoor[facing=south,open=true]")
    b.set(9,78,8,"fern")
    b.set(10,78,8,"azure_bluet")
    b.set(11,78,8,"poppy")


def windows(b):
    recess_window(b,"south",6,3,79)
    for x in (-4,3):
        recess_window(b,"south",6,x,85)
        recess_window(b,"north",-9,x,85)
    for z in (-6,1):
        recess_window(b,"west",-7,z,79)
        recess_window(b,"west",-7,z,85)
    recess_window(b,"east",6,-6,85)


def floors(b):
    y=UPPER_FLOOR
    rectangle(b,-6,5,y,-8,5,"spruce_planks")
    b.box((0,y,-2),(1,y,1),"air")
    for step in range(6):
        rise,z=78+step,3-step
        rectangle(b,0,1,rise,z,z,"spruce_stairs[facing=north]")
        if step:
            rectangle(b,0,1,rise-1,z,z,"dark_oak_planks")
    for z,rise in ((1,79),(-1,81)):
        b.box((1,78,z),(1,rise,z),BEAM)
    for x in (-1,2):
        b.box((x,y+1,-2),(x,y+1,2),"spruce_fence")
    rectangle(b,0,1,y+1,2,2,"spruce_fence")
    rectangle(b,-1,2,y,-4,-3,BEAM+"[axis=x]")
    rectangle(b,-4,3,y+1,3,4,"brown_carpet")
    rectangle(b,-4,3,y+1,5,5,"red_carpet")
    # Only booths on the ground level will connect to lobby interactions.
    rectangle(b,-6,-5,77,1,2,"waxed_oxidized_cut_copper")
    rectangle(b,8,9,77,1,2,"amethyst_block")
    b.set(-6,78,0,"barrel[facing=up]")
    b.set(-6,79,0,"lantern")
    b.set(8,78,0,"lectern[facing=south]")
    b.box((10,78,-1),(11,79,-1),"bookshelf")
    b.label((-5.5,80,1.5),"入梦","gold")
    b.label((8.5,80,1.5),"教程","light_purple")
    b.box((-6,78,-4),(-4,79,-4),"mossy_stone_bricks")
    b.set(-5,79,-4,"campfire[lit=true]")
    rectangle(b,-6,-4,81,-4,-4,BEAM+"[axis=x]")
    rectangle(b,-5,-3,78,-2,0,"brown_carpet")
    rectangle(b,-4,-4,78,-2,0,"red_carpet")
    for x in (3,5):
        b.set(x,78,-4,"spruce_fence")
    rectangle(b,3,5,79,-5,-3,"spruce_slab[type=bottom]")
    b.set(4,80,-4,"lantern")
    b.set(3,78,-2,"spruce_stairs[facing=north]")
    b.set(5,78,-2,"spruce_stairs[facing=north]")
    b.box((-6,84,3),(-6,85,5),"bookshelf")
    b.set(-6,86,4,"lantern")
    for x in (3,4):
        b.set(x,84,5,"spruce_stairs[facing=south]")
    for z in (2,3):
        b.set(5,84,z,"spruce_stairs[facing=east]")
    b.box((-7,89,1),(6,89,1),BEAM+"[axis=x]")
    b.set(-2,88,1,"chain[axis=y]")
    b.set(-2,87,1,"lantern[hanging=true]")


def build():
    b=Build()
    rng=random.Random(80517)
    grounds(b,rng)
    woodland["grove"](b,rng)
    mixed_stone(b,rng)
    framing(b)
    main_roof(b)
    entrance(b)
    reading_bay(b)
    windows(b)
    floors(b)
    return b.lines


if __name__=="__main__":
    write(HERE/"小屋建造.mcfunction",build())
