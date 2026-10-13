# ============================================================
# sweetdream:equipment/axe/sacred_relic/second —— 圣骸主动的每秒结算
# ------------------------------------------------------------
# 【谁调用它】core/tick: zx.sr_next 到点时, 以玩家身份 at @s 调用。
# 【执行者/位置】施法者本人(所以"自身 12 格内"才是对的基准)
# 【每秒干什么】
#   ① 把施法者钉成标签 zx.sr_caster —— 给 strike 反查"释放者是谁"
#   ② 圈出自身 12 格内的全部「遗骸」
#   ③ 逐个结算(strike)  ④ 状态计时 -1
# 【★ 为什么要钉 zx.sr_caster ★】第 ③ 步 `as 遗骸` 会换掉执行者, 那时已经拿不到
#   "谁是释放者"了; 而归因(击杀算谁的)与面板(最大魔力)都必须用释放者。
# 【★ 一次施法 = 12 次结算 ★】zx.sr_on 从 12 起、每秒结算一次再 -1, 正好 12 跳。
# 【★ 释放者的面板/身份由 strike 自己现取(不在这里取)★】因为一圈遗骸是**逐个**结算的,
#   中途 with_from 可能会碰 zx:data self —— 每颗遗骸都在 strike 开头重取一次最稳。
# ============================================================

tag @a remove zx.sr_caster
tag @s add zx.sr_caster

tag @e[tag=zx.sr_near] remove zx.sr_near
tag @e[tag=zx.sr_relic,distance=..12] add zx.sr_near
execute as @e[tag=zx.sr_near,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/strike

tag @e[tag=zx.sr_near,distance=0..] remove zx.sr_near
tag @s remove zx.sr_caster
# 以实际结算刻重新排下一跳, 离线归来/漏帧不会在连续几刻内补打全部旧脉冲。
scoreboard players operation @s zx.sr_next = #now manacore.meta
scoreboard players add @s zx.sr_next 20
scoreboard players remove @s zx.sr_on 1

# 圣骸武器动效；原技能数值与计时不变。
function sweetdream:equipment/axe/sacred_relic/visual/pulse
