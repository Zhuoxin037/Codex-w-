# ============================================================
# sweetdream:upgrade/api/bonus_held —— 汇总**主手**这件装备上所有升级的加成
# ------------------------------------------------------------
# 【出参】zx:out r = {count:0~4, dmg, mana, cd, mm, mr, mh, mhp, ar, at, hp, cdex, aspd, ms_pct, ms_every}
#   dmg/mana/cd = 乘区加算后的小数(0.10 = +10%; cd 负数 = 减冷却)
#   aspd = 攻击速度固定值加算(0.10 = +0.1; 神经衰弱石, 由 upgrade/held_apply 挂到玩家属性)
#   mm=魔力上限 / mr=每秒回魔 / mh=每次攻击回魔 / mhp=每次攻击回魔百分比(1.5 = 1.5%)
#   ★ 2026-10-07 扩: ar/at/hp=护甲值/护甲韧性/最大生命值(整数);
#     cdex=1 表示"冷却 >30 秒的技能每秒额外 -1 秒"; ms_pct/ms_every=魔力沸涌阈值与间隔秒
# 【怎么算】up 列表逐条查定义表(新槽位制最多 2 条 = 2 个系列; 旧规则敲出的老物品
#   可能还有 4 条, 逐条遍历照旧兼容):
#   老三样累加, 分级链条按"同系取最高 tier"(见 bonus_take)。
# 【武器怎么用】技能伤害: `lib/skill_mul` 那条 damage_calc 链路上的
#   upgrade/api/dmg_held 读 r.dmg 折进加算池; 冷却/魔力沸涌: upgrade/api/cd_tick 读
#   r.cd / r.cdex / r.ms_*; 攻击回魔读 r.mh / r.mhp(见 upgrade/api/on_hit)。
# ============================================================

data modify storage zx:out r set value {count:0,dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,aspd:0.0,ms_pct:0,ms_every:0}
scoreboard players set #up_dmg zx.meta 0
scoreboard players set #up_mana zx.meta 0
scoreboard players set #up_cd zx.meta 0
scoreboard players set #up_mm zx.meta 0
scoreboard players set #up_mr zx.meta 0
scoreboard players set #up_mh zx.meta 0
scoreboard players set #up_mhp zx.meta 0
# ★ 2026-10-07 扩: 硬化(ar/at/hp) + 冷却剂·Ω(cdex) + 魔力沸涌(ms.pct/ms.every)
scoreboard players set #up_ar zx.meta 0
scoreboard players set #up_at zx.meta 0
scoreboard players set #up_hp zx.meta 0
scoreboard players set #up_cdex zx.meta 0
scoreboard players set #up_msp zx.meta 0
scoreboard players set #up_mse zx.meta 0
# ★ 2026-10-08 扩: 效果开关(火炬 tc / 沸腾 boil / 夜视 nv / 再生 rg)
#   四个都要归零 —— bonus_take 会读它们, 调用方不归零就会留着上一次的值。
#   (武器只输出 tc/boil, nv/rg 归零但不输出; 盔甲那边反过来, 见 bonus_armor)
scoreboard players set #up_tc zx.meta 0
scoreboard players set #up_boil zx.meta 0
scoreboard players set #up_nv zx.meta 0
scoreboard players set #up_rg zx.meta 0
# ★ 2026-10-12 扩: 神经衰弱(攻速 aspd) —— bonus_take 会读/减/加它, 不归零会残留上一次的值。
scoreboard players set #up_aspd zx.meta 0
# 分级链条的桶每次重来(不然上一次的结果会残留)
data remove storage zx:work up_val

scoreboard players set #up_have zx.meta 0
execute store result score #up_have zx.meta run data get entity @s SelectedItem.components."minecraft:custom_data".up
execute store result storage zx:out r.count int 1 run scoreboard players get #up_have zx.meta

execute if score #up_have zx.meta matches 1.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[0]
execute if score #up_have zx.meta matches 1.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 2.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[1]
execute if score #up_have zx.meta matches 2.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 3.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[2]
execute if score #up_have zx.meta matches 3.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 4.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[3]
execute if score #up_have zx.meta matches 4.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up

execute store result storage zx:out r.dmg double 0.01 run scoreboard players get #up_dmg zx.meta
execute store result storage zx:out r.mana double 0.01 run scoreboard players get #up_mana zx.meta
execute store result storage zx:out r.cd double 0.01 run scoreboard players get #up_cd zx.meta
execute store result storage zx:out r.mm int 1 run scoreboard players get #up_mm zx.meta
execute store result storage zx:out r.mr int 1 run scoreboard players get #up_mr zx.meta
execute store result storage zx:out r.mh int 1 run scoreboard players get #up_mh zx.meta
execute store result storage zx:out r.mhp double 0.01 run scoreboard players get #up_mhp zx.meta
# ★ 硬化 / 冷却剂·Ω / 魔力沸涌
execute store result storage zx:out r.ar int 1 run scoreboard players get #up_ar zx.meta
execute store result storage zx:out r.at int 1 run scoreboard players get #up_at zx.meta
execute store result storage zx:out r.hp int 1 run scoreboard players get #up_hp zx.meta
execute store result storage zx:out r.cdex int 1 run scoreboard players get #up_cdex zx.meta
execute store result storage zx:out r.ms_pct int 1 run scoreboard players get #up_msp zx.meta
execute store result storage zx:out r.ms_every int 1 run scoreboard players get #up_mse zx.meta
# ★ 效果开关(火炬 / 沸腾)
execute store result storage zx:out r.tc int 1 run scoreboard players get #up_tc zx.meta
execute store result storage zx:out r.boil int 1 run scoreboard players get #up_boil zx.meta
# ★ 神经衰弱(攻速): 与 dmg 同一套 ×0.01 换回小数(0.1 -> 10 -> 0.1)
execute store result storage zx:out r.aspd double 0.01 run scoreboard players get #up_aspd zx.meta
