"""Refresh the camp controls, welcome text, and wooden door anchors."""

import gzip
from pathlib import Path
from struct import pack, unpack_from

from cabin_lobby import CAMP_BOX, LOBBY_BOX, PAD
from floor_upgrade import edit, text, write
from forest_economy import FN, button, literal, say
from lobby_expansion import LOBBY, READY, TRAINING_TAG

NAME = "坠梦"
LEVEL_NAME = "§6§l坠梦§r §8- §7FALLEN DREAM§r"
SNEAK = "predicate sweetdream:is_sneaking"
PROMPT = "sd.camp_prompt"
HEALING = "sd.lobby_healing"


def rename_level(blob):
    raw = gzip.decompress(blob)
    key = b"\x08\x00\x09LevelName"
    if raw.count(key) != 1:
        raise ValueError("Unexpected LevelName layout")
    start = raw.index(key)+len(key)
    length = unpack_from(">H",raw,start)[0]
    encoded=LEVEL_NAME.encode("utf8")
    if raw[start+2:start+2+length]==encoded:
        return blob
    return gzip.compress(raw[:start]+pack(">H",len(encoded))+encoded+raw[start+2+length:],mtime=0)


def stage(world):
    world=Path(world)
    f=world/"datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name,*rows):
        write(f/f"{name}.mcfunction","\n".join(rows))

    map_record=world/"level.dat"
    map_record.write_bytes(rename_level(map_record.read_bytes()))
    file=f/"lobby/menu.mcfunction"
    body=text(file).replace("甜梦回廊",NAME)
    guard=next(line for line in body.splitlines() if "execute unless entity @s[" in line)
    write(file, body.replace(guard,guard+f"\nexecute if entity @s[tag={READY}] run return run function {LOBBY}ready_menu"))
    ready_buttons=literal([button("开始游戏",4),{"text":"    "},button("取消准备",5,"gray")])
    mc("lobby/ready_menu", say("已准备","green"), "tellraw @s "+ready_buttons)
    file=f/"lobby/prepare.mcfunction"
    edit(file,("已准备的玩家会一起入梦","已准备的玩家会开始游戏"))
    file=f/"lobby/unready.mcfunction"
    write(file,f"execute unless entity @s[tag={READY}] run return 0\n"+text(file))

    mc("lobby/pad","tag @s add sd.floor_pad")
    mc("lobby/camp_prompt",f"tag @s add {PROMPT}",f"function {LOBBY}menu")
    file=f/"lobby/player_tick.mcfunction"
    body=text(file)
    write(file,body+"\n"+"\n".join((
        f"execute unless entity @s[tag=sd.floor_pad] run tag @s remove {PROMPT}",
        f"execute unless {SNEAK} run tag @s remove {PROMPT}",
        f"execute if entity @s[tag=sd.floor_pad,tag=!{PROMPT},{CAMP_BOX}] if block ~ ~-1 ~ {PAD} "
        f"if {SNEAK} run function {LOBBY}camp_prompt",
    )))

    eligible=f"{LOBBY_BOX},tag=!sd.floor_run,tag=!sd.floor_tutorial,tag=!{TRAINING_TAG}"
    mc("lobby/healing/tick",
       f"execute as @a[tag={HEALING}] at @s unless dimension minecraft:overworld run function {LOBBY}healing/clear",
       f"execute as @a[tag={HEALING}] at @s unless entity @s[{eligible}] run function {LOBBY}healing/clear",
       "scoreboard players add #lobby_heal sd.floor 1",
       "execute unless score #lobby_heal sd.floor matches 20.. run return 0",
       "scoreboard players set #lobby_heal sd.floor 0",
       f"execute in minecraft:overworld as @a[{eligible}] "
       f'unless data entity @s active_effects[{{id:"minecraft:regeneration"}}] run function {LOBBY}healing/grant')
    mc("lobby/healing/grant","effect give @s minecraft:regeneration 4 0 true",f"tag @s add {HEALING}")
    mc("lobby/healing/clear","effect clear @s minecraft:regeneration",f"tag @s remove {HEALING}")
    file=f/"tick.mcfunction"
    ready=next(line for line in text(file).splitlines() if "{lobby:1b,cabin_layout:1b}" in line)
    edit(file,(ready,ready+f"\nfunction {LOBBY}healing/tick"))
    doors(mc,f)


def doors(mc,f):
    file=f/"room/doors/update.mcfunction"
    edit(file,("positioned $(x) 81 $(z) positioned","positioned $(x) 81 $(z) align xz positioned"))
    file=f/"room/doors/tick.mcfunction"
    write(file,
          "execute as @e[type=minecraft:block_display,tag=sd.floor_gate,tag=!sd.floor_gate_aligned,distance=0..] "
          "at @s align xz run function sweetdream_floor:room/doors/align\n"+text(file))
    mc("room/doors/align","tp @s ~ ~ ~","tag @s add sd.floor_gate_aligned")
