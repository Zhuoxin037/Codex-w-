# ============================================================
# sweetdream:equipment/armor/condensed_shell/field_one —— 生成一个「凝壳」领域
# ------------------------------------------------------------
# 【宏参数】zx:work csf {dmg, uu, u0, u1, u2, u3}   【执行位置】玩家所在处
# 【领域是什么】一个 marker 实体(标签 zx.cs_field), NBT 里存:
#   data.zx.dmg = 每秒那一段的伤害值(施放那刻算好 = **基础攻击力 ×4**)
#   data.zx.u   = 施放者 UUID 的四个整数(击杀归属)
#   data.zx.uu  = 施放者 UUID 文本(field_end 删框架术阵时的键)
#   计时用计分项 zx.cs_ft(= 4 秒), 由 lib/second 每秒 -1, 归零走 field_end。
# 【为什么用 marker 而不是"贴在生物身上"】领域是**地面上的区域**: 生物离开就不该再吃伤害,
#   施法者走远了领域也还在原地(和神裁领域 / 崩裂裂缝 / 重溟深池同一套做法)。
# 【领域实例号不写进 NBT】= 本 marker 自己的 UUID[0] —— field_tick 直接读 @s 就有。
#   冻过谁用**生物自己**的 zx.cs_fid 记"我上次是被哪个领域冻的" ⇒ 同一个领域不重复冻。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.cs_field","zx.cs_new"],data:{zx:{dmg:$(dmg),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 4 秒计时(它带 zx.cs_new, 场上最多一个, 就近取)
execute as @e[tag=zx.cs_new,distance=..2,limit=1] run scoreboard players set @s zx.cs_ft 4
tag @e[tag=zx.cs_new,distance=..2] remove zx.cs_new
