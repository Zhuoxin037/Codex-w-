"""Thin cabin joinery and vanilla display furniture with usable seats."""

from math import cos, degrees, pi, sin, sqrt
import runpy

from architecture import Build, write
from cabin_finish import FINISH, blocks, joinery, staircase
from cabin_lobby import CANDIDATE, LOBBY_BOX, OFFSET, STORAGE, rewrite

ROOT = "sweetdream_floor:lobby/cabin"
MARKER = "cabin_furnish"
TAG = "sd.floor_cabin_furnish"
MOUNT = "sd.floor_seat_mount"
CLICK = "sd.floor_seat_click"
AIR = "minecraft:air"
OAK = "dark_oak_planks"
SPRUCE = "spruce_planks"
TRIM = "stripped_spruce_log"
NORTH, EAST, SOUTH, WEST = pi, pi/2, 0, -pi/2


def coords(x, y, z):
    return f"{OFFSET+x:.5f} {y:.5f} {z:.5f}"


def display(pos, size=(1, 1, 1), wood=OAK, *, pitch=0, yaw=0, tag=TAG, state=""):
    x,y,z = pos
    scale = ",".join(f"{a:.5f}f" for a in size)
    left = (sin(pitch/2)*cos(yaw/2), sin(yaw/2)*cos(pitch/2),
            -sin(pitch/2)*sin(yaw/2), cos(pitch/2)*cos(yaw/2))
    rotation = ",".join(f"{a:.8f}f" for a in left)
    return (
        f'summon minecraft:block_display {coords(x,y,z)} '
        f'{{Tags:["sd.floor_lobby_display","{tag}"],'
        f'block_state:{{Name:"minecraft:{wood}"{state}}},'
        f'transformation:{{translation:[0f,0f,0f],left_rotation:[{rotation}],'
        f'scale:[{scale}],right_rotation:[0f,0f,0f,1f]}}}}'
    )


def frame_x(x, start, end, floor, height):
    for face in (x-.064,x+1-.018):
        # Each stile overlaps the existing jamb. The opening keeps its clear width.
        for z in (start-.096,end-.018):
            yield display((face,floor,z),(.082,height,.114),TRIM)
        yield display((face,floor+height,start-.096),(.082,.16,end-start+.192),SPRUCE)


def door_frames():
    yield from frame_x(6,0,4,78,3.84)
    yield from frame_x(-6,-2,3,78,3.84)
    yield from frame_x(-6,-2,0,84,2.0)
    for x in (-5-.096,-3-.018):
        yield display((x,78,5.936),(.114,2,.082),TRIM)
    yield display((-5.096,80,5.936),(2.192,.16,.082),SPRUCE)


def rails():
    for x in (1.155,2.845):
        end_y, end_z, start_z = 85.09,-2.78,2.66
        # Both rails run inside the floor opening, with a separate landing return.
        yield display((x-.05,end_y,end_z),(.10,.104,(start_z-end_z)*sqrt(2)),pitch=pi/4)
        yield display((x-.05,end_y,-3.57),(.10,.104,.81))
        for z, foot, top in ((2.60,78.49,79.82),(.30,80.99,82.15),
                             (-2.78,83.99,85.24),(-3.55,83.99,85.21)):
            yield display((x-.071,foot,z-.076),(.142,top-foot,.152),TRIM)


def furnish_group(commands, origin, yaw, click_count, back):
    x,y,z = origin

    def position(dx, dy, dz):
        return x+dx*cos(yaw)+dz*sin(yaw), y+dy, z-dx*sin(yaw)+dz*cos(yaw)

    def part(dx, dy, dz, w, h, d, wood=OAK):
        commands.append(display(position(dx,dy,dz),(w,h,d),wood,yaw=yaw))

    width = click_count*.84 - .06
    for lx in (-width/2+.075,width/2-.185):
        for lz in (-.205,.13):
            part(lx,0,lz,.11,.424,.11,TRIM)
    part(-width/2,.403,-.268,width,.115,.536,SPRUCE)
    part(-width/2+.07,.337,.123,width-.14,.079,.076)
    if back:
        for lx in (-width/2+.075,width/2-.185):
            part(lx,.498,-.232,.11,.565,.10,TRIM)
        part(-width/2+.06,.936,-.240,width-.12,.112,.091,SPRUCE)
        for i in range(click_count):
            dx = (i-(click_count-1)/2)*.84
            for slat in (-.17,.08):
                part(dx+slat,.503,-.211,.09,.46,.061,SPRUCE)
    for i in range(click_count):
        dx = (i-(click_count-1)/2)*.84
        commands.append(display(position(dx,.518,.031),wood="air",tag=MOUNT))
        px,py,pz = position(dx,.398,.031)
        commands.append(f'summon minecraft:interaction {coords(px,py,pz)} '
                        f'{{Tags:["{CLICK}"],width:0.64f,height:0.40f,response:1b,'
                        f'Rotation:[{-degrees(yaw):.2f}f,0f]}}')


def hearth_table():
    # An open trestle with a slim three-board top and a small candle.
    x,y,z = -7.5,78,.50
    for board in range(3):
        yield display((x-1.25,y+.827,z-.387+board*.261),(2.5,.104,.251),SPRUCE)
    for dx in (-.99,.84):
        for dz in (-.294,.134):
            yield display((x+dx,y,z+dz),(.15,.832,.148),TRIM)
        yield display((x+dx,y+.688,z-.287),(.15,.12,.56))
    yield display((x-.97,y+.22,z-.047),(1.96,.105,.094))
    yield display((x-.50,y+.931,z-.50),wood="brown_candle",
                  state=',Properties:{candles:"2",lit:"true"}')


def footprint(x, y, z, dx, dz, count):
    return [(x+i*dx,y,z+i*dz) for i in range(count)]


def furniture():
    # Each entry names its existing floor cells, seating position and facing.
    for name,x,y,z,dx,dz,count,yaw,back in (
        ("hearth_side",-7,78,-4,0,1,2,WEST,True),
        ("hearth_bench",-8,78,2,1,0,2,NORTH,True),
        ("hearth_chair",-10,78,2,1,0,1,NORTH,True),
        ("hall_bench",-4,78,-6,1,0,2,SOUTH,True),
        ("desk_chair",4,84,-1,1,0,1,EAST,True),
        ("window_bench",-5,84,6,1,0,3,NORTH,True),
        ("loft_bench",1,84,6,1,0,3,NORTH,True),
        ("terrace_bench",-11,84,-4,0,1,2,EAST,True),
        ("terrace_stools",-11,84,1,0,1,2,EAST,False),
        ("tutorial_chair",12,78,4,1,0,1,WEST,True),
        ("tutorial_bench",9,78,8,1,0,3,NORTH,True),
        ("camp_stools",-1,78,13,1,0,2,SOUTH,False),
    ):
        cells = footprint(x,y,z,dx,dz,count)
        commands = []
        if name.endswith("stools"):
            for a,b,c in cells:
                furnish_group(commands,(a+.5,b,c+.5),yaw,1,False)
        else:
            n = (count-1)/2
            furnish_group(commands,(x+.5+dx*n,y,z+.5+dz*n),yaw,count,back)
        yield name,cells,commands
    cells = footprint(-9,78,0,1,0,3) + [(-8,79,0)]
    yield "hearth_table",cells,list(hearth_table())


def point(pos):
    x,y,z = pos
    return f"{x+OFFSET} {y} {z}"


def stage(addon):
    functions = addon/"data/sweetdream_floor/function"
    lobby = functions/"lobby/cabin"
    approved = runpy.run_path(str(CANDIDATE))
    stock = blocks(approved["build"]())
    trim,stairs = Build(),Build()
    joinery(trim)
    staircase(stairs)
    legacy = blocks(trim.lines + stairs.lines)
    restore = set(blocks(trim.lines))
    restore.update(pos for pos in blocks(stairs.lines) if pos[0] in (0,3))
    clear = {(3,78,2),(3,79,2),(-7,78,-5),(-9,78,2),(-2,84,6),
             (-11,84,0)}
    patch = []
    for pos in sorted(restore|clear,key=lambda pos:(pos[1],pos[0],pos[2])):
        old = legacy.get(pos,stock.get(pos,AIR))
        new = AIR if pos in clear else stock.get(pos,AIR)
        if old != new:
            patch.append(f"execute if block {point(pos)} {old} run setblock {point(pos)} {new}")
        if pos in clear and stock.get(pos,AIR) not in (old,new):
            patch.append(f"execute if block {point(pos)} {stock[pos]} run setblock {point(pos)} {new}")
    patch = [
        f"kill @e[type=minecraft:block_display,tag={tag},{LOBBY_BOX}]" for tag in
        ("sd.floor_cabin_rail",TAG,MOUNT)
    ] + [f"kill @e[type=minecraft:interaction,tag={CLICK},{LOBBY_BOX}]"] + patch
    patch.extend(door_frames())
    patch.extend(rails())
    for name,cells,commands in furniture():
        guards, replacement = [], []
        for pos in cells:
            expected = stock.get(pos,AIR)
            allow_empty = f" unless block {point(pos)} {AIR}" if expected!=AIR else ""
            guards.append(f"execute unless block {point(pos)} {expected}{allow_empty} run return 0")
            if expected != AIR:
                replacement.append(f"execute if block {point(pos)} {expected} run setblock {point(pos)} {AIR}")
        patch.append(f"function {ROOT}/furniture/{name}")
        write(lobby/f"furniture/{name}.mcfunction",guards+replacement+commands)
    patch.append(f"data modify storage {STORAGE} {MARKER} set value 1b")
    write(lobby/"furnish.mcfunction",patch)

    seat_zone = "x=242,y=77,z=-8,dx=29,dy=10,dz=24"
    selector = f"@e[type=minecraft:block_display,tag={MOUNT},distance=..0.24,limit=1,sort=nearest]"
    write(lobby/"seat_tick.mcfunction",[
        f"execute as @e[type=minecraft:block_display,tag={MOUNT},{seat_zone}] on passengers "
        "if entity @s[type=minecraft:player] if predicate sweetdream:is_sneaking run ride @s dismount",
        f"execute as @e[type=minecraft:interaction,tag={CLICK},{seat_zone},nbt={{interaction:{{}}}}] "
        f"at @s run function {ROOT}/seat_click",
    ])
    write(lobby/"seat_click.mcfunction",[
        "scoreboard players set #seat_busy sd.floor 0",
        f"execute as {selector} on passengers if entity @s[type=minecraft:player] run scoreboard players set #seat_busy sd.floor 1",
        "execute unless score #seat_busy sd.floor matches 1.. "
        "on target if entity @s[type=minecraft:player,gamemode=!spectator,tag=!sd.floor_run,tag=!sd.floor_tutorial,distance=..3.6] "
        f"unless predicate sweetdream:is_sneaking run function {ROOT}/seat_mount",
        "data remove entity @s interaction",
    ])
    write(lobby/"seat_mount.mcfunction",[
        "scoreboard players set #seat_mounted sd.floor 0",
        f"execute store success score #seat_mounted sd.floor run ride @s mount {selector}",
        "execute if score #seat_mounted sd.floor matches 1 run rotate @s ~ 0",
    ])
    tick = functions/"tick.mcfunction"
    tick.write_text(f"execute in minecraft:overworld if entity @a[{seat_zone},distance=0..] "
                    f"run function {ROOT}/seat_tick\n" + tick.read_text(encoding="utf-8"),encoding="utf-8")
    rewrite(functions/"load.mcfunction",
            f"unless data storage {STORAGE} {{cabin_finish:1b}} run function {FINISH}_load",
            f"unless data storage {STORAGE} {{{MARKER}:1b}} run function {FINISH}_load")
    rewrite(lobby/"ready_loaded.mcfunction",f"function {FINISH}\n",
            f"function {FINISH}\nfunction {ROOT}/furnish\n")
    rewrite(lobby/"finish_loaded.mcfunction",f"run function {FINISH}\n",
            f"run function {FINISH}\nexecute unless data storage {STORAGE} {{{MARKER}:1b}} run function {ROOT}/furnish\n")
