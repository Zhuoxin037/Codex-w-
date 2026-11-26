"""Room admission, decisions, and the optional Forest shortcut."""

from itertools import product
from pathlib import Path

from architecture import Build, RADII, PITCH
from floor_upgrade import edit, text, write
from forest_economy import FN, RUN, literal, say

PARTY = "@a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={sd.floor_death=0}]"
AIR = "#sweetdream_floor:room_air"
GATE = "scoreboard players set #door_closed sd.floor"
R = "sweetdream:rogue/"


def stage(world):
    home = Path(world) / "datapacks/zz_sweetdream_floor/data"
    f = home / "sweetdream_floor/function"
    r = home / "sweetdream/function/rogue"

    def mc(name, *commands):
        write(f / f"{name}.mcfunction", "\n".join(commands))

    def append(path, *commands):
        write(path, text(path) + "\n".join(commands))

    def prepend(path, *commands):
        write(path, "\n".join(commands) + "\n" + text(path))

    append(f/"load.mcfunction",
           *(f"scoreboard objectives add {obj} dummy" for obj in ("sd.flow_last", "sd.flow_pick")),
           "scoreboard players add #flow_pick sd.floor 0")
    write(home/"sweetdream_floor/tags/block/room_air.json", literal({"values":["minecraft:air","minecraft:cave_air","minecraft:void_air","minecraft:light"]}))
    mc("room/teleport_cell",
       *(f'$execute positioned $(x) 81 $(z) align xz positioned ~{dx+.5} ~ ~{dz+.5} '
         f'if block ~ ~ ~ {AIR} if block ~ ~1 ~ {AIR} unless block ~ ~-1 ~ {AIR} '
         f'run return run function {FN}room/land {{cell:$(cell)}}'
         for dx,dz in ((4,0),(0,4),(-4,0),(0,-4),(0,0))),
       "return fail")
    edit(f/"room/return_to_explored.mcfunction", ("#room_anchor sd.floor", "@s sd.flow_last"))
    edit(f/"room/admit.mcfunction", ("#room_anchor sd.floor", "@s sd.flow_last"))
    edit(f/"room/read.mcfunction", (f"data remove storage {RUN} inspected",
         f"data remove storage {RUN} inspected\nexecute unless score @s zx.rg_room matches 0..24 run return 0"))
    edit(r/"map/visit_pick.mcfunction", ("#room_anchor sd.floor", "@s sd.flow_last"),
         ("matches 1..3", "matches 1"))
    for path in ("run/arrive","next/wait"):
        prepend(f/f"{path}.mcfunction", "scoreboard players set @s sd.flow_last 10")
    edit(r/"map/locate.mcfunction", (
        f"execute if entity @s[tag=sd.floor_run] if data storage {RUN} encounter run return run function {FN}combat/confine with storage {RUN} encounter",
        f"execute if entity @s[tag=sd.floor_run] if data storage {RUN} encounter run return run function {FN}combat/confine with storage {RUN} encounter\n"
        f"execute if entity @s[tag=sd.floor_run] if score @s sd.flow_pick = #flow_pick sd.floor if data storage {RUN} choice_room run return run function {FN}flow/keep_choice with storage {RUN} choice_room\n"
        "scoreboard players set @s zx.rg_room -1"))
    mc("combat/confine",
       f"$execute positioned $(minx) 78 $(minz) unless entity @s[dx=$(width),dy=19,dz=$(width)] run function {FN}room/teleport_cell with storage {RUN} encounter",
       "$scoreboard players set @s zx.rg_room $(cell)",
       "$scoreboard players set @s sd.flow_last $(cell)")
    p=f/"run/player_tick.mcfunction"
    body=text(p)
    line=next(line for line in body.splitlines() if "doors/exhausted" in line)
    write(p, body.replace(line, f'execute if data storage {RUN} {{exploration_doors:1b}} run function {FN}flow/old_gates\n'
          f'execute if score @s zx.rg_room matches 0..24 unless score @s sd.flow_last matches 0..24 run scoreboard players operation @s sd.flow_last = @s zx.rg_room'))
    edit(p, (f"execute unless score @s sd.lobby_room", f"execute unless score @s zx.rg_room matches 0..24 run return 0\nexecute unless score @s sd.lobby_room"))
    edit(f/"room/select_go.mcfunction", (text(f/"room/select_go.mcfunction").splitlines()[0],
         '$execute positioned $(minx) 78 $(minz) unless entity @s[dx=$(width),dy=19,dz=$(width)] run return 0'))
    edit(f/"room/store.mcfunction", (text(f/"room/store.mcfunction").splitlines()[1],
         '$execute positioned $(minx) 78 $(minz) unless entity @s[dx=$(width),dy=19,dz=$(width)] run return 0'))
    edit(f/"run/arrive.mcfunction", ("本层可探索 8 间新房。首次进入扣一次，走过的房间可以重走。",
         "全队共用 8 次探索。首次到访扣一次，走过的房间可以重走。"))
    edit(f/"room/status.mcfunction", ("剩余探索 ", "全队探索 "))
    mc("flow/old_gates",
       GATE+" 0",
       f"data modify storage sweetdream_floor:routing doors set value []",
       f"data modify storage sweetdream_floor:routing doors append from storage zx:rogue floor.cells[{{present:1b}}]",
       f"execute if data storage sweetdream_floor:routing doors[0] run function {FN}room/doors/close_next",
       f"data remove storage {RUN} exploration_doors",
       f"execute if data storage {RUN} encounter run {GATE} 1",
       f"execute if data storage {RUN} choice_room run {GATE} 1",
       f"execute if data storage {RUN} encounter run function {FN}room/doors/update with storage {RUN} encounter",
       f"execute if data storage {RUN} choice_room run function {FN}room/doors/update with storage {RUN} choice_room")

    door = f/"room/doors/close_visual.mcfunction"
    fill = text(door).splitlines()[0]
    edit(door, (fill, fill+"\n"+fill.replace("replace minecraft:air","replace minecraft:light")))
    # Restore hidden light inside the free passage without occupying the floor.
    p = f/"room/doors/open_visual.mcfunction"
    source=text(p)
    write(p, source.replace(source.splitlines()[0], source.splitlines()[0]+"\n"+
          "$fill ~-$(x) ~1 ~-$(z) ~$(x) ~1 ~$(z) minecraft:light[level=15] replace minecraft:air"))
    p = f/"room/doors/threshold.mcfunction"
    lines=text(p).splitlines()
    write(p, "\n".join(row for row in lines if "return_to_explored" not in row))
    for name,old,new in (("combat","门已落下。清完怪群，门会打开。","清完怪群并处理奖励后，门会打开。"),
                         ("elite","精英的奖励更稀有。清完守卫才能离开。","可在房间内直接开战。处理完奖励即可离开。")):
        edit(f/f"room/info/{name}.mcfunction",(old,new))
    choices(f, mc, prepend)
    encounters(f, mc, prepend)
    shrubs(f, mc)


def choices(f, mc, prepend):
    for name in ("run/orphan_forest","run/orphan_trial"):
        prepend(f/f"{name}.mcfunction", f"data remove storage {RUN} choice_room")
    for name,marker in (("run/start",f"function {FN}room/event/reset"),
                        ("next/wait",f"data modify storage {RUN} floor set value 2")):
        edit(f/f"{name}.mcfunction",(marker,f"data remove storage {RUN} choice_room\n"+marker))
    prepend(f/"run/join_party.mcfunction", "scoreboard players reset @s sd.flow_pick")
    prepend(f/"reward/ask.mcfunction", f"execute unless data storage {RUN} choice_room run function {FN}flow/locate_choice")
    edit(f/"combat/win.mcfunction", (f"function {FN}combat/open_doors",
         f"function {FN}flow/locate_choice"))
    mc("flow/locate_choice",
       f"execute if data storage {RUN} encounter run data modify storage {RUN} choice_room set from storage {RUN} encounter",
       f"execute unless data storage {RUN} choice_room run function {FN}room/read",
       f"execute unless data storage {RUN} choice_room if data storage {RUN} inspected.cell run data modify storage {RUN} choice_room set from storage {RUN} inspected",
       f"execute if data storage {RUN} choice_room.minx run function {FN}flow/lock_choice with storage {RUN} choice_room")
    mc("flow/lock_choice", "scoreboard players add #flow_pick sd.floor 1",
       f'$execute positioned $(minx) 78 $(minz) as {PARTY[:-1]},dx=$(width),dy=19,dz=$(width)] '
       "run scoreboard players operation @s sd.flow_pick = #flow_pick sd.floor",
       GATE+" 1", f"function {FN}room/doors/update with storage {RUN} choice_room")
    mc("flow/keep_choice",
       f"$execute positioned $(minx) 78 $(minz) unless entity @s[dx=$(width),dy=19,dz=$(width)] run function {FN}room/teleport_cell with storage {RUN} choice_room",
       "$scoreboard players set @s zx.rg_room $(cell)")
    for path in ("reward/give","reward/god","bank/clear"):
        prepend(f/f"{path}.mcfunction", f"function {FN}flow/open_choice")
    mc("flow/open_choice", GATE+" 0",
       f"execute if data storage {RUN} choice_room run function {FN}room/doors/update with storage {RUN} choice_room",
       f"data remove storage {RUN} choice_room")
    prepend(f/"tick.mcfunction",
       f'execute if score #phase sd.floor matches 3..4 if data storage {RUN} choice_room if data storage {RUN} {{floor:2}} '
       f'in sweetdream:floor_2_trial run function {FN}flow/recover_choice',
       f'execute if score #phase sd.floor matches 3..4 if data storage {RUN} choice_room unless data storage {RUN} {{floor:2}} '
       f'in sweetdream:floor_1_forest run function {FN}flow/recover_choice')
    mc("flow/recover_choice",
       f"execute as {PARTY} if score @s sd.flow_pick = #flow_pick sd.floor run return 0",
       f"execute as {PARTY[:-1]},limit=1] at @s run function {FN}flow/accept_choice with storage {RUN} choice_room")
    mc("flow/accept_choice",
       f"function {FN}room/teleport_cell with storage {RUN} choice_room",
       "scoreboard players operation @s sd.flow_pick = #flow_pick sd.floor",
       f"execute if score #phase sd.floor matches 3 run function {FN}reward/show",
       f"execute if score #phase sd.floor matches 4 run function {FN}reward/god_show")
    mc("reward/empty_battle_pool", say("这类没有可抽装备，可以换一类或寄存、销毁。","yellow"), f"function {FN}reward/ask")
    prepend(f/"run/route.mcfunction",
            f"execute if score #phase sd.floor matches 3..4 if data storage {RUN} choice_room unless score @s sd.flow_pick = #flow_pick sd.floor run return run "
            + say("奖励由房间内的队友处理。"))


def encounters(f, mc, prepend):
    # Step out of an unclaimed random event to relinquish it. Other players in
    # the room may finish deciding before the shared event expires.
    prepend(f/"room/info/event.mcfunction",
            f"function {FN}flow/record_event with storage {RUN} inspected")
    mc("flow/record_event",
       f'$execute unless data storage {RUN} open_events[{{cell:$(cell)}}] run data modify storage {RUN} open_events append from storage {RUN} inspected')
    mc("flow/events_tick",
       f"data modify storage {RUN} event_queue set from storage {RUN} open_events",
       f"data modify storage {RUN} open_events set value []",
       f"function {FN}flow/events_next")
    mc("flow/events_next",
       f"function {FN}flow/check_event with storage {RUN} event_queue[0]",
       f"data remove storage {RUN} event_queue[0]",
       f"execute if data storage {RUN} event_queue[0] run function {FN}flow/events_next")
    mc("flow/check_event",
       f'$execute if data storage {RUN} rooms[{{cell:$(cell)}}] run return 0',
       f'$execute positioned $(minx) 78 $(minz) if entity {PARTY[:-1]},dx=$(width),dy=19,dz=$(width)] run return run '
       f'data modify storage {RUN} open_events append from storage {RUN} event_queue[0]',
       f'$data modify storage {RUN} rooms append value {{cell:$(cell)}}')
    anchor=f"function {FN}room/event/reset"
    edit(f/"run/start.mcfunction",(anchor, f"data modify storage {RUN} open_events set value []\n"
         f"data remove storage {RUN} ambush_pending\n"+anchor))
    edit(f/"next/wait.mcfunction", (f"data remove storage {RUN} ambush_pending",
         f"data remove storage {RUN} ambush_pending\ndata modify storage {RUN} open_events set value []"))
    p=f/"room/arrive.mcfunction"
    write(p,"\n".join(line for line in text(p).splitlines() if "check_ambush" not in line))
    mc("room/event/save_ambush",f"function {FN}room/event/accept",
       say("你从草丛里退开了，伏兵散去。","gray"))
    edit(f/"room/event/ambush.mcfunction", ("现在离开，回来时遭遇更强的埋伏","离开，放弃这次伏击"))
    prepend(f/"tick.mcfunction",
       f'execute if data storage {RUN} open_events[0] if data storage {RUN} {{floor:2}} in sweetdream:floor_2_trial run function {FN}flow/events_tick',
       f'execute if data storage {RUN} open_events[0] unless data storage {RUN} {{floor:2}} in sweetdream:floor_1_forest run function {FN}flow/events_tick')


def shrubs(f, mc):
    p=f/"junction/plan_shrub.mcfunction"
    write(p,"\n".join(line for line in text(p).splitlines() if "fallback_grid" not in line
          and "unless data storage" not in line))
    mc("junction/closed_panel",
       f'$execute positioned $(x) 80 $(z) run function {FN}junction/brush/$(axis)_$(r1)_$(r2)')
    p=f/"junction/unlock.mcfunction"
    old=f"$execute positioned $(x) 80 $(z) run function {FN}junction/brush/open_$(axis)_$(r1)_$(r2)"
    edit(p,(old,f"$execute positioned $(x) 80 $(z) run function {R}corridors/$(axis)_$(r1)_$(r2)"))
    edit(f/"junction/can_sacrifice.mcfunction",("sd_floor_rental:1b","sd_rental:1b"))
    for axis,a,b in product(("east","south"),RADII,RADII):
        build=Build(relative=True)
        def point(along,y,across):
            return (along,y,across) if axis=="east" else (across,y,along)
        for start,direction in ((a,-1),(PITCH-b,1)):
            for offset,height in ((-3,2),(-2,3),(-1,5),(0,4),(1,4),(2,3),(3,2)):
                pos=point(start,1,offset)
                build.box(pos,point(start,height,offset),"azalea_leaves[persistent=true]")
                before=start+direction if abs(offset)>1 else start
                if abs(offset) in (2,3):
                    build.set(*point(before,1,offset),"mangrove_roots")
            bx,by,bz=point(start+direction*.55,1,.5)
            build.lines.append(f'summon minecraft:interaction {build.pos(bx,by,bz)} '
                               '{Tags:["sd.floor_junction","sd.shrub_click"],width:3.0f,height:3.2f,response:1b}')
        mc(f"junction/brush/{axis}_{a}_{b}",*build.lines)
