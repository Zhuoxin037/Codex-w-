# ============================================================
# sweetdream:equipment/staff/late_court/place —— 在**当前位置**生成迟庭的领域
# ------------------------------------------------------------
# 【谁调用它】late_court/ray 的 ①②(带着 zx:work ltf 进来)
# 【宏参数】zx:work ltf {dmg, dmg2, uu, u0, u1, u2, u3}
# 【领域是什么】一个 marker 实体(标签 zx.ltc_field), NBT 里存:
#   data.zx.dmg  = 每秒那一段 = **最大魔力值 ×0.04**(施放那刻算好)
#   data.zx.dmg2 = "缓慢结束"那一段 = **基础攻击力 ×4**(施放那刻算好)
#   data.zx.uu   = 施放者 UUID 文本(field_end 删框架术阵时的键)
#   data.zx.u    = 施放者 UUID 的四个整数(击杀归属 + lt_end 打伤害时用)
#   计时用计分项 zx.ltc_ft(= 6 秒), 由 lib/second 每秒 -1, 归零走 field_end。
# 【领域实例号不写进 NBT】= 本 marker 自己的 UUID[0]; field_tick 直接读 @s。
#   "每个生物整次领域最多触发一次该结束效果"就靠它比对(见 field_tick 文件头)。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.ltc_field","zx.ltc_new"],data:{zx:{dmg:$(dmg),dmg2:$(dmg2),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 6 秒计时(它带 zx.ltc_new, 场上最多一个, 就近取)
execute as @e[tag=zx.ltc_new,distance=..2,limit=1] run scoreboard players set @s zx.ltc_ft 6
tag @e[tag=zx.ltc_new,distance=..2] remove zx.ltc_new
