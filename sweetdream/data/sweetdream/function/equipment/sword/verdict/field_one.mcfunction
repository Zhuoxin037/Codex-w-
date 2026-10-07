# ============================================================
# sweetdream:equipment/sword/verdict/field_one —— 生成一个领域(宏 {dmg,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】field: execute at @e[tag=zx.vd_mark] run function ... with storage zx:work vdf
# 【执行位置】被伤害生物所在处
# 【领域是什么】一个 marker 实体, 带标签 zx.vd_field, NBT 里存:
#   data.zx.dmg = 每次的伤害值(施放那刻基于施放者基础攻击力算好)
#   data.zx.u   = 施放者 UUID 的四个整数(击杀归属)
#   计时用计分项 zx.vd_ft(=3 秒), 由 lib/second 每秒 -1, 归零 kill(见 field_tick)。
# 【为什么用 marker 而不是"贴在生物身上"】领域是**地面上的区域**, 生物离开它就不该再吃伤害;
#   也不是"施法者的持续状态" —— 施法者走远了领域还在原地。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.vd_field","zx.vd_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 3 秒计时(它带 zx.vd_new, 场上最多一个, 就近取)
execute as @e[tag=zx.vd_new,distance=..2,limit=1] run scoreboard players set @s zx.vd_ft 3
tag @e[tag=zx.vd_new,distance=..2] remove zx.vd_new
