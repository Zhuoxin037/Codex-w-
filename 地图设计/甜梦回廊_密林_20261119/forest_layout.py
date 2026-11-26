"""Match the held map to the physical grid and block direct views between rooms."""

import gzip
from itertools import product
from pathlib import Path
import re
import struct

from architecture import Build, PITCH, RADII, DOOR_HALF, WORN, LEAVES, corridor as original_corridor
from floor_upgrade import MAP_ID, text, write

CENTER = 2 * PITCH
MAP_SCALE = 1

# Seven-pixel symbols stay readable on a held vanilla map.
ICONS = {
    "entry":   ("oak_planks",       ["...#...","..###..",".#####.","...#...","...#...","..###..","......."]),
    "combat":  ("orange_concrete",  [".#...#.",".##.##.","..###..","...#...","..###..",".##.##.",".#...#."]),
    "elite":   ("red_concrete",     [".#.#.#.",".#####.",".#####.",".#####.","..###..","...#...","......."]),
    "safe":    ("orange_concrete",  ["...#...","..##...","..###..",".#####.",".##+##.",".+++++.","++...++"]),
    "forge":   ("white_concrete",   [".......","#######",".#####.","...#...","..###..","..###..","......."]),
    "merchant":("yellow_concrete", ["..###..",".##+##.","###+###",".#...#.",".#...#.",".#####.","......."]),
    "blackmarket":("purple_concrete",[".#####.","##+#+##","#######",".####@.","..###..","...#...","......."]),
    "astrology":("light_blue_concrete",["...#...","...#...","..#+#..","###+###","..#+#..","...#...","...#..."]),
    "gamble":  ("white_concrete",   [".#####.",".#@###.",".#####.",".##@##.",".#####.",".###@#.",".#####."]),
    "rental":  ("light_blue_concrete",["....###","....##.","...##..","..##...",".#@#...",".##....","......."]),
    "event":   ("white_terracotta", [".#####.",".##+##.",".#+++@.",".#+++@.",".#####.","..#####","......."]),
    "boss":    ("red_concrete",     ["..###..",".#####.",".#@#@#.",".#####.","..###..","..#.#..","......."]),
}


def corridor(axis, first, second):
    b = Build(relative=True)
    end = PITCH-second
    # The topology places one boss. Keep the unreachable two-boss template valid.
    if end-first < 5:
        return original_corridor(axis, first, second)
    center = (first+end)//2
    bend = 1 if axis == "east" else -1

    def xyz(a, y, w):
        return (a,y,w*bend) if axis == "east" else (w*bend,y,a)

    def box(a,y,w,aa,yy,ww,block):
        b.box(xyz(a,y,w), xyz(aa,yy,ww), block)

    # The clearance plane stays seven blocks wide at both room entrances. The
    # opaque center wall forces two turns through the wider side of the passage.
    assert first+1 < center < end-1
    box(first,-1,-4,end,0,7,"rooted_dirt")
    box(first,0,-DOOR_HALF,end,0,DOOR_HALF,WORN)
    box(first+1,0,4,end-1,0,6,"spruce_planks")
    box(first,1,-DOOR_HALF,end,5,DOOR_HALF,"air")
    box(first+1,1,4,end-1,5,6,"air")
    box(first+1,1,-4,end-1,5,-4,"mossy_cobblestone")
    box(first+1,1,7,end-1,5,7,"mossy_cobblestone")
    for stop in (first,end):
        box(stop,1,4,stop,5,7,"tuff_bricks")
        box(stop,1,-4,stop,5,-4,"stripped_dark_oak_log")
        box(stop,6,-4,stop,6,7,"dark_oak_log")
        b.set(*xyz(stop,6,0),"shroomlight")
    box(first+1,6,-4,end-1,6,7,LEAVES)
    box(center,1,-DOOR_HALF,center,6,DOOR_HALF,"mossy_cobblestone")
    box(center,1,-3,center,5,-3,"stripped_spruce_log")
    box(center,1,3,center,5,3,"stripped_spruce_log")
    box(center,5,-2,center,5,2,"tuff_bricks")
    b.set(*xyz(center,6,5),"shroomlight")
    b.set(*xyz(center,7,-2),"moss_block")
    b.set(*xyz(center,7,2),"mangrove_roots")
    return b.lines


def canvas_route(axis):
    b = Build(relative=True)

    def box(a,w,aa,ww):
        if axis == "east":
            b.box((a,0,w),(aa,0,ww),"light_gray_concrete")
        else:
            b.box((-w-1,0,a),(-ww-1,0,aa),"light_gray_concrete")

    box(14,-2,17,1)
    box(16,-2,17,7)
    box(16,4,21,7)
    box(20,-2,21,7)
    box(20,-2,23,1)
    return b.lines


def icon(ink, rows):
    assert all(len(row)==7 for row in rows)
    b = Build(relative=True)
    for iz,row in enumerate(rows):
        for ix,pixel in enumerate(row):
            if pixel == ".":
                continue
            x,z = 2*(ix-3), 2*(iz-3)
            color = {"#":ink, "+":"yellow_terracotta", "@":"black_concrete"}[pixel]
            b.box((x,0,z),(x+1,0,z+1),color)
    return b.lines


def revise_map(blob):
    """Retarget the known map record; changing its grid invalidates cached colors."""
    raw = gzip.decompress(blob)

    def field(data, name, kind, fmt, old_values, replacement):
        key = bytes((kind,)) + struct.pack(">H", len(name)) + name.encode("ascii")
        if data.count(key) != 1:
            raise ValueError(f"Missing or duplicate map field {name}")
        start = data.index(key)+len(key)
        old = struct.unpack_from(fmt,data,start)[0]
        if old not in old_values:
            raise ValueError(f"Unexpected map field {name}: {old}")
        value = struct.pack(fmt,replacement)
        return data[:start]+value+data[start+len(value):], old

    scale = b"\x01\x00\x05scale"
    if scale in raw:
        raw, previous = field(raw,"scale",1,">b",(0,MAP_SCALE),MAP_SCALE)
    else:
        # 1.21.5 omits the default scale (0) when resaving a map.
        data = b"\x0a\x00\x04data"
        if raw.count(data) != 1:
            raise ValueError("Unexpected map record")
        raw = raw.replace(data, data+scale+bytes((MAP_SCALE,)), 1)
        previous = 0
    raw, _ = field(raw,"xCenter",3,">i",(48,CENTER),CENTER)
    raw, _ = field(raw,"zCenter",3,">i",(48,CENTER),CENTER)
    if previous != MAP_SCALE:
        key = b"\x07\x00\x06colors\x00\x00\x40\x00"
        if raw.count(key) != 1:
            raise ValueError("Unexpected canvas color array")
        start = raw.index(key)+len(key)
        raw = raw[:start]+bytes(16384)+raw[start+16384:]
    return gzip.compress(raw,mtime=0)


def stage(world):
    world = Path(world)
    dp = world/"datapacks/zz_sweetdream_floor/data/sweetdream/function/rogue"

    def mc(path, rows):
        write(dp/f"{path}.mcfunction", "\n".join(rows))

    for axis,first,second in product(("east","south"),RADII,RADII):
        mc(f"corridors/{axis}_{first}_{second}", corridor(axis,first,second))
    for axis in ("east","south"):
        mc(f"canvas/{axis}", canvas_route(axis))
    for key,(ink,pixels) in ICONS.items():
        mc(f"canvas/icon_{key}", icon(ink,pixels))
    for key,fill in (("room","gray_terracotta"),("visited","green_terracotta"),
                     ("boss","black_terracotta"),("boss_visited","black_terracotta")):
        stroke = "red_terracotta" if key.startswith("boss") else "light_gray_concrete"
        mc(f"canvas/{key}", [f"fill ~-12 ~ ~-12 ~13 ~ ~13 minecraft:{stroke}",
                              f"fill ~-10 ~ ~-10 ~11 ~ ~11 minecraft:{fill}"])
    for key in ("gen/build_cell","gen/corridor","map/visit","map/draw_icon"):
        p = dp/f"{key}.mcfunction"
        write(p,text(p).replace("$(mx) 319 $(mz)","$(x) 319 $(z)"))
    clear = dp/"gen/clear.mcfunction"
    write(clear,re.sub(r'^fill -16 319 -16 111 319 111 [^\n]+$',
                       'fill -32 319 -32 79 319 191 minecraft:black_terracotta\n'
                       'fill 80 319 -32 191 319 191 minecraft:black_terracotta',text(clear),flags=re.M))
    for key in ("prep/begin", "prep/tick"):
        p = dp/f"{key}.mcfunction"
        write(p,text(p).replace("48.5 320 48.5",f"{CENTER}.5 320 {CENTER}.5"))
    bitmap = world/"data"/f"map_{MAP_ID}.dat"
    bitmap.write_bytes(revise_map(bitmap.read_bytes()))
