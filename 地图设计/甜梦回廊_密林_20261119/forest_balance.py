"""Tune dungeon mobs against the actual equipment in the stand-alone save."""

import re
from itertools import product
from pathlib import Path

from floor_upgrade import edit, text, write
from forest_economy import FN, RUN, literal
from forest_places import light
from forest_scene import KINDS
from architecture import Build, radius

# The common axe pool already contains fixed hits of 12 and 30. The first
# melee mob remains disposable, while controllers and elites live long enough
# to use their distinct attacks. These numbers belong to this dungeon only.
STATS = {
    "cover": (14, 2), "rooted": (34, 3), "resin": (22, 2),
    "root": (24, 0), "moss": (46, 0), "crown": (70, 4),
}
IMPACT = {"resin_burst": (450,25), "ring_hit": (500,25), "sweep_hit": (550,30)}


def stage(world):
    root = Path(world) / "datapacks/zz_sweetdream_floor/data"
    addon = root / "sweetdream_floor"
    f = addon / "function"
    r = root / "sweetdream/function/rogue"
    mobs = f / "combat/mobs"

    def add(path, *lines):
        write(path, text(path) + "\n".join(lines))

    def mc(path, *lines):
        write(f/f"{path}.mcfunction","\n".join(lines))

    # Compile all regular spawns with the same initializer. It can bind the
    # summoned entity without racing the other mobs spawned on the same tick.
    for kind, (hp, attack) in (*STATS.items(), ("child",STATS["cover"])):
        init = mobs / f"init_{kind}.mcfunction"
        spawn = mobs / f"spawn_{kind}.mcfunction"
        if not init.exists():
            entity = "zombie" if kind in ("cover","child") else "husk"
            nbt=text(spawn).strip().split(" ~ ~ ~ ",1)[1]
            write(init,"data merge entity @s "+nbt)
            write(spawn,f"execute summon minecraft:{entity} run function {FN}combat/mobs/init_{kind}")
        rows=text(init).splitlines()
        rows[0]=re.sub(r"Health:[0-9.]+f","Health:"+str(hp)+"f",rows[0])
        rows[0]=re.sub(r'(max_health",base:)[0-9.]+d',rf"\g<1>{hp}d",rows[0])
        rows[0]=re.sub(r'(attack_damage",base:)[0-9.]+d',rf"\g<1>{attack}d",rows[0])
        for tier, factor in ((2,1.35),(3,1.7),(4,2.05)):
            health=round(hp*factor)
            selector=f"execute if score #combat_party sd.floor matches {str(tier)+('..' if tier==4 else '')} run "
            rows.extend((selector+f"attribute @s minecraft:max_health base set {health}",
                         selector+f"data modify entity @s Health set value {health}f"))
        if kind=="moss":
            rows=[row for row in rows if "scoreboard players set @s sd.mob_hp " not in row]
            rows.append("execute store result score @s sd.mob_hp run data get entity @s Health 100")
        write(init,"\n".join(rows))
    p = f/"combat/begin.mcfunction"
    hook=f"function {FN}combat/arena with storage {RUN} current"
    party="@a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={sd.floor_death=0}]"
    edit(p,(hook,
        f"execute as {party} at @s run function {FN}combat/confine with storage {RUN} encounter\n"
        f"execute store result score #combat_party sd.floor if entity {party}\n"+hook))
    p = mobs/"init_crown.mcfunction"
    # The held sword already has no modifiers, so the mob attack base has
    # one owner regardless of the display weapon.
    assert '"minecraft:attribute_modifiers":[]' in text(p)
    write(addon/"damage_type/forest_impact.json",literal({
        "message_id":"mob","scaling":"never","exhaustion":0.1,"effects":"hurt"
    }))
    # Toll from the special blows has smooth diminishing armor returns. This
    # is a single damage call so hurt animation, resistance, Protection and
    # invulnerability time still work.
    write(root/"minecraft/tags/damage_type/bypasses_armor.json",literal({"replace":False,"values":["sweetdream_floor:forest_impact"]}))
    mc("combat/mobs/impact",
       "execute store result score #impact_armor sd.floor run attribute @s minecraft:armor get",
       "scoreboard players set #impact_mul sd.floor 3",
       "scoreboard players operation #impact_armor sd.floor *= #impact_mul sd.floor",
       "scoreboard players set #impact_mul sd.floor 100",
       "scoreboard players operation #impact_mul sd.floor -= #impact_armor sd.floor",
       "execute if score #impact_mul sd.floor matches ..41 run scoreboard players set #impact_mul sd.floor 42",
       "$scoreboard players set #impact_hp sd.floor $(power)",
       "scoreboard players operation #impact_hp sd.floor *= #impact_mul sd.floor",
       "execute store result score #impact_cap sd.floor run attribute @s minecraft:max_health get 100",
       "$scoreboard players set #impact_mul sd.floor $(cap)",
       "scoreboard players operation #impact_cap sd.floor *= #impact_mul sd.floor",
       "scoreboard players operation #impact_hp sd.floor < #impact_cap sd.floor",
       f"execute store result storage {RUN} impact.hp double 0.0001 run scoreboard players get #impact_hp sd.floor",
       f"function {FN}combat/mobs/deal_impact with storage {RUN} impact")
    mc("combat/mobs/deal_impact","$damage @s $(hp) sweetdream_floor:forest_impact")
    for attack in IMPACT:
        path=mobs/f"{attack}.mcfunction"
        write(path, impact_on_hit(text(path),attack))
    for kind in KINDS:
        for variant in range(9 if kind=="event" else 3):
            size=radius(kind)
            b=Build(relative=True)
            # Add a second, offset set of sources facing the perimeter and
            # fill pockets above furnishings once placed.
            for side, off in product((-1,1),range(-size+2,size-1,3)):
                for x,z in ((side*(size-2),off),(off,side*(size-2))):
                    light(b,x,3,z)
                    light(b,x,7,z)
            for x,z in product(range(-size+3,size-2,4),repeat=2):
                light(b,x,4,z)
            add(r/f"detail/{kind}_{variant}.mcfunction",*b.lines)
    p = f/"junction/annex_build.mcfunction"
    add(p,*(f"setblock ~{x} ~2 ~{z} minecraft:light[level=15] keep"
            for x,z in product((5,8,11),(5,8,11))))


def impact_on_hit(body, attack):
    """Replace the actual player hit, leaving the friendly-fire row intact."""
    power,cap=IMPACT[attack]
    previous="run damage @s 5 minecraft:mob_attack"
    rows=body.splitlines()
    matches=[i for i,row in enumerate(rows) if "@a[" in row and row.endswith(previous)]
    if len(matches)!=1:
        raise ValueError(f"{attack}: expected one direct player damage command")
    i=matches[0]
    rows[i]=rows[i].replace(previous,f"run function {FN}combat/mobs/impact {{power:{power},cap:{cap}}}")
    return "\n".join(rows)+"\n"
