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

# ⓪ 节流倒计时: 每刻 -1(@s = 水晶; 计分项不存在 = "可以触发")
#   ★★ 2026-10-20 从 pass_set 挪过来 ★★ 必须在下面的事件闸**之前**:
#     这个倒计时是按**真实时间**走的(0.5 秒 = 10 刻), 不能因为"这刻没事件"就停,
#     否则 cd 永远不归零 ⇒ 下次真有事件时被自己的旧 cd 挡住, 表现 = 水晶偶尔不触发。
execute if score @s zx.ch_cd matches 1.. run scoreboard players remove @s zx.ch_cd 1

# ⓪' ★ 2026-10-20 卡顿修复: 本刻根本不可能有事件 -> 直接收工 ★
#   事件只有两条来源(见 pass_set 的 ① 来源 a / 来源 b):
#     · 附近有自己人的法球(宽松粗筛 2.5 格, pass_set 内部再按 1.5 格 + NBT 精筛);
#     · 正被自己人的持续光束照着(zx.ch_beam = 1)。
#   两条都不成立时, pass_set 的 80 行(含 4 次从实体 NBT 抄 UUID + 1 次宏解析)
#   全是白烧 —— 而水晶一放就是 8 秒(160 刻), 平时就杵在那里。
#   ★ 闸放在"备 UUID"之前: 连那 4 行 data modify 都省掉。
#   ★ 语义不变: 闸只判"有没有可能", 精筛仍然全在 pass_set 里。
execute unless score @s zx.ch_beam matches 1 unless entity @e[tag=zx.ball,distance=..2.5,limit=1] run return 0

# ① 把水晶身上的"释放者 UUID 四 int"抄进宏节点(pass_set 要拼选择器)
data modify storage zx:work chp set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work chp.u0 set from entity @s data.zx.ch.u0
data modify storage zx:work chp.u1 set from entity @s data.zx.ch.u1
data modify storage zx:work chp.u2 set from entity @s data.zx.ch.u2
data modify storage zx:work chp.u3 set from entity @s data.zx.ch.u3

# ①' 超限分档: 穿过段的倍率 0.05 -> 0.1(pass_go 读它)
data modify storage zx:work chp.mm2 set value 0.05
execute if data entity @s data.zx.ch{ol:1} run data modify storage zx:work chp.mm2 set value 0.1

# ② 交给宏: 反查释放者 + 抓"还没触发过的自己人的法球"
function sweetdream:equipment/staff/chime/pass_set with storage zx:work chp
