# ============================================================
# sweetdream:equipment/sword/thunder_wedge/wedge_end —— "雷楔"收摊(执行者 = 雷楔 marker)
# ------------------------------------------------------------
# 【三处调用它】
#   ① lib/second -> thunder_wedge/wedge_tick 的 8 秒计时归零
#   ② cast ⑧ 的"同一使用者只能存在一个": 把施法者自己那只旧的收掉
#      (那时 @s 是旧雷楔, 靠 `as @e[...]` 换进来的)
# 【做什么】删掉框架里登记的那个真术阵(键 = marker 上的 data.zx.uu) -> 表现 -> kill 自己
# 【为什么要杀自己】"持续 8 秒"的雷楔必须真的消失 —— 它同时是"8 格内"判定的圆心,
#   留着会让使用者 8 秒后仍能触发闪电。
# 【不撤任何东西】它没有给生物挂状态, 所以没有需要还原的东西(与深池那类不同)。
# ============================================================

# ① 删掉框架里的真术阵(caster 的 cast ⑨ 建的)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:thunder_wedge"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

# ② 表现: 楔子散成电火花
execute at @s run particle minecraft:electric_spark ~ ~0.6 ~ 0.5 0.8 0.5 0.12 30 normal
execute at @s run playsound minecraft:block.respawn_anchor.deplete player @a ~ ~ ~ 0.6 1.2

# ②.5 超限 + **自然到期**: 对范围内全部生物各落一道雷
#   【设计原文】"雷楔在结束后对范围内的全部生物都会释放一次闪电。"
#   ★ 两个门缺一不可 ★
#     · zx.twg_ol  = 超限版才有这一段;
#     · zx.twg_end = "这一只是**到点**结束的"(wedge_tick 打的临时标签)。
#       cast ⑧ 的"同一使用者只能存在一个"也会走本函数, 那种替换不算"结束后",
#       不炸雷 —— 否则连放两次技能等于白送一刀范围雷。
#   ★ 排在 kill **之前** ★ ol_end 还要读 marker 的 NBT(dmg/u0..u3)与位置。
execute if entity @s[tag=zx.twg_ol] if entity @s[tag=zx.twg_end] at @s run function sweetdream:equipment/sword/thunder_wedge/ol_end

# ③ 收掉自己
kill @s
