# ============================================================
# sweetdream:equipment/armor/bright_candle/convert —— 「流火」→「夜火」(烛火烤出来的)
# ------------------------------------------------------------
# 【执行者】烛火   【前置】zx.bc_cvt 打在"这一秒该转化"的生物上
# 【★ 为什么是"先摘后上" ★】替换, 不是叠加。流火 + 夜火双持 ⇒ 下次熄灭又会升级
#   一次 ⇒ 可消耗资源被凭空刷新(余烬 burned_out 踩过的刷魔力漏洞)。
# 【★ 为什么走 tag/unmark + tag/mark ★】五个状态的通用接口; 转化类**不走**
#   mark_consume(那是"消耗"语义, 会触发别人的 consume 钩子)。
# ============================================================

data modify storage zx:work ic set value {target:"@e[tag=zx.bc_cvt]",mark:"liuhuo"}
function sweetdream:tag/unmark with storage zx:work ic
data modify storage zx:work ic set value {target:"@e[tag=zx.bc_cvt]",mark:"yehuo"}
function sweetdream:tag/mark with storage zx:work ic

# 转化完就把这一只的"烤制计时"清零 —— 它已经没有流火了, 不该再计
scoreboard players set @e[tag=zx.bc_cvt,distance=0..] zx.bc_dw 0
execute at @e[tag=zx.bc_cvt,distance=0..] run particle minecraft:soul_fire_flame ~ ~0.9 ~ 0.2 0.3 0.2 0.01 8 normal
