# ============================================================
# sweetdream:equipment/axe/fissure/field —— 生成一个「裂缝」(宏 {dmg2,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】fissure/cast: execute rotated ~ 0 positioned ^ ^ ^2.5 run function ... with storage zx:work fia
# 【执行位置】落点(施法者前方 2.5 格)
# 【裂缝是什么】一个 marker 实体, 带标签 zx.fi_field, NBT 里存:
#   data.zx.d2 = 每秒那一段的伤害值(施放那刻基于施放者基础攻击力算好)
#   data.zx.u  = 施放者 UUID 的四个整数(击杀归属)
#   计时用计分项 zx.fi_ft(= 5 秒), 由 lib/second 每秒 -1, 归零 kill(见 field_tick)。
# 【为什么用 marker 而不是"贴在生物身上"】裂缝是**地面上的区域**, 生物离开它就不该再吃伤害;
#   也不是"施法者的持续状态" —— 施法者走远了裂缝还在原地(和神裁领域同一个道理)。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.fi_field","zx.fi_new"],data:{zx:{d2:$(dmg2),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 5 秒计时(它带 zx.fi_new, 场上最多一个, 就近取)
execute as @e[tag=zx.fi_new,distance=..2,limit=1] run scoreboard players set @s zx.fi_ft 5
tag @e[tag=zx.fi_new,distance=..2] remove zx.fi_new
