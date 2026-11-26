"""Vanilla end-to-end regression for the independent Forest floor."""
import re
import time

from world import WORLD, native
from cabin_corner import BUILT, CORNER, changes
from cabin_furnish import CLICK, MOUNT, TAG, point
from cabin_lobby import CAMP, LOBBY_BOX, SPAWN, STORAGE, TUTORIAL
from floor_upgrade import DIM, MAP_ID, PITCH
from architecture import radius, ENTRY_Z
from verify import PLAYER, OTHER, block_is, check, command, phase, status, storage, tags, trigger, wait


def on_floor(cmd):
    return command(f"execute in {DIM} run {cmd}")


def at_floor(cmd):
    return command(f"execute in {DIM} as {PLAYER} at @s run {cmd}")


def floor_block(x, y, z, material):
    return "passed" in on_floor(f"execute if block {x} {y} {z} minecraft:{material}").lower()


def entity_count(selector):
    reply = on_floor(f"execute if entity {selector}")
    match = re.search(r"count: (\d+)", reply)
    return int(match[1]) if match else 0


def cells():
    result = {}
    for i in range(25):
        fields = storage(f"floor.cells[{i}]", "zx:rogue")
        kind = re.search(r'kind: "(\w+)"', fields)
        if "present: 1b" in fields and kind:
            result[i] = ((i%5)*PITCH,(i//5)*PITCH,kind[1],i)
    return result


def enter(job=10):
    move(*CAMP, "minecraft:overworld")
    wait(lambda: "sd.floor_pad" in tags(PLAYER),"camp entrance")
    trigger(job)
    if "1b" in storage("lobby_expansion"):
        wait(lambda: "sd.lobby_ready" in tags(PLAYER), "select a class and ready up")
        trigger(4)
    wait(lambda: "zx.rg_active" in tags(PLAYER) and "sd.floor_hud" in tags(PLAYER),"arrive after loading",60)
    return cells()


def move(x,y,z,dim=DIM):
    command(f"execute in {dim} run tp {PLAYER} {x} {y} {z} 0 0")


def visit(room, dx=4, dz=0):
    x,z,_,idx=room
    move(x+dx+.5,81,z+dz+.5)
    wait(lambda: status(PLAYER,"zx.rg_room")==idx, f"visit cell {idx}")


def map_edges():
    return re.findall(r"([01])b", storage("floor.edges","zx:rogue"))


def doors(room, edges):
    x,z,k,i=room
    r=radius(k)
    row,col=divmod(i,5)
    yield from (
        (x+dx*r,z+dz*r,dx,dz) for valid,edge,dx,dz in (
            (col>0,row*4+col-1,-1,0),(col<4,row*4+col,1,0),
            (row>0,20+i-5,0,-1),(row<4,20+i,0,1),
        ) if valid and edges[edge]=="1"
    )


def doors_are(room, edges, material):
    positions=list(doors(room,edges))
    return positions and all(floor_block(x,81,z,material) and floor_block(x,85,z,material)
                             for x,z,_,_ in positions)


def no_item(predicate):
    return "Found" not in command(f"clear {PLAYER} {predicate} 0")


def position_is(coord):
    xyz=", ".join(str(float(c))+"d" for c in coord)
    return f"[{xyz}]" in command(f"data get entity {PLAYER} Pos")


def player_value(field):
    return float(command(f"data get entity {PLAYER} {field}").rsplit(": ",1)[1].rstrip("fd"))


def lobby_count(tag):
    return command(f"execute if entity @e[tag={tag},{LOBBY_BOX}]")


def furniture_absent():
    return all("failed" in lobby_count(tag).lower() for tag in (CLICK,MOUNT))


def corner_built():
    return "1b" in storage(BUILT) and all(
        block_is(x+256,y,z,new.removeprefix("minecraft:"))
        for (x,y,z),(_,new) in changes().items()
    )


def verify_cabin_migration():
    command("forceload add 240 -16")
    plan=changes()
    for pos,(old,new) in sorted(plan.items(),key=lambda item:item[0][1]):
        if old!=new and pos not in ((4,80,-5),(4,81,-5)):
            command(f"setblock {point(pos)} {old}")
    command("setblock 260 81 -5 minecraft:chain[axis=y]")
    command("setblock 260 80 -5 minecraft:lantern[hanging=true]")
    command("clone 258 78 -6 258 79 -4 258 78 -3 replace move")
    command("item replace block 258 78 -3 container.0 with minecraft:blaze_rod")
    command("setblock 248 78 0 minecraft:jungle_planks")
    check("the test save has the previous running stair and its stocked barrel",
          block_is(260,78,1,"spruce_stairs[facing=west]") and
          "passed" in command("execute if items block 258 78 -3 container.0 minecraft:blaze_rod").lower())
    command("setblock 260 78 -4 minecraft:gold_block")
    command("function sweetdream_floor:lobby/cabin/corner_stair")
    check("a touched footprint leaves the entire old staircase accessible",
          "0b" in storage(BUILT) and block_is(260,78,-4,"gold_block")
          and block_is(260,78,1,"spruce_stairs[facing=west]"))
    command("setblock 260 78 -4 minecraft:air")
    command(f"data remove storage {STORAGE} {CORNER}")
    command("reload")
    wait(lambda: "1b" in storage(CORNER),"upgrade an existing cabin")
    check("the upgrade moves the stair, fills the centre and preserves elsewhere handwork",
          corner_built() and block_is(248,78,0,"jungle_planks"))
    check("the contents of old storage travel to the new stair",
          block_is(258,78,-3,"air") and
          "passed" in command("execute if items block 258 78 -6 container.0 minecraft:blaze_rod").lower())
    check("the upgrade releases its temporary chunks and preserves a preloaded chunk",
          "is marked" in command("forceload query 240 -16") and
          all("not marked" in command(f"forceload query {x} {z}") for x,z in ((240,0),(256,-16),(256,0))))
    command("function sweetdream_floor:lobby/cabin/corner_stair")
    check("corner conversion is idempotent and does not duplicate storage",
          corner_built() and block_is(258,78,-3,"air") and
          "passed" in command("execute if items block 258 78 -6 container.0 minecraft:blaze_rod").lower())
    command("forceload remove 240 -16")
    command("setblock 248 78 0 minecraft:air")


def main():
    fresh = not any((WORLD/"playerdata").glob("*.dat"))
    wait(lambda: "1b" in storage("cabin_layout"), "build the approved lobby", 60)
    wait(lambda: "1b" in storage(CORNER), "build the corner stair", 60)
    if PLAYER not in command("list"):
        native.clients()
    wait(lambda: PLAYER in command("list") and OTHER in command("list"),"connect both 1.21.5 test clients")
    wait(lambda: "sd.floor_seen" in tags(PLAYER),"lobby")
    if "sd.floor_run" in tags(PLAYER) or "sd.floor_tutorial" in tags(PLAYER):
        trigger(3)
    wait(lambda: phase()==0 and status("#rv_clean","zx.meta")==0,"lobby reset")
    if not fresh:
        for player in (PLAYER,OTHER):
            command(f"ride {player} dismount")
        move(*SPAWN,"minecraft:overworld")
    check("the lobby trail spawn is ready",
          block_is(252,75,20,"podzol") and position_is(SPAWN))
    check("all four camp tiles and both campfire and tutorial are built",
          all(block_is(x,77,z,"waxed_oxidized_cut_copper") for x in (257,258) for z in (15,16))
          and block_is(255,78,16,"campfire[lit=true,signal_fire=true]")
          and all(block_is(x,77,z,"amethyst_block") for x in (265,266) for z in (1,2)))
    check("canvas uses seven display panels and the cabin has no floating text",
          "count: 7" in command(f"execute if entity @e[type=minecraft:block_display,tag=sd.floor_lobby_display,tag=!{TAG},tag=!{MOUNT},{LOBBY_BOX}]")
          and "failed" in command(f"execute if entity @e[type=minecraft:text_display,{LOBBY_BOX}]").lower())
    check("both halves of the two front doors survived world generation",
          all(block_is(x,y,6,f"spruce_door[half={half}]")
              for x in (251,252) for y,half in ((78,"lower"),(79,"upper"))))
    check("both side passages discard their oversized braces and floating shutters",
          all(block_is(x,80,z,"air") for x,z in ((261,0),(251,-2)))
          and all(block_is(x,79,z,"air") for x,z in ((261,-1),(263,4),(249,-3),(251,3),(253,5)))
          and block_is(250,79,5,"tuff_bricks")
          and all(block_is(x,y,z,"air") for x,z in ((262,1),(250,0)) for y in (78,79)))
    check("the compact switchback rises in the northeast corner with native wood railing",corner_built())
    check("the former stair location and its upper floor are both clear for use",
          all(block_is(x,83,z,"spruce_planks") for x in (257,258) for z in range(-3,1))
          and all(block_is(x,y,z,"air") for x,z in ((258,-2),(260,1),(257,3)) for y in (78,79)))
    check("the chimney narrows above its flashing and keeps real smoke",
          block_is(250,89,-6,"polished_deepslate") and block_is(250,90,-6,"campfire[lit=true]")
          and block_is(250,91,-6,"brick_wall") and block_is(250,92,-6,"stone_brick_wall")
          and block_is(251,92,-6,"air"))
    check("new cabins leave the furnishing spots empty and omit all door and stair display trim",
          furniture_absent() and "failed" in lobby_count(TAG).lower()
          and all(block_is(x,y,z,"air") for x,y,z in ((248,78,0),(260,84,-1),(265,78,8),(255,78,13))))
    trigger(11)
    wait(lambda: status(PLAYER,"sd.floor_cmd")==0,"resolve an off-pad start")
    check("the profession shortcut cannot start away from the camp",phase()==0 and "sd.floor_run" not in tags(PLAYER))
    move(-48.5,90,48.5,"minecraft:overworld")
    wait(lambda: position_is(SPAWN), "redirect an old lobby position")
    check("returning players at the previous lobby migrate to the cabin trail",True)
    move(*TUTORIAL,"minecraft:overworld")
    wait(lambda: "sd.floor_tutorial" in tags(PLAYER),"tutorial entrance")
    wait(lambda: block_is(-100,90,46,"lectern[has_book=true]"),"live tutorial")
    trigger(3)
    wait(lambda: "sd.floor_tutorial" not in tags(PLAYER),"leave tutorial")
    check("the actual lesson still loads and its exit returns to the trail",position_is(SPAWN))
    rooms=enter(11)
    edges=map_edges()
    check("separate dimension and widened physical grid",
          DIM in command(f"data get entity {PLAYER} Dimension") and position_is((.5,81,ENTRY_Z+.5))
          and len(rooms)==16 and len({item[2] for item in rooms.values()})==12
          and "radius: 13" in storage("floor.cells[10]","zx:rogue")
          and not block_is(0,80,ENTRY_Z,"moss_block"))
    check("real map in ninth slot is linked to the independent dimension",
          str(MAP_ID) in command(f'data get entity {PLAYER} Inventory[{{Slot:8b}}].components."minecraft:map_id"')
          and (WORLD/"data"/f"map_{MAP_ID}.dat").exists() and floor_block(0,319,48,"cyan_concrete"))
    check("deep canopy and illumination cover the larger rooms",
          all(floor_block(x,92,z,"dark_oak_leaves") and floor_block(x,84,z,"light[level=12]")
              for x,z,_,_ in rooms.values()))
    check("map routes are physically passable before exploring",
          all(doors_are(room, edges,"air") for room in rooms.values()))
    check("four service villagers and four right-click hitboxes are present",
          entity_count('@e[type=minecraft:villager,tag=sd.floor_vendor,distance=0..]')==4
          and entity_count('@e[type=minecraft:interaction,tag=sd.floor_vendor_hitbox,distance=0..]')==4)
    check("starter kit no longer gives mirror, Pump, duplicate weapons or food",
          all(no_item(item) for item in ('*[minecraft:custom_data~{zx:["look"]}]',
                                        '*[minecraft:custom_data~{zx:["intravenous_pump"]}]',
                                        'minecraft:cooked_beef'))
          and "Found 1 matching" in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["mana_crystal"]}}] 0')
          and "Found 1 matching" in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["grimoire"]}}] 0'))
    command(f"effect give {PLAYER} minecraft:saturation 1 20 true")
    command(f"effect give {PLAYER} minecraft:hunger 5 255 true")
    time.sleep(.7)
    command(f"effect clear {PLAYER} minecraft:hunger")
    wait(lambda: player_value("foodLevel")==20,"restore a full hunger bar")
    saturation=player_value("foodSaturationLevel")
    command(f"damage {PLAYER} 4 minecraft:out_of_world")
    wounded=player_value("Health")
    time.sleep(5)
    check("full food does not refill saturation or regenerate health",
          "false" in command("gamerule naturalRegeneration") and 0<=saturation<20 and
          player_value("foodLevel")==20 and player_value("foodSaturationLevel")<=saturation and
          0<wounded<20 and player_value("Health")==wounded)
    command(f"effect give {PLAYER} minecraft:instant_health 1 0 true")
    wait(lambda: player_value("Health")>wounded,"healing potion remains effective")
    check("explicit instant health still heals",True)
    check("mirror stays active without its item and reads both live scores",
          "test_look_on" not in tags(PLAYER)
          and all(name in storage("xline","zx:look") for name in ("梦屑","探索","#lumen","#budget")))
    check("first arrival has no leftover construction drops, including lanterns",
          entity_count('@e[type=minecraft:item,distance=0..]')==0)

    event,forge,combat,elite,boss = (
        next(r for r in rooms.values() if r[2]==kind)
        for kind in ("event","forge","combat","elite","boss")
    )
    visit(event)
    check("event props leave the center and every open threshold traversable",
          floor_block(event[0],81,event[1],"air") and doors_are(event,edges,"air"))
    command(f"data modify storage zx:rogue floor.cells[{event[3]}].variant set value 0")
    trigger(20)
    wait(lambda: status("#lumen")==2,"event reward")
    visit(forge,dx=-4,dz=-3)
    at_floor("function sweetdream_floor:room/vendor/interact")
    trigger(20)
    wait(lambda: status("#lumen")==1,"forge service")
    check("forge villager offers the native upgrade service",
          "Found" in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["up_mana_up_a"]}}] 0'))
    cx,cz,_,ci=combat
    x,z,dx,dz=next(doors(combat,edges))
    move(x+.5+dx*1.4,81,z+.5+dz*1.4)
    time.sleep(.2)
    check("standing in the corridor leaves the room gate raised", floor_block(x,81,z,"air"))
    move(x+.5-dx*2.7,81,z+.5-dz*2.7)
    wait(lambda: status(PLAYER,"zx.rg_room")==ci and doors_are(combat,edges,"barrier"),"lock on entry")
    gate='@e[type=minecraft:block_display,tag=sd.floor_gate,distance=0..'
    gate_count=len(list(doors(combat,edges)))
    first_panel=gate+',tag=sd.floor_gate_row_0,limit=1]'
    wait(lambda: on_floor(f"data get entity {first_panel} transformation.translation[1]").endswith("0.0f"),"logs descend to their doorway")
    check("entry uses seven full-size logs per row and five rows per doorway",
          phase()==1 and entity_count(gate+"]")==gate_count*35
          and all(entity_count(gate+f",tag=sd.floor_gate_row_{row}]")==gate_count*7 for row in range(5))
          and "[1.0f, 1.0f, 1.0f]" in on_floor(f"data get entity {first_panel} transformation.scale"))
    move(.5,81,ENTRY_Z+.5)
    wait(lambda: position_is((cx+4.5,81,cz+.5)),"entry confinement after forced movement")
    trigger(21)
    wait(lambda: phase()==2 and entity_count("@e[tag=sd.floor_enemy,distance=0..]")>=5,"battle wave")
    move(.5,81,ENTRY_Z+.5)
    wait(lambda: position_is((cx+4.5,81,cz+.5)),"active confinement after forced movement")
    check("escaping cannot reset the active fight",phase()==2 and entity_count("@e[tag=sd.floor_enemy,distance=0..]")>=5)
    on_floor("kill @e[tag=sd.floor_enemy,distance=0..]")
    first_open_panel=first_panel[:-1]+",tag=sd.floor_gate_open]"
    wait(lambda: on_floor(f"data get entity {first_open_panel} transformation.translation[1]").endswith("-5.0f"),
         "victory sends gate logs five blocks down",3)
    wait(lambda: phase()==3 and doors_are(combat,edges,"air") and entity_count(gate+"]")==0,"reward and fully retracted gate")
    check("victory sinks the wooden gate into the floor and cleans every display",True)
    check("first victory grants one draw and reopens the weighted fight", "1b" in storage("battle_draw"))
    trigger(30)
    wait(lambda: phase()==1,"claim equipment")
    visit(elite)
    trigger(20)
    wait(lambda: phase()==2 and entity_count("@e[tag=sd.floor_enemy,distance=0..]")>=5,"elite")
    on_floor("kill @e[tag=sd.floor_enemy,distance=0..]")
    wait(lambda: phase()==3,"elite reward")
    roll=status("#quality")
    expected=next((tier for tier,limit in enumerate((3000,6000,9200),1) if roll<=limit),4)
    check("elite still uses its dedicated rarity odds",storage("exact_tier").endswith(f": {expected}"))
    trigger(30)
    wait(lambda: phase()==1,"claim elite")
    services=[room for room in rooms.values()
              if room[2] not in ("entry","boss","combat","elite","event","forge")]
    for room in services[:4]:
        visit(room)
    wait(lambda: status("#budget")==0 and "1b" in storage("exploration_doors"),"exhaustion")
    blocked=next(r for r in rooms.values() if r[2]=="combat" and r!=combat)
    check("exhaustion closes unexplored doors and keeps access to the boss",
          doors_are(blocked,edges,"barrier") and doors_are(boss,edges,"air"))
    trigger(24)
    wait(lambda: status(PLAYER,"zx.rg_room")==boss[3],"boss shortcut")
    trigger(20)
    wait(lambda: phase()==2 and entity_count("@e[tag=sd.kn.body,distance=0..]")==1,"Knight in custom dimension")
    on_floor("damage @e[tag=sd.kn.body,limit=1,distance=0..] 110 minecraft:out_of_world")
    wait(lambda: status("@e[tag=sd.kn.body,limit=1]","sdk.phase")==2,"Knight phase two")
    check("the real Knight advances to phase two in the independent dimension",True)
    on_floor("kill @e[tag=sd.kn.body,distance=0..,limit=1]")
    wait(lambda: phase()==4,"god choice")
    trigger(41)
    wait(lambda: phase()==5,"claim god")
    trigger(3)
    wait(lambda: phase()==0 and status("#rv_clean","zx.meta")==0,"clean first run")
    check("ending a run clears the full loadout and the persistent HUD",
          no_item("*") and "sd.floor_hud" not in tags(PLAYER) and position_is(SPAWN))
    replay=enter()
    check("can replay without leftover door panels or NPC duplicates", replay!=rooms
          and entity_count('@e[type=minecraft:block_display,tag=sd.floor_gate,distance=0..]')==0
          and entity_count('@e[type=minecraft:villager,tag=sd.floor_vendor,distance=0..]')==4)
    command(f"item replace entity {PLAYER} armor.chest with minecraft:diamond_chestplate")
    command(f"item replace entity {PLAYER} enderchest.0 with minecraft:diamond_sword")
    command(f"kill {PLAYER}")
    wait(lambda: phase()==0 and "sd.floor_run" not in tags(PLAYER),"death returns to lobby")
    check("death actually clears armor, inventory, offhand and reserved equipment",
          no_item("*") and "passed" in command(f"execute unless items entity {PLAYER} armor.* *").lower()
          and "passed" in command(f"execute unless items entity {PLAYER} enderchest.* *").lower()
          and position_is(SPAWN))
    verify_cabin_migration()


if __name__=="__main__":
    main()
