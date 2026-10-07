# ============================================================
# sweetdream:equipment/axe/thunderclap/field —— 生成威霆「术阵」(宏 {x,dur,uu,u0..u3})
# ------------------------------------------------------------
# 【谁调用它】thunderclap/open: execute at @e[tag=zx.victim] run function ... with storage zx:work tcf
# 【执行位置】被击者所在处
# 【术阵是什么】一个 marker 实体, 带标签 zx.tc_field, NBT 里存:
#   data.zx.n  = X(天煌×0.005, 决定"每次落雷几道")
#   data.zx.uu = 施法者 uuid **文本**(算"自身最大魔力值 ×0.1"时当 manacore 的玩家键)
#   data.zx.u  = 施法者 UUID 四个整数(反查施法者 / 击杀归属)
#   计时用计分项 zx.tc_ft(= X×2 秒), 由 lib/second 每秒 -1, 归零由 field_end 收场。
# 【为什么 marker 带 uuid 文本又要四整数】manacore 的伤害计算要 uuid 文本当键;
#   而"反查施法者实体"只能用四个整数拼选择器 —— 两种都得有。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.tc_field","zx.tc_new"],data:{zx:{n:$(x),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
$execute as @e[tag=zx.tc_new,distance=..2,limit=1] run scoreboard players set @s zx.tc_ft $(dur)
tag @e[tag=zx.tc_new,distance=..2] remove zx.tc_new
