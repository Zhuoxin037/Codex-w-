# ============================================================
# sweetdream:equipment/armor/borrow_fire/strike —— 「借火」兑现(宏)
# ------------------------------------------------------------
# 【执行者】被平A打中的那只生物   【位置】它自己   【宏参数】zx:work bf {u0..u3}
# 【顺序逐字对文案】① 附加「流火」 → ② 燃烧立即结束 + 剩余燃烧时间×5 的真伤
#                   → ③ 有护甲值则削减 -30% / -50% 韧性并转移给自己(5 秒)
# ============================================================

# ① 附加「流火」
function sweetdream:tag/mark {target:"@s",mark:"liuhuo"}

# ② 还在烧 ⇒ 结算真伤 + 熄灭
scoreboard players set #bf_f zx.meta 0
execute store result score #bf_f zx.meta run data get entity @s Fire
#   ★ 必须 `with storage zx:work bf`: 宏参数**不会**传给下一层普通函数
#     (burn 里有 $(u0)..$(u3), 缺参数会让那条命令整段跳过、零日志)。
execute if score #bf_f zx.meta matches 1.. run function sweetdream:equipment/armor/borrow_fire/burn with storage zx:work bf

# ③ 护甲那一档(需要玩家实体 ⇒ 先反查)
data modify storage zx:work ub set value {}
data modify storage zx:work ub.u0 set from storage zx:work bf.u0
data modify storage zx:work ub.u1 set from storage zx:work bf.u1
data modify storage zx:work ub.u2 set from storage zx:work bf.u2
data modify storage zx:work ub.u3 set from storage zx:work bf.u3
function sweetdream:lib/u_by
execute if entity @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/borrow_fire/strip
