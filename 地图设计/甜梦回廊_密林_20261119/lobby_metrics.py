"""Show camp readiness and actual damage dealt to each training dummy."""

from pathlib import Path

from floor_upgrade import edit, text, write
from forest_economy import literal
from lobby_expansion import CAMP, DUMMY, DUMMY_PADS, JOB, JOBS, LOBBY, READY, TRAINING_DIM, coords

NS = LOBBY + "metrics/"
STORE = "sweetdream_floor:lobby_metrics"
OBJ = "sd.lobby_stats"
WINDOW = 100
RECOVERY_INTERVAL = 5
RECOVERY_AMOUNT = 32_000
ROSTER = (255.5, 80.2, 20.0)
PALETTE = ("white", "aqua", "red", "yellow", "light_purple")


def display(position, tag):
    return (f'summon minecraft:text_display {coords(position)} '
            f'{{Tags:["{tag}"],text:{{text:""}},billboard:"center",background:1074792454,'
            'shadow:1b,view_range:0.35f,line_width:210,'
            'transformation:{translation:[0f,0f,0f],scale:[0.75f,0.75f,0.75f],'
            'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}')


def stage(world):
    root = Path(world)/"datapacks"
    overlay = root/"zz_sweetdream_floor/data"
    floor = overlay/"sweetdream_floor/function"
    runtime = overlay/"sweetdream/function"
    core = root/"sweetdream/data/sweetdream/function"

    def mc(name, *rows):
        write(floor/f"lobby/metrics/{name}.mcfunction", "\n".join(rows))

    file = floor/"load.mcfunction"
    write(file, text(file)+f"\nscoreboard objectives add {OBJ} dummy\n"
          f"scoreboard players set #ten {OBJ} 10\n"
          f"scoreboard players set #hundred {OBJ} 100")
    path = floor/"tick.mcfunction"
    line = f"execute in minecraft:overworld run function {LOBBY}practice/tick"
    edit(path, (line, f"execute in minecraft:overworld run function {NS}tick\n"+line))

    # Sampling on the pack's hit boundaries preserves separately applied hits
    # in the same tick. The floor tick accounts for other health changes.
    for rel, anchors in (
        ("internal/damage/one.mcfunction", ("function sweetdream:lib/damage_text/before with storage zx:work a",
                                           "function sweetdream:lib/damage_text/after")),
        ("internal/native/target.mcfunction", ("function sweetdream:lib/damage_text/native",)),
    ):
        file = runtime/rel
        if not file.is_file():
            write(file, text(core/rel))
        hook = f"execute if entity @s[tag={DUMMY}] run function {NS}sample"
        replacements = []
        for anchor in anchors:
            old = anchor
            if anchor.endswith("with storage zx:work a"):
                old = "execute unless data storage zx:work ob{src:\"enemy\"} run " + anchor
            replacements.append((old, hook+"\n"+old))
        edit(file, *replacements)
    mc("sample", *(f"execute if entity @s[tag={DUMMY}_{i}] run function {NS}dummy{i}/sample"
                   for i in range(len(DUMMY_PADS))))
    camp_roster(mc)
    training_metrics(mc)


def refresh_training(world):
    floor = Path(world)/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name, *rows):
        write(floor/f"lobby/metrics/{name}.mcfunction", "\n".join(rows))

    training_metrics(mc)
    camp_roster(mc)


def training_metrics(mc):
    mc("tick",
       f"execute unless data storage {STORE} {{damage_schema:2}} run function {NS}reset_old_samples",
       f"scoreboard players add #clock {OBJ} 1",
       f"scoreboard players add #recovery_tick {OBJ} 1",
       f"execute if score #recovery_tick {OBJ} matches {RECOVERY_INTERVAL}.. run scoreboard players set #recovery_tick {OBJ} 0",
       f"scoreboard players add #roster_poll {OBJ} 1",
       f"execute if score #roster_poll {OBJ} matches 5.. positioned {coords(ROSTER)} "
       f"if entity @a[distance=..32] run function {NS}roster",
       f"execute if score #roster_poll {OBJ} matches 5.. run scoreboard players set #roster_poll {OBJ} 0",
       *(f"execute in {TRAINING_DIM} positioned {coords(point)} if loaded ~ ~ ~ "
         f"if entity @a[distance=..32] run function {NS}dummy{i}/tick"
         for i,point in enumerate(DUMMY_PADS)))
    mc("reset_old_samples",
       *(line for i in range(len(DUMMY_PADS)) for line in (
          f"scoreboard players set #hp{i} {OBJ} -1",
          f"scoreboard players set #last{i} {OBJ} 0",
          f"scoreboard players set #sum{i} {OBJ} 0",
          f"scoreboard players set #dirty{i} {OBJ} 1",
          f"data remove storage {STORE} hits{i}",
       )),
       f"data modify storage {STORE} damage_schema set value 2")
    for i, pos in enumerate(DUMMY_PADS):
        dummy_stats(mc, i, pos)


def camp_roster(mc):
    tag = "sd.camp_roster"
    board = f"@e[type=minecraft:text_display,tag={tag},distance=..1,limit=1]"
    ready = f"@a[{CAMP},tag={READY},tag=!sd.floor_run,tag=!sd.floor_tutorial,scores={{{JOB}=10..14}}]"
    heading = [{"text":"已准备  ", "color":"gold", "bold":True},
               {"score":{"name":"#roster","objective":OBJ},"color":"white"},
               {"text":" 人","color":"white"}]
    rows = []
    for i, (job, color) in enumerate(zip(JOBS, PALETTE), 10):
        group = ready.replace("=10..14", f"={i}")
        rows.append(f'execute if entity {group} run data modify storage {STORE} roster append value '
                    + literal({"text":"\n"+job+"  ","color":color}))
        rows.append(f'execute if entity {group} run data modify storage {STORE} roster append value '
                    + literal({"selector":group,"color":"white","separator":{"text":"、"}}))
    mc("roster",
       f"execute as @e[type=minecraft:text_display,tag={tag},distance=0..] unless entity @s[distance=..1] run kill @s",
       f"execute unless entity {board} run {display(ROSTER, tag)}",
       f"scoreboard players set #roster {OBJ} 0",
       f"execute store result score #roster {OBJ} if entity {ready}",
       f"data modify storage {STORE} roster set value {literal(heading)}",
       *rows,
       f"data modify entity {board} text set from storage {STORE} roster")


def dummy_stats(mc, i, pos):
    name = f"dummy{i}"
    sub = NS + name + "/"
    path = name + "/"
    log = f"hits{i}"
    target=f"@e[type=minecraft:husk,tag={DUMMY}_{i},distance=0..,sort=nearest,limit=1]"
    board_tag = f"sd.practice_board_{i}"
    panel_group = f"type=minecraft:text_display,tag={board_tag},distance=0.."
    board = f"@e[{panel_group},sort=nearest,limit=1]"
    panel_keep = "sd.practice_panel_kept"
    ref = f"dummy_ref{i}"
    x,y,z = pos
    mc(path+"tick",
       f"scoreboard players add #sum{i} {OBJ} 0",
       f"scoreboard players add #panel_at{i} {OBJ} 0",
       f"scoreboard players set #panels {OBJ} 0",
       f"execute store result score #panels {OBJ} if entity @e[{panel_group}]",
       f"execute if score #panels {OBJ} matches 2.. run function {sub}prune_panels",
       f"execute if score #panels {OBJ} matches 0 if score #clock {OBJ} >= #panel_at{i} {OBJ} "
       f"if entity {target} run function {sub}spawn_panel",
       f"execute as {target} run function {sub}observe",
       f"execute unless entity {target} if score #hp{i} {OBJ} matches 1.. run function {sub}missing",
       f"execute if score #hp{i} {OBJ} matches 1.. if score #recovery_tick {OBJ} matches 0 "
       f"as {target} run function {sub}heal",
       f"execute if data storage {STORE} {log}[0] run function {sub}expire",
       f"execute if score #dirty{i} {OBJ} matches 1 if entity {board} run function {sub}display")
    mc(path+"spawn_panel",
       f"scoreboard players operation #panel_at{i} {OBJ} = #clock {OBJ}",
       f"scoreboard players add #panel_at{i} {OBJ} 20",
       f"scoreboard players set #dirty{i} {OBJ} 1",
       display((x,y+2.65,z), board_tag))
    mc(path+"prune_panels",
       f"tag @e[{panel_group},tag={panel_keep}] remove {panel_keep}",
       f"tag {board} add {panel_keep}",
       f"kill @e[{panel_group},tag=!{panel_keep}]",
       f"tag {board} remove {panel_keep}",
       f"scoreboard players set #dirty{i} {OBJ} 1")
    mc(path+"observe",
       f"function {sub}sample",
       f"execute unless data storage {STORE} {ref}.uuid run function {sub}remember")
    mc(path+"remember",
       "data modify storage zx:work nh_snapshot.UUID set from entity @s UUID",
       "function sweetdream:lib/entity_uuid/build",
       f"data modify storage {STORE} {ref} set from storage zx:work native_uuid")
    mc(path+"sample",
       f"execute store result score #current {OBJ} run data get entity @s Health 1000",
       f"execute store success score #new_dummy {OBJ} run data modify storage {STORE} dummy_id{i} set from entity @s UUID",
       f"execute if score #new_dummy {OBJ} matches 1 run data remove storage {STORE} {ref}",
       f"execute if score #new_dummy {OBJ} matches 1 run scoreboard players set #hp{i} {OBJ} -1",
       f"execute unless score #hp{i} {OBJ} matches 0.. run scoreboard players operation #hp{i} {OBJ} = #current {OBJ}",
       f"scoreboard players operation #delta {OBJ} = #hp{i} {OBJ}",
       f"scoreboard players operation #delta {OBJ} -= #current {OBJ}",
       f"scoreboard players operation #hp{i} {OBJ} = #current {OBJ}",
       f"execute if score #delta {OBJ} matches 1.. run function {sub}record")
    mc(path+"missing",
       f"execute if data storage {STORE} {ref}.uuid run function {sub}confirmed_death with storage {STORE} {ref}",
       f"scoreboard players set #hp{i} {OBJ} -1")
    mc(path+"confirmed_death",
       f"$execute as $(uuid) if data entity @s {{Health:0.0f}} run function {sub}sample")
    mc(path+"record",
       f"scoreboard players operation #last{i} {OBJ} = #delta {OBJ}",
       f"scoreboard players operation #sum{i} {OBJ} += #delta {OBJ}",
       f"scoreboard players set #dirty{i} {OBJ} 1",
       f"scoreboard players operation #expires {OBJ} = #clock {OBJ}",
       f"scoreboard players add #expires {OBJ} {WINDOW}",
       f"execute unless data storage {STORE} {log} run data modify storage {STORE} {log} set value []",
       f"execute store result score #tail {OBJ} run data get storage {STORE} {log}[-1].until",
       f"execute if score #tail {OBJ} = #expires {OBJ} run return run function {sub}merge",
       f"data modify storage {STORE} {log} append value {{until:0,amount:0}}",
       f"execute store result storage {STORE} {log}[-1].until int 1 run scoreboard players get #expires {OBJ}",
       f"execute store result storage {STORE} {log}[-1].amount int 1 run scoreboard players get #delta {OBJ}")
    mc(path+"heal",
       f"execute store result score #cap {OBJ} run attribute @s minecraft:max_health get 1000",
       f"execute if score #hp{i} {OBJ} >= #cap {OBJ} run return 0",
       f"scoreboard players operation #recovered {OBJ} = #hp{i} {OBJ}",
       f"scoreboard players add #recovered {OBJ} {RECOVERY_AMOUNT}",
       f"scoreboard players operation #recovered {OBJ} < #cap {OBJ}",
       f"execute store result entity @s Health float 0.001 run scoreboard players get #recovered {OBJ}",
       f"function {sub}sample",
       # Native hit detection and floating numbers also compare against saved health.
       "function sweetdream:internal/native/stamp",
       "function sweetdream:lib/damage_text/sample")
    # The rolling sum batches hits from the same tick. The last-hit readout
    # still changes at each separate damage callback.
    mc(path+"merge",
       f"execute store result score #bucket {OBJ} run data get storage {STORE} {log}[-1].amount",
       f"scoreboard players operation #bucket {OBJ} += #delta {OBJ}",
       f"execute store result storage {STORE} {log}[-1].amount int 1 run scoreboard players get #bucket {OBJ}")
    mc(path+"expire",
       f"execute store result score #expires {OBJ} run data get storage {STORE} {log}[0].until",
       f"execute if score #expires {OBJ} > #clock {OBJ} run return 0",
       f"execute store result score #expired {OBJ} run data get storage {STORE} {log}[0].amount",
       f"scoreboard players operation #sum{i} {OBJ} -= #expired {OBJ}",
       f"data remove storage {STORE} {log}[0]",
       f"scoreboard players set #dirty{i} {OBJ} 1",
       f"execute if data storage {STORE} {log}[0] run function {sub}expire")

    format_rows = [f"scoreboard players set #dirty{i} {OBJ} 0", f"scoreboard players add #last{i} {OBJ} 0"]
    for key in ("last", "sum"):
        format_rows.extend((
            f"scoreboard players operation #cents {OBJ} = #{key}{i} {OBJ}",
            f"scoreboard players add #cents {OBJ} 5",
            f"scoreboard players operation #cents {OBJ} /= #ten {OBJ}",
            f"scoreboard players operation #whole {OBJ} = #cents {OBJ}",
            f"scoreboard players operation #whole {OBJ} /= #hundred {OBJ}",
            f"scoreboard players operation #decimal {OBJ} = #cents {OBJ}",
            f"scoreboard players operation #decimal {OBJ} /= #ten {OBJ}",
            f"scoreboard players operation #decimal {OBJ} %= #ten {OBJ}",
            f"scoreboard players operation #cents {OBJ} %= #ten {OBJ}",
            *(f"execute store result storage {STORE} values.{key}_{part} int 1 run scoreboard players get #{score} {OBJ}"
              for part,score in (("whole","whole"),("tens","decimal"),("ones","cents"))),
        ))
    mc(path+"display", *format_rows, f"function {sub}render with storage {STORE} values")
    parts = [{"text":"单次伤害  ","color":"gray"},
             {"text":"$(last_whole).$(last_tens)$(last_ones)","color":"yellow"},
             {"text":"\n近 5 秒  ","color":"gray"},
             {"text":"$(sum_whole).$(sum_tens)$(sum_ones)","color":"aqua"}]
    mc(path+"render", f"$data modify entity {board} text set value {literal(parts)}")
