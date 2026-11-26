"""First-floor room probabilities, event state, and event encounters."""

from pathlib import Path
import architecture
from floor_upgrade import DIM, edit, text, write
from forest_economy import FN, RUN, button, literal, say

EVENT = FN + "room/event/"
GEAR = ("sword", "axe", "bow", "staff", "armor")
VARIANTS = ("traveler", "well", "clock", "cross", "ambush", "cabin", "medicine", "sign", "casket")
NS = "sweetdream:rogue/"


def stage(world):
    world = Path(world)
    addon = world / "datapacks/zz_sweetdream_floor/data"
    core = world / "datapacks/sweetdream/data/sweetdream/function/rogue"
    f = addon / "sweetdream_floor/function"
    r = addon / "sweetdream/function/rogue"

    def mc(path, *lines):
        write(f / f"{path}.mcfunction", "\n".join(lines))

    def ev(path, *lines):
        mc("room/event/" + path, *lines)

    def story(path, name, description, *options):
        ev(path, say("\n◇  " + name, "green"), say(description),
           *("tellraw @s " + literal([{"text":"    "},button(label,code),{"text":"  "+hint,"color":"gray"}])
             for code,label,hint in options))

    generate(r, core, mc)
    for variant in range(3, len(VARIANTS)):
        write(r / f"rooms/event_{variant}.mcfunction", "\n".join(architecture.room("event", variant)))

    mc("room/info/event", *(f'execute if data storage {RUN} inspected{{variant:{i}}} run return run function {EVENT}{name}'
                            for i,name in enumerate(VARIANTS) if i), f"function {EVENT}traveler")
    mc("room/service/event", *(f'execute if data storage {RUN} inspected{{variant:{i}}} run return run function {EVENT}choose_{name}'
                               for i,name in enumerate(VARIANTS) if i >= 3),
       'execute unless score #input sd.floor matches 20..21 run return 0',
       f"function {FN}room/mark with storage {RUN} inspected",
       f'execute if data storage {RUN} current{{variant:1}} run return run function {EVENT}resolve_well',
       f'execute if data storage {RUN} current{{variant:2}} run return run function {EVENT}resolve_clock',
       f"function {EVENT}resolve_traveler")
    ev("accept", f"function {FN}room/mark with storage {RUN} inspected")
    story("well", "回声井", "井水一半映着你的伤口，一半映着熄灭的术纹。",
          (20,"饮下井水","恢复生命"),(21,"触碰术纹","本局每 3 秒恢复 1 魔力"))
    ev("resolve_well", "execute if score #input sd.floor matches 20 run effect give @s minecraft:instant_health 1 5 true",
       "execute if score #input sd.floor matches 21 run tag @s add sd.event_well",
       "playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.8 1.0")
    edit(f / "run/route.mcfunction", ("execute if score #input sd.floor matches 20..22",
         f'execute if score #input sd.floor matches 25..26 run return run function {EVENT}fire_route\n'
         "execute if score #input sd.floor matches 20..22"))
    ev("fire_route", f"execute unless dimension {DIM} run return 0", f"function {FN}room/read",
       f'execute unless data storage {RUN} inspected{{kind:"event",variant:3}} run return 0',
       f"function {FN}room/select_go with storage {RUN} inspected")
    edit(f / "load.mcfunction", ("gamerule doMobLoot false", "gamerule doMobLoot false\n"
         "scoreboard objectives add sd.event_time dummy\nscoreboard objectives add sd.event_cut dummy"))
    edit(f / "run/player_tick.mcfunction", (f"execute unless dimension {DIM} run return 0",
         f"execute unless dimension {DIM} run return 0\nfunction {EVENT}tick"))
    for state in ("start", "exit", "stale"):
        file = f / f"run/{state}.mcfunction"
        anchor = "tag @s add sd.floor_run" if state == "start" else "execute if entity @s[tag=zx.rg_active]"
        edit(file, (anchor, f"function {EVENT}reset\n" + anchor))
    ev("tick", "scoreboard players add @s sd.event_time 1",
       f"execute if score @s sd.event_time matches 20 run function {EVENT}mana_reconcile",
       f"execute if score @s sd.event_time matches 40 run function {EVENT}mana_reconcile",
       f"execute if score @s sd.event_time matches 60.. run function {EVENT}second")
    ev("second", "scoreboard players set @s sd.event_time 0",
       f"function {EVENT}mana_reconcile",
       f"execute if entity @s[tag=sd.event_well] run function {FN}run/mana {{value:1.0}}")
    ev("reset",
       f"execute if score @s sd.event_cut matches 1.. run function {EVENT}restore_mana",
       "scoreboard players set @s sd.event_time 0", "scoreboard players set @s sd.event_cut 0",
       'execute if entity @s[tag=sd.event_cross] run attribute @s minecraft:max_health modifier remove sweetdream_floor:cross',
       'execute if entity @s[tag=sd.event_fire] run attribute @s minecraft:max_health modifier remove sweetdream_floor:cross_fire',
       *(f"tag @s remove sd.event_{status}" for status in ("well","cross","fire")),
       f"data remove storage {RUN} ambush_pending", f"data remove storage {RUN} fire_quote")

    cross(ev, story, addon)
    ambush(ev, story, f)
    supply_events(ev, story, f)
    fire_bonus(ev, f)


def generate(r, base, mc):
    assign = text(base / "gen/assign.mcfunction")
    head, _ = assign.split('function sweetdream:rogue/gen/assign_one {kind:', 1)
    required = ("merchant","forge","astrology","elite","event","rental","combat","combat","combat")
    write(r / "gen/assign.mcfunction", head + f"function {FN}generation/reset_pool\n"
          + "\n".join(f'function {NS}gen/assign_one {{kind:"{kind}"}}' for kind in required)
          + f"\nfunction {FN}generation/optional\nfunction {NS}gen/assign_rest")
    mc("generation/reset_pool", f"data modify storage {RUN} unused_events set value {literal(list(range(len(VARIANTS))))}")
    mc("generation/optional", *(line for kind,threshold in (("gamble",2000),("blackmarket",3333),("safe",1000))
        for line in ("execute store result score #optional_roll sd.floor run random value 1..10000 sweetdream:rogue",
                     f'execute if score #optional_roll sd.floor matches ..{threshold} run function {NS}gen/assign_one {{kind:"{kind}"}}')))
    rest = text(base / "gen/assign_rest.mcfunction")
    write(r / "gen/assign_rest.mcfunction", "\n".join(line for line in rest.splitlines()
          if "floor.candidates append value" not in line or any(f'kind:"{k}"' in line for k in ("combat","elite","event"))))
    pick = text(base / "gen/assign_pick.mcfunction")
    before = f"function {NS}gen/assign_apply"
    write(r / "gen/assign_pick.mcfunction", pick.replace(before,
          f'execute if data storage zx:work rd_assign{{kind:"event"}} run function {FN}generation/event_pick\n' + before))
    mc("generation/event_pick", f"execute unless data storage {RUN} unused_events[0] run function {FN}generation/reset_pool",
       f"execute store result score #event_max sd.floor run data get storage {RUN} unused_events",
       "scoreboard players remove #event_max sd.floor 1",
       f"execute store result storage {RUN} event_roll.max int 1 run scoreboard players get #event_max sd.floor",
       f"function {FN}reward/random with storage {RUN} event_roll",
       f"function {FN}generation/event_set with storage {RUN} draw")
    mc("generation/event_set",
       f"$data modify storage zx:work rd_assign.variant set from storage {RUN} unused_events[$(index)]",
       f"$data remove storage {RUN} unused_events[$(index)]")


def cross(ev, story, addon):
    story("cross", "被藤蔓缠绕的十字架", "树根压住了石座。你刚碰到藤尖，整座十字架就轻轻响了一声。",
          (20,"拔下藤蔓","生命上限 −10%，此后受伤回 5 魔力"),
          (21,"置之不理","离开十字架"),(25,"点火","需流火或夜火装备 · 查看代价"))
    ev("choose_cross", f"execute if score #input sd.floor matches 25 run return run function {EVENT}fire_inspect",
       f"execute if score #input sd.floor matches 26 run return run function {EVENT}fire_confirm",
       "execute unless score #input sd.floor matches 20..21 run return 0", f"function {EVENT}accept",
       'execute if score #input sd.floor matches 21 run return run ' + say("你选择了袖手旁观。"),
       'attribute @s minecraft:max_health modifier add sweetdream_floor:cross -0.1 add_multiplied_total',
       "tag @s add sd.event_cross", f"function {EVENT}defoliate with storage {RUN} inspected",
       say("你拔下了藤蔓。身上留下了一道旧伤，十字架的祝福仍在。", "green"))
    ev("defoliate", '$execute positioned $(x) 80 $(z) run fill ~-8 ~2 ~-7 ~-4 ~6 ~-6 minecraft:air replace minecraft:vine')
    write(addon / "sweetdream_floor/advancement/events/cross_hurt.json", literal({
        "criteria":{"hurt":{"trigger":"minecraft:entity_hurt_player","conditions":{
            "player":[{"condition":"minecraft:entity_properties","entity":"this","predicate":{"nbt":'{Tags:["sd.event_cross"]}'}}],
            "damage":{"taken":{"min":0.001}}}}},"rewards":{"function":EVENT+"cross_hurt"}}))
    ev("cross_hurt", "advancement revoke @s only sweetdream_floor:events/cross_hurt",
       f"execute if dimension {DIM} if entity @s[tag=sd.floor_run,tag=sd.event_cross] run function {FN}run/mana {{value:5.0}}")

    slots = [(f"hotbar.{i}", i) for i in range(9)] + [(f"inventory.{i}", i+9) for i in range(27)] + [
        ("armor.head",103),("armor.chest",102),("armor.legs",101),("armor.feet",100),("weapon.offhand",-106)]
    ev("fire_scan", f"data modify storage {RUN} fire_candidates set value []",
       f"data modify storage {RUN} fire_inventory set from entity @s Inventory",
       *(f'function {EVENT}fire_slot {{slot:"{slot}",inv:{idx}}}' for slot,idx in slots))
    ev("fire_slot",
       '$execute unless items entity @s $(slot) *[minecraft:custom_data~{tags:["liuhuo"]}] '
       'unless items entity @s $(slot) *[minecraft:custom_data~{tags:["yehuo"]}] run return 0',
       *(f'$execute if items entity @s $(slot) *[minecraft:custom_data~{{zx:["{kind}"]}}] run return run '
         f'function {EVENT}fire_found {{slot:"$(slot)",inv:$(inv)}}' for kind in GEAR))
    ev("fire_found", f'$data modify storage {RUN} fire_candidates append value {{slot:"$(slot)"}}',
       f'$data modify storage {RUN} fire_candidates[-1].item set from storage {RUN} fire_inventory[{{Slot:$(inv)b}}]')
    ev("fire_inspect", f"data remove storage {RUN} fire_quote", f"function {EVENT}fire_scan",
       f"execute unless data storage {RUN} fire_candidates[0] run return run " + say("你身上没有带流火或夜火标签的可献祭装备。", "yellow"),
       f"data modify storage {RUN} fire_quote set from storage {RUN} fire_candidates",
       f"execute store result score #fire_count sd.floor run data get storage {RUN} fire_candidates",
       'tellraw @s [{"text":"会从 ","color":"gold"},{"score":{"name":"#fire_count","objective":"sd.floor"}},{"text":" 件流火／夜火装备中随机烧掉一件。生命与魔力上限各减 20%。"}]',
       f'execute if data storage {RUN} fire_quote[].item.components."minecraft:item_name" run tellraw @s '
       '[{text:"    候选  ",color:"gray"},{nbt:\'fire_quote[].item.components."minecraft:item_name"\','
       f'storage:"{RUN}",interpret:true,separator:{{text:" / "}}}}]',
       "tellraw @s " + literal(button("确认点火", 26, "red")))
    ev("fire_confirm", f"execute unless data storage {RUN} fire_quote[0] run return run function {EVENT}fire_inspect",
       f"function {EVENT}fire_scan", f"data modify storage {RUN} fire_compare set from storage {RUN} fire_quote",
       f"execute store success score #fire_changed sd.floor run data modify storage {RUN} fire_compare set from storage {RUN} fire_candidates",
       f"execute if score #fire_changed sd.floor matches 1 run return run function {EVENT}fire_inspect",
       f"execute store result score #event_max sd.floor run data get storage {RUN} fire_candidates",
       "scoreboard players remove #event_max sd.floor 1",
       f"execute store result storage {RUN} event_roll.max int 1 run scoreboard players get #event_max sd.floor",
       f"function {FN}reward/random with storage {RUN} event_roll",
       f"function {EVENT}fire_take with storage {RUN} draw")
    ev("fire_take", f'$function {EVENT}fire_remove with storage {RUN} fire_candidates[$(index)]',
       f"data remove storage {RUN} fire_quote", f"function {EVENT}accept",
       'attribute @s minecraft:max_health modifier add sweetdream_floor:cross_fire -0.2 add_multiplied_total',
       "tag @s add sd.event_fire", f"function {EVENT}mana_reconcile", f"function {EVENT}burn_cross with storage {RUN} inspected",
       say("藤蔓烧尽了。十字架也一起灰飞烟灭。", "red"))
    ev("fire_remove", "$item replace entity @s $(slot) with minecraft:air")
    ev("burn_cross", f"function {EVENT}defoliate with storage {RUN} inspected",
       '$execute positioned $(x) 80 $(z) run fill ~-8 ~2 ~-7 ~-4 ~6 ~-7 minecraft:air replace minecraft:stripped_dark_oak_log',
       '$execute positioned $(x) 80 $(z) run particle minecraft:campfire_cosy_smoke ~-6 ~3 ~-7 .6 1.0 .45 .01 18 force')

    ev("mana_reconcile", "execute unless entity @s[tag=sd.event_fire] run return 0",
       "function sweetdream:lib/uuid", "execute unless data storage zx:data self{ok:1b} run return 0",
       'data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}',
       'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
       'function manacore:api/stats/get',
       'execute store result score #old_max sd.floor run data get storage manacore:out r.value 100',
       'scoreboard players operation #new_cut sd.floor = #old_max sd.floor',
       'scoreboard players operation #new_cut sd.floor += @s sd.event_cut',
       'scoreboard players set #div sd.floor 5',
       'scoreboard players operation #new_cut sd.floor /= #div sd.floor',
       f"execute unless score #new_cut sd.floor = @s sd.event_cut run function {EVENT}apply_mana")
    ev("apply_mana", "scoreboard players operation #ev_delta sd.floor = @s sd.event_cut",
       "scoreboard players operation #ev_delta sd.floor -= #new_cut sd.floor",
       "scoreboard players operation @s sd.event_cut = #new_cut sd.floor", f"function {EVENT}write_mana")
    ev("restore_mana", "function sweetdream:lib/uuid", "execute unless data storage zx:data self{ok:1b} run return 0",
       "scoreboard players operation #ev_delta sd.floor = @s sd.event_cut", f"function {EVENT}write_mana")
    ev("write_mana", 'data modify storage manacore:in arg set value {uuid:"",value:0.0}',
       'data modify storage manacore:in arg.uuid set from storage zx:data self.uuid',
       'execute store result storage manacore:in arg.value double 0.01 run scoreboard players get #ev_delta sd.floor',
       'function manacore:api/mana/max/add', f"function {FN}run/mana {{value:0.0}}")


def ambush(ev, story, f):
    story("ambush", "草丛里的埋伏", "风往左吹，靠近路边的草却向右倒。一截箭杆贴在地上。",
          (20,"全力以赴","立刻进入精英战"),(21,"跑入草丛","现在离开，回来时遭遇更强的埋伏"))
    ev("choose_ambush", f"execute if score #input sd.floor matches 20 run return run function {EVENT}start_ambush",
       f"execute if score #input sd.floor matches 21 run function {EVENT}save_ambush with storage {RUN} inspected")
    ev("save_ambush", f'$data modify storage {RUN} ambush_pending set value {{cell:$(cell)}}',
       say("你从草丛里退开了。下一次进这间房时，伏兵会有准备。", "gold"))
    edit(f / "room/arrive.mcfunction", ("function sweetdream_floor:room/announce",
         f'execute if data storage {RUN} inspected{{kind:"event",variant:4}} if data storage {RUN} ambush_pending '
         f'run function {EVENT}check_ambush with storage {RUN} inspected\n'
         'execute unless score #phase sd.floor matches 1 run return 0\nfunction sweetdream_floor:room/announce'))
    ev("check_ambush", f'$execute if data storage {RUN} ambush_pending{{cell:$(cell)}} run function {EVENT}return_ambush')
    ev("start_ambush", f"execute if data storage {RUN} ambush_pending run return run " + say("这场埋伏要等你离开后再进房。"),
       f"function {EVENT}accept", f'data modify storage {RUN} current.kind set value "elite"', f"function {FN}combat/begin")
    ev("return_ambush", f"data remove storage {RUN} ambush_pending", f"function {EVENT}accept",
       f'data modify storage {RUN} current.kind set value "elite"',
       f"data modify storage {RUN} current.ambush_harder set value 1b", f"function {FN}combat/begin")
    edit(f / "combat/win.mcfunction", ("effect give @s minecraft:instant_health 1 0 true",
         f'execute if data storage {RUN} current{{ambush_harder:1b}} run scoreboard players add #lumen sd.floor 1\n'
         "effect give @s minecraft:instant_health 1 0 true"))


def supply_events(ev, story, f):
    story("cabin", "无人的小屋", "一个干净的像是有人刚打扫过一样的小屋，但屋内又好像是很久没人住过了。",
          (20,"搜寻屋内","获得 2–4 梦屑"),(21,"翻找屋外","获得一次装备抽取"))
    ev("choose_cabin", "execute unless score #input sd.floor matches 20..21 run return 0", f"function {EVENT}accept",
       f"execute if score #input sd.floor matches 20 run return run function {EVENT}cabin_lumen",
       f'data modify storage {RUN} draw_source set value "normal"', f"function {FN}reward/ask")
    ev("cabin_lumen", "execute store result score #cabin_lumen sd.floor run random value 2..4 sweetdream:rogue",
       "scoreboard players operation #lumen sd.floor += #cabin_lumen sd.floor", f"function {FN}room/status")
    story("medicine", "被雨淋湿的药箱", "木药箱的底已经泡软，最上面一包绷带还是干的。",
          (20,"拿走绷带","获得一份林地补给"),(21,"救下药瓶","花 1 梦屑，得两瓶护命药剂"))
    ev("choose_medicine", "execute unless score #input sd.floor matches 20..21 run return 0",
       f"execute if score #input sd.floor matches 21 unless score #lumen sd.floor matches 1.. run return run " + say("梦屑不足。", "yellow"),
       f"function {EVENT}accept",
       f"execute if score #input sd.floor matches 20 run return run function {EVENT}supply",
       "scoreboard players remove #lumen sd.floor 1", f"function {FN}room/service/ward_potion")
    ev("supply", 'give @s minecraft:potion[minecraft:item_name={text:"林地补给",color:"gold"},'
       'minecraft:potion_contents={custom_color:11841377,custom_effects:[{id:"minecraft:instant_health",amplifier:0,duration:1},'
       '{id:"minecraft:absorption",amplifier:0,duration:600}]}]')
    # Absorption I grants 4 points. A consumption advancement trims this supply's bonus to the intended 2.
    edit(f / "room/event/supply.mcfunction", ('minecraft:item_name=',
         'minecraft:custom_data={sd_forest_supply:1b},minecraft:item_name='))
    write(f.parent / "advancement/events/supply.json", literal({"criteria":{"use":{
        "trigger":"minecraft:consume_item","conditions":{"item":{"predicates":{
            "minecraft:custom_data":"{sd_forest_supply:1b}"}}}}},
        "rewards":{"function":EVENT+"supply_used"}}))
    ev("supply_used", "advancement revoke @s only sweetdream_floor:events/supply",
       "execute if entity @s[tag=sd.floor_run] run tag @s add sd.event_supply_used")
    edit(f / "room/event/tick.mcfunction", ("scoreboard players add @s sd.event_time 1",
         f"execute if entity @s[tag=sd.event_supply_used] run function {EVENT}supply_absorption\n"
         "scoreboard players add @s sd.event_time 1"))
    ev("supply_absorption", "tag @s remove sd.event_supply_used",
       # A capped attribute limits this item's effect; the 30-second vanilla effect expires it.
       'attribute @s minecraft:max_absorption modifier add sweetdream_floor:supply -2 add_value',
       "tag @s add sd.event_supply_cap", "scoreboard players set @s sd.event_supply_time 600")
    edit(f / "load.mcfunction", ("scoreboard objectives add sd.event_cut dummy",
         "scoreboard objectives add sd.event_cut dummy\nscoreboard objectives add sd.event_supply_time dummy"))
    edit(f / "room/event/tick.mcfunction", ("scoreboard players add @s sd.event_time 1",
         "execute if score @s sd.event_supply_time matches 1.. run scoreboard players remove @s sd.event_supply_time 1\n"
         f"execute if entity @s[tag=sd.event_supply_cap] if score @s sd.event_supply_time matches ..0 run function {EVENT}supply_clear\n"
         "scoreboard players add @s sd.event_time 1"))
    edit(f / "room/event/reset.mcfunction", ("scoreboard players set @s sd.event_time 0",
         f"execute if entity @s[tag=sd.event_supply_cap] run function {EVENT}supply_clear\n"
         "tag @s remove sd.event_supply_used\nscoreboard players set @s sd.event_time 0"))
    ev("supply_clear", "attribute @s minecraft:max_absorption modifier remove sweetdream_floor:supply",
       "tag @s remove sd.event_supply_cap", "scoreboard players set @s sd.event_supply_time 0")
    edit(f / "run/starter.mcfunction", ("give @s minecraft:arrow 32",
         f"give @s minecraft:arrow 32\nfunction {EVENT}supply\n"
         "execute if score @s zx.job matches 0 run function sweetdream:equipment/armor/mana_helm/give\n"
         "execute if score @s zx.job matches 0 run function sweetdream:equipment/armor/mana_plate/give\n"
         "execute if score @s zx.job matches 1 run function sweetdream:equipment/armor/still_sky/give"))

    story("sign", "折断的路标", "断开的木牌指向两边。朝密林深处的那块背面，有人划了几道笔直的线。",
          (20,"拼回路标","多走 1 间，揭示一间功能房"),(21,"顺着刮痕找","揭示未探索房间的类型"))
    ev("choose_sign", "execute unless score #input sd.floor matches 20..21 run return 0", f"function {EVENT}accept",
       f"execute if score #input sd.floor matches 20 run return run function {EVENT}sign_repair",
       f"function {EVENT}unseen", f"function {EVENT}reveal_all", f"function {EVENT}refresh_map")
    ev("unseen", f"data modify storage {RUN} reveal set value []",
       f"data modify storage {RUN} reveal append from storage zx:rogue floor.cells[{{present:1b,visited:0b}}]")
    ev("sign_repair", "scoreboard players add #budget sd.floor 1",
       f"execute if data storage {RUN} {{exploration_doors:1b}} run function {EVENT}reopen_routes",
       f"function {EVENT}unseen",
       *(f'data remove storage {RUN} reveal[{{kind:"{kind}"}}]' for kind in ("combat","elite","entry","boss","event")),
       f"execute if data storage {RUN} reveal[0] run function {EVENT}reveal_pick", f"function {EVENT}refresh_map",
       f"function {FN}room/status")
    ev("reopen_routes", "data modify storage sweetdream_floor:routing doors set value []",
       'data modify storage sweetdream_floor:routing doors append from storage zx:rogue floor.cells[{present:1b,visited:0b}]',
       "scoreboard players set #door_closed sd.floor 0",
       f"execute if data storage sweetdream_floor:routing doors[0] run function {FN}room/doors/close_next",
       f"data remove storage {RUN} exploration_doors")
    ev("reveal_pick", f"execute store result score #event_max sd.floor run data get storage {RUN} reveal",
       "scoreboard players remove #event_max sd.floor 1",
       f"execute store result storage {RUN} event_roll.max int 1 run scoreboard players get #event_max sd.floor",
       f"function {FN}reward/random with storage {RUN} event_roll",
       f"function {EVENT}reveal_chosen with storage {RUN} draw")
    ev("reveal_chosen", f'$function {EVENT}reveal_one with storage {RUN} reveal[$(index)]')
    ev("reveal_all", f"execute unless data storage {RUN} reveal[0] run return 0",
       f"function {EVENT}reveal_one with storage {RUN} reveal[0]", f"data remove storage {RUN} reveal[0]",
       f"function {EVENT}reveal_all")
    ev("reveal_one", '$data modify storage zx:rogue floor.cells[$(cell)].revealed set value 1b',
       '$function sweetdream:rogue/map/draw_icon with storage zx:rogue floor.cells[$(cell)]')
    ev("refresh_map", "function sweetdream:rogue/map/flags", "scoreboard players add #rd_rev zx.meta 1")

    story("casket", "碎甲铁匣", "匣锁被砸开过，里面的石头和一截磨秃的刃口贴在一起。",
          (20,"撬出石头","获得主手可用的随机 α 升级"),(21,"掏出铁夹层","得 2 梦屑和 16 支箭"))
    ev("choose_casket", f"execute if score #input sd.floor matches 21 run return run function {EVENT}casket_items",
       "execute unless score #input sd.floor matches 20 run return 0",
       f"function {EVENT}alpha_pool", f"execute unless data storage {RUN} event_alpha[0] run return run " + say("主手没有能用此处升级石的装备。"),
       f"function {EVENT}accept", f"function {EVENT}give_alpha")
    ev("casket_items", f"function {EVENT}accept", "scoreboard players add #lumen sd.floor 2",
       "give @s minecraft:arrow 16", f"function {FN}room/status")
    ev("alpha_pool", f"data modify storage {RUN} event_alpha set value []",
       *(f'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{{zx:["{kind}"]}}] run return run '
         f'data modify storage {RUN} event_alpha append from storage sweetdream_floor:pool upgrades[{{categories:["{kind}"]}}]' for kind in GEAR))
    ev("give_alpha", f"execute store result score #event_max sd.floor run data get storage {RUN} event_alpha",
       "scoreboard players remove #event_max sd.floor 1",
       f"execute store result storage {RUN} event_roll.max int 1 run scoreboard players get #event_max sd.floor",
       f"function {FN}reward/random with storage {RUN} event_roll",
       f"function {EVENT}alpha_item with storage {RUN} draw")
    ev("alpha_item", f'$function {EVENT}alpha_payout with storage {RUN} event_alpha[$(index)]')
    ev("alpha_payout", "$function $(signed) {refund:2}")


def fire_bonus(ev, f):
    file = f / "reward/check_tag.mcfunction"
    old = text(file).rstrip()
    write(file, old + "\n" +
          f'$execute if entity @s[tag=sd.event_fire] if data storage {RUN} pool[0] run function {EVENT}fire_tickets {{tag:"$(tag)",name:"$(name)"}}')
    ev("fire_tickets",
       f'$data modify storage {RUN} fire_tag set value {{tag:"$(tag)"}}',
       f'execute unless data storage {RUN} fire_tag{{tag:"liuhuo"}} unless data storage {RUN} fire_tag{{tag:"yehuo"}} run return 0',
       *(f'$data modify storage {RUN} options append value {{tag:"$(tag)",name:"$(name)",weight:{i}}}' for i in (1,2)))
    write(f / "reward/take_option.mcfunction",
          f'$data modify storage {RUN} offers append from storage {RUN} options[$(index)]\n'
          f'$function {EVENT}drop_tag with storage {RUN} options[$(index)]')
    ev("drop_tag", f'$data remove storage {RUN} options[{{tag:"$(tag)"}}]')
    edit(f / "reward/pick_go.mcfunction", (f"function {FN}reward/give with storage {RUN} draw",
         f'$execute if entity @s[tag=sd.event_fire] run function {EVENT}fire_bonus with storage {RUN} offers[$(index)]\n'
         f"function {FN}reward/give with storage {RUN} draw"))
    # Run after the ordinary picker has chosen a candidate, then optionally move to the next available tier.
    ev("fire_bonus", f'$data modify storage {RUN} fire_pick set value {{tag:"$(tag)"}}',
       f'execute unless data storage {RUN} fire_pick{{tag:"liuhuo"}} unless data storage {RUN} fire_pick{{tag:"yehuo"}} run return 0',
       "execute store result score #fire_roll sd.floor run random value 1..100 sweetdream:rogue",
       "execute unless score #fire_roll sd.floor matches ..30 run return 0",
       f"function {EVENT}base_tier with storage {RUN} draw",
       "scoreboard players set #fire_limit sd.floor 4",
       f'execute if data storage {RUN} {{draw_source:"capped"}} run scoreboard players operation #fire_limit sd.floor = #tier sd.floor',
       f"data modify storage {RUN} fire_saved_pool set from storage {RUN} pool",
       *(f'execute if score #fire_base sd.floor matches ..{i-1} if score #fire_limit sd.floor matches {i}.. run '
         f'function {EVENT}test_tier {{tier:{i}}}' for i in range(2,6)),
       f"execute unless data storage {RUN} fire_hit run data modify storage {RUN} pool set from storage {RUN} fire_saved_pool",
       f"data remove storage {RUN} fire_hit")
    ev("base_tier", f'$execute store result score #fire_base sd.floor run data get storage {RUN} pool[$(index)].tier')
    ev("test_tier", f"execute if data storage {RUN} fire_hit run return 0",
       f'$data modify storage {RUN} exact_tier set value $(tier)', f"function {FN}pool/filter with storage {RUN} fire_pick",
       f"execute unless data storage {RUN} pool[0] run return 0",
       f"data modify storage {RUN} fire_hit set value 1b",
       f"execute store result score #event_max sd.floor run data get storage {RUN} pool",
       "scoreboard players remove #event_max sd.floor 1",
       f"execute store result storage {RUN} draw.max int 1 run scoreboard players get #event_max sd.floor",
       f"function {FN}reward/random with storage {RUN} draw")
