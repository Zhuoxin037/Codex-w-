"""A two-storey hideout set behind the banks of a winding woodland path."""

from pathlib import Path
import math
import random
import runpy
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from architecture import Build, write

leaf_cluster = runpy.run_path(str(HERE.parent/"林间小屋候选"/"build.py"))["leaf_cluster"]
TIMBER = "stripped_dark_oak_log"
BARK = "dark_oak_log"
WOOD = "spruce_planks"
STONE = "tuff_bricks"
ROOF = "deepslate_tile"
LEAF = "dark_oak_leaves[persistent=true]"
UPPER_FLOOR = 83
LOWER_ENTRY = (-5,6)
PADS = ((-8,4),(13,1))
TRAIL = ((8,-5),(13,-5),(17,-7),(22,-2),(28,5),(35,5),(48,-3))
TRAIL_LIGHTS = ((-8,13),(-5,20),(3,25))


def line(b,y,x0,x1,z0,z1,material):
    b.box((x0,y,z0),(x1,y,z1),material)


def trail_x(z):
    for (near,x0),(far,x1) in zip(TRAIL,TRAIL[1:]):
        if z<=far:
            return x0+(x1-x0)*max(0,z-near)/(far-near)
    return TRAIL[-1][1]


def trail_y(z):
    return 76 if z<18 else 75 if z<25 else 76 if z<39 else 77


def branch(x):
    return 29+abs(x-5)*.19


def height(x,z):
    if -12<=x<=17 and -10<=z<=8:
        return 77 if z<8 else 76
    base=76+1.2*math.sin(x*.15+z*.06)+1.4*math.cos(z*.16-x*.085)
    for bx,bz,rx,rz,rise in ((-14,13,10,9,6),(7,16,10,8,6),(22,12,9,10,5),
                            (-16,-9,13,10,5),(9,-15,14,11,7),(18,33,9,19,4),(-13,37,12,12,4)):
        base+=rise*max(0,1-((x-bx)/rx)**2-((z-bz)/rz)**2)
    if z>=9:
        distance=abs(x-trail_x(z))
        branch_distance=abs(z-branch(x))
        if abs(x-5)<40 and branch_distance<distance:
            base=76+(base-76)*min(1,max(0,(branch_distance-1.4)/4))
        else:
            base=trail_y(z)+(base-trail_y(z))*min(1,max(0,(distance-1.5)/4.7))
    return round(base)


def on_trail(x,z):
    return (z>=8 and abs(x-trail_x(z))<1.7) or (abs(x-5)<40 and abs(z-branch(x))<1.4)


def terrain(b,rng):
    for x in range(-42,43):
        for z in range(-36,50):
            y=height(x,z)
            b.box((x,70,z),(x,y-2,z),"stone")
            b.set(x,y-1,z,"rooted_dirt")
            if on_trail(x,z):
                top=rng.choices(("coarse_dirt","dirt_path","podzol","mud_bricks"),(6,5,3,1))[0]
            elif y>=80 and rng.random()<.28:
                top=rng.choice(("mossy_cobblestone","tuff","moss_block"))
            else:
                top=rng.choices(("grass_block","moss_block","podzol","rooted_dirt"),(4,5,2,1))[0]
            b.set(x,y,z,top)
            if (not on_trail(x,z) and (z>9 or x<-12 or x>17 or z<-10) and rng.random()<.35):
                b.set(x,y+1,z,rng.choice(("fern","fern","short_grass","brown_mushroom","dead_bush")))
    for z in (17,24,38):
        for x in range(round(trail_x(z))-1,round(trail_x(z))+2):
            direction="north" if trail_y(z)>trail_y(z+1) else "south"
            b.set(x,max(trail_y(z),trail_y(z+1)),z,"mossy_stone_brick_stairs[facing="+direction+"]")
    for x,z in ((-10,11),(-11,12),(-13,14),(2,12),(3,13),(6,15),(7,15),(-1,20),(-9,24),(11,24),(13,26)):
        y=height(x,z)
        if not on_trail(x,z):
            b.set(x,y,z,"mossy_cobblestone")
            b.set(x,y+1,z,rng.choice(("mossy_cobblestone_slab[type=bottom]","cobblestone_wall","fern")))
    light_trail(b)


def light_trail(b):
    for x,z in TRAIL_LIGHTS:
        y=height(x,z)
        b.set(x,y+1,z,"mossy_cobblestone_wall")
        b.set(x,y+2,z,"lantern")


def tree(b,rng,x,z,tall,width):
    ground=height(x,z)+1
    crown=ground+tall
    trunk=int(tall>=13)
    b.box((x,ground-1,z),(x+trunk,crown-1,z+trunk),BARK)
    for dx,dz in ((1,0),(-1,0),(0,1),(0,-1)):
        for step in (1,2):
            root_x,root_z=x+dx*step,z+dz*step
            if not on_trail(root_x,root_z):
                root=height(root_x,root_z)
                b.set(root_x,root+1,root_z,"mangrove_roots")
        y=crown-rng.randint(4,7)
        length=rng.randint(2,width-1)
        for step in range(1,length+1):
            b.set(x+dx*step,y+step//2,z+dz*step,BARK+("[axis=x]" if dx else "[axis=z]"))
        leaf_cluster(b,rng,x+dx*length,y+3,z+dz*length,width-1,2,width-1,LEAF)
    leaf_cluster(b,rng,x,crown,z,width,3,width,LEAF)


def woods(b,rng,open_front=False):
    near_right=(10,15,12,4) if open_front else (4,14,12,5)
    trunks=((-15,7,14,6),(18,-1,16,6),(-15,-11,18,6),(-5,-14,15,5),(12,-16,19,5),
            (-12,15,13,6),near_right,(14,16,15,6),(-13,23,17,5),(8,24,14,4),
            (-5,29,15,6),(15,31,17,5))
    placed=[(x,z) for x,z,_,_ in trunks]
    for x,z,h,w in trunks:
        tree(b,rng,x,z,h,w)
    for _ in range(780):
        x,z=rng.randint(-39,39),rng.randint(-33,47)
        if (-16<x<20 and -14<z<25) or (z>=9 and abs(x-trail_x(z))<4) or abs(z-branch(x))<3:
            continue
        if any((x-px)**2+(z-pz)**2<50 for px,pz in placed):
            continue
        placed.append((x,z))
        tree(b,rng,x,z,rng.randint(12,20),rng.randint(4,6))
    front_scrub=((3,16,2),(7,15,2)) if open_front else ((1,14,3),(5,15,4))
    for x,z,w in ((-12,11,3),(-10,17,2),(-12,20,3),*front_scrub,(4,20,3),
                  (10,18,3),(15,10,3),(-13,4,3),(17,7,3),(10,27,2)):
        leaf_cluster(b,rng,x,height(x,z)+1,z,w,1,2,LEAF)


def glazed(b,wall,at,center,bottom,palette):
    front=wall in ("south","north")
    out=1 if wall in ("south","east") else -1
    across="x" if front else "z"

    def place(u,y,depth,material):
        pos=(u,y,at+out*depth) if front else (at+out*depth,y,u)
        b.set(*pos,material)

    for i,u in enumerate(range(center-1,center+2)):
        for y in (bottom,bottom+1):
            place(u,y,0,palette[(i+y-bottom)%len(palette)])
        place(u,bottom-1,1,"dark_oak_slab[type=top]")
        place(u,bottom+2,1,TIMBER+"[axis="+across+"]")
    for y in (bottom,bottom+1):
        place(center,y,1,"spruce_fence")
        place(center-2,y,1,"spruce_trapdoor[open=true,facing="+wall+"]")
        place(center+2,y,1,"dark_oak_trapdoor[open=true,facing="+wall+"]")


AMBER=("brown_stained_glass","orange_stained_glass","orange_stained_glass")


def shell(b):
    b.box((-11,75,-8),(11,76,8),"mossy_cobblestone")
    line(b,77,-10,10,-7,7,WOOD)
    b.shell(-10,10,78,80,-7,7,STONE)
    b.shell(-10,10,81,85,-7,7,"dark_oak_planks")
    for x,z,axis in ((-10,-7,"x"),(-10,7,"x"),(-10,-7,"z"),(10,-7,"z")):
        end=(10,83,z) if axis=="x" else (x,83,7)
        b.box((x,83,z),end,TIMBER+"[axis="+axis+"]")
    for z in (-7,7):
        for x in (-10,-7,-3,1,8,10):
            b.box((x,79,z),(x,85,z),TIMBER)
    for x in (-10,10):
        for z in (-4,3):
            b.box((x,79,z),(x,85,z),TIMBER)
    for x,z in ((-9,7),(-8,7),(-7,7),(0,7),(1,7),(7,7),(8,7),(9,7),(-10,4),(-10,5),(-10,-5),(10,-6)):
        b.set(x,78,z,"mossy_stone_bricks")
        if (x+z)%3:
            b.set(x,79,z,"mossy_cobblestone")
    for x,z in ((-9,7),(-8,7),(-1,7),(0,7),(8,7),(9,7),(-10,5)):
        b.set(x,81,z,"packed_mud")
        b.set(x,82,z,"packed_mud")
    glazed(b,"south",7,4,80,AMBER)
    glazed(b,"north",-7,-5,80,AMBER)
    b.box((-6,78,7),(-4,80,7),"air")
    line(b,77,-8,-2,8,10,WOOD)
    line(b,77,-6,-4,11,11,"mossy_stone_brick_stairs[facing=north]")
    for x in (-8,-3):
        b.box((x,78,10),(x,81,10),BARK)
        b.set(x,78,10,"mossy_cobblestone")
        b.set(x,80,9,"dark_oak_stairs[half=top,facing=north]")
    line(b,81,-8,-3,10,10,TIMBER+"[axis=x]")
    line(b,82,-9,-2,9,11,"dark_oak_slab[type=top]")
    line(b,83,-9,-2,8,9,"deepslate_tile_stairs[facing=north]")
    line(b,83,-9,-2,10,11,"deepslate_tile_slab[type=bottom]")
    b.set(-7,81,9,"lantern[hanging=true]")
    b.set(-8,79,8,"barrel[facing=up]")
    b.set(-8,80,8,"flower_pot")
    for x,z in ((-8,11),(-7,11),(-7,8)):
        b.set(x,77,z,"dark_oak_slab[type=top]")
    b.set(-9,83,11,"mossy_cobblestone_slab[type=bottom]")
    b.set(-2,82,10,"spruce_trapdoor[half=top,facing=east]")
    for x,z in ((-10,8),(-10,9),(-9,9),(-9,10),(-2,9),(0,8),(1,8),(9,8),(10,8)):
        b.set(x,77,z,"mossy_cobblestone")
        if (x+z)%2:
            b.set(x,78,z,"moss_carpet")
    for x,low,high in ((-9,79,84),(-8,82,85),(0,79,84),(8,81,83),(9,80,84)):
        b.box((x,low,8),(x,high,8),"vine[north=true]")


def roof(b,rng):
    for z in range(-9,10):
        y=max(85,93-abs(z))
        facing="south" if z<0 else "north"
        slope=ROOF+"_stairs[facing="+facing+"]" if 0<abs(z)<9 else ROOF+"_slab[type=bottom]"
        line(b,y,-12,12,z,z,slope)
        line(b,y-1,-12,12,z,z,"deepslate_tiles")
        if abs(z)<=7:
            for x in (-10,10):
                if y>=87:
                    b.box((x,86,z),(x,y-1,z),"dark_oak_planks")
                if z in (-3,0,3):
                    b.box((x,85,z),(x,y-1,z),TIMBER)
        for x in (-12,12):
            edge="polished_deepslate_stairs[facing="+facing+",half=top]"
            b.set(x,y-1,z,edge if 0<abs(z)<9 else "polished_deepslate")
        for x in range(-11,12):
            moss_region=((x+8)/4)**2+((z-5)/3.6)**2<1 or ((x-8)/3.2)**2+((z+5)/3)**2<1
            if moss_region and rng.random()<.72 and z:
                material="mossy_cobblestone_stairs[facing="+facing+"]" if abs(z)<9 else "mossy_cobblestone_slab"
                b.set(x,y,z,material)
    for x,z in ((-10,7),(-8,7),(-9,8),(-11,8),(9,-8),(10,-8)):
        y=max(85,93-abs(z))
        b.set(x,y+1,z,"moss_carpet")
    # The dormer projects from beneath the long roof and opens onto the upper reading nook.
    b.box((3,84,6),(7,90,8),"air")
    line(b,83,2,8,6,8,WOOD)
    for x in (2,8):
        b.box((x,84,5),(x,88,8),TIMBER)
    b.shell(2,8,84,88,8,8,"dark_oak_planks")
    for x in range(1,10):
        y=92-abs(x-5)
        slope=ROOF+"_stairs[facing="+("east" if x<5 else "west")+"]" if x!=5 else ROOF+"_slab[type=bottom]"
        line(b,y,x,x,4,9,slope)
        line(b,y-1,x,x,4,9,"deepslate_tiles")
        if 3<=x<=7:
            b.box((x,89,8),(x,y-2,8),"dark_oak_planks")
            b.set(x,y-1,8,TIMBER+"[axis=x]")
    glazed(b,"south",8,5,85,AMBER)
    glazed(b,"east",10,-1,85,AMBER)
    glazed(b,"west",-10,-2,85,AMBER)
    # A crooked stack marks the hearth at the other end of the cabin.
    b.box((-10,88,-1),(-8,93,1),"stone_bricks")
    b.box((-10,84,0),(-9,87,1),"cracked_stone_bricks")
    b.box((-10,92,-1),(-8,93,1),"cracked_stone_bricks")
    line(b,94,-11,-7,-2,2,"stone_brick_slab[type=bottom]")
    b.set(-9,94,0,"campfire[lit=true]")


def annex(b):
    b.box((10,75,-5),(16,76,4),"mossy_cobblestone")
    line(b,77,10,16,-5,4,WOOD)
    b.shell(10,16,78,81,-5,4,STONE)
    b.box((10,78,0),(10,80,3),"air")
    for x,z in ((11,4),(16,4),(16,-5),(11,-5)):
        b.box((x,79,z),(x,82,z),TIMBER)
        b.set(x,78,z,"mossy_stone_bricks")
    for z in range(-6,6):
        y=86-abs(z+1)
        facing="south" if z<-1 else "north"
        slope=ROOF+"_stairs[facing="+facing+"]" if z!=-1 else ROOF+"_slab[type=bottom]"
        line(b,y,11,17,z,z,slope)
        line(b,y-1,11,17,z,z,"deepslate_tiles")
        if -5<=z<=4 and y>83:
            b.box((16,82,z),(16,y-1,z),"dark_oak_planks")
    glazed(b,"south",4,13,79,AMBER)
    glazed(b,"east",16,0,79,AMBER)
    line(b,78,12,14,5,5,"dark_oak_trapdoor[open=true,facing=south]")
    line(b,77,12,14,5,5,"moss_block")
    b.set(12,78,5,"fern")
    b.set(14,78,5,"brown_mushroom")
    # A low patch in old oxidized copper reads as a repair among the slate.
    for z in (1,2,3):
        for x in range(14 if z!=2 else 13,17):
            b.set(x,86-abs(z+1),z,"waxed_weathered_cut_copper_stairs[facing=north]")
    annex_interior(b)


def annex_interior(b):
    line(b,77,12,13,1,2,"amethyst_block")
    b.box((12,78,-4),(15,80,-4),"bookshelf")
    b.set(12,79,-4,"chiseled_bookshelf[facing=south,slot_0_occupied=true,slot_2_occupied=true]")
    b.set(13,79,-4,"chiseled_bookshelf[facing=south,slot_1_occupied=true,slot_4_occupied=true]")
    b.set(14,78,-4,"barrel[facing=south]")
    line(b,81,12,15,-4,-4,"spruce_slab[type=bottom]")
    line(b,82,11,16,-2,-2,TIMBER+"[axis=x]")
    b.set(13,81,-2,"chain")
    b.set(13,80,-2,"lantern[hanging=true]")
    b.set(13,78,-1,"lectern[facing=south]")
    b.set(15,78,2,"cartography_table")
    b.set(15,79,2,"flower_pot")
    b.set(15,78,3,"dark_oak_stairs[facing=east]")
    b.label((13,80,1.5),"教程","light_purple")


def stair_and_floors(b):
    line(b,83,-9,9,-6,6,WOOD)
    b.box((2,83,-3),(3,83,0),"air")
    for step in range(6):
        y,z=78+step,2-step
        line(b,y,2,3,z,z,"dark_oak_stairs[facing=north]")
        if step:
            line(b,y-1,2,3,z,z,TIMBER+"[axis=z]")
        if step>1:
            b.set(4,y,z,"dark_oak_slab[type=top]")
        b.set(4,y+1,z,"spruce_fence")
    for x in (1,4):
        b.box((x,84,-3),(x,84,1),"spruce_fence")
    line(b,84,2,3,1,1,"spruce_fence")
    line(b,83,1,4,-4,-4,TIMBER+"[axis=x]")
    for z in (-6,5):
        line(b,83,-9,9,z,z,"stripped_spruce_log[axis=x]")
    for z in (-5,0,5):
        line(b,82,-9,9,z,z,TIMBER+"[axis=x]")
        for x in (-9,9):
            b.set(x,81,z,"dark_oak_stairs[half=top,facing="+("east" if x<0 else "west")+"]")
    # Preserve both treads where a ceiling beam crosses the opening.
    line(b,82,2,3,0,0,"air")
    for x,z in ((-3,-4),(-3,4),(6,-2),(7,3)):
        b.set(x,82,z,TIMBER)
        b.set(x,81,z,"chain[axis=y]")
        b.set(x,80,z,"lantern[hanging=true]")


def rug(b,y,x0,x1,z0,z1,border,field):
    line(b,y,x0,x1,z0,z1,border+"_carpet")
    line(b,y,x0+1,x1-1,z0+1,z1-1,field+"_carpet")
    for x,z in ((x0,z0),(x0,z1),(x1,z0),(x1,z1)):
        b.set(x,y,z,"air")
    for x in (x0+1,x1-1):
        for z in (z0+1,z1-1):
            b.set(x,y,z,"gray_carpet")
    center=(x0+x1)//2
    for z in (z0+1,z1-1):
        b.set(center,y,z,"gray_carpet")


def trestle(b,y,x0,x1,z0,z1):
    line(b,y,x0+1,x1-1,z0,z1,"spruce_slab[type=top]")
    for x in (x0,x1):
        facing="east" if x==x0 else "west"
        line(b,y,x,x,z0,z1,"spruce_stairs[half=top,facing="+facing+"]")


def ground_interior(b):
    line(b,77,-9,-8,3,4,"waxed_oxidized_cut_copper")
    b.set(-9,78,5,"barrel[facing=up]")
    b.set(-9,79,5,"lantern")
    b.set(-9,78,6,"dark_oak_stairs[facing=west]")
    b.label((-8.5,80,4),"入梦","gold")
    b.box((-10,78,-3),(-9,83,2),"mossy_stone_bricks")
    b.box((-9,78,-2),(-9,79,1),"air")
    for z in (-2,-1,0,1):
        b.set(-10,79,z,"cracked_stone_bricks")
        b.set(-8,78,z,"stone_brick_slab[type=bottom]")
    for z in (-1,0):
        b.set(-9,78,z,"campfire[lit=true]")
    b.box((-8,79,-3),(-8,80,-3),"cobblestone_wall")
    b.box((-8,79,2),(-8,80,2),"cobblestone_wall")
    line(b,80,-9,-8,-3,2,"stone_brick_stairs[half=top,facing=east]")
    line(b,81,-9,-8,-3,2,TIMBER+"[axis=z]")
    b.set(-8,82,-2,"flower_pot")
    b.set(-8,82,1,"lantern")
    line(b,77,-8,-6,-2,1,"mossy_stone_bricks")
    b.set(-9,78,-5,"spruce_log[axis=x]")
    b.set(-9,79,-5,"spruce_log[axis=x]")
    b.set(-9,78,-4,"spruce_log[axis=x]")
    rug(b,78,-6,0,-3,3,"brown","green")
    line(b,78,-6,-3,-5,-5,"dark_oak_stairs[facing=north]")
    for x in (-7,-2):
        b.set(x,78,-5,"dark_oak_trapdoor[open=true,facing="+("east" if x==-7 else "west")+"]")
    trestle(b,78,-6,-3,-2,-1)
    b.set(-6,79,-2,"potted_fern")
    b.set(-3,79,-1,"brown_candle[candles=2,lit=true]")
    b.set(-4,79,-2,"flower_pot")
    b.set(-7,78,1,"spruce_stairs[facing=south]")
    b.set(-6,78,1,"spruce_stairs[facing=south]")
    b.box((5,78,-6),(8,80,-6),"bookshelf")
    b.set(5,78,-6,"barrel[facing=south]")
    b.set(6,78,-6,"barrel[facing=south]")
    line(b,81,5,8,-6,-6,"dark_oak_slab[type=bottom]")
    b.set(7,78,-3,"cartography_table")
    b.set(7,79,-3,"lantern")
    b.set(7,78,-2,"dark_oak_stairs[facing=south]")


def study(b, window_seat_z=7, roof_heights=None):
    rug(b,84,-5,0,-1,5,"brown","gray")
    for x,z0,z1 in ((-9,-5,-4),(-9,2,5),(9,2,5)):
        b.box((x,84,z0),(x,86,z1),"bookshelf")
        line(b,87,x,x,z0,z1,"dark_oak_slab[type=bottom]")
    for x,z in ((-9,-4),(-9,2),(9,5)):
        b.set(x,84,z,"barrel[facing=up]")
    for x,z in ((-9,-5),(-9,3),(-9,5),(9,4)):
        b.set(x,86,z,"chiseled_bookshelf[facing="+("east" if x<0 else "west")+
              ",slot_0_occupied=true,slot_1_occupied=true,slot_3_occupied=true]")
    beam_heights={}
    for z in (-3,0,3):
        underside=92-abs(z) if roof_heights is None else roof_heights[z]-1
        y=min(89 if z==0 else 88,underside)
        beam_heights[z]=y
        line(b,y,-7,7,z,z,TIMBER+"[axis=x]")
        for x in (-7,7):
            b.set(x,y-1,z,"dark_oak_stairs[facing="+("east" if x<0 else "west")+",half=top]")
            b.box((x,y,z),(x,underside,z),TIMBER)
    for x,z in ((-4,0),(6,3),(-5,-3)):
        y=beam_heights[z]
        b.set(x,y-1,z,"chain[axis=y]")
        b.set(x,y-2,z,"lantern[hanging=true]")
    # Writing desk by the west window and a bench below the front window.
    b.set(-9,84,-3,"barrel[facing=east]")
    b.set(-9,84,-1,"dark_oak_stairs[half=top,facing=north]")
    b.set(-9,84,-2,"spruce_slab[type=top]")
    b.set(-9,85,-3,"lantern")
    b.set(-7,84,-2,"dark_oak_stairs[facing=east]")
    b.set(-8,85,0,"potted_fern")
    b.set(-8,84,0,"barrel[facing=up]")
    foot=window_seat_z-1
    line(b,84,3,7,window_seat_z,window_seat_z,"dark_oak_stairs[facing=south]")
    line(b,84,4,6,foot,foot,"brown_carpet")
    b.set(7,84,foot,"barrel[facing=up]")
    b.set(7,85,foot,"lantern")
    b.set(3,84,foot,"barrel[facing=up]")
    b.set(3,85,foot,"potted_fern")
    line(b,84,-4,-1,4,4,"spruce_stairs[facing=south]")
    trestle(b,84,-4,-1,2,2)
    b.set(-4,85,2,"brown_candle[candles=2,lit=true]")
    b.set(-1,85,2,"potted_fern")


def build():
    b=Build()
    rng=random.Random(19406)
    terrain(b,rng)
    woods(b,rng)
    shell(b)
    roof(b,rng)
    annex(b)
    stair_and_floors(b)
    ground_interior(b)
    study(b)
    return b.lines


if __name__=="__main__":
    write(HERE/"小屋建造.mcfunction",build())
