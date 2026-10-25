# ============================================================
# sweetdream:equipment/axe/deep_brine/field_one —— 生成一个「领域」(宏 {dmg,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】dom_one ④: execute at @e[tag=zx.db_cur] run function ... with storage zx:work dbf
# 【执行位置】被消耗掉「渊海」的那只生物所在处
# 【领域是什么】一个 **marker** 实体, 带标签 zx.db_field, NBT 里存:
#   data.zx.dmg = 每秒那一段的伤害(施放那刻基于施法者最大魔力值算好)
#   data.zx.u   = 施法者 UUID 的四个整数(击杀归属)
# 计时用计分项 zx.db_ft; **半径**用计分项 zx.db_r(field_tick 读它去拼选择器)。
# 【为什么用 marker 而不是贴生物】领域是**地面上的区域**: 生物离开它就不该再吃伤害
#   也不该被拉; 施法者走远了领域仍在原地(与神裁领域 / 崩裂裂缝 / 海棠漩涡同构)。
# 【★ 超限分档(2026-10-23 批 K6) ★】半径 3→5、持续 4→6 秒;
#   超限领域额外打标记 zx.db_olm —— 它同时表示"结束时要有那一下超大力拉动"。
# 【★ 半径为什么放计分项而不是写死 ★】合并之后的领域会是 8/11/14 格,
#   选择器里的 distance 只能写字面量 ⇒ field_tick 把 zx.db_r 读进 storage 再走宏。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.db_field","zx.db_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 分档: 普通 半径 3 / 4 秒; 超限 半径 5 / 6 秒 + zx.db_olm 标记
#   ★ 判的是**施法者**身上的 zx.db_ol, 所以先拍成假玩家再拿去筛 marker(as 之后就换人了)。
scoreboard players set #db_o zx.meta 0
execute if score @s zx.db_ol matches 1 run scoreboard players set #db_o zx.meta 1
execute as @e[tag=zx.db_new,distance=..2,limit=1] run scoreboard players set @s zx.db_r 3
execute as @e[tag=zx.db_new,distance=..2,limit=1] run scoreboard players set @s zx.db_ft 4
execute if score #db_o zx.meta matches 1 as @e[tag=zx.db_new,distance=..2,limit=1] run scoreboard players set @s zx.db_r 5
execute if score #db_o zx.meta matches 1 as @e[tag=zx.db_new,distance=..2,limit=1] run scoreboard players set @s zx.db_ft 6
execute if score #db_o zx.meta matches 1 run tag @e[tag=zx.db_new,distance=..2] add zx.db_olm
tag @e[tag=zx.db_new,distance=..2] remove zx.db_new

# 超限: 立刻检查"和已有领域重不重叠", 重叠就合并(见 ol_merge)
execute if score #db_o zx.meta matches 1 run function sweetdream:equipment/axe/deep_brine/ol_merge
