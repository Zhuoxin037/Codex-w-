"""Keep routes open and populated; furnish rooms on the first admitted visit."""

from itertools import product
from pathlib import Path

import architecture
from floor_upgrade import edit, text, write
from forest_economy import FN

KINDS = ("entry","combat","elite","boss","safe","merchant","rental","blackmarket","forge","astrology","gamble","event")


def stage(world):
    home=Path(world)/"datapacks/zz_sweetdream_floor/data"
    r=home/"sweetdream/function/rogue"
    f=home/"sweetdream_floor/function"
    for kind in KINDS:
        for variant in range(9 if kind=="event" else 3):
            shell,detail=architecture.room_parts(kind,variant)
            write(r/f"shell/{kind}_{variant}.mcfunction","\n".join(shell))
            write(r/f"detail/{kind}_{variant}.mcfunction","\n".join(detail) if detail else "# Open floor")
    for axis,first,last in product(("east","south"),architecture.RADII,architecture.RADII):
        commands=architecture.corridor(axis,first,last)
        for a in range(first+1,architecture.PITCH-last,3):
            x,z=(a,0) if axis=="east" else (0,a)
            commands.extend((f"setblock ~{x or ''} ~6 ~{z or ''} minecraft:shroomlight",
                             f"setblock ~{x or ''} ~3 ~{z or ''} minecraft:light[level=15] keep"))
        write(r/f"corridors/{axis}_{first}_{last}.mcfunction","\n".join(commands))
    for axis in ("east","south"):
        a,b=((14,-2),(23,1)) if axis=="east" else ((-2,14),(1,23))
        write(r/f"canvas/{axis}.mcfunction",f"fill ~{a[0]} ~ ~{a[1]} ~{b[0]} ~ ~{b[1]} minecraft:light_gray_concrete")
    edit(r/"gen/clear.mcfunction",("minecraft:black_terracotta","minecraft:smooth_sandstone"))
    edit(r/"gen/build_cell.mcfunction", ("sweetdream:rogue/rooms/$(kind)_$(variant)","sweetdream:rogue/shell/$(kind)_$(variant)"),
         (f"$function {FN}room/vendor/check with storage zx:rogue floor.cells[$(cell)]", ""))
    plan=r/"gen/plan.mcfunction"
    if not plan.exists():
        write(plan,text(Path(world)/"datapacks/sweetdream/data/sweetdream/function/rogue/gen/plan.mcfunction"))
    edit(plan, ("function sweetdream:rogue/gen/grow",
         "data modify storage zx:rogue floor.delayed_scene set value 1b\nfunction sweetdream:rogue/gen/grow"))
    p=r/"map/visit_pick.mcfunction"
    anchor="$execute if score @s zx.rg_room matches $(cell) unless data storage zx:rogue floor.cells[{cell:$(cell),visited:1b}]"
    render=(f'$execute if score @s zx.rg_room matches $(cell) if data storage zx:rogue floor{{delayed_scene:1b}} '
            f'unless data storage zx:rogue floor.cells[{{cell:$(cell),furnished:1b}}] run function {FN}scene/furnish with storage zx:rogue floor.cells[$(cell)]')
    edit(p,(anchor,render+"\n"+anchor))
    write(f/"scene/furnish.mcfunction", "\n".join((
          '$data modify storage zx:rogue floor.cells[$(cell)].furnished set value 1b',
          '$execute positioned $(x) 80 $(z) run function sweetdream:rogue/detail/$(kind)_$(variant)',
          f'$function {FN}room/vendor/check with storage zx:rogue floor.cells[$(cell)]')))
