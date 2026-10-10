# ============================================================
# sweetdream:equipment/staff/chime/pass_check —— 共鸣水晶: "法术穿过"判定(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一行; 执行者 = 水晶 marker, 位置 = 水晶处)
# 【文案】自身释放的法术穿过“共鸣水晶”时会**立即**对其 3 格内的全部生物造成一次
#   相当于自身最大魔力值 ×0.05 的伤害。
# 【"自身释放的法术"= 释放者自己的法球】法球带着 u0..u3(= 发射者 UUID 四个 int),
#   水晶也带着同一份 —— 比对四个 int 就知道"这颗球是不是自己人的"。
# 【为什么必须每刻】"穿过时立即"是刻级事件, 每秒轮询会漏(法球每刻飞 0.75 格)。
# 【执行者/位置原样传给 pass_set】@s 仍是水晶(不换), 位置仍是水晶。
#   ★ 注意: pass_set 内部**找球**时会把基准抬高 1.6 格再判 distance ——
#     水晶召唤在脚底、法球却飞在眼睛高度, 差约 1.62 格, 三维 distance 直接判
#     会恒不成立(2026-10-09 修)。详见 pass_set 头注释的"位置口径"。
# ============================================================

# ① 把水晶身上的"释放者 UUID 四 int"抄进宏节点(pass_set 要拼选择器)
data modify storage zx:work chp set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work chp.u0 set from entity @s data.zx.ch.u0
data modify storage zx:work chp.u1 set from entity @s data.zx.ch.u1
data modify storage zx:work chp.u2 set from entity @s data.zx.ch.u2
data modify storage zx:work chp.u3 set from entity @s data.zx.ch.u3

# ② 交给宏: 反查释放者 + 抓"还没触发过的自己人的法球"
function sweetdream:equipment/staff/chime/pass_set with storage zx:work chp
