# ============================================================
# sweetdream:equipment/armor/last_breath/hit —— 归息: 近战命中后消耗状态换回复
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/last_breath_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +140。普通近战命中了附有「渊海」或「噬心」且
#   仍存活的生物后，消耗其一种效果，并为自身恢复 6 点生命值及 20 点魔力值
#   （优先消耗「渊海」）。该效果 8 秒内不可再次触发，自身生命值为满时不触发。
# 【★ "且仍存活" 是天然满足的 ★】进度在**伤害打完之后**才抛；目标若被这一下打死，
#   它已从世界移除 ⇒ 身上那条标签也就没了 ⇒ 下面挑不出状态、直接收工。
# 【★ 消耗必须标 src:"equip" ★】这是**装备被动**顺手消耗的，不是"技能消耗" ——
#   不标的话，穿回潮扣/烛跬时一次平A会白蹭到那两件的"技能消耗"效果。
#
# 【★ 分级诊断锚(2026-10-15 加) ★】这条链上有 6 个**静默**断点，断在哪一级的表现
#   都是"什么都没发生、零日志"。所以每"通过一级"就把 #lb_d1..d8 里对应的那个 +1，
#   用 /function sweetdream:debug/lb_probe 读：**哪一级计数明显小于上一级，就断在那里**。
#   d1=进度触发 · d2=蓄力过 · d3=穿着过 · d4=定位到目标 · d5=非满血 · d6=冷却就绪 ·
#   d7=目标带渊海/噬心 · d8=真的兑现了。锚只加在"假玩家"上，不改任何行为。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/last_breath_hit
scoreboard players add #lb_d1 zx.meta 1

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
scoreboard players add #lb_d2 zx.meta 1

# ① 没穿归息就没这事（胸甲）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["last_breath"]}] run return 0
scoreboard players add #lb_d3 zx.meta 1

# ② 定位"刚才这一下平A打的是哪一只"（lib/victim：last_hurt_by_player + HurtTime 收窄）
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0
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
execute as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.yuanhai] run scoreboard players set #lb_mk zx.meta 1
execute if score #lb_mk zx.meta matches 0 as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.shixin] run scoreboard players set #lb_mk zx.meta 2
execute if score #lb_mk zx.meta matches 0 run return 0
scoreboard players add #lb_d7 zx.meta 1

# ⑥ 消耗它（统一入口；by = 自己）
data modify storage zx:work a set value {target:"@e[tag=zx.victim,limit=1]",mark:"yuanhai",by:"@s",src:"equip"}
execute if score #lb_mk zx.meta matches 1 run function sweetdream:lib/mark_consume
data modify storage zx:work a set value {target:"@e[tag=zx.victim,limit=1]",mark:"shixin",by:"@s",src:"equip"}
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
tag @e[tag=zx.victim] remove zx.victim
