"""Update lobby entrances, reuse the former practice clearing, and keep one dummy per lane."""

from pathlib import Path

from architecture import Build, LEAVES, MOSS, PALE_LEAVES, WORN, lamp
from cabin_lobby import TUTORIAL, TUTORIAL_BOX
from floor_upgrade import edit, text, write
from forest_economy import FN, RUN, say
from lobby_expansion import DUMMY, DUMMY_PADS, LOBBY, TRAINING_DIM, TRAINING_TAG, coords
from training_world import EXIT, GATE_TAG, NS, STORE, sign

GATE = (276.0, 78, 30.0)
GATE_BOX = "x=275,y=78,z=29,dx=1,dy=1,dz=1"
SNEAK = "predicate sweetdream:is_sneaking"
PAD = "minecraft:waxed_oxidized_cut_copper"
KEPT = "sd.practice_kept"


def garden():
    b = Build()
    # Keep the shed and its approach clear. Only dress the retired lanes east of it.
    b.disk(285,77,30,4,3,MOSS)
    b.disk(287,77,38,4,3,"podzol")
    b.disk(284,77,39,3,2,MOSS)
    for x,z in ((279,31),(280,32),(281,33),(282,34),(284,35),(285,35),(287,35),(289,34)):
        b.set(x,77,z,"coarse_dirt")
    for x,z in ((281,32),(283,34),(286,35),(288,34)):
        b.set(x,77,z,"mossy_cobblestone")
    # A low spring and its spillway sit where the forward practice target stood.
    b.disk(285,77,30,2,2,WORN)
    b.set(285,77,30,"water")
    for x,z in ((284,30),(286,30),(285,29)):
        b.set(x,78,z,"mossy_stone_brick_wall")
    b.set(285,78,31,"mossy_stone_brick_slab[type=bottom]")
    b.set(283,78,29,"azalea")
    b.set(287,78,29,"flowering_azalea")
    b.set(284,78,32,"fern")
    b.set(287,78,32,"moss_carpet")
    # Mixed-height planting and a tucked woodpile fill the far edge.
    b.box((288,78,39),(288,82,39),"dark_oak_log")
    b.box((287,81,39),(289,81,39),"dark_oak_log[axis=x]")
    for y,x,z,rx,rz,leaves in (
        (82,288,39,3,3,LEAVES), (83,288,40,3,2,LEAVES),
        (84,289,40,2,2,PALE_LEAVES), (85,288,40,1,1,LEAVES),
    ):
        b.disk(x,y,z,rx,rz,leaves)
    b.set(288,78,38,"mangrove_roots")
    b.set(289,78,39,"mangrove_roots")
    for x,z in ((282,38),(283,40),(286,41),(288,41),(290,35),(281,36)):
        b.set(x,78,z,"fern" if x%2 else "azalea")
    b.set(283,78,37,"brown_mushroom")
    b.set(285,78,40,"red_mushroom")
    b.box((286,78,37),(288,78,37),"spruce_log[axis=x]")
    b.box((287,79,37),(288,79,37),"stripped_spruce_log[axis=x]")
    b.set(286,79,37,"spruce_slab[type=bottom]")
    b.set(287,80,37,"lantern")
    b.set(288,80,37,"moss_carpet")
    lamp(b,282,41)
    return b.lines


def stage(world):
    floor = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name, *rows):
        write(floor/f"{name}.mcfunction", "\n".join(rows))

    file = floor/"lobby/player_tick.mcfunction"
    line = f"execute if entity @s[{TUTORIAL_BOX}] if block ~ ~-1 ~ minecraft:amethyst_block run return run function {FN}tutorial/enter"
    edit(file,(line,line.replace(" run return",f" if {SNEAK} run return")))
    file = floor/"tutorial/enter.mcfunction"
    body = text(file)
    write(file, "\n".join((
        "execute unless dimension minecraft:overworld run return 0",
        f"execute unless entity @s[{TUTORIAL_BOX},tag=!sd.floor_tutorial] run return 0",
        f"execute unless {SNEAK} run return 0",
        "execute unless block ~ ~-1 ~ minecraft:amethyst_block run return 0",
        body,
    )))
    edit(floor/"route.mcfunction", (f"matches 2 run return run function {FN}tutorial/enter",
         "matches 2 run return run "+say("在紫晶台潜行进入。","light_purple")))
    mc("training/gate",
       f"execute unless {SNEAK} run tag @s remove {GATE_TAG}",
       f"execute unless entity @s[{GATE_BOX}] run tag @s remove {GATE_TAG}",
       f"execute if data storage {STORE} {{gate_ui:1b}} if entity @s[tag=!{GATE_TAG},{GATE_BOX}] "
       f"if block ~ ~-1 ~ {PAD} if {SNEAK} run function {NS}enter")

    # Update saved displays through tagged migration. Fresh builds get the same wording.
    tut = sign((TUTORIAL[0],79.6,TUTORIAL[2]),"甜梦研习","潜行进入","sd.tutorial_gate_sign","light_purple")
    entrance = sign((GATE[0],80.0,GATE[2]),"训练场","潜行进入","sd.training_gate_sign")
    departure = sign((EXIT[0],80.45,EXIT[2]),"返回大厅","","sd.training_exit")
    rules = (
        ("training/replace_gate.mcfunction","sd.training_gate_sign",entrance),
        ("training/arena.mcfunction","sd.training_exit",departure),
        ("lobby/expansion/build_loaded.mcfunction",'"甜梦研习"',tut),
    )
    for path,tag,replacement in rules:
        file = floor/path
        line = next(row for row in text(file).splitlines() if row.startswith("summon minecraft:text_display ") and tag in row)
        edit(file,(line,replacement))
    for name in ("capture","restore"):
        file = floor/f"training/{name}.mcfunction"
        write(file,"\n".join(row for row in text(file).splitlines()
                             if not row.startswith("tellraw @s ") or '"click_event"' in row))

    mc("training/portal_updates",
       f"execute if data storage {RUN} {{lobby_expansion:1b}} unless data storage {STORE} {{tutorial_ui:1b}} "
       f"if loaded 266 78 2 run function {NS}tutorial_sign",
       f"execute if data storage {STORE} {{built:1b}} unless data storage {STORE} {{gate_ui:1b}} "
       f"if loaded 275 78 30 run function {NS}entrance_sign",
       f"execute if data storage {STORE} {{built:1b}} unless data storage {STORE} {{old_yard:1b}} "
       f"if loaded 279 78 27 if loaded 291 78 27 if loaded 279 78 39 if loaded 291 78 39 run function {NS}garden",
       f"execute if data storage {STORE} {{built:1b}} unless data storage {STORE} {{exit_ui:1b}} "
       f"in {TRAINING_DIM} if loaded 266 78 37 run function {NS}exit_sign")
    mc("training/tutorial_sign",
       'execute positioned 266.5 79.6 2.5 run kill @e[type=minecraft:text_display,tag=sd.lobby_expansion,distance=..0.4]',
       f"kill @e[type=minecraft:text_display,tag=sd.tutorial_gate_sign,distance=0..]",
       tut, f"data modify storage {STORE} tutorial_ui set value 1b")
    mc("training/entrance_sign",
       f"fill 275 77 29 276 77 30 {PAD}",
       "kill @e[type=minecraft:text_display,tag=sd.training_gate_sign,distance=0..]",
       entrance, f"data modify storage {STORE} gate_ui set value 1b")
    mc("training/exit_sign",
       "kill @e[type=minecraft:text_display,tag=sd.training_exit,distance=0..]",
       departure, f"data modify storage {STORE} exit_ui set value 1b")
    mc("training/garden", *garden(), f"data modify storage {STORE} old_yard set value 1b")

    file = floor/"tick.mcfunction"
    edit(file,
         (f"run function {NS}player_tick", f"run function {NS}player_tick\n"
          f"execute in minecraft:overworld run function {NS}portal_updates"),
         (f"execute in minecraft:overworld run function {LOBBY}metrics/tick",
          f"execute in {TRAINING_DIM} if entity @a[tag={TRAINING_TAG},distance=0..] run function {LOBBY}practice/settle_dummies\n"
          f"execute in minecraft:overworld run function {LOBBY}metrics/tick"))

    dummies(mc, floor)


def dummies(mc, floor):
    spawn = floor/"lobby/practice/dummies.mcfunction"
    body = text(spawn)
    for i,point in enumerate(DUMMY_PADS):
        old = f"positioned {coords(point)} unless entity @e[tag={DUMMY}_{i},distance=..4]"
        body = body.replace(old, f"positioned {coords(point)} if loaded ~ ~ ~ "
                            f"unless entity @e[type=minecraft:husk,tag={DUMMY}_{i},distance=0..]")
    write(spawn,body.replace("CustomNameVisible:1b","CustomNameVisible:0b"))
    file=floor/"lobby/practice/tick.mcfunction"
    edit(file,(f"if entity @a[tag={TRAINING_TAG}]",f"if entity @a[tag={TRAINING_TAG},distance=0..]"))

    mc("lobby/practice/settle_dummies", *(
        f"execute positioned {coords(point)} if loaded ~ ~ ~ run function {LOBBY}practice/settle_{i}"
        for i,point in enumerate(DUMMY_PADS)))
    for i,(x,y,z) in enumerate(DUMMY_PADS):
        group=f"type=minecraft:husk,tag={DUMMY}_{i},distance=0.."
        lane = f"x={int(x)-2},y=76,z={int(z)-2},dx=4,dy=20,dz=4"
        mc(f"lobby/practice/settle_{i}",
           f"tag @e[{group},tag={KEPT}] remove {KEPT}",
           f"tag @e[{group},sort=nearest,limit=1] add {KEPT}",
           f"execute as @e[{group},tag=!{KEPT}] at @s run function {LOBBY}practice/discard_duplicate",
           f"execute as @e[{group},tag={KEPT}] unless entity @s[{lane}] run tp @s ~ ~ ~ 90 0",
           f"execute as @e[{group},tag={KEPT},nbt={{CustomNameVisible:1b}}] run data merge entity @s {{CustomNameVisible:0b}}",
           f"tag @e[{group},tag={KEPT}] remove {KEPT}")
    mc("lobby/practice/discard_duplicate", "tp @s ~ -128 ~", "kill @s")
