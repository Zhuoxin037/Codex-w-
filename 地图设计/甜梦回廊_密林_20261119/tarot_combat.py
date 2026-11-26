"""Combat hooks for Fool, Lovers, and Tower. No effects run in the lobby."""
import math
import re
from tarot_floor import F,T,R,S,M,PLAYERS,DIMS,j


HEART="@a[tag=ft.link_player,tag=sd.floor_run,tag=zx.rg_active,gamemode=!spectator,gamemode=!creative,distance=0..,limit=1,nbt=!{Health:0f},scores={sd.floor_death=0}]"
FOE="@e[tag=ft.link_enemy,tag=sd.floor_enemy,distance=0..,limit=1,nbt=!{Health:0f}]"
LIVING="@e[tag=sd.floor_enemy,distance=0..,nbt=!{Health:0f}]"


def combat(p):
    begin=p.read(F+"combat/begin")
    p.mc(F+"combat/begin",*begin,
        f"execute if score #phase sd.floor matches 2 run function {T}combat/start with storage {R} current")
    win=p.read(F+"combat/win")
    p.mc(F+"combat/win",f"function {T}combat/clear",*win)
    p.ft("combat/start",
        f"function {T}combat/clear",
        f"scoreboard players set #armed {M} 1",
        f"$function {T}fool/battle {{cell:$(cell)}}",
        f"execute if data storage {S} card{{id:1}} run function {T}combat/buff",
        f'$execute if data storage {S} card{{id:2}} positioned $(x).5 81 $(z).5 run function {T}love/begin',
        f'$execute if data storage {S} card{{id:3}} positioned $(x) 81 $(z) align xyz run function {T}tower/build')
    p.ft("combat/tick",
        f"execute if score #armed {M} matches 0 run return 0",
        f"execute if data storage {S} card{{id:1}} run return run function {T}combat/buff",
        f"execute if data storage {S} card{{id:2}} run return run function {T}love/tick",
        f"execute if data storage {S} card{{id:3}} run function {T}tower/tick")
    p.ft("combat/clear",
        f"scoreboard players set #armed {M} 0",
        f"scoreboard players set #attack {M} 100",
        "tag @a[tag=ft.link_player] remove ft.link_player",
        "tag @e[tag=ft.link_enemy,distance=0..] remove ft.link_enemy",
        "execute as @e[tag=ft.fool_mob,distance=0..] run attribute @s minecraft:attack_damage modifier remove fallentarot:fool",
        "tag @e[tag=ft.fool_mob,distance=0..] remove ft.fool_mob",
        f"execute as @e[tag=ft.column,type=marker,distance=0..] at @s run function {T}tower/clear_column",
        f"execute as @e[tag=ft.rubble,type=marker,distance=0..] at @s run function {T}tower/clear_rubble",
        "kill @e[tag=ft.tower,distance=0..]")
    p.ft("combat/buff",
        f"execute unless score #attack {M} matches 100 as @e[tag=sd.floor_enemy,tag=!ft.fool_mob,distance=0..,nbt=!{{Health:0f}}] run function {T}fool/mob")
    p.ft("fool/mob",
        "tag @s add ft.fool_mob",
        f"scoreboard players operation #bonus {M} = #attack {M}",
        f"scoreboard players remove #bonus {M} 100",
        f"execute store result storage {S} hit.bonus double .01 run scoreboard players get #bonus {M}",
        f"function {T}fool/attribute with storage {S} hit")
    p.ft("fool/attribute","$attribute @s minecraft:attack_damage modifier add fallentarot:fool $(bonus) add_multiplied_total")
    p.ft("fool/attack",
        f"scoreboard players operation #hit {M} *= #attack {M}",
        f"scoreboard players operation #hit {M} /= #100 {M}",
        f"execute store result storage {S} hit.damage double .001 run scoreboard players get #hit {M}")
    p.ft("fool/hit_active",
        f"execute unless dimension {DIMS[0]} unless dimension {DIMS[1]} run return 0",
        f"execute unless score #armed {M} matches 1 run return 0",
        f"execute unless data storage {R} encounter run return 0",
        f"execute if score #attack {M} matches 100 run return 0",
        "return 1")
    p.around(F+"combat/mobs/impact","#impact_hp sd.floor < #impact_cap",
        f"execute if score #armed {M} matches 1 run scoreboard players operation #impact_hp sd.floor *= #attack {M}",
        f"execute if score #armed {M} matches 1 run scoreboard players operation #impact_hp sd.floor /= #100 {M}")
    for name in ("branch/left_hit","branch/right_hit","moth/hit","moth/touch"):
        replace_damage(p,F+"combat/mobs/"+name)
    # This namespace also runs in the base game's boss showcase. The overlay
    # multiplies its hits only within a live Fallen Dream encounter.
    for name in ("echo/hit_one","wave/hit_one","hit/deal","shadow/deal"):
        replace_damage(p,"fallendream:boss/knight/"+name)
    love(p)
    tower(p)
    p.asset("data/fallentarot/damage_type/stone.json",j({"message_id":"fallingBlock","scaling":"never","exhaustion":0}))


def replace_damage(p,name):
    out=[]
    for i,row in enumerate(p.read(name)):
        match=re.search(r"\bdamage (\S+) (\$\(amount\)|[\d.]+) ",row)
        if not match or row.startswith("#"):
            out.append(row)
            continue
        original=row.lstrip("$")
        pos=match.start(2)-int(row.startswith("$"))
        end=match.end(2)-int(row.startswith("$"))
        sub=f"fool/script/{name.replace(':','/')}_{i}"
        command="$"+original[:pos]+"$(damage)"+original[end:]
        macro_keys=re.findall(r"\$\(([^)]+)\)",command)
        extra=[key for key in dict.fromkeys(macro_keys) if key!="damage"]
        amount=match[2]
        macro=bool(extra or amount.startswith("$"))
        out.append(("$" if macro else "")+f"execute if function {T}fool/hit_active run function {T}{sub} "
                   +(f'{{base:{amount},'+",".join(f'{key}:"$({key})"' for key in extra)+"}" if extra else f"{{base:{amount}}}"))
        original_exec=original[len("execute "):] if original.startswith("execute ") else "run "+original
        # The unchanged branch preserves the original execution result for callers
        # and the original amount when this overlay is not active.
        out.append(("$" if row.startswith("$") else "")+f"execute unless function {T}fool/hit_active "+original_exec)
        p.ft(sub,
             f"$data modify storage {S} amount set value $(base)",
             f"execute store result score #hit {M} run data get storage {S} amount 1000",
             *(f'$data modify storage {S} hit.{key} set value "$({key})"' for key in extra),
             f"function {T}fool/attack",f"function {T}{sub}_deal with storage {S} hit")
        p.ft(sub+"_deal",command)
    p.mc(name,*out)


def love(p):
    candidates=f"{PLAYERS[:-1]},gamemode=!creative,gamemode=!spectator,sort=random,limit=1]"
    p.ft("love/begin",
        "tag @e[tag=sd.floor_enemy,distance=..24,sort=random,limit=1,nbt=!{Health:0f}] add ft.link_enemy",
        f"execute if entity {FOE} run tag {candidates} add ft.link_player",
        *(f"scoreboard players set #{key} {M} 0" for key in ("love_charge","love_cooldown","love_uses","pulse")),
        f'execute as {HEART} run title @s actionbar {{text:"恋人 · 血线已建立",color:"#e6abb7"}}')
    p.ft("love/tick",
        f"execute unless entity {HEART} run return 0",
        f"execute unless entity {FOE} run return 0",
        f"execute if score #love_uses {M} matches 2.. run return 0",
        f"scoreboard players add #pulse {M} 1",
        f"execute if score #pulse {M} matches 4.. as {HEART} at @s facing entity {FOE} eyes run function {T}love/line",
        f"execute if score #love_cooldown {M} matches 1.. run return run scoreboard players remove #love_cooldown {M} 1",
        f"execute if score #reverse {M} matches 0 at {HEART} unless entity {FOE.replace('distance=0..','distance=..5')} run return run scoreboard players set #love_charge {M} 0",
        f"execute if score #reverse {M} matches 1 at {HEART} if entity {FOE.replace('distance=0..','distance=..8')} run return run scoreboard players set #love_charge {M} 0",
        f"execute unless score #love_charge {M} matches 40.. run scoreboard players add #love_charge {M} 1",
        f"execute if score #love_charge {M} matches 40.. run function {T}love/pulse")
    p.ft("love/line",f"scoreboard players set #pulse {M} 0",
        *(f"execute anchored eyes positioned ^ ^ ^{d*.65:g} if entity {FOE.replace('distance=0..','distance=.55..')} "
          'run particle minecraft:dust{color:[.90,.36,.50],scale:.82} ~ ~ ~ 0 0 0 0 1 force @a[distance=..32]' for d in range(1,20)))
    p.ft("love/pulse",
        f"scoreboard players set #healed {M} 0",
        f"execute store result score #player_hp {M} run data get entity {HEART} Health 1000",
        f"execute store result score #enemy_hp {M} run data get entity {FOE} Health 1000",
        f"execute as {HEART} store result score #player_max {M} run attribute @s minecraft:max_health get 1000",
        f"execute as {FOE} store result score #enemy_max {M} run attribute @s minecraft:max_health get 1000",
        f"execute if score #reverse {M} matches 0 run function {T}love/together",
        f"execute if score #reverse {M} matches 1 run function {T}love/apart",
        f"execute unless score #healed {M} matches 1 run return 0",
        f"scoreboard players add #love_uses {M} 1",
        f"scoreboard players set #love_charge {M} 0",
        f"scoreboard players set #love_cooldown {M} 100")
    p.ft("love/together",
        f"execute if score #player_hp {M} < #player_max {M} as {HEART} at @s run function {T}love/heal_player {{amount:4}}",
        f"execute if score #enemy_hp {M} < #enemy_max {M} as {FOE} at @s run function {T}love/heal_enemy {{amount:8000}}")
    p.ft("love/apart",
        f"scoreboard players set #thousand {M} 1000",
        *(cmd for side in ("player","enemy") for cmd in (
            f"scoreboard players operation #{side}_ratio {M} = #{side}_hp {M}",
            f"scoreboard players operation #{side}_ratio {M} *= #thousand {M}",
            f"scoreboard players operation #{side}_ratio {M} /= #{side}_max {M}")),
        f"execute if score #player_ratio {M} < #enemy_ratio {M} as {HEART} at @s run function {T}love/heal_player {{amount:6}}",
        f"execute if score #enemy_ratio {M} < #player_ratio {M} as {FOE} at @s run function {T}love/heal_enemy {{amount:12000}}")
    p.ft("love/heal_player",
        "$scoreboard players set #heal_pt zx.meta $(amount)",
        "scoreboard players set #heal_got zx.meta 0",
        "function fallendream:lib/heal",
        f"execute if score #heal_got zx.meta matches 1.. run function {T}love/heal_fx")
    p.ft("love/heal_enemy",
        f"scoreboard players operation #new_hp {M} = #enemy_hp {M}",
        f"$scoreboard players add #new_hp {M} $(amount)",
        f"scoreboard players operation #new_hp {M} < #enemy_max {M}",
        f"execute store result entity @s Health float .001 run scoreboard players get #new_hp {M}",
        f"function {T}love/heal_fx")
    p.ft("love/heal_fx",
        f"scoreboard players set #healed {M} 1",
        "particle minecraft:heart ~ ~1.4 ~ .32 .35 .32 .03 5 force @a[distance=..32]",
        "playsound minecraft:block.amethyst_block.chime master @a[distance=..16] ~ ~ ~ .65 1.25")
    p.ft("love/restore_previous",
        "attribute @s minecraft:max_health modifier remove fallentarot:love_cap",
        "scoreboard players reset @s ft.cap")

def tower(p):
    p.ft("tower/build",f"function {T}tower/layout_left",f"function {T}tower/layout_right")
    for side,dir in (("left",1),("right",-1)):
        p.ft("tower/layout_"+side,
            *(f"execute positioned ~{x*dir} ~ ~{z*dir} if function {T}tower/check_{side} run return 1"
              for x,z in ((-8,-7),(-9,-5),(-10,-8),(-8,-10))))
        cells=[(0,y,0) for y in range(3)]
        conditions=" ".join(f"if block ~{x} ~{y} ~{z} #sweetdream_floor:room_air" for x,y,z in cells)
        p.ft("tower/check_"+side,
            f"execute {conditions} positioned ~.5 ~ ~.5 unless entity @a[distance=..1.5] "
            f"unless entity @e[tag=sd.floor_enemy,distance=..1.5] run return run function {T}tower/place_{side}",
            "return 0")
        p.ft("tower/place_"+side,
            "fill ~ ~ ~ ~ ~2 ~ minecraft:barrier replace #sweetdream_floor:room_air",
            f'summon minecraft:marker ~ ~ ~ {{Tags:["ft.tower","ft.column","ft.{side}"]}}',
            f'summon minecraft:interaction ~ ~ ~ {{Tags:["ft.tower","ft.pillar_hit","ft.{side}"],width:1.36f,height:3.05f,response:1b}}',
            f'summon minecraft:block_display ~ ~ ~ {{Tags:["ft.tower","ft.shaft","ft.{side}"],block_state:{{Name:"minecraft:chiseled_tuff_bricks"}},'
            'width:4f,height:4f,transformation:{translation:[-.5f,0f,-.5f],scale:[1f,3f,1f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}',
            "return 1")
        p.ft("tower/trigger_"+side,
            f"tag @e[tag=ft.column,tag=ft.{side},distance=..0.2,limit=1] add ft.fall",
            f"scoreboard players set @e[tag=ft.column,tag=ft.{side},distance=..0.2,limit=1] ft.age 18",
            "fill ~ ~ ~ ~ ~2 ~ minecraft:air replace minecraft:barrier",
            "playsound minecraft:block.tuff.break master @a[distance=..24] ~ ~ ~ 1 .67",
            "kill @s")
        # Mark every reachable block of the straight horizontal fall line.
        p.ft("tower/warn_"+side, *(f'particle minecraft:dust{{color:[.96,.65,.23],scale:1.25}} ~{dir*k} ~.12 ~ .18 0 .45 0 3 force @a[distance=..30]' for k in range(5)))
        rotation=-dir*math.sin(math.pi/4)
        p.ft("tower/fall_"+side,
            "fill ~ ~ ~ ~ ~2 ~ minecraft:air replace minecraft:barrier",
            f"execute if score #reverse {M} matches 1 run return run function {T}tower/erect",
            f"data merge entity @e[tag=ft.shaft,tag=ft.{side},distance=..0.4,limit=1] "
            f"{{start_interpolation:0,interpolation_duration:5,transformation:{{left_rotation:[0f,0f,{rotation:.6f}f,.707107f],scale:[1f,4.5f,1f]}}}}",
            "playsound minecraft:block.deepslate_bricks.break master @a[distance=..26] ~ ~ ~ 1 .65",
            "scoreboard players set @s ft.age 9",
            "tag @s remove ft.fall",
            "tag @s add ft.fallen")
        p.ft("tower/land_"+side,
            f"execute positioned ~{min(0,dir*4)-.5} ~ ~-.95 as {PLAYERS} if entity @s[dx=4,dy=2,dz=1] run damage @s 9 {T}stone",
            f"execute positioned ~{min(0,dir*4)-.5} ~ ~-.95 as {LIVING} if entity @s[dx=4,dy=2,dz=1] run damage @s 16 {T}stone")
    p.ft("tower/tick",
        *(f"execute as @e[tag=ft.pillar_hit,tag=ft.{side},distance=0..] at @s if data entity @s attack.player run function {T}tower/trigger_{side}" for side in ("left","right")),
        *(f"execute as @e[tag=ft.pillar_hit,tag=ft.{side},distance=0..] at @s if entity @e[tag=sd.stag.body,distance=..4] run function {T}tower/trigger_{side}" for side in ("left","right")),
        f"execute as @e[tag=ft.column,tag=ft.fall,distance=0..] at @s run function {T}tower/count",
        "scoreboard players remove @e[tag=ft.fallen,distance=0..] ft.age 1",
        *(f"execute as @e[tag=ft.fallen,tag=ft.{side},distance=0..,scores={{ft.age=4}}] at @s run function {T}tower/land_{side}" for side in ("left","right")),
        f"execute as @e[tag=ft.fallen,distance=0..,scores={{ft.age=..0}}] at @s run function {T}tower/clear_column",
        "scoreboard players remove @e[tag=ft.rubble,distance=0..] ft.age 1",
        f"execute as @e[tag=ft.rubble,distance=0..] at @s if entity @e[tag=sd.stag.body,distance=..3.5] run function {T}tower/clear_rubble",
        f"execute as @e[tag=ft.rubble,distance=0..,scores={{ft.age=..0}}] at @s run function {T}tower/clear_rubble")
    p.ft("tower/count",
        "scoreboard players remove @s ft.age 1",
        *(f"execute if entity @s[tag=ft.{side}] if score @s ft.age matches {ages} run function {T}tower/{func}_{side}"
          for side in ("left","right") for ages,func in (("5..17","warn"),("..0","fall"))))
    p.ft("tower/clear_column",
        "fill ~ ~ ~ ~ ~2 ~ minecraft:air replace minecraft:barrier",
        "kill @e[tag=ft.shaft,distance=..0.5]",
        "kill @e[tag=ft.pillar_hit,distance=..0.5]",
        "kill @s")
    p.ft("tower/erect",
        *(f"execute positioned ~ ~{y} ~{z} if block ~ ~ ~ #sweetdream_floor:room_air unless entity @e[distance=..0.78,type=!marker,type=!block_display] run function {T}tower/rubble"
          for y in range(2) for z in range(-2,3)),
        f"function {T}tower/clear_column")
    p.ft("tower/rubble",
        "setblock ~ ~ ~ minecraft:cracked_deepslate_bricks",
        'execute summon minecraft:marker run function fallentarot:tower/mark_rubble')
    p.ft("tower/mark_rubble","tag @s add ft.tower","tag @s add ft.rubble","scoreboard players set @s ft.age 160")
    p.ft("tower/clear_rubble",
        "execute if block ~ ~ ~ minecraft:cracked_deepslate_bricks run setblock ~ ~ ~ minecraft:air",
        "kill @s")
