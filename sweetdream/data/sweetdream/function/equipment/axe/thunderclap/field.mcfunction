# ============================================================
# sweetdream:equipment/axe/thunderclap/field —— 生成威霆「术阵」(宏 {x,dur,et,uu,u0..u3})
# ------------------------------------------------------------
# 【谁调用它】thunderclap/open: execute at @e[tag=zx.victim] run function ... with storage zx:work tcf
# 【执行位置】被击者所在处
# 【术阵是什么】一个 marker 实体, 带标签 zx.tc_field, NBT 里存:
#   data.zx.n  = X(天煌×0.005, 决定"每次落雷几道")
#   data.zx.uu = 施法者 uuid **文本**(算"自身最大魔力值 ×0.1"时当 manacore 的玩家键)
#   data.zx.u  = 施法者 UUID 四个整数(反查施法者 / 击杀归属)
#   计时用计分项 zx.tc_ft(= X×2 秒), 由 lib/second 每秒 -1, 归零由 field_end 收场。
#   ★ 另存绝对到期 tick zx.tc_end(R03 卸载补偿, 见 open ④-b / field_tick ②-b)。
#   ★ 2026-10-08 批 D: ⑤ 顺带生成「领域」实体(domain, 暗紫法阵 + 符文碎片) ——
#     位置与 marker 完全相同, 寿命也挂在 marker 的存在性上(见 domain 头注释)。
# 【为什么 marker 带 uuid 文本又要四整数】manacore 的伤害计算要 uuid 文本当键;
#   而"反查施法者实体"只能用四个整数拼选择器 —— 两种都得有。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.tc_field","zx.tc_new"],data:{zx:{n:$(x),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
$execute as @e[tag=zx.tc_new,distance=..2,limit=1] run scoreboard players set @s zx.tc_ft $(dur)
# 【R03】绝对到期 tick(gametime) —— 见 open 的 ④-b 与 field_tick 的卸载补偿。
#   旧 marker(本改动之前开的)没有这个分数 ⇒ field_tick 的补偿对它不成立, 行为照旧。
$execute as @e[tag=zx.tc_new,distance=..2,limit=1] run scoreboard players set @s zx.tc_end $(et)

# ⑤ 领域实体(2026-10-08 批 D): 暗紫法阵盘 + 6 片环绕符文碎片
#   位置就在上面 marker 那里(本函数执行位置 = 被击者处), 寿命跟着 marker 走。
#   ★ 2026-10-10 修 F17: 摘 zx.tc_new 的那一行**必须挪到 domain 之后** ——
#     domain 要靠这个标签认出"刚建的那座 marker", 把 marker 的 UUID 写进领域实体
#     (收尾时按它精确匹配, 免得误删隔壁术阵的领域)。
function sweetdream:equipment/axe/thunderclap/domain
tag @e[tag=zx.tc_new,distance=..2] remove zx.tc_new
