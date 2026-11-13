$execute unless entity $(vx_uuid) run return 0
scoreboard players add #lb_d4 zx.meta 1

# ③ 自身生命值为满 -> 整段不触发
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #lb_mh zx.meta run data get storage manacore:out r.value 1000
execute store result score #lb_hp zx.meta run data get entity @s Health 1000
execute if score #lb_hp zx.meta >= #lb_mh zx.meta run return 0
scoreboard players add #lb_d5 zx.meta 1

# ④ 8 秒节流（账本存"下次可触发刻"，口径同 frostmirror/em_gate）
scoreboard players set #lb_due zx.meta 0
execute store result score #lb_due zx.meta run scoreboard players get @s zx.lb_cd
execute if score #lb_due zx.meta > #now manacore.meta run return 0
scoreboard players add #lb_d6 zx.meta 1

# ⑤ 挑要消耗的那一种（优先「渊海」，没有才轮到「噬心」）
scoreboard players set #lb_mk zx.meta 0
$execute as $(vx_uuid) if entity @s[tag=zx.status.yuanhai] run scoreboard players set #lb_mk zx.meta 1
$execute if score #lb_mk zx.meta matches 0 as $(vx_uuid) if entity @s[tag=zx.status.shixin] run scoreboard players set #lb_mk zx.meta 2
execute if score #lb_mk zx.meta matches 0 run return 0
scoreboard players add #lb_d7 zx.meta 1

# ⑥ 消耗它（统一入口；by = 自己）
$data modify storage zx:work a set value {target:"$(vx_uuid)",mark:"yuanhai",by:"@s",src:"equip"}
execute if score #lb_mk zx.meta matches 1 run function sweetdream:lib/mark_consume
$data modify storage zx:work a set value {target:"$(vx_uuid)",mark:"shixin",by:"@s",src:"equip"}
execute if score #lb_mk zx.meta matches 2 run function sweetdream:lib/mark_consume

# ⑦ 兑现：恢复 6 点生命值 + 20 点魔力值
#   （lib/heal 的入参是**整点数**；它本身走"压上限 → instant_health 顶满 → 撤上限"，
#     因为原版不允许写玩家 NBT —— 详见 lib/heal 文件头）
scoreboard players set #heal_pt zx.meta 6
function sweetdream:lib/heal
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
scoreboard players add #lb_d8 zx.meta 1

# ⑧ 表现
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.4 0.3 0.0 4 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6

# ⑨ 记下"下次可触发刻"（现在 + 160 刻 = 8 秒）
scoreboard players operation @s zx.lb_cd = #now manacore.meta
scoreboard players operation @s zx.lb_cd += #160 zx.meta

# ⑩ 收尾
$tag $(vx_uuid) remove zx.victim
