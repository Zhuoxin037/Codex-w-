"""Geometry for the playable Forest routing prototype."""

import json
import math
from random import Random

from architecture import Build


LEAVES = "dark_oak_leaves[persistent=true]"
MOSS = "moss_block"
DIMENSION = "fallenroute:forest"
ROOMS = (
    (0, "林地入口", "entry", -3.02, 3.02),
    (72, "断桥", "combat", 0.0, 3.02),
    (144, "铸造坊", "forge", 3.02, 3.02),
    (216, "占星室", "astrology", 3.02, -3.02),
    (288, "旧矿口", "event", -3.02, -3.02),
)
EDGES = ((0, 1), (1, 2), (2, 3), (3, 4), (4, 0), (1, 4))
TREE = (2, 3)
COLLAPSE = (1, 4)
ROAD_ARRIVAL = "0.5 81 7.5 180 0"
MAP_VIEWS = {"normal": (.26, 2.82), "compact": (.19, 1.88), "narrow": (.142, 1.34)}


def map_art(name):
    return f'{{id:"minecraft:paper",count:1,components:{{"minecraft:item_model":"fallenroute:panel/{name}"}}}}'


def map_segments(a, b, inset):
    def trim(point, other):
        x,y = point
        dx,dy = other[0]-x,other[1]-y
        scale = inset/math.hypot(dx,dy)
        return x+dx*scale,y+dy*scale

    start = ROOMS[a][3:]
    end = ROOMS[b][3:]
    if (a,b) == COLLAPSE:
        turn = (0,-1.26)
        points = (trim(start,turn),turn,(-2.38,turn[1]),(-2.38,end[1]+inset))
    else:
        points = (trim(start,end),trim(end,start))
    return zip(points, points[1:])


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def display(x, y, z, message, color="white", scale=1, tag="rd.scene"):
    text = compact({"text": message, "color": color})
    return (f'summon minecraft:text_display {x:.3f} {y:.3f} {z:.3f} {{Tags:["{tag}"],text:{text},'
            'billboard:"center",shadow:1b,background:0,brightness:{block:15,sky:15},'
            f'transformation:{{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[{scale}f,{scale}f,{scale}f],right_rotation:[0f,0f,0f,1f]}}}}')


def black_arch(b, x, z, axis):
    # The portal triggers before the matte backing. All dark geometry stays
    # behind the threshold plane and leaves a walkable approach.
    if axis == "z":
        for dx in (-2, 2):
            b.box((x+dx, 1, z-1), (x+dx, 4, z+1), "stripped_dark_oak_log")
        b.box((x-2, 4, z-1), (x+2, 4, z+1), "dark_oak_log[axis=x]")
        back = z + (1 if z > 0 else -1)
        b.box((x-1, 1, back), (x+1, 3, back), "black_concrete")
        b.box((x-1, 0, z-1), (x+1, 0, z+1), "blackstone")
    else:
        for dz in (-2, 2):
            b.box((x-1, 1, z+dz), (x+1, 4, z+dz), "stripped_dark_oak_log")
        b.box((x-1, 4, z-2), (x+1, 4, z+2), "dark_oak_log[axis=z]")
        back = x + (1 if x > 0 else -1)
        b.box((back, 1, z-1), (back, 3, z+1), "black_concrete")
        b.box((x-1, 0, z-1), (x+1, 0, z+1), "blackstone")


def woodland(b, radius, seed):
    rng = Random(seed)
    b.box((-radius, -2, -radius), (radius, -1, radius), "rooted_dirt")
    b.box((-radius, 0, -radius), (radius, 0, radius), MOSS)
    b.shell(-radius, radius, 1, 3, -radius, radius, "mossy_cobblestone")
    b.shell(-radius, radius, 4, 9, -radius, radius, LEAVES)
    for x, z in ((-radius+2,-radius+3), (radius-2,-radius+3), (-radius+2,radius-4), (radius-2,radius-3),
                 (-radius+1,2), (radius-1,-2), (-7,-radius+2), (7,-radius+2)):
        b.oak(x, 1, z, rng.randrange(6,9), rng.randrange(3,5), thick=True)
    for x in range(-radius+2, radius-1):
        for z in range(-radius+2, radius-1):
            if abs(x) < 4 and z > -2:
                continue
            roll = rng.randrange(24)
            if roll == 0:
                b.set(x, 0, z, "mossy_cobblestone")
            elif roll == 1:
                b.set(x, 0, z, "podzol")
    for x, z in ((-5,-7), (6,-6), (-8,4), (8,5), (-4,radius-4), (4,radius-4)):
        b.set(x, 1, z, "mossy_cobblestone_wall")
        b.set(x, 2, z, "lantern")


def road():
    b = Build(relative=True)
    woodland(b, 20, 7124)
    for x0, z0, x1, z1 in ((-17,-2,17,2), (-2,-17,2,17)):
        b.box((x0, 0, z0), (x1, 0, z1), "rooted_dirt")
    b.disk(0, 0, 0, 6, 6, "mossy_stone_bricks")
    b.disk(0, 0, 0, 5, 5, "packed_mud")
    b.disk(0, 0, 0, 2, 2, "chiseled_tuff_bricks")
    for x,z in ((-4,-4),(4,-4),(-4,4),(4,4),(-11,-3),(10,3),(-3,-11),(3,11)):
        b.set(x, 1, z, "mossy_stone_brick_wall")
        b.set(x, 2, z, "lantern")
    for x,z,axis in ((-17,0,"x"),(17,0,"x"),(0,-17,"z"),(0,17,"z")):
        black_arch(b,x,z,axis)
        if axis == "z":
            low, high = sorted((z, z * 11 // 17))
            for dx in (-2,2):
                b.box((dx,1,low),(dx,1,high),"mossy_cobblestone_wall")
        else:
            low, high = sorted((x, x * 11 // 17))
            for dz in (-2,2):
                b.box((low,1,dz),(high,1,dz),"mossy_cobblestone_wall")
    for x,z in ((-10,-8),(11,-7),(-9,9),(9,11)):
        b.oak(x,1,z,8,3,thick=True)
    return b.lines


def content(index):
    b = Build(relative=True)
    radius = 13
    woodland(b, radius, 3+index)
    b.box((-1, 0, -3), (1, 0, 12), "coarse_dirt")
    black_arch(b, 0, 11, "z")
    if index == 0:
        b.disk(0,0,-2,5,4,"mossy_stone_bricks")
        b.set(0,1,-3,"campfire")
        b.box((-5,1,-2),(-3,1,-2),"spruce_stairs[facing=east]")
        b.box((3,1,-1),(5,1,-1),"spruce_stairs[facing=west]")
        b.box((-7,1,-6),(-7,4,-6),"spruce_log")
        b.box((7,1,-6),(7,4,-6),"spruce_log")
        b.box((-7,4,-6),(7,4,-6),"spruce_log[axis=x]")
        for i in range(4):
            b.box((-8,6-i,-7-i),(8,6-i,-7-i),"spruce_stairs[facing=north]")
            b.box((-8,6-i,-6+i),(8,6-i,-6+i),"spruce_stairs[facing=south]")
        b.set(-5,1,-5,"barrel[facing=up]")
        b.set(-5,2,-5,"lantern")
    elif index == 1:
        b.box((-10,0,-2),(10,0,0),"mud")
        b.box((-10,-1,-1),(10,-1,-1),"clay")
        b.box((-2,0,-3),(2,0,1),"dark_oak_planks")
        for x in (-3,3):
            b.box((x,1,-3),(x,1,0),"dark_oak_fence")
        for x,z in ((-7,-6),(7,4),(-8,6)):
            b.box((x-1,0,z),(x+1,1,z),"tuff_bricks")
            b.set(x+1,2,z,"moss_carpet")
    elif index == 2:
        b.box((-8,0,-9),(8,0,-2),"tuff_bricks")
        b.box((-7,1,-9),(7,5,-9),"deepslate_bricks")
        b.box((-8,5,-10),(8,5,-2),"polished_deepslate_slab[type=top]")
        for x in (-8,8):
            b.box((x,1,-4),(x,5,-4),"stripped_spruce_log")
        b.box((-5,1,-8),(5,2,-8),"polished_blackstone_bricks")
        b.box((-2,3,-8),(2,6,-8),"deepslate_tiles")
        b.box((-1,1,-8),(1,1,-8),"campfire")
        b.set(-4,1,-5,"anvil[facing=east]")
        b.set(4,1,-5,"smithing_table")
        b.set(5,1,-5,"barrel[facing=up]")
        b.set(5,2,-5,"lantern")
    elif index == 3:
        b.disk(0,0,-5,7,5,"polished_tuff")
        b.disk(0,1,-5,4,3,"waxed_oxidized_cut_copper")
        b.set(0,2,-5,"amethyst_block")
        b.set(0,3,-5,"amethyst_cluster[facing=up]")
        b.set(0,2,-3,"lectern[facing=north]")
        for x,z in ((-5,-6),(5,-6),(-3,-9),(3,-9)):
            b.box((x,1,z),(x,3,z),"chiseled_tuff_bricks")
            b.set(x,4,z,"soul_lantern")
        b.box((-5,7,-6),(5,7,-6),"dark_oak_log[axis=x]")
        b.set(0,6,-6,"chain")
        b.set(0,5,-6,"soul_lantern[hanging=true]")
    else:
        b.box((-7,0,-8),(7,0,-2),"gravel")
        b.box((-7,1,-9),(7,6,-9),"tuff")
        b.box((-4,4,-8),(4,5,-4),"tuff_bricks")
        b.box((-4,1,-4),(-4,4,-4),"stripped_dark_oak_log")
        b.box((4,1,-4),(4,4,-4),"stripped_dark_oak_log")
        b.box((-2,1,-8),(2,3,-8),"black_concrete")
        for x in (-1,1):
            b.box((x,1,-6),(x,1,-2),"rail[shape=north_south]")
        for x,z in ((-5,-4),(5,-2),(4,-6),(-3,-7)):
            b.set(x,1,z,"mossy_cobblestone")
            b.set(x,2,z,"cobblestone_slab[type=bottom]")
    return b.lines


class MapView:
    FRAME_SIDE = 12.0
    ROOM_SIDE = 2.08
    GLYPH_SIDE = 2.32

    def __init__(self, variant):
        self.scale, self.distance = MAP_VIEWS[variant]

    def at(self, x, y, layer=0):
        return f"^{-x*self.scale:.4f} ^{y*self.scale:.4f} ^{self.distance+layer*self.scale:.4f}"

    def clearance(self):
        edge = self.FRAME_SIDE / 2 - .015
        for depth in (.28,.46,.64,.82,1.0):
            for x in (-edge,-edge/2,0,edge/2,edge):
                for y in (-edge,0,edge):
                    side = -x*self.scale*depth
                    up = y*self.scale*depth
                    forward = self.distance*depth
                    yield f"^{side:.4f} ^{up:.4f} ^{forward:.4f}", f"^{side:.4f} ^{up-.49:.4f} ^{forward:.4f}"

    def plane(self, x, y, layer, w, h, name, tag="rd.panel", angle=0):
        s, c = math.sin(angle/2), math.cos(angle/2)
        return (f'execute positioned {self.at(x,y,layer)} run summon minecraft:item_display ~ ~ ~ '
                f'{{Tags:["rd.ui","rd.rotate","{tag}"],item:{map_art(name)},item_display:"none",'
                'brightness:{block:15,sky:15},transformation:{translation:[0f,0f,0f],'
                f'scale:[{w*self.scale:.4f}f,{h*self.scale:.4f}f,1f],'
                f'left_rotation:[0f,0f,{s:.7f}f,{c:.7f}f],right_rotation:[0f,0f,0f,1f]}}}}')

    def text(self, x, y, label, scale):
        text = compact({"text":label,"color":"#563b24"})
        size = f"{scale*self.scale:.4f}f"
        return (f'execute positioned {self.at(x,y,-.28)} run summon minecraft:text_display ~ ~ ~ '
                f'{{Tags:["rd.ui","rd.rotate"],text:{text},billboard:"fixed",shadow:0b,background:0,'
                'brightness:{block:15,sky:15},transformation:{translation:[0f,0f,0f],'
                f'scale:[{size},{size},{size}],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}')

    def hitbox(self, x, y, tag, width=1.45, height=1.71):
        return (f"execute positioned {self.at(x,y,-.28)} run summon minecraft:interaction ~ ~-{height*self.scale/2:.4f} ~ "
                f'{{Tags:["rd.ui","rd.node","{tag}"],width:{width*self.scale:.4f}f,height:{height*self.scale:.4f}f,response:1b}}')

    def board(self):
        lines = [self.plane(0,0,0,self.FRAME_SIDE,self.FRAME_SIDE,"parchment","rd.map_frame"),
                 self.text(0,4.72,"密林",1.68),
                 self.text(4.52,4.74,"收起",1.07), self.hitbox(4.52,4.84,"rd.cancel",1.62,.77)]
        for i, (a,b) in enumerate(EDGES):
            for (ax,ay),(bx,by) in map_segments(a,b,self.ROOM_SIDE/2):
                width = math.hypot(bx-ax,by-ay)+.075
                lines.append(self.plane((ax+bx)/2,(ay+by)/2,-.08,width,.22,"road",
                                        f"rd.edge_{i}",math.atan2(by-ay,bx-ax)))
        for i, (_, _, _, x, y) in enumerate(ROOMS):
            # Stop the ink at each room edge while keeping the sprite's surroundings paper-coloured.
            lines.append(self.room_stamp(i,1,-.19,f"rd.frame_{i}"))
            lines.append(self.icon(i))
            lines.append(self.hitbox(x,y,f"rd.node_{i}",2.35,2.35))
        return lines

    def room_stamp(self, index, zoom, layer, tag, name="room"):
        *_, x, y = ROOMS[index]
        side = self.ROOM_SIDE*zoom
        return self.plane(x,y,layer,side,side,name,tag)

    def icon(self, index, zoom=1, layer=-.26, tag=None):
        _, _, kind, x, y = ROOMS[index]
        side = self.GLYPH_SIDE*zoom
        return self.plane(x,y,layer,side,side,f"icon_{kind}",tag or f"rd.icon_{index}")
