"""Sculpted oaks around the entrance and a staggered stand of spruce farther uphill."""

from pathlib import Path
import math
import random
import runpy

HERE=Path(__file__).resolve().parent
house=runpy.run_path(str(HERE.parent/"林间隐屋_新门与屋顶候选"/"build.py"))
terrain=house["hideout"]
height=terrain["height"]
on_trail=terrain["on_trail"]
trail_x=house["trail_x"]
UPPER_FLOOR=house["UPPER_FLOOR"]
LOWER_ENTRY=house["LOWER_ENTRY"]
PADS=house["PADS"]
OAK="dark_oak_wood"
OAK_LEAVES="oak_leaves[persistent=true]"
SPRUCE_LEAVES="spruce_leaves[persistent=true]"
AZALEA="azalea_leaves[persistent=true]"


def boughs(b,origin,chains,material):
    bark={}
    for chain in chains:
        for a,c in zip(chain,chain[1:]):
            delta=[c[i]-a[i] for i in range(3)]
            steps=max(map(abs,delta))
            grain="xyz"[max(range(3),key=lambda i:abs(delta[i]))]
            position=list(a)
            for step in range(steps+1):
                target=[round(a[i]+delta[i]*step/steps) for i in range(3)]
                for axis in (1,0,2):
                    while position[axis]!=target[axis]:
                        bark[tuple(position)]=grain
                        position[axis]+=1 if target[axis]>position[axis] else -1
                bark[tuple(position)]=grain
    for point,grain in bark.items():
        b.set(*(base+offset for base,offset in zip(origin,point)),material+"[axis="+grain+"]")


def canopy(b,rng,c,rx,ry,rz,material):
    cx,cy,cz=c
    # Offset lobes share an irregular shell. Inner leaves stay dense along the bough.
    for y in range(-ry,ry+1):
        for x in range(-rx,rx+1):
            cut=(x/rx)**2+(y/ry)**2
            radius=rz*math.sqrt(max(0,1.08-cut))
            if cut>1.08:
                continue
            left=min(rz,round(radius+rng.uniform(-1,.55)))
            right=min(rz,round(radius+rng.uniform(-1,.55)))
            if left+right<0:
                continue
            b.box((cx+x,cy+y,cz-left),(cx+x,cy+y,cz+right),material)


def old_oak(b,rng,x,z,low_fork,mirror):
    base=height(x,z)
    origin=(x,base,z)
    if low_fork:
        main=((0,0,0),(0,4,0),(-1,7,0),(-2,10,-1),(-3,13,-1),(-3,15,-2))
        forks=(((0,3,0),(2,6,0),(4,8,-1),(5,10,-1)),
               ((-1,7,0),(-2,9,2),(-4,11,3)),
               ((-2,10,-1),(-2,11,-3),(-1,13,-5)))
        lobes=((-3,15,-2,4,2,3),(-5,14,-1,3,2,3),(-4,12,3,3,2,3),
               (-1,14,-5,3,2,3),(5,11,-1,4,2,3),(3,12,-2,3,2,2),
               (5,11,-4,3,2,2),(7,10,0,2,1,2),(-2,13,1,3,2,3))
    else:
        main=((0,0,0),(0,5,0),(1,8,-1),(1,11,-1),(3,14,-2),(4,17,-2))
        forks=(((0,5,0),(-2,8,0),(-4,10,1),(-5,12,1)),
               ((1,8,-1),(2,11,1),(3,13,4)),
               ((1,11,-1),(0,13,-3),(-2,14,-4)),
               ((1,8,-1),(3,9,-2),(4,9,-3)))
        lobes=((4,17,-2,4,2,4),(2,16,0,3,2,3),(-5,13,1,4,2,3),(-7,12,0,2,1,2),
               (-3,14,1,3,2,3),(3,14,4,3,2,3),(-2,15,-4,4,2,3),(6,16,-3,3,2,2),
               (3,15,-6,2,2,2),(5,9,-3,3,1,2),(4,10,-5,2,1,2))
    for dx,dy,dz,rx,ry,rz in lobes:
        canopy(b,rng,(x+mirror*dx,base+dy,z+dz),rx,ry,rz,OAK_LEAVES)
    chains=[[(dx*mirror,dy,dz) for dx,dy,dz in chain] for chain in (main,*forks)]
    boughs(b,origin,chains,OAK)
    for dx,dz in ((0,-1),(1,0),(-1,0),(0,1)):
        root_x,root_z=x+dx,z+dz
        if on_trail(root_x,root_z):
            continue
        root=height(root_x,root_z)
        b.set(root_x,root,root_z,"rooted_dirt")
        b.box((root_x,root+1,root_z),(root_x,max(base+1,root+1),root_z),OAK)
        end_x,end_z=x+2*dx,z+2*dz
        if not on_trail(end_x,end_z):
            end=height(end_x,end_z)
            b.set(end_x,end,end_z,"rooted_dirt")
    b.box((x+mirror,base+1,z),(x+mirror,base+3,z),OAK)


def spruce(b,rng,x,z,tall):
    base=height(x,z)
    lean=rng.choice((-1,0,1))
    origin=(x,base,z)
    for layer,radius in enumerate((3,4,3,2,2,1)):
        y=tall-11+layer*2
        center_x=x+(lean if y>tall//2 else 0)
        lateral=rng.choice((-1,0,1))
        canopy(b,rng,(center_x,base+y,z+lateral),radius,2 if layer<4 else 1,radius,SPRUCE_LEAVES)
        if layer<3:
            dx,dz=rng.choice(((1,0),(-1,0),(0,-1),(0,1)))
            b.set(center_x+radius*dx,base+y-1,z+lateral+radius*dz,SPRUCE_LEAVES)
    boughs(b,origin,(((0,0,0),(0,tall//2,0),(lean,tall//2+2,0),(lean,tall-2,0)),),"spruce_log")
    b.set(x+lean,base+tall,z,SPRUCE_LEAVES)


def young_oak(b,rng,x,z,tall):
    base=height(x,z)
    bend=rng.choice((-1,1))
    for dx,dy,dz,rx,ry,rz in ((bend,tall,0,3,2,2),(2*bend,tall-1,1,2,1,2),
                             (-bend,tall-2,-1,2,1,2),(bend,tall-1,-2,2,1,2)):
        canopy(b,rng,(x+dx,base+dy,z+dz),rx,ry,rz,OAK_LEAVES)
    chains=(((0,0,0),(0,tall//2,0),(bend,tall-1,0)),
            ((0,tall//2,0),(-bend,tall-3,-1)))
    boughs(b,(x,base,z),chains,"oak_wood")


def woodland(b,rng,entrance_trees=((-11,12,True,1),(9,16,False,-1))):
    # The two entrance trees turn their branches in different directions.
    for x,z,fork,mirror in (*entrance_trees,(-17,-9,False,1),
                            (18,-5,True,1),(-15,28,False,-1),(14,32,True,-1)):
        old_oak(b,rng,x,z,fork,mirror)
    fixed=((-18,4,13),(21,10,15),(-15,22,12),(15,21,13),(-1,32,11),(12,27,10),(13,10,8),
           (-9,-18,14),(6,-17,13),(15,-14,16),(-22,-4,16),(-19,35,18),(1,-17,17),(10,-23,18))
    placed=[(x,z) for x,z,_ in fixed]
    for index,(x,z,tall) in enumerate(fixed):
        species=young_oak if index in (2,4,5,6) else spruce
        species(b,rng,x,z,tall)
    for _ in range(530):
        x,z=rng.randint(-39,39),rng.randint(-33,47)
        if (-23<x<23 and -11<=z<35) or on_trail(x,z):
            continue
        if (z>=8 and abs(x-trail_x(z))<5) or abs(z-terrain["branch"](x))<3:
            continue
        if any((x-a)**2+(z-c)**2<24 for a,c in placed):
            continue
        placed.append((x,z))
        if rng.random()<.73:
            spruce(b,rng,x,z,rng.randint(12,21))
        else:
            young_oak(b,rng,x,z,rng.randint(8,13))
    for x,z,rx,rz in ((-11,14,2,2),(-11,20,2,2),(-15,24,3,2),(7,16,2,2),
                      (11,19,2,2),(4,23,2,1),(14,13,2,2),(-11,27,2,1)):
        canopy(b,rng,(x,height(x,z)+1,z),rx,1,rz,AZALEA)
    for x,z in ((-9,14),(-10,17),(-10,18),(8,16),(7,18),(10,20),(11,16),(-14,25),(-15,24)):
        if not on_trail(x,z):
            b.set(x,height(x,z)+1,z,"fern")
    terrain["light_trail"](b)


def build():
    return house["build"](plant_woods=woodland)


if __name__=="__main__":
    house["write"](HERE/"小屋建造.mcfunction",build())
