"""Generate the extra mirror pair and a separately unlockable forest route."""

from itertools import product
from pathlib import Path

from architecture import RADII, PITCH, Build
from floor_upgrade import DIM, edit, text, write
from forest_economy import FN, RUN, button, literal, say
from forest_floors import NEXT

J = FN + "junction/"
ROGUE = "sweetdream:rogue/"
PAIRS = ([(i//4*5+i%4,i//4*5+i%4+1,"east") for i in range(20)] +
         [(i,i+5,"south") for i in range(20)])
WEAPONS = ("sword","axe","bow","staff")


def stage(world):
    base=Path(world)/"datapacks"
    addon=base/"zz_sweetdream_floor/data"
    f=addon/"sweetdream_floor/function"
    r=addon/"sweetdream/function/rogue"

    def j(name,*commands):
        write(f/f"junction/{name}.mcfunction", "\n".join(commands))

    def click(name,tag,commands):
        write(addon/f"sweetdream_floor/advancement/junction/{name}.json",literal({
            "criteria":{"act":{"trigger":"minecraft:player_interacted_with_entity","conditions":{
                "entity":{"type":"minecraft:interaction","nbt":'{Tags:["'+tag+'"]}'}}}},
            "rewards":{"function":J+name}}))
        j(name,f"advancement revoke @s only sweetdream_floor:junction/{name}",
          "execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active] run return 0",
          "execute unless score #phase sd.floor matches 1 run return 0",*commands)

    edit(f/"run/route.mcfunction", ("execute if score #input sd.floor matches 24",
         f"execute if entity @s[tag=sd.floor_mirror] run return run function {J}mirror_route\n"
         f"execute if score #input sd.floor matches 80 run return run function {J}shrub_confirm\n"
         "execute if score #input sd.floor matches 24"))
    for name in ("player_tick_forest","player_tick_trial"):
        edit(r/f"{name}.mcfunction", ("function sweetdream:rogue/map/locate",
             "execute unless entity @s[tag=sd.floor_mirror] run function sweetdream:rogue/map/locate"))
    edit(f/"run/player_tick.mcfunction", ("execute unless score #last sd.floor = @s zx.rg_room",
         "execute if entity @s[tag=sd.floor_mirror] run return 0\nexecute unless score #last sd.floor = @s zx.rg_room"))
    for mode in ("forest","trial"):
        p=f/f"run/orphan_{mode}.mcfunction"
        write(p,f"function {J}cleanup\n" + text(p))
    j("cleanup",f'execute if data storage {RUN} {{floor:2}} in {NEXT} run return run function {J}cleanup_here',
      f"execute in {DIM} run function {J}cleanup_here")
    j("cleanup_here",f"execute if data storage {RUN} mirror.a{{built:1b}} run function {J}annex_clear with storage {RUN} mirror.a",
      f"execute if data storage {RUN} mirror.b{{built:1b}} run function {J}annex_clear with storage {RUN} mirror.b",
      'kill @e[tag=sd.floor_junction,distance=0..]',f"data remove storage {RUN} mirror",f"data remove storage {RUN} shrub",
      f"data remove storage {RUN} shrub_quote")
    j("annex_clear", '$execute positioned $(x) 112 $(z) run fill ~3 ~ ~3 ~13 ~7 ~13 minecraft:air')
    edit(r/"gen/plan.mcfunction",("function sweetdream:rogue/gen/grow",f"function {ROGUE}gen/grow\nfunction {J}plan_shrub"),
         ("function sweetdream:rogue/gen/assign",f"function {ROGUE}gen/assign\nfunction {J}plan_mirrors"))
    edit(r/"gen/build_links.mcfunction",("data modify storage zx:rogue built set value 1b",
         f"execute if data storage {RUN} shrub.edge run function {J}build_shrub with storage {RUN} shrub\n"
         "data modify storage zx:rogue built set value 1b"))
    edit(f/"scene/furnish.mcfunction",(f'$function {FN}room/vendor/check with storage zx:rogue floor.cells[$(cell)]',
         f'$function {FN}room/vendor/check with storage zx:rogue floor.cells[$(cell)]\n'
         f'$function {J}mirror_host with storage zx:rogue floor.cells[$(cell)]'))
    shrub(j,click,r,base)
    mirrors(j,click)
    p=f/"load.mcfunction"
    write(p,text(p)+"\nscoreboard objectives add sd.mirror_side dummy")


def draw(j,name,pool,result):
    j(name,f"execute store result score #junction_size sd.floor run data get storage {RUN} {pool}",
      "scoreboard players remove #junction_size sd.floor 1",
      f"execute store result storage {RUN} junction_roll.max int 1 run scoreboard players get #junction_size sd.floor",
      f"function {FN}reward/random with storage {RUN} junction_roll",f"function {J}{result} with storage {RUN} draw")


def shrub(j,click,r,base):
    source=base/"sweetdream/data/sweetdream/function/rogue/gen/extra.mcfunction"
    row="execute store result score #rd_size zx.meta run data get storage zx:rogue floor.candidates"
    write(r/"gen/extra.mcfunction",text(source).replace(row,
          f"execute if data storage {RUN} shrub.edge run function {J}reserve with storage {RUN} shrub\n"+row))
    j("reserve",'$data remove storage zx:rogue floor.candidates[{edge:$(edge)}]')
    j("plan_shrub",f"data remove storage {RUN} shrub",f"execute if data storage {RUN} {{floor:2}} run return 0",
      f"function {J}shrub_candidates",
      f"execute unless data storage {RUN} picks[0] run function {J}fallback_grid",
      f"execute unless data storage {RUN} picks[0] run function {J}shrub_candidates",
      f"execute if data storage {RUN} picks[0] run function {J}shrub_draw")
    j("shrub_candidates",f"data modify storage {RUN} picks set value []",
      *(cmd for i,(a,b,axis) in enumerate(PAIRS) for cmd in (
          f"execute store result score #junction_edge sd.floor run data get storage zx:rogue floor.edges[{i}]",
          f"execute if score #junction_edge sd.floor matches 0 if data storage zx:rogue floor.cells[{{cell:{a},present:1b}}] "
          f"if data storage zx:rogue floor.cells[{{cell:{b},present:1b}}] run data modify storage {RUN} picks append value "
          f'{{edge:{i},a:{a},b:{b},axis:"{axis}"}}')))
    # A connected 4x4 fallback has fifteen ordinary edges and a guaranteed unused adjacency.
    active={x+5*z for x in range(4) for z in range(4)}
    edge_bits=[a in active and b in active and (axis=="east" or a%5==0) for a,b,axis in PAIRS]
    j("fallback_grid",'data modify storage zx:rogue floor.edges set value ['+','.join('1b' if e else '0b' for e in edge_bits)+']',
      *(f'data modify storage zx:rogue floor.cells[{i}].present set value {int(i in active)}b' for i in range(25)))
    draw(j,"shrub_draw","picks","shrub_choose")
    j("shrub_choose",f'$data modify storage {RUN} shrub set from storage {RUN} picks[$(index)]')
    j("build_shrub",f'$data modify storage {RUN} shrub.x set from storage zx:rogue floor.cells[$(a)].x',
      f'$data modify storage {RUN} shrub.z set from storage zx:rogue floor.cells[$(a)].z',
      f'$data modify storage {RUN} shrub.r1 set from storage zx:rogue floor.cells[$(a)].radius',
      f'$data modify storage {RUN} shrub.r2 set from storage zx:rogue floor.cells[$(b)].radius',
      "scoreboard players set #shrub_paid sd.floor 0", "scoreboard players set #shrub_need sd.floor 1",
      'execute store result score #shrub_party sd.floor if entity @a[tag=sd.floor_run]',
      "execute if score #shrub_party sd.floor matches 2.. run scoreboard players operation #shrub_need sd.floor = #shrub_party sd.floor",
      f"function {J}closed_panel with storage {RUN} shrub")
    j("closed_panel",f'$execute positioned $(x) 80 $(z) run function {ROGUE}corridors/$(axis)_$(r1)_$(r2)',
      f'$execute positioned $(x) 80 $(z) run function {J}brush/$(axis)_$(r1)_$(r2)')
    for axis,a,b in product(("east","south"),RADII,RADII):
        middle=(a+PITCH-b)//2
        shape=(f"~{middle} ~1 ~-3 ~{middle} ~5 ~3" if axis=="east" else f"~-3 ~1 ~{middle} ~3 ~5 ~{middle}")
        effects=[]
        for delta in (-0.55,1.55):
            x,z=((middle+delta,.5) if axis=="east" else (.5,middle+delta))
            effects.append(f'summon minecraft:interaction ~{x} ~1 ~{z} '
                           '{Tags:["sd.floor_junction","sd.shrub_click"],width:2.9f,height:3.2f,response:1b}')
        j(f"brush/{axis}_{a}_{b}",f"fill {shape} minecraft:dark_oak_leaves[persistent=true]",*effects)
        j(f"brush/open_{axis}_{a}_{b}",f"fill {shape} minecraft:air replace minecraft:dark_oak_leaves")
    click("shrub_touch","sd.shrub_click",(f"function {J}shrub_quote",))
    j("can_sacrifice",f"execute unless dimension {DIM} run return 0",
      f"execute unless data storage {RUN} shrub.edge run return 0",f"execute if data storage {RUN} shrub{{open:1b}} run return 0",
      'execute unless entity @e[type=minecraft:interaction,tag=sd.shrub_click,distance=..4] run return 0',
      'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{sd_floor_rental:1b}] run return 0',
      *(f'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{{zx:["{k}"]}}] run return 1' for k in WEAPONS),"return 0")
    j("shrub_quote",f"execute store result score #shrub_ok sd.floor run function {J}can_sacrifice",
      "execute unless score #shrub_ok sd.floor matches 1 run return run " + say("用主手武器右键清理树丛。"),
      f"data modify storage {RUN} shrub_quote set from entity @s SelectedItem",f"function {J}brush_progress",
      "tellraw @s "+literal(button("确认交出主手武器",80,"gold")))
    j("brush_progress",'tellraw @s [{"text":"树丛   ","color":"green"},{"score":{"name":"#shrub_paid","objective":"sd.floor"}},'
      '{"text":"／"},{"score":{"name":"#shrub_need","objective":"sd.floor"}},{"text":" 件武器"}]')
    j("shrub_confirm",f"execute store result score #shrub_ok sd.floor run function {J}can_sacrifice",
      f"execute unless score #shrub_ok sd.floor matches 1 run return 0",f"execute unless data storage {RUN} shrub_quote run return 0",
      f"execute store success score #shrub_changed sd.floor run data modify storage {RUN} shrub_quote set from entity @s SelectedItem",
      f"execute if score #shrub_changed sd.floor matches 1 run return run function {J}shrub_quote",
      "item replace entity @s weapon.mainhand with minecraft:air",f"data remove storage {RUN} shrub_quote",
      "scoreboard players add #shrub_paid sd.floor 1", f"function {J}brush_progress",
      f"execute if score #shrub_paid sd.floor >= #shrub_need sd.floor run function {J}unlock with storage {RUN} shrub")
    j("unlock",f"data modify storage {RUN} shrub.open set value 1b",
      '$data modify storage zx:rogue floor.edges[$(edge)] set value 1b',
      f'$execute positioned $(x) 80 $(z) run function {J}brush/open_$(axis)_$(r1)_$(r2)',
      f'$execute positioned $(x) 319 $(z) run function {ROGUE}canvas/$(axis)',
      'kill @e[tag=sd.shrub_click,distance=0..]',f"function {ROGUE}map/flags","scoreboard players add #rd_rev zx.meta 1",
      say("树丛让开了，一条小径接上了楼层图。","green"))


def mirrors(j,click):
    j("plan_mirrors",f"data remove storage {RUN} mirror",
      "execute store result score #mirror_roll sd.floor run random value 1..4 sweetdream:rogue",
      "execute unless score #mirror_roll sd.floor matches 1 run return 0",
      f"data modify storage {RUN} mirror_anchors set value []",
      f"data modify storage {RUN} mirror_anchors append from storage zx:rogue floor.cells[{{present:1b}}]",
      f'data remove storage {RUN} mirror_anchors[{{kind:"entry"}}]',f'data remove storage {RUN} mirror_anchors[{{kind:"boss"}}]',
      f"function {J}choose_first")
    j("choose_first",f"execute if data storage {RUN} mirror_anchors[0] run function {J}draw_first")
    draw(j,"draw_first","mirror_anchors","distance_seed")
    j("distance_seed",f'$data modify storage {RUN} first_mirror set from storage {RUN} mirror_anchors[$(index)]',
      f'$data remove storage {RUN} mirror_anchors[$(index)]',
      *(f"scoreboard players set #mirror_{i} sd.floor -1" for i in range(25)),
      f"function {J}seed_anchor with storage {RUN} first_mirror",
      "scoreboard players set #mirror_depth sd.floor 0","scoreboard players set #mirror_next sd.floor 1",
      *(f"function {J}expand" for _ in range(3)),
      f"data modify storage {RUN} far_mirrors set value []",
      *(f'execute if score #mirror_{i} sd.floor matches -1 if data storage zx:rogue floor.cells[{{cell:{i},present:1b}}] '
        f'unless data storage zx:rogue floor.cells[{{cell:{i},kind:"entry"}}] unless data storage zx:rogue floor.cells[{{cell:{i},kind:"boss"}}] '
        f'run data modify storage {RUN} far_mirrors append from storage zx:rogue floor.cells[{i}]' for i in range(25)),
      f"execute unless data storage {RUN} far_mirrors[0] run return run function {J}choose_first",
      f"function {J}draw_second")
    j("seed_anchor","$scoreboard players set #mirror_$(cell) sd.floor 0")
    j("expand",*(line for i,(a,b,_) in enumerate(PAIRS) for line in (
        f"execute store result score #mirror_edge sd.floor run data get storage zx:rogue floor.edges[{i}]",
        *(f"execute if score #mirror_edge sd.floor matches 1 if score #mirror_{start} sd.floor = #mirror_depth sd.floor "
          f"if score #mirror_{end} sd.floor matches -1 run scoreboard players operation #mirror_{end} sd.floor = #mirror_next sd.floor"
          for start,end in ((a,b),(b,a))))),"scoreboard players add #mirror_depth sd.floor 1","scoreboard players add #mirror_next sd.floor 1")
    draw(j,"draw_second","far_mirrors","bind_pair")
    j("bind_pair", f"data modify storage {RUN} mirror.a set from storage {RUN} first_mirror",
      f'$data modify storage {RUN} mirror.b set from storage {RUN} far_mirrors[$(index)]')
    j("mirror_host",
      *(f'$execute if data storage {RUN} mirror.{side}{{cell:$(cell)}} run function {J}host_{side} with storage {RUN} mirror.{side}' for side in ("a","b")))
    for side,number in (("a",1),("b",2)):
        j(f"host_{side}",f'$execute positioned $(x) 80 $(z) run function {J}host_build',
          f"function {J}discover_{side}")
        j(f"discover_{side}",f"execute if data storage {RUN} mirror.{side}{{seen:1b}} run return 0",
          f"data modify storage {RUN} mirror.{side}.seen set value 1b",
          f'function {J}paint_mirror with storage {RUN} mirror.{side}',"scoreboard players add #rd_rev zx.meta 1")
        j(f"go_{side}",f"execute unless data storage {RUN} mirror.{side}.cell run return 0",
          f"execute unless data storage {RUN} mirror.{side}{{built:1b}} run function {J}make_{side} with storage {RUN} mirror.{side}",
          f"tag @s add sd.floor_mirror", f"scoreboard players set @s sd.mirror_side {number}",
          f"function {J}land_mirror with storage {RUN} mirror.{side}",f"function {J}discover_{side}",f"function {J}mirror_menu")
        j(f"make_{side}",f'$execute positioned $(x) 112 $(z) run function {J}annex_build',
          f"data modify storage {RUN} mirror.{side}.built set value 1b")
    j("paint_mirror",'$execute positioned $(x) 319 $(z) run fill ~14 ~ ~-12 ~17 ~ ~-7 minecraft:light_blue_concrete',
      '$execute positioned $(x) 319 $(z) run fill ~14 ~ ~-10 ~15 ~ ~-7 minecraft:white_concrete')
    j("host_build",'fill ~7 ~1 ~7 ~9 ~4 ~9 minecraft:air',
      'fill ~7 ~ ~7 ~9 ~ ~9 minecraft:waxed_weathered_cut_copper','fill ~7 ~1 ~9 ~9 ~4 ~9 minecraft:tuff_bricks',
      'fill ~8 ~2 ~9 ~8 ~3 ~9 minecraft:light_blue_stained_glass','setblock ~8 ~4 ~9 minecraft:shroomlight',
      'summon minecraft:interaction ~8.5 ~1 ~8.75 {Tags:["sd.floor_junction","sd.mirror_host"],width:1.7f,height:2.9f,response:1b}')
    j("annex_build",'fill ~3 ~ ~3 ~13 ~6 ~13 minecraft:tuff_bricks',
      'fill ~4 ~1 ~4 ~12 ~5 ~12 minecraft:air','fill ~4 ~ ~4 ~12 ~ ~12 minecraft:waxed_oxidized_cut_copper',
      'fill ~6 ~1 ~12 ~10 ~4 ~12 minecraft:polished_blackstone_bricks',
      'fill ~7 ~2 ~12 ~9 ~3 ~12 minecraft:light_blue_stained_glass',
      'fill ~5 ~1 ~4 ~11 ~4 ~4 minecraft:polished_blackstone_bricks',
      'fill ~7 ~2 ~4 ~9 ~3 ~4 minecraft:tinted_glass',
      *(f'setblock ~{x} ~5 ~{z} minecraft:shroomlight' for x,z in product((5,8,11),(6,10))),
      'summon minecraft:interaction ~8.5 ~1 ~11.75 {Tags:["sd.floor_junction","sd.mirror_jump"],width:2.1f,height:2.9f,response:1b}',
      'summon minecraft:interaction ~8.5 ~1 ~5.1 {Tags:["sd.floor_junction","sd.mirror_exit"],width:2.1f,height:2.9f,response:1b}')
    j("land_mirror",'$execute positioned $(x) 113 $(z) run tp @s ~8.5 ~ ~8.5 0 0')
    j("mirror_menu",say("◇  镜房", "aqua"),"tellraw @s "+literal([button("镜间传送",81,"aqua"),{"text":"    "},button("走出镜房",83)]))
    j("mirror_route",
      f"execute if score #input sd.floor matches 81 run return run function {J}mirror_jump",
      f"execute if score #input sd.floor matches 83 run return run function {J}mirror_exit",
      f"execute if score #input sd.floor matches 23 run function {J}mirror_menu")
    click("touch_host","sd.mirror_host",(
        'execute if entity @s[tag=sd.floor_mirror] run return 0',
        f'execute if data storage {RUN} encounter run return run '+say("战斗房解锁后才能进入镜房。"),
        'execute unless entity @e[tag=sd.mirror_host,distance=..4,type=minecraft:interaction] run return 0',
        *(f"execute if data storage {RUN} mirror.{side}.cell run function {J}enter_{side} with storage {RUN} mirror.{side}" for side in ("a","b"))))
    for side in ("a","b"):
        j(f"enter_{side}",f'$execute if score @s zx.rg_room matches $(cell) run function {J}go_{side}')
    click("touch_jump","sd.mirror_jump",(f"execute if entity @s[tag=sd.floor_mirror] if entity @e[tag=sd.mirror_jump,distance=..4] run function {J}mirror_jump",))
    click("touch_exit","sd.mirror_exit",(f"execute if entity @s[tag=sd.floor_mirror] if entity @e[tag=sd.mirror_exit,distance=..4] run function {J}mirror_exit",))
    j("mirror_jump",f"execute if score @s sd.mirror_side matches 1 run return run function {J}go_b",f"function {J}go_a")
    j("mirror_exit",f"execute if score @s sd.mirror_side matches 1 run return run function {J}exit_to with storage {RUN} mirror.a",
      f"function {J}exit_to with storage {RUN} mirror.b")
    j("exit_to",'$execute if score #budget sd.floor matches 0 unless data storage zx:rogue floor.cells[{cell:$(cell),visited:1b}] run return run '
      +say("探索次数已用完。可以传回另一间镜房。","yellow"),
      "tag @s remove sd.floor_mirror",
      f'$function {FN}room/teleport_cell with storage zx:rogue floor.cells[$(cell)]')
