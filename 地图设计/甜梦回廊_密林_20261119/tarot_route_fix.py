"""Keep routes visible on the parchment and mark the actual entry openings."""
from math import pi
import re

from floor_route_map import EDGES, ROOM_SIDE, STEP, point
from route_trial_scenes import MapView
from portal_edges import SIDES, local


def map_roads(rows,variant):
    view=MapView(variant)
    result=[]
    for text in rows:
        if '"rgp.road"' not in text:
            result.append(text)
            continue
        edge=int(re.search(r"#e(\d+)\b",text)[1])
        material=re.search(r'fallenroute:panel/(\w+)"}',text)[1]
        a,b=EDGES[edge]
        ax,ay=point(a)
        bx,by=point(b)
        plane=view.plane((ax+bx)/2,(ay+by)/2,-.32,STEP-ROOM_SIDE+.12,.19,
                         material,"rgp.road",0 if ay==by else pi/2)
        plane=(plane.replace('"rd.ui"','"rgp.ui","rgp.new"')
               .replace('"rgp.road"','"rgp.road","rgp.edge_'+str(edge)+'"')
               .replace('item_display:"none",','item_display:"none",width:1.1f,height:1.1f,'))
        before=text.split("run execute positioned ",1)[0]
        result.append(before+"run "+plane)
    return result


def entry_lights(p):
    for name,sx,sz in SIDES:
        target="sweetdream_floor:routes/portal/build/"+name
        p.mc(target,*p.read(target),
             f"$execute if entity @a[tag=sd.floor_run] if score #phase sd.floor matches 1 "
             f"if data storage zx:rogue floor.cells[{{cell:$(cell),kind:\"entry\"}}] "
             f"run function fallentarot:entry/{name}")

        def point_at(lateral,y,depth):
            return local(lateral if sz else depth*sx,y,depth*sz if sz else lateral)

        p.ft("entry/"+name,
             *(f"fill {point_at(-1,-1,-7)} {point_at(1,-1,-3)} minecraft:mossy_stone_bricks replace minecraft:{ground}"
               for ground in ("moss_block","podzol","rooted_dirt","coarse_dirt","grass_block")),
             *(row for lateral in (-2,2) for row in (
                 f"setblock {point_at(lateral,-1,-3)} minecraft:mossy_stone_bricks",
                 f"setblock {point_at(lateral,0,-3)} minecraft:mossy_stone_brick_wall",
                 f"setblock {point_at(lateral,1,-3)} minecraft:lantern[hanging=false]")))
