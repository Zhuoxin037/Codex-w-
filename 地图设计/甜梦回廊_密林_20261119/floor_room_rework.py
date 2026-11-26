"""Install isolated Forest rooms and the authored room interiors."""

from pathlib import Path
import json
import re

from architecture import Build, LEAVES, PITCH, RADII
from floor_route_map import DIMS, EDGES, KINDS
from forest_new_interiors import blade_clear_arena, interiors
from route_trial_scenes import black_arch
from wardrobe_panel import wardrobe


F = "sweetdream_floor:"
RG = "fallendream:rogue/"
RUN = F+"run"
GRAPH = "zx:rogue"
ROAD_Y = 120
ROAD_REACH = 14
SIDES = ((0,-1),(1,0),(0,1),(-1,0))
ROAD_TAG = "sd.room_road"


def stage(destination, original):
    original=Path(original)
    pack=Path(destination)/"datapacks/zzzz_fallendream_rooms"

    def asset(path,content):
        target=pack/path
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(content.rstrip()+"\n",encoding="utf8")

    def mc(path,*lines):
        namespace,name=path.split(":",1)
        asset(f"data/{namespace}/function/{name}.mcfunction","\n".join(lines))

    def read(path):
        namespace,name=path.split(":",1)
        return (original/f"data/{namespace}/function/{name}.mcfunction").read_text(encoding="utf8").splitlines()

    def remove(path, needle):
        body=read(path)
        assert sum(needle in line for line in body)==1,(path,needle)
        mc(path,*(line for line in body if needle not in line))

    asset("pack.mcmeta",json.dumps({"pack":{"pack_format":71,"description":"坠梦 · 独立房间与林屋陈设"}},ensure_ascii=False))
    for event in ("load","tick"):
        asset(f"data/minecraft/tags/function/{event}.json",json.dumps({"values":[F+"routes/"+event,F+"wardrobe/"+event]}))
    remove(F+"combat/boss",F+"combat/deer_glade")
    for variant in range(3):
        mc(RG+f"shell/boss_{variant}",*blade_clear_arena())
        mc(RG+f"detail/boss_{variant}","return 1")
    for kind,lines in interiors():
        for variant in range(3):
            mc(RG+f"detail/{kind}_{variant}",*lines)
    for kind in ("market","black"):
        path=F+"shop/"+kind+"_at"
        mc(path,*(line.replace(" ~ ~5 run "," ~ ~-7 run ").replace("distance=..10","distance=..12") for line in read(path)))

    remove(RG+"gen/corridor",RG+"corridors/")
    remove(F+"junction/build_shrub",F+"junction/closed_panel")
    remove(F+"junction/unlock",RG+"corridors/")
    mc(RG+"gen/build_cell",*read(RG+"gen/build_cell"),
       f"$execute positioned $(x) 80 $(z) run function {F}routes/room_exit_$(radius)",
       f"$data modify storage {GRAPH} floor.cells[$(cell)].isolated set value 1b")
    mc(RG+"map/locate",f"execute if entity @s[tag={ROAD_TAG},y=120,dy=14] run return run scoreboard players operation @s zx.rg_room = @s sd.road_cell",
       *read(RG+"map/locate"))
    mc(F+"run/join_party",f"tag @s remove {ROAD_TAG}",*read(F+"run/join_party"))
    rooms_and_roads(mc)
    loading(mc,read)
    health_bars(mc,read)
    reward_cards(mc,read)
    combat_clock(mc,read)
    narrow_gates(mc,read)
    room_effects(mc,read)
    weapon_effects(mc,original.parent/"fallendream")
    wardrobe(mc,asset,read)


def loading(mc,read):
    b=Build(relative=False)
    seats=((24,24),(120,24),(24,120),(120,120),(72,72))
    for x,z in seats:
        b.box((x-2,55,z-2),(x+2,60,z+2),"black_concrete")
        b.box((x-1,56,z-1),(x+1,59,z+1),"air")
    mc(F+"routes/black",*b.lines)
    for variant,dimension in zip(("forest","trial"),DIMS,strict=True):
        path=RG+f"prep/begin_{variant}"
        rows=[]
        for line in read(path):
            if "run tp @s " in line:
                rows.append(f"execute in {dimension} run function {F}routes/black")
                line=line.replace(" 320 "," 56 ")
            rows.append(line)
        mc(path,*rows)
        mc(F+f"routes/wait_{variant}",
           "execute unless loaded 72 56 72 run return 0",
           f"function {F}routes/black",
           "tag @s add sd.black_loading",
           "tp @s 72.5 56 72.5 0 80")
    original=RG+"prep/scan_canvas"
    mc(original,*(line.replace(" 320 "," 56 ") for line in read(original)))


def health_bars(mc,read):
    old=read(F+"mob_hp/update")
    old=[line.replace("if score #bar_found", "if score #max sd.exhibit = @s sd.hbar_max if score #bar_found")
         if line.startswith("execute if score #hp sd.exhibit = @s") else line for line in old]
    old.insert(-1,"scoreboard players operation @s sd.hbar_max = #max sd.exhibit")
    old[-1]=f"function {F}mob_hp/info"
    mc(F+"mob_hp/update",*old)
    mc(F+"mob_hp/info",
       f'data modify storage {RUN} mob_bar.name set value {{text:"敌对生物",color:"gray"}}',
       f"execute if data entity @s CustomName run data modify storage {RUN} mob_bar.name.text set from entity @s CustomName",
       f"execute if data entity @s CustomName.text run data modify storage {RUN} mob_bar.name set from entity @s CustomName",
       f"execute if data storage {RUN} mob_bar.name.text[0] run data modify storage {RUN} mob_bar.name set from entity @s CustomName",
       "scoreboard players set #hp_div sd.exhibit 100",
       "scoreboard players operation #hp_int sd.exhibit = #hp sd.exhibit",
       "scoreboard players add #hp_int sd.exhibit 99",
       "scoreboard players operation #hp_int sd.exhibit /= #hp_div sd.exhibit",
       "scoreboard players operation #max_int sd.exhibit = #max sd.exhibit",
       "scoreboard players add #max_int sd.exhibit 99",
       "scoreboard players operation #max_int sd.exhibit /= #hp_div sd.exhibit",
       f"execute store result storage {RUN} mob_bar.hp int 1 run scoreboard players get #hp_int sd.exhibit",
       f"execute store result storage {RUN} mob_bar.max int 1 run scoreboard players get #max_int sd.exhibit",
       f"execute store result storage {RUN} mob_bar.seg int 1 run scoreboard players get #bar_segments sd.exhibit",
       f"execute on passengers if entity @s[tag=sd.mob_healthbar] run function {F}mob_hp/fill with storage {RUN} mob_bar")
    header=json.dumps({"text":"  $(hp)/$(max)\n","color":"#f9ddbf"})
    mc(F+"mob_hp/fill",*("$"+row.replace("text set value [",f"text set value [$(name),{header},",1)
                          for row in read(F+"mob_hp/fill")))


def reward_cards(mc,read):
    open_reward=read(F+"reward/open")
    first_other=next(i for i,row in enumerate(open_reward) if '{tag:"cur_mana"' in row)
    open_reward.insert(first_other,f"data modify storage {RUN} archetype_options set from storage {RUN} options")
    show=open_reward.pop()
    assert show==f"function {F}reward/show"
    open_reward=[row for row in open_reward if row!=f"function {F}reward/sample" and not row.startswith("# dup-ok")]
    mc(F+"reward/open",*open_reward,f"function {F}reward/choose_archetype",
       *([f"function {F}reward/sample"]*3),show)
    mc(F+"reward/choose_archetype",
       f"execute unless data storage {RUN} archetype_options[0] run return run function {F}reward/sample",
       f"data modify storage {RUN} full_options set from storage {RUN} options",
       f"data modify storage {RUN} options set from storage {RUN} archetype_options",
       f"function {F}reward/sample",
       f"data modify storage {RUN} options set from storage {RUN} full_options",
       f"data remove storage {RUN} full_options",
       f"function {F}room/event/drop_tag with storage {RUN} offers[0]")
    show_reward=read(F+"reward/show")
    show_reward.insert(-1,f"execute if data storage {RUN} offers[3] run function {F}reward/button {{index:3,code:33}}")
    mc(F+"reward/show",*show_reward)


def narrow_gates(mc,read):
    gate=F+"routes/gate/"
    mc(F+"room/doors/update",
       '$execute if data storage zx:rogue floor.cells[{cell:$(cell),isolated:1b}] run return run function '
       +gate+'update {x:$(x),z:$(z),radius:$(radius)}',
       *read(F+"room/doors/update"))
    mc(gate+"update",f"$execute positioned $(x) 81 $(z) positioned ~ ~ ~$(radius) positioned ~ ~ ~-1 run function {gate}threshold")
    mc(gate+"threshold",
       f"execute if score #door_closed sd.floor matches 0 run return run function {gate}open",
       "execute if block ~ ~ ~ minecraft:barrier run return 0",
       "fill ~-1 ~ ~ ~1 ~2 ~ minecraft:barrier replace #sweetdream_floor:room_air",
       "kill @e[tag=sd.isolated_gate,distance=..0.2]",
       f"function {gate}panels")
    mc(gate+"open","fill ~-1 ~ ~ ~1 ~2 ~ minecraft:air replace minecraft:barrier",
       f"execute as @e[tag=sd.isolated_gate,tag=!sd.floor_gate_open,distance=..0.2] run function {F}room/doors/sink")
    panels=[]
    for x in (-1,0,1):
        for y in range(3):
            log="stripped_spruce_log" if x==0 else "stripped_dark_oak_log"
            panels.append(f'summon minecraft:block_display ~ ~ ~ {{Tags:["sd.isolated_gate","sd.floor_gate_row_{y}"],'
                          f'block_state:{{Name:"minecraft:{log}",Properties:{{axis:"x"}}}},'
                          f'transformation:{{translation:[{x}.0f,{y}.0f,0f],scale:[1f,1f,1f],left_rotation:[0f,0f,0f,1f],'
                          'right_rotation:[0f,0f,0f,1f]},width:5f,height:5f,view_range:.75f}')
    mc(gate+"panels",*panels)


def room_effects(mc,read):
    fx=F+"routes/effects/"
    for path,key in (("forge/alpha","forge_alpha"),("forge/promote","forge_promote"),("astrology/claim","astrology")):
        body=read(F+path)
        mc(F+path,*body,f"function {fx}{key} with storage {RUN} inspected")
    mc(fx+"forge_alpha",
       '$particle minecraft:small_flame $(x) 82 $(z) .6 .24 .6 .02 14 normal',
       '$particle minecraft:electric_spark $(x) 82 $(z) .7 .22 .7 .075 18 normal',
       '$playsound minecraft:block.anvil.use block @s $(x) 81 $(z) .6 1.25')
    mc(fx+"forge_promote",
       '$particle minecraft:electric_spark $(x) 82 $(z) .9 .28 .9 .08 34 normal',
       '$particle minecraft:crit $(x) 82 $(z) .65 .55 .65 .12 18 normal',
       '$playsound minecraft:block.anvil.use block @s $(x) 81 $(z) .8 .86')
    astro=[]
    for x,z in ((0,-3),(2,-2),(3,0),(2,2),(0,3),(-2,2),(-3,0),(-2,-2)):
        astro.append(f'$execute positioned $(x) 82 $(z) run particle minecraft:end_rod ~{x} ~ ~{z-7} .11 .28 .11 .014 2 normal')
    mc(fx+"astrology",*astro,
       '$execute positioned $(x) 82 $(z) run particle minecraft:enchant ~ ~ ~-7 2.5 .3 2.5 .075 40 normal')

    pick=read(F+"reward/pick_go")
    award=next(i for i,row in enumerate(pick) if F+"reward/give with storage" in row)
    pick.insert(award,f"function {fx}draw_prepare with storage {RUN} draw")
    mc(F+"reward/pick_go",*pick)
    mc(fx+"draw_prepare", f"$data modify storage {RUN} preview_entry set from storage {RUN} pool[$(index)]",
       f"execute unless data storage {RUN} preview_entry.signed run return 0",
       f"data remove storage {RUN} preview_item",
       f"execute summon minecraft:item_display run function {F}market/read_preview",
       f"execute unless data storage {RUN} preview_item.id run return 0",
       f"execute at @s rotated ~ 0 positioned ^ ^1 ^2 if block ~ ~ ~ #sweetdream_floor:room_air "
       f"if block ~ ~1 ~ #sweetdream_floor:room_air run function {fx}draw_display")
    mc(fx+"draw_display",f"execute summon minecraft:item_display run function {fx}draw_init",
       "particle minecraft:enchant ~ ~.45 ~ .4 .35 .4 .08 25 normal",
       "playsound minecraft:block.amethyst_block.hit player @s ~ ~ ~ .8 1.35")
    mc(fx+"draw_init",
       'data merge entity @s {Tags:["sd.draw_fx"],item_display:"fixed",billboard:"vertical",brightness:{block:15,sky:13},'
       'transformation:{translation:[0f,0f,0f],scale:[.04f,.04f,.04f],left_rotation:[0f,.10f,0f,.995f],right_rotation:[0f,0f,0f,1f]}}',
       f"data modify entity @s item set from storage {RUN} preview_item",
       "scoreboard players set @s sd.clock 32")
    mc(fx+"draw_tick",
       "scoreboard players remove @e[tag=sd.draw_fx,distance=0..] sd.clock 1",
       f"execute as @e[tag=sd.draw_fx,distance=0..,scores={{sd.clock=29}}] at @s run function {fx}draw_reveal",
       "kill @e[tag=sd.draw_fx,distance=0..,scores={sd.clock=..0}]")
    mc(fx+"draw_reveal",
       'data merge entity @s {start_interpolation:0,interpolation_duration:11,transformation:{translation:[0f,.74f,0f],'
       'scale:[.82f,.82f,.82f],left_rotation:[0f,-.24f,0f,.971f],right_rotation:[0f,0f,0f,1f]}}',
       "particle minecraft:end_rod ~ ~.45 ~ .24 .25 .24 .022 9 normal")


def weapon_effects(mc,source):
    fx=F+"routes/effects/"

    def wrap(path,*lines):
        body=(source/f"data/fallendream/function/{path}.mcfunction").read_text(encoding="utf8").splitlines()
        mc("fallendream:"+path,*body,*lines)

    def ribbon(points):
        rows=[]
        for i,(x,y,z) in enumerate(points):
            color=".23,.85,.96" if i%3 else ".74,.96,1.0"
            rows.append(f"particle minecraft:dust{{color:[{color}],scale:0.85}} ^{x:.2f} ^{y:.2f} ^{z:.2f} .05 .045 .05 0 2 normal")
        return rows

    wrap("equipment/sword/tidemark/cast",f"execute at @s rotated ~ 0 run function {fx}tidemark")
    wrap("equipment/sword/tidemark/overlimit",f"execute at @s rotated ~ 0 run function {fx}tidemark_wide")
    mc(fx+"tidemark",*ribbon((x,.48+.09*z,z) for z in (.5,.95,1.4,1.85,2.3,2.75,3.2,3.65)
                                     for x in (-.78,0,.78)))
    mc(fx+"tidemark_wide",*ribbon((x,.48+.09*z,z) for z in (.5,1.15,1.8,2.45,3.10,3.75)
                                          for x in (-2,-1,0,1,2)))

    wrap("equipment/sword/backflow_tide/cast",
         f"execute if score #bft_ol zx.meta matches 0 at @s rotated ~ 0 run function {fx}backflow",
         f"execute if score #bft_ol zx.meta matches 1 at @s rotated ~ 0 run function {fx}backflow_wide")
    arc=tuple((i*.3,.76-.02*abs(i),3.7-.04*i*i) for i in range(-6,7))
    mc(fx+"backflow",*ribbon(arc))
    mc(fx+"backflow_wide",*ribbon((x+offset,y+j*.18,z+1.05) for j,offset in enumerate((-.95,0,.95))
                                    for x,y,z in arc))
    wrap("station/api/apply",
         f'execute if entity @s[tag=sd.floor_run] if data storage zx:out r{{ok:1b}} if data storage zx:work st{{kind:"overlimit"}} at @s run function {fx}overlimit')
    mc(fx+"overlimit",
       "particle minecraft:reverse_portal ~ ~1.0 ~ .44 .51 .44 .08 28 normal",
       "particle minecraft:flash ~ ~1.2 ~ 0 0 0 0 1 normal",
       "playsound minecraft:block.respawn_anchor.charge player @s ~ ~ ~ .45 1.22")


def combat_clock(mc,read):
    clock=F+"combat/clock/"
    bar="fallendream:room_clock"
    bossbar=f"bossbar set {bar}"
    clock_name=json.dumps({"text":"本房战斗时间","color":"gold"},ensure_ascii=False)
    rage_name=json.dumps({"text":"超时 · 敌人狂暴","color":"red"},ensure_ascii=False)
    mc(F+"routes/load", "scoreboard objectives add sd.road_cell dummy","scoreboard objectives add sd.road_rev dummy",
       "scoreboard objectives add sd.hbar_max dummy","scoreboard objectives add sd.clock dummy",
       f"bossbar add {bar} {clock_name}", f"function {clock}stop")
    # Combat begin is shared by normal rooms, ambushes, elites, and floor bosses.
    mc(F+"combat/begin",*read(F+"combat/begin"),
       f"execute if score #phase sd.floor matches 2 run function {clock}start")
    combat=read(F+"combat/tick")
    combat.insert(1,f"execute if score #clock_active sd.clock matches 1 run function {clock}tick")
    mc(F+"combat/tick",*combat)
    mc(clock+"start", "scoreboard players set #limit sd.clock 2400",
       "execute if score #hard sd.floor matches 1 run scoreboard players set #limit sd.clock 3600",
       f'execute if data storage {RUN} current{{kind:"boss"}} run scoreboard players set #limit sd.clock 6000',
       "scoreboard players operation #left sd.clock = #limit sd.clock",
       "scoreboard players set #clock_active sd.clock 1",
       f"{bossbar} name {clock_name}",f"{bossbar} color yellow",f"{bossbar} style notched_12",
       f"execute store result bossbar {bar} max run scoreboard players get #limit sd.clock",
       f"execute store result bossbar {bar} value run scoreboard players get #left sd.clock",
       f"{bossbar} players @a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={{sd.floor_death=0}}]",
       f"{bossbar} visible true")
    mc(clock+"tick", "scoreboard players remove #left sd.clock 1",
       f"execute if score #left sd.clock matches 0.. store result bossbar {bar} value run scoreboard players get #left sd.clock",
       f'execute if score #left sd.clock matches 200 run {bossbar} name {{text:"10 秒后狂暴",color:"gold"}}',
       f"execute if score #left sd.clock matches 0 run function {clock}rage",
       "execute if score #left sd.clock matches 1.. run return 0",
       f"execute as @e[tag=sd.floor_enemy,tag=!sd.clock_rage,nbt=!{{Health:0f}},distance=0..] run function {clock}buff",
       "scoreboard players add #pulse sd.clock 1",
       "execute unless score #pulse sd.clock matches 40.. run return 0",
       "scoreboard players set #pulse sd.clock 0",
       f"execute as @e[tag=sd.floor_enemy,nbt=!{{Health:0f}},distance=0..] run function {clock}heal")
    mc(clock+"rage", f"{bossbar} name {rage_name}",f"{bossbar} color red",
       f"execute store result bossbar {bar} value run scoreboard players get #limit sd.clock",
       "scoreboard players set #pulse sd.clock 0",
       "playsound minecraft:block.note_block.didgeridoo hostile @a[tag=sd.floor_run,distance=0..] ~ ~ ~ 0.9 0.65")
    mc(clock+"buff", "tag @s add sd.clock_rage",
       "attribute @s minecraft:attack_damage modifier add fallendream:room_rage 0.2 add_multiplied_total",
       "attribute @s minecraft:movement_speed modifier add fallendream:room_rage 0.15 add_multiplied_total")
    mc(clock+"heal", "execute store result score #hp sd.clock run data get entity @s Health 1000",
       "execute unless score #hp sd.clock matches 1.. run return 0",
       "execute store result score #cap sd.clock run attribute @s minecraft:max_health get 1000",
       "execute if score #hp sd.clock >= #cap sd.clock run return 0",
       "execute store result score #heal sd.clock run attribute @s minecraft:max_health get 10",
       "scoreboard players operation #hp sd.clock += #heal sd.clock",
       "scoreboard players operation #hp sd.clock < #cap sd.clock",
       "execute store result entity @s Health float 0.001 run scoreboard players get #hp sd.clock")
    mc(clock+"stop","scoreboard players set #clock_active sd.clock 0","scoreboard players set #left sd.clock 1",
       f"{bossbar} visible false",f"{bossbar} players")
    impact=read(F+"combat/mobs/impact")
    soft_cap=next(i for i,row in enumerate(impact) if "#impact_hp sd.floor <" in row)
    impact.insert(soft_cap,
                  f"execute if score #clock_active sd.clock matches 1 if score #left sd.clock matches ..0 run function {clock}boost_impact")
    mc(F+"combat/mobs/impact",*impact)
    mc(clock+"boost_impact","scoreboard players set #six sd.clock 6","scoreboard players set #five sd.clock 5",
       "scoreboard players operation #impact_hp sd.floor *= #six sd.clock",
       "scoreboard players operation #impact_hp sd.floor /= #five sd.clock")
    for path in ("branch/left_hit","branch/right_hit","moth/hit","moth/touch"):
        rows=[]
        for row in read(F+"combat/mobs/"+path):
            match=re.search(r"(\bdamage \S+ )([0-9.]+)( minecraft:mob_attack by )",row)
            if not match:
                rows.append(row)
                continue
            if row.startswith("damage "):
                row="execute run "+row
                match=re.search(r"(\bdamage \S+ )([0-9.]+)( minecraft:mob_attack by )",row)
            boosted=row[:match.start(2)]+f"{float(match[2])*1.20:g}"+row[match.end(2):]
            rows.append(row.replace("execute ","execute unless score #left sd.clock matches ..0 ",1))
            rows.append(boosted.replace("execute ","execute if score #left sd.clock matches ..0 ",1))
        mc(F+"combat/mobs/"+path,*rows)
    # Scripted rush uses local offsets instead of the ravager's movement attribute.
    rush=[]
    for row in read(F+"stag/attack/rush"):
        step=re.search(r"positioned \^ \^ \^([0-9.]+) run function",row)
        if not step:
            rush.append(row)
            continue
        before,after=row.split("rotated as @s",1)
        condition="if score #clock_active sd.clock matches 1 if score #left sd.clock matches ..0"
        rush.append(f"{before}{condition} rotated as @s"+after.replace(step[1],f"{float(step[1])*1.15:.3f}",1))
        rush.append(f"{before}unless score #left sd.clock matches ..0 rotated as @s"+after)
    mc(F+"stag/attack/rush",*rush)


def stage_route_room():
    b=Build(relative=True)
    b.box((-16,-1,-16),(16,0,16),"rooted_dirt")
    b.shell(-16,16,1,3,-16,16,"mossy_cobblestone")
    b.shell(-16,16,4,9,-16,16,LEAVES)
    b.box((-16,9,-16),(16,9,16),LEAVES)
    b.box((-15,0,-15),(15,0,15),"moss_block")
    b.box((-14,0,-1),(14,0,1),"coarse_dirt")
    b.box((-1,0,-14),(1,0,14),"coarse_dirt")
    b.disk(0,0,0,4,4,"mossy_stone_bricks")
    b.box((-9,0,4),(-7,0,14),"rooted_dirt")
    b.box((-9,0,3),(1,0,5),"rooted_dirt")
    for x,z in ((-5,-4),(5,-4),(5,4),(-5,6),(-10,10),(4,10),(-10,-10),(10,-10)):
        b.set(x,1,z,"mossy_stone_brick_wall")
        b.set(x,2,z,"lantern")
    for sx,sz in SIDES:
        black_arch(b,sx*ROAD_REACH,sz*ROAD_REACH,"x" if sx else "z")
    black_arch(b,-8,ROAD_REACH,"z")
    for x in (-10,-5,0,5,10):
        for z in (-10,-5,0,5,10):
            b.set(x,3,z,"light[level=15]")
    return b.lines


def rooms_and_roads(mc):
    mc(F+"routes/shell",*stage_route_room())
    for r in RADII:
        b=Build(relative=True)
        b.box((-2,0,r-5),(2,0,r),"mossy_stone_bricks")
        b.box((-1,1,r-2),(1,3,r-1),"air")
        black_arch(b,0,r-1,"z")
        mc(F+f"routes/room_exit_{r}",*b.lines)
    mc(F+"routes/tick",
       f"execute unless score #phase sd.floor matches 2 if score #clock_active sd.clock matches 1 run function {F}combat/clock/stop",
       *(f"execute in {dim} if entity @e[tag=sd.draw_fx,distance=0..] run function {F}routes/effects/draw_tick" for dim in DIMS),
       "tag @a[tag=sd.black_loading,tag=!zx.rg_wait] remove sd.black_loading",
       f"execute as @a[tag=sd.floor_run,tag=zx.rg_wait,tag=!sd.black_loading] unless data storage {RUN} {{floor:2}} in {DIMS[0]} run function {F}routes/wait_forest",
       f"execute as @a[tag=sd.floor_run,tag=zx.rg_wait,tag=!sd.black_loading] if data storage {RUN} {{floor:2}} in {DIMS[1]} run function {F}routes/wait_trial",
       f"execute as @a[tag={ROAD_TAG}] at @s unless entity @s[y=119,dy=15] run tag @s remove {ROAD_TAG}",
       *(f"execute in {dim} as @a[tag=sd.floor_run,tag=zx.rg_active,distance=0..] at @s run function {F}routes/player" for dim in DIMS))
    mc(F+"routes/player",
       "execute unless score #phase sd.floor matches 1 run return 0",
       f"execute if data storage {RUN} encounter run return 0",
       f"execute if data storage {RUN} choice_room if score @s sd.flow_pick = #flow_pick sd.floor run return 0",
       f"execute if entity @s[tag=sd.floor_mirror] run return 0",
       f"execute if entity @s[tag={ROAD_TAG}] run return run function {F}routes/check",
       f"function {F}routes/find_exit")
    entries=[]
    road_checks=[]
    for cell in range(25):
        x,z=PITCH*(cell%5),PITCH*(cell//5)
        for r in RADII:
            entries.append(f"execute if data storage {GRAPH} floor.cells[{{cell:{cell},present:1b,radius:{r},isolated:1b}}] "
                           f"positioned {x-1} 81 {z+r-2} if entity @s[dx=2,dy=2,dz=1] run return run function {F}routes/enter_{cell}")
        road_checks.append(f"execute if score @s sd.road_cell matches {cell} run return run function {F}routes/step_{cell}")
        mc(F+f"routes/enter_{cell}",
           f"execute unless data storage {GRAPH} floor.cells[{{cell:{cell},route_built:1b}}] positioned {x} {ROAD_Y} {z} run function {F}routes/shell",
           f"data modify storage {GRAPH} floor.cells[{cell}].route_built set value 1b",
           f"tag @s add {ROAD_TAG}", f"scoreboard players set @s sd.road_cell {cell}",f"scoreboard players set @s zx.rg_room {cell}",
           "execute if entity @s[tag=rgp.open] run function fallenroute:floor/close",
           f"function {F}routes/draw_{cell}",f"tp @s {x+.5} {ROAD_Y+1} {z+.5} 180 0")
        mc(F+f"routes/back_{cell}", f"tag @s remove {ROAD_TAG}",
           "execute if entity @s[tag=rgp.open] run function fallenroute:floor/close",
           f"function {F}room/teleport_cell with storage {GRAPH} floor.cells[{cell}]")
        moves=[f"execute unless score @s sd.road_rev = #rd_rev zx.meta run function {F}routes/draw_{cell}",
               f"execute positioned {x-9} {ROAD_Y+1} {z+ROAD_REACH} if entity @s[dx=2,dy=2,dz=0] run return run function {F}routes/back_{cell}"]
        draw=[f"kill @e[tag=sd.road_hedge_{cell},distance=0..]",f"kill @e[tag=sd.road_label_{cell},distance=0..]",
              f"execute store result score #road_shrub sd.floor run data get storage {RUN} shrub.edge",
              f"execute unless data storage {RUN} shrub.edge run scoreboard players set #road_shrub sd.floor -1"]
        for sx,sz in SIDES:
            col,row=cell%5+sx,cell//5+sz
            target=row*5+col
            possible=0<=col<5 and 0<=row<5
            ax,az=x+sx*ROAD_REACH,z+sz*ROAD_REACH
            def gate_at(depth):
                gx,gz=x+sx*depth,z+sz*depth
                return (f"{gx} {ROAD_Y+1} {gz-1} {gx} {ROAD_Y+3} {gz+1}" if sx else
                        f"{gx-1} {ROAD_Y+1} {gz} {gx+1} {ROAD_Y+3} {gz}")
            barrier=gate_at(ROAD_REACH-2)
            if not possible:
                draw.append(f"fill {barrier} minecraft:{LEAVES}")
                continue
            edge=EDGES.index(tuple(sorted((cell,target))))
            edge_key=f"#road{edge}"
            draw.extend((f"execute store result score {edge_key} sd.floor run data get storage {GRAPH} floor.edges[{edge}]",
                         f"execute if score {edge_key} sd.floor matches 1 run fill {barrier} minecraft:air",
                         f"execute if score {edge_key} sd.floor matches 0 unless score #road_shrub sd.floor matches {edge} run fill {barrier} minecraft:{LEAVES}",
                         f"execute if score #road_shrub sd.floor matches {edge} if score {edge_key} sd.floor matches 0 run fill {barrier} minecraft:azalea_leaves[persistent=true]",
                         f'execute if score #road_shrub sd.floor matches {edge} if score {edge_key} sd.floor matches 0 run summon minecraft:interaction {x+sx*11+.5} {ROAD_Y+1} {z+sz*11+.5} {{Tags:["sd.shrub_click","sd.road_hedge_{cell}","sd.floor_junction"],width:2.9f,height:2.7f,response:1b}}'))
            floor=(f"{x+sx*7} {ROAD_Y} {z-1} {ax} {ROAD_Y} {z+1}" if sx else f"{x-1} {ROAD_Y} {z+sz*7} {x+1} {ROAD_Y} {az}")
            draw.append(f"execute if score #road_shrub sd.floor matches {edge} run fill {floor} minecraft:moss_block")
            for kind,label in {**KINDS,"unknown":"未探索"}.items():
                cond=(f"if data storage {GRAPH} floor.cells[{{cell:{target},kind:\"{kind}\",revealed:1b}}]" if kind!="unknown" else
                      f"unless data storage {GRAPH} floor.cells[{{cell:{target},revealed:1b}}]")
                label_data=json.dumps({"text":label,"color":"#eed8ac"},ensure_ascii=False)
                draw.append(f'execute if score {edge_key} sd.floor matches 1 {cond} run summon minecraft:text_display {x+sx*11.5+.5} {ROAD_Y+4.2:g} {z+sz*11.5+.5} {{Tags:["sd.road_label_{cell}"],billboard:"center",background:0,shadow:1b,text:{label_data}}}')
            threshold=f"{ax} {ROAD_Y+1} {az-1} if entity @s[dx=0,dy=2,dz=2]" if sx else f"{ax-1} {ROAD_Y+1} {az} if entity @s[dx=2,dy=2,dz=0]"
            moves.append(f"execute positioned {threshold} run return run function {F}routes/cross_{cell}_{target}")
            mc(F+f"routes/cross_{cell}_{target}",
               f"execute store result score #road_edge sd.floor run data get storage {GRAPH} floor.edges[{edge}]",
               "execute unless score #road_edge sd.floor matches 1 run return 0",
               f"function {F}routes/travel {{cell:{target}}}",
               f"execute if score @s zx.rg_room matches {target} if entity @s[tag=rgp.open] run function fallenroute:floor/close",
               f"execute if entity @s[tag={ROAD_TAG}] if score @s zx.rg_room matches {target} run tag @s remove {ROAD_TAG}",
               f"execute if entity @s[tag={ROAD_TAG}] run tp @s {x+sx*9+.5} {ROAD_Y+1} {z+sz*9+.5}")
        mc(F+f"routes/step_{cell}",*moves)
        mc(F+f"routes/draw_{cell}",*draw,"scoreboard players operation @s sd.road_rev = #rd_rev zx.meta")
    mc(F+"routes/find_exit",*entries)
    mc(F+"routes/check",*road_checks)
    mc(F+"routes/travel", f"$function {F}room/read_go {{cell:$(cell)}}",
       f"execute store result score #road_safe sd.floor run function fallenroute:floor/can_land with storage {RUN} inspected",
       "execute unless score #road_safe sd.floor matches 1 run return 0",
       f"execute store result score #road_paid sd.floor run function {F}explore/enter with storage {RUN} inspected",
       "tag @a[tag=sd.explore_arriving,distance=0..] remove sd.explore_arriving",
       'execute unless score #road_paid sd.floor matches 1 run return run title @s actionbar {text:"探索不足。",color:"yellow"}',
       f"$function {F}room/teleport_cell with storage {GRAPH} floor.cells[$(cell)]")
