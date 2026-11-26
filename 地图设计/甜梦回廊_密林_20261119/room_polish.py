"""Build the live-room interaction and presentation patch."""
import json
from pathlib import Path
from tempfile import mkdtemp
import shutil

from architecture import PITCH
from floor_route_map import DIMS
from migrate_world_resources import WORLD, MASTER, ENABLED, ROOT
from portal_edges import generate as portals
from forest_new_interiors import interiors
from wardrobe_panel import wardrobe


F = "sweetdream_floor:"
RP = "fallenrooms:"
RUN = F + "run"
PLAYERS = "@a[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,scores={sd.floor_death=0}]"
PACK = "zzzzzzz_fallendream_polish"
WORK = ROOT / ".workbuddy/rogue_route_trial_20261125"
BASE = "zz_sweetdream_floor"
ROOMS = "zzzz_fallendream_rooms"
DRAW = "zzzzz_fallendream_draw"


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def stage(world, source):
    target = world / "datapacks" / PACK

    def asset(name, body):
        path = target / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body.rstrip() + "\n", encoding="utf8")

    def path(name):
        namespace, sub = name.split(":", 1)
        return f"data/{namespace}/function/{sub}.mcfunction"

    def mc(name, *rows):
        asset(path(name), "\n".join(rows))

    def read(name, packs=(DRAW, ROOMS, BASE)):
        return next((source / p / path(name)).read_text(encoding="utf8").splitlines()
                    for p in packs if (source / p / path(name)).is_file())

    def base(name):
        return read(name, (BASE,))

    description = "坠梦 · 林间陈设"
    asset("pack.mcmeta", compact({"pack":{"pack_format":71,"description":description}}))
    for event in ("load", "tick"):
        asset(f"data/minecraft/tags/function/{event}.json", compact({"values":[RP + event]}))
    mc(RP+"load", *(f"scoreboard objectives add fr.{o} dummy" for o in
         ("quote", "quote_room", "quote_run", "quote_time", "cabinet", "astro_time", "astro_room")))
    mc(RP+"tick",
       "scoreboard players remove @a[scores={fr.quote_time=1..}] fr.quote_time 1",
       f"execute as {PLAYERS} at @s run function {RP}cabinet/tick",
       f"execute as {PLAYERS.replace('sd.floor_death=0','sd.floor_death=0,fr.astro_time=1..')} at @s run function {RP}astral/finish",
       *(f"execute in {dim} as @e[type=interaction,tag=fr.astrolabe,distance=0..] at @s if data entity @s interaction.player run function {RP}astral/click"
         for dim in DIMS))

    def build_portals(name, *rows):
        if name == F+"scene/furnish":
            rows += (f'$execute if data storage zx:rogue floor.cells[{{cell:$(cell),kind:"astrology"}}] '
                     f'positioned $(x) 81 $(z) align xyz run function {RP}astral/build {{cell:$(cell)}}',)
        mc(name, *rows)

    portals(build_portals, base)
    locate = read("fallendream:rogue/map/locate")
    before_visit = next(i for i, row in enumerate(locate) if "rd_visit set value" in row)
    locate[before_visit:before_visit] = [
        f"execute if score @s zx.rg_room matches -1 if data storage zx:rogue "
        f"floor.cells[{{cell:{cell},present:1b,isolated:1b,radius:{r}}}] "
        f"positioned {PITCH*(cell%5)-r+1} 78 {PITCH*(cell//5)-r+1} "
        f"if entity @s[dx={2*r-2},dy=19,dz={2*r-2}] run scoreboard players set @s zx.rg_room {cell}"
        for cell in range(25) for r in (13,14,17)
    ]
    mc("fallendream:rogue/map/locate", *locate)
    unlock = [row for row in read(F+"junction/unlock") if "corridors/" not in row]
    mc(F+"junction/unlock", *unlock,
       *(f"$function {F}routes/portal/build with storage zx:rogue floor.cells[$({end})]" for end in ("a","b")))
    for kind, rows in interiors():
        for variant in range(3):
            mc(f"fallendream:rogue/detail/{kind}_{variant}", *rows)

    mc(F+"room/event/fire_take", *base(F+"room/event/fire_take"),
       'tellraw @s [{text:"余烬祝福",color:"gold",bold:true},{text:"  流火、夜火更容易成为抽取词条。选择其一时，有 30% 概率尝试获得更高稀有度。",color:"yellow"}]',
       'tellraw @s {text:"本局生命与魔力上限各降低 20%。",color:"gray"}')
    shop(mc, read)
    astral(mc, read)
    cabinet(mc, asset, read, base)
    from combat_draw_table import room_control, drawing
    room_control(lambda name, *rows: mc("drawlab:combat/"+name, *rows))
    drawing(lambda name, *rows: mc("drawlab:combat/"+name, *rows))
    return target


def button(text, code, color):
    return {"text":f"[{text}]","color":color,
            "click_event":{"action":"run_command","command":f"/trigger sd.floor_cmd set {code}"}}


def shop(mc, read):
    for name in ("market", "black"):
        mc(F+"shop/"+name, *(row.replace(" run function", " align xyz run function") for row in read(F+"shop/"+name)))
    route = read(F+"run/route")
    index = next(i for i, row in enumerate(route) if "matches 100..113" in row)
    route[index:index]=[f"execute if score #input sd.floor matches {codes} run return run function {RP}shop/resolve"
                        for codes in ("9070..9072","9099..9109")]
    mc(F+"run/route", *route)
    mc(RP+"shop/resolve",
       "execute if score #input sd.floor matches 9099 run return run scoreboard players set @s fr.quote_time 0",
       'execute unless score @s fr.quote_time matches 1.. run return run tellraw @s {text:"请重新右击商品。",color:"gray"}',
       "execute unless score @s fr.quote_room = @s zx.rg_room run return 0",
       "execute unless score @s fr.quote_run = @s sd.floor run return 0",
       "scoreboard players remove #input sd.floor 9000",
       "scoreboard players operation #quote_delta sd.floor = #input sd.floor",
       "scoreboard players operation #quote_delta sd.floor -= @s fr.quote",
       'execute if score #input sd.floor matches 70..72 unless score #quote_delta sd.floor matches 0 run return run tellraw @s {text:"商品已切换，请确认最新报价。",color:"gray"}',
       'execute if score #input sd.floor matches 100..109 unless score #quote_delta sd.floor matches 0..1 run return run tellraw @s {text:"商品已切换，请确认最新报价。",color:"gray"}',
       "function sweetdream_floor:room/read",
       "scoreboard players set @s fr.quote_time 0",
       f'execute if data storage {RUN} inspected{{kind:"merchant"}} run function {RP}shop/buy_market with storage {RUN} inspected',
       f'execute if data storage {RUN} inspected{{kind:"blackmarket"}} run function {RP}shop/buy_black with storage {RUN} inspected')
    for name, container, start, count, stride in (
        ("market","merchant",70,3,1), ("black","black",100,5,2)
    ):
        switched = []
        purchase = ['$execute positioned $(x) 81 $(z) unless entity @s[distance=..13] run return 0']
        for row in read(F+name+"/action"):
            if f"run function {F}{name}/buy " in row:
                purchase.append(row)
                row = row.replace(f"{F}{name}/buy", f"{RP}shop/quote_{name}")
            switched.append(row.replace("distance=..8", "distance=..13"))
        mc(F+name+"/action", *switched)
        mc(RP+"shop/buy_"+name, *purchase)
        name_part = '{text:"$(name)",color:"#fff0d1",bold:true,hover_event:{action:"show_item",id:"$(preview_id)",count:1,components:$(preview)}}'
        render = '$tellraw @s [{text:"◇  ",color:"#c79962"},'+name_part+']'
        lore = (f'execute if data storage {RUN} shop_quote.preview."minecraft:lore"[0] run tellraw @s '
                f'{{nbt:\'shop_quote.preview."minecraft:lore"[]\',storage:"{RUN}",interpret:true,separator:{{text:"\\n"}}}}')
        if name == "market":
            sold = 'merchant.bought[{code:$(code)}]'
            setup = '$scoreboard players set @s fr.quote $(code)'
            price = '$tellraw @s [{text:"$(price) 梦屑   ",color:"gold"},'+compact(button("确认购买","90$(code)","green"))+',{"text":"  "},'+compact(button("取消",9099,"gray"))+']'
        else:
            sold = 'black.sold[{slot:$(slot)}]'
            setup = '$scoreboard players set @s fr.quote $(hp_code)'
            price = '$tellraw @s '+compact([
                button("确认  生命 −$(hp)%","9$(hp_code)","red"),{"text":"   "},
                button("确认  魔力 −$(mana)%","9$(mana_code)","aqua"),{"text":"   "},button("取消",9099,"gray")])
        mc(RP+"shop/quote_"+name,
           f'$execute if data storage {RUN} {sold} run return run tellraw @s {{text:"这件商品已售罄。",color:"gray"}}',
           setup, "scoreboard players operation @s fr.quote_room = @s zx.rg_room",
           "scoreboard players operation @s fr.quote_run = @s sd.floor",
           "scoreboard players set @s fr.quote_time 1200",
           render,
           *(f"execute if score @s fr.quote matches {start+slot*stride} run data modify storage {RUN} shop_quote set from storage {RUN} {container}.stock[{slot}]" for slot in range(count)),
           lore, price)
    mc(F+"shop/buy", *[row for row in read(F+"shop/buy") if "is_sneaking" not in row])


def astral(mc, read):
    mc(F+"astrology/show",
       f"execute store result score #astro_floor sd.floor run data get storage {RUN} floor",
       'execute unless score @s sd.astro_floor = #astro_floor sd.floor run title @s actionbar {text:"右击星盘",color:"#d9bcff"}')
    mc(F+"room/select_go", *(row.replace("astrology/claim","astrology/show") for row in read(F+"room/select_go")))
    mc(RP+"astral/build",
       "execute positioned ~-4.5 ~ ~-7.5 if entity @e[type=interaction,tag=fr.astrolabe,distance=..0.2] run return 0",
       'summon minecraft:interaction ~-4.5 ~ ~-7.5 {Tags:["fr.astrolabe","fr.astrolabe_new","sd.floor_junction"],width:1.8f,height:2.55f,response:1b}',
       '$execute positioned ~-4.5 ~ ~-7.5 run scoreboard players set @e[tag=fr.astrolabe_new,distance=..0.2] fr.astro_room $(cell)',
       'execute positioned ~-4.5 ~ ~-7.5 run tag @e[tag=fr.astrolabe_new,distance=..0.2] remove fr.astrolabe_new')
    mc(RP+"astral/click",
       f"data modify storage {RUN} astral.player set from entity @s interaction.player",
       "data remove entity @s interaction",
       f"execute store result storage {RUN} astral.cell int 1 run scoreboard players get @s fr.astro_room",
       f"function {RP}astral/resolve with storage {RUN} astral")
    mc(RP+"astral/resolve",
       "execute unless score #phase sd.floor matches 1 run return 0",
       f"$execute as @a[tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,distance=..4.7,nbt={{UUID:$(player)}},scores={{sd.floor_death=0,zx.rg_room=$(cell)}}] run function {RP}astral/begin {{cell:$(cell)}}")
    mc(RP+"astral/begin",
       f"execute store result score #astro_floor sd.floor run data get storage {RUN} floor",
       'execute if score @s sd.astro_floor = #astro_floor sd.floor run return run title @s actionbar {text:"星盘已回应",color:"gray"}',
       "execute if score @s fr.astro_time matches 1.. run return 0",
       "$scoreboard players set @s fr.astro_room $(cell)",
       "scoreboard players set @s fr.astro_time 20",
       "particle minecraft:enchant ~ ~1.7 ~ .7 .4 .7 .5 28 force @a[distance=..22]",
       "playsound minecraft:block.amethyst_block.chime master @a[distance=..22] ~ ~ ~ .65 .8")
    mc(RP+"astral/finish",
       f"execute unless score @s fr.astro_room = @s zx.rg_room run return run scoreboard players set @s fr.astro_time 0",
       "scoreboard players remove @s fr.astro_time 1",
       "execute unless score @s fr.astro_time matches 0 run return 0",
       "execute unless score #phase sd.floor matches 1 run return 0",
       "function sweetdream_floor:room/read",
       f'execute unless data storage {RUN} inspected{{kind:"astrology"}} run return 0',
       "scoreboard players set #input sd.floor 20",
       "function sweetdream_floor:astrology/claim",
       "particle minecraft:end_rod ~ ~1 ~ .4 .4 .4 .04 12 force @s")


def cabinet(mc, asset, read, base):
    wardrobe(mc, asset, base)
    item = "minecraft:paper[minecraft:custom_data~{fr_cabinet:1b}]"
    components = {
        "minecraft:custom_data":{"fr_cabinet":True},
        "minecraft:item_model":RP+"cabinet",
        "minecraft:item_name":{"text":"装备寄存","color":"#ebcf9c","italic":False},
        "minecraft:max_stack_size":1,
        "minecraft:consumable":{"consume_seconds":3600,"animation":"none",
                                "sound":"minecraft:intentionally_empty","has_consume_particles":False},
    }
    values = ",".join(key+"="+compact(val) for key,val in components.items())
    asset("data/fallenrooms/advancement/cabinet.json", compact({
        "criteria":{"use":{"trigger":"minecraft:using_item","conditions":{
            "item":{"items":"minecraft:paper","predicates":{"minecraft:custom_data":"{fr_cabinet:1b}"}}}}},
        "rewards":{"function":RP+"cabinet/input"}}))
    mc(RP+"cabinet/input",
       "advancement revoke @s only fallenrooms:cabinet",
       "scoreboard players operation #cabinet fr.cabinet = @s fr.cabinet",
       "scoreboard players set @s fr.cabinet 0",
       "execute if score #cabinet fr.cabinet matches ..5 run return 0",
       f"execute unless items entity @s hotbar.7 {item} run return 0",
       "execute if entity @s[tag=sdc.open] at @s run return run function sweetdream_floor:wardrobe/close",
       "execute at @s run function sweetdream_floor:wardrobe/open")
    mc(RP+"cabinet/tick",
       "execute unless score @s fr.cabinet matches 8.. run scoreboard players add @s fr.cabinet 1",
       f"execute unless dimension {DIMS[0]} unless dimension {DIMS[1]} run return 0",
       f"execute if items entity @s hotbar.7 {item} run return 0",
       f"clear @s {item}",
       f"execute if items entity @s hotbar.7 * run function {RP}cabinet/free",
       f"execute unless items entity @s hotbar.7 * run item replace entity @s hotbar.7 with minecraft:paper[{values}]")
    slots = [f"inventory.{i}" for i in range(27)] + [f"hotbar.{i}" for i in range(7)]
    mc(RP+"cabinet/free", *(f"execute unless items entity @s {slot} * run return run function {RP}cabinet/move {{slot:\"{slot}\"}}" for slot in slots))
    mc(RP+"cabinet/move",
       "$execute store success score #cabinet_moved fr.cabinet run item replace entity @s $(slot) from entity @s hotbar.7",
       "execute if score #cabinet_moved fr.cabinet matches 1 run item replace entity @s hotbar.7 with minecraft:air")
    mc(F+"run/recycle_kit", f"clear @s {item}",
       "scoreboard players set @s fr.quote_time 0",
       "scoreboard players set @s fr.astro_time 0",
       *read(F+"run/recycle_kit"))
    mc(F+"gear/build", "return 0")
    mc(F+"run/arrive", *(row.replace("按 9 查看层主位置。","8 装备寄存 · 9 地图")
       for row in read(F+"run/arrive") if "gear/build" not in row and "状态菜单中可存取" not in row),
       f"function {RP}cabinet/tick")
    mc(F+"gear/menu", 'tellraw @s {text:"按 8 右击打开装备寄存。",color:"gray"}')
    mc(F+"gear/put", 'tellraw @s {text:"按 8 右击打开装备寄存。",color:"gray"}')


def install(pack, assets):
    destination = WORLD / "datapacks" / PACK
    if destination.exists() or (WORLD / "resources.zip").exists():
        raise RuntimeError("Expected a clean release destination")
    for original in assets:
        relative = original.relative_to(MASTER)
        target = ENABLED / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(original, target)
        assert original.read_bytes() == target.read_bytes(), relative
    temp = Path(mkdtemp(prefix=".room-polish-", dir=WORLD))
    ready = temp / PACK
    shutil.copytree(pack, ready)
    for file in pack.rglob("*"):
        if file.is_file():
            assert (ready / file.relative_to(pack)).read_bytes() == file.read_bytes(), file
    ready.rename(destination)
    temp.rmdir()
    print(f"Installed {len(list(destination.rglob('*.mcfunction')))} functions, {len(assets)} resource files.")


if __name__ == "__main__":
    import sys
    from room_polish_art import art

    candidate = Path(sys.argv[1])
    built = stage(candidate, WORLD / "datapacks")
    added = art(MASTER)
    if "--install" in sys.argv:
        install(built, added)
