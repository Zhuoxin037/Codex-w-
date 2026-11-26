"""Personal exploration charges with atomic party sponsorship."""

from pathlib import Path

from floor_upgrade import edit, text, write
from forest_economy import FN, RUN, say
from forest_flow import PARTY

SCORE = "sd.explore"
ARRIVING = "sd.explore_arriving"
PAID = "sd.explored"


def stage(world):
    home=Path(world)/"datapacks/zz_sweetdream_floor/data"
    f=home/"sweetdream_floor/function"
    r=home/"sweetdream/function/rogue"

    def mc(name,*lines):
        write(f/f"{name}.mcfunction","\n".join(lines))

    def prepend(path,*lines):
        write(path,"\n".join(lines)+"\n"+text(path))

    objectives = f/"load.mcfunction"
    write(objectives,text(objectives)+f"scoreboard objectives add {SCORE} dummy")
    mc("explore/reset",
       *(f"tag @s remove {PAID}.{cell}" for cell in range(25)),
       f"scoreboard players set @s {SCORE} 8")
    mc("explore/migrate",
       f"execute if score @s {SCORE} matches 0.. run return 0",
       f"function {FN}explore/reset",
       f"execute if score #budget sd.floor matches 0.. run scoreboard players operation @s {SCORE} = #budget sd.floor",
       *(f'execute if data storage zx:rogue floor.cells[{{cell:{cell},visited:1b}}] run tag @s add {PAID}.{cell}'
         for cell in range(25)))
    prepend(f/"run/join_party.mcfunction",f"function {FN}explore/reset")
    file=f/"next/wait.mcfunction"
    anchor=f"tag @s remove sd.floor_transfer"
    edit(file,(anchor,f"function {FN}explore/reset\n"+anchor))
    prepend(r/"map/locate.mcfunction",
            f"execute if entity @s[tag=sd.floor_run] unless score @s {SCORE} matches 0.. run function {FN}explore/migrate")
    mc("room/admit",f"function {FN}room/read",
       f"execute store result score #explore_ok sd.floor run function {FN}explore/enter with storage {RUN} inspected",
       f"execute unless score #explore_ok sd.floor matches 1 run function {FN}explore/reject_arrivals with storage {RUN} inspected",
       f"tag {PARTY} remove {ARRIVING}")
    mc("explore/enter",f"tag {PARTY} remove {ARRIVING}",f"tag @s add {ARRIVING}",
       f'execute if data storage {RUN} inspected{{kind:"entry"}} run return run function {FN}explore/admit_free with storage {RUN} inspected',
       # Cliques merge upon entering an encounter with all living teammates,
       # so the entire squad needs its share before any gate is allowed to close.
       f'$execute unless data storage {RUN} rooms[{{cell:$(cell)}}] if data storage {RUN} inspected{{kind:"combat"}} run tag {PARTY} add {ARRIVING}',
       f'$execute unless data storage {RUN} rooms[{{cell:$(cell)}}] if data storage {RUN} inspected{{kind:"elite"}} run tag {PARTY} add {ARRIVING}',
       f'execute if data storage {RUN} inspected{{kind:"boss"}} run return run function {FN}explore/admit_free with storage {RUN} inspected',
       f'$execute positioned $(minx) 78 $(minz) run tag {PARTY[:-1]},dx=$(width),dy=19,dz=$(width)] add {ARRIVING}',
       f"execute as {PARTY} unless score @s {SCORE} matches 0.. run function {FN}explore/migrate",
       "scoreboard players set #route_debt sd.floor 0",
       f'$execute as {PARTY[:-1]},tag={ARRIVING},tag=!{PAID}.$(cell)] if score @s {SCORE} matches 0 run scoreboard players add #route_debt sd.floor 1',
       "scoreboard players set #route_spare sd.floor 0",
       f'$execute as {PARTY} if score #route_debt sd.floor matches 1.. run function {FN}explore/count_spare {{cell:$(cell)}}',
       "execute if score #route_debt sd.floor > #route_spare sd.floor run return fail",
       f"$return run function {FN}explore/commit {{cell:$(cell)}}")
    mc("explore/count_spare",
       f"scoreboard players operation #route_capacity sd.floor = @s {SCORE}",
       f"$execute unless entity @s[tag={PAID}.$(cell)] run scoreboard players remove #route_capacity sd.floor 1",
       "execute if score #route_capacity sd.floor matches 1.. run scoreboard players operation #route_spare sd.floor += #route_capacity sd.floor")
    mc("explore/commit",
       f"$execute as {PARTY[:-1]},tag={ARRIVING},tag=!{PAID}.$(cell)] if score @s {SCORE} matches 1.. run scoreboard players remove @s {SCORE} 1",
       f"$tag {PARTY[:-1]},tag={ARRIVING}] add {PAID}.$(cell)",
       f"$execute as {PARTY[:-1]},tag={PAID}.$(cell)] if score #route_debt sd.floor matches 1.. if score @s {SCORE} matches 1.. run function {FN}explore/sponsor",
       f"$execute as {PARTY[:-1]},tag=!{PAID}.$(cell)] if score #route_debt sd.floor matches 1.. if score @s {SCORE} matches 2.. "
       f"run function {FN}explore/prepay {{cell:$(cell)}}",
       f"$return run function {FN}explore/admit_free {{cell:$(cell)}}")
    mc("explore/prepay",
       f"scoreboard players remove @s {SCORE} 1",
       f"$tag @s add {PAID}.$(cell)",
       f"function {FN}explore/sponsor")
    mc("explore/sponsor",
       f"scoreboard players operation #route_payment sd.floor = @s {SCORE}",
       "scoreboard players operation #route_payment sd.floor < #route_debt sd.floor",
       f"scoreboard players operation @s {SCORE} -= #route_payment sd.floor",
       "scoreboard players operation #route_debt sd.floor -= #route_payment sd.floor",
       say("已代付队友的探索次数。","aqua"))
    mc("explore/admit_free",
       f"$scoreboard players set {PARTY[:-1]},tag={ARRIVING}] sd.flow_last $(cell)",
       "return 1")
    mc("explore/reject_arrivals",
       f'$execute positioned $(minx) 78 $(minz) as {PARTY[:-1]},tag={ARRIVING},dx=$(width),dy=19,dz=$(width)] at @s run function {FN}room/reject')
    mc("room/reject", "scoreboard players set @s zx.rg_room -1", f"function {FN}room/return_to_explored",
       say("探索不足，队伍凑不齐这间房的费用。","yellow"))
    mc("junction/exit_to",
       f"$function {FN}room/read_go {{cell:$(cell)}}",
       f"execute store result score #mirror_exit_paid sd.floor run function {FN}explore/enter with storage {RUN} inspected",
       f"tag {PARTY} remove {ARRIVING}",
       "execute unless score #mirror_exit_paid sd.floor matches 1 run return run "+say("探索不足，可传回另一间镜房。","yellow"),
       "tag @s remove sd.floor_mirror",
       f"$function {FN}room/teleport_cell with storage zx:rogue floor.cells[$(cell)]")
    edit(f/"run/arrive.mcfunction",
         ("全队共用 8 次探索。首次到访扣一次，走过的房间可以重走。",
          "每人有 8 次探索。首次进房扣一次，队友可代付。"))
    for key in ("run/mirror_text","room/status","run/boss_shortcut","room/event/sign_repair"):
        p=f/f"{key}.mcfunction"
        body=text(p).replace('"name":"#budget","objective":"sd.floor"','"name":"@s","objective":"sd.explore"')
        write(p,body.replace("全队探索 ","我的探索 ").replace("#budget sd.floor",f"@s {SCORE}"))
