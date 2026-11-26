# ============================================================
# fallendream:equipment/armor/tread_ash/field_tick —— 超限·踏灰: 灰痕逐刻结算
# ------------------------------------------------------------
# 【谁调用它】core/tick（三维度各一行，`as @e[type=marker,tag=zx.ta_field] at @s`）
# 【执行者】@s = 那片灰痕的 marker（at @s 已经把执行位置放在灰痕中心）
# 【文案(lore 逐字)】…触发后在位移终点留下半径 1 格、持续 6 秒的灰痕。生物首次经过时
#   获得 3 秒缓慢Ⅲ；自身离开后再次走入时，额外恢复 8% 最大生命值，并获得 6 秒迅捷Ⅱ。
#   每片灰痕最多触发一次效果。
# 【★ "主人"怎么找 ★】marker 上存了施放者 UUID 四段（data.zx.u，reward 写的），
#   用 lib/u_by 打 zx.ub 标签反查回来 —— 零 NBT 序列化。
# 【★ 两条效果互斥 ★】`zx.ta_used` 一置 1 就"只等死"，所以"每片灰痕最多触发一次效果"
#   不是靠调用方自觉，而是靠这条闸。
# 【★ "自身离开后再次走入"怎么判 ★】每刻看主人是否在 1 格内: 只要有一刻不在就把
#   `zx.ta_out` 记成 1; 之后某一刻又在 1 格内且 out==1 => 兑现。
#   这样"站在灰痕上不动"不会反复触发, 而"走开再回来"只给一次。
# ============================================================

# ① 寿命（每刻 -1；到 0 就消失）
scoreboard players remove @s zx.ta_life 1
execute if score @s zx.ta_life matches ..0 run kill @s
execute if score @s zx.ta_life matches ..0 run return 0

# ② 已经用过 -> 只等死（留一点灰在飘）
execute if score @s zx.ta_used matches 1 run particle minecraft:ash ~ ~0.05 ~ 0.4 0.02 0.4 0.0 1 normal
execute if score @s zx.ta_used matches 1 run return 0

# ③ 反查主人
data modify storage zx:work ub set from entity @s data.zx.u
function fallendream:lib/u_by
scoreboard players set #ta_who zx.meta 0
execute if entity @a[tag=zx.ub,limit=1] run scoreboard players set #ta_who zx.meta 1

# ④ 主人在不在灰痕上
scoreboard players set #ta_in zx.meta 0
execute if score #ta_who zx.meta matches 1 if entity @a[tag=zx.ub,distance=..1,limit=1] run scoreboard players set #ta_in zx.meta 1
#   主人不在（走开了）-> 记下"离开过"
execute if score #ta_who zx.meta matches 1 if score #ta_in zx.meta matches 0 run scoreboard players set @s zx.ta_out 1

# ⑤ 生物首次经过 -> 3 秒缓慢Ⅲ（排除主人自己；`!#fallendream:no_damage` = 非玩家生物）
execute if entity @e[type=!#fallendream:no_damage,distance=..1,tag=!zx.ub] run effect give @e[type=!#fallendream:no_damage,distance=..1,tag=!zx.ub] minecraft:slowness 3 2 true
execute if entity @e[type=!#fallendream:no_damage,distance=..1,tag=!zx.ub] run particle minecraft:ash ~ ~0.2 ~ 0.6 0.2 0.6 0.01 10 normal
execute if entity @e[type=!#fallendream:no_damage,distance=..1,tag=!zx.ub] run scoreboard players set @s zx.ta_used 1

# ⑥ 自身离开后再次走入 -> 额外回 8% 最大生命 + 6 秒迅捷Ⅱ
execute if score @s zx.ta_out matches 1 if score #ta_in zx.meta matches 1 as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/tread_ash/field_own
execute if score @s zx.ta_out matches 1 if score #ta_in zx.meta matches 1 run scoreboard players set @s zx.ta_used 1
